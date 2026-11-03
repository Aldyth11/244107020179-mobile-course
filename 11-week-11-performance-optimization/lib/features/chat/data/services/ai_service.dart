import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/utils/ai_fallback.dart';
import '../../../../core/utils/pii_sanitizer.dart';
import '../models/chat_models.dart';

/// Optimized AI Service with bounded LRU memory cache,
/// request deduplication, and safe memory footprint.
class AiService {
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final PiiSanitizer _sanitizer;
  final AiFallback _fallback;

  // Optimasi Memori: Bounded LRU Cache (maksimal 50 entri)
  // Menghindari memory leak dan pertumbuhan heap tak terbatas
  static const int _maxCacheEntries = 50;
  final Map<String, String> _cache = {};
  String? _discoveredModel;

  AiService({
    FlutterSecureStorage? storage,
    http.Client? client,
    PiiSanitizer? sanitizer,
    AiFallback? fallback,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client(),
        _sanitizer = sanitizer ?? const PiiSanitizer(),
        _fallback = fallback ?? const AiFallback();

  SanitizationResult sanitizePrompt(String text) => _sanitizer.sanitize(text);

  void _saveToCache(String key, String value) {
    if (_cache.length >= _maxCacheEntries) {
      // LRU Eviction: Hapus entri tertua
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  Future<String> ask(String question, {bool useSanitization = true, bool forceOffline = false}) async {
    final q = question.trim();
    if (q.isEmpty) throw Exception('Pertanyaan tidak boleh kosong.');
    final cacheKey = q.toLowerCase();

    // 1. Cache-First Check: Menghindari network overhead dan komputasi ulang
    if (_cache.containsKey(cacheKey)) {
      return '[Cached] ${_cache[cacheKey]!}';
    }

    if (forceOffline) {
      final answer = _fallback.getResponse(q);
      _saveToCache(cacheKey, answer);
      return answer;
    }

    final rawKey = await getActiveApiKey();
    if (rawKey == null || rawKey.isEmpty) {
      return '${_fallback.getResponse(q)}\n\n(Catatan: Mode Offline aktif karena API Key belum dikonfigurasi).';
    }

    final key = rawKey.trim();
    final prompt = useSanitization ? _sanitizer.sanitize(q).sanitizedText : q;
    final primary = _discoveredModel ?? EnvConfig.defaultModel;
    final models = [primary, ...EnvConfig.candidateModels.where((m) => m != primary)];
    String lastErr = '';

    for (final m in models) {
      try {
        final res = await _client.post(
          Uri.parse('${EnvConfig.geminiBaseUrl}/$m:generateContent?key=$key'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'system_instruction': {
              'parts': [{'text': EnvConfig.defaultSystemPrompt}]
            },
            'contents': [
              {
                'parts': [{'text': prompt}]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 500,
            }
          }),
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final ans = jsonDecode(res.body)['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (ans is String) {
            _discoveredModel = m;
            _saveToCache(cacheKey, ans);
            return ans;
          }
        } else if (res.statusCode == 404) {
          lastErr = _extractError(res.statusCode, res.body);
          continue;
        } else if (res.statusCode == 429) {
          return '[Fallback Rate Limit] ${_fallback.getResponse(q)}';
        }
        throw Exception(_extractError(res.statusCode, res.body));
      } catch (e) {
        lastErr = e.toString();
        if (m == models.last) rethrow;
      }
    }
    return '[Offline Fallback] ${_fallback.getResponse(q)}\n(Detail error: $lastErr)';
  }

  Future<String> understandImage({
    required String prompt,
    required String base64Image,
    String mimeType = 'image/jpeg',
  }) async {
    // Optimasi Memori Citra: Validasi dan batasi ukuran payload base64 di memori
    // Mencegah heap bloat saat memproses citra resolusi tinggi
    if (base64Image.length > 5 * 1024 * 1024) {
      return 'Ukuran gambar terlalu besar. Mohon gunakan gambar dengan kompresi yang lebih kecil (<5MB).';
    }

    final rawKey = await getActiveApiKey();
    if (rawKey == null || rawKey.isEmpty) return _fallback.simulatedOcrResult;

    final key = rawKey.trim();
    final primary = _discoveredModel ?? EnvConfig.defaultModel;
    final models = [primary, ...EnvConfig.candidateModels.where((m) => m != primary)];

    for (final m in models) {
      try {
        final res = await _client.post(
          Uri.parse('${EnvConfig.geminiBaseUrl}/$m:generateContent?key=$key'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                  {
                    'inline_data': {
                      'mime_type': mimeType,
                      'data': base64Image,
                    }
                  }
                ]
              }
            ]
          }),
        ).timeout(const Duration(seconds: 12));

        if (res.statusCode == 200) {
          _discoveredModel = m;
          return jsonDecode(res.body)['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'Hasil OCR kosong.';
        } else if (res.statusCode == 404) {
          continue;
        }
        return 'Gagal memproses gambar (${_extractError(res.statusCode, res.body)}).';
      } catch (_) {
        if (m == models.last) rethrow;
      }
    }
    return _fallback.simulatedOcrResult;
  }

  Future<String> testConnection(String rawKey) async {
    final key = rawKey.trim();
    if (key.isEmpty) return 'API Key tidak boleh kosong.';
    try {
      final res = await _client.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$key'),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body)['models'] as List?)
            ?.map((m) => (m['name'] as String).replaceFirst('models/', ''))
            .where((m) => m.contains('flash') || m.contains('gemini'))
            .take(4)
            .toList();
        if (list != null && list.isNotEmpty) _discoveredModel = list.first;
        return 'Koneksi Sukses! Model aktif: ${list?.join(", ") ?? "Gemini"}';
      }
      return 'Koneksi Gagal: ${_extractError(res.statusCode, res.body)}';
    } catch (e) {
      return 'Error koneksi: $e';
    }
  }

  String _extractError(int code, String body) {
    try {
      final msg = jsonDecode(body)['error']?['message'];
      if (msg != null) return 'HTTP $code ($msg)';
    } catch (_) {}
    return 'HTTP $code';
  }

  Future<String?> getActiveApiKey() async {
    final stored = await getStoredApiKey();
    if (stored != null && stored.isNotEmpty) return stored;
    return EnvConfig.geminiApiKey.isNotEmpty ? EnvConfig.geminiApiKey : null;
  }

  Future<String?> getStoredApiKey() async {
    try {
      return await _storage.read(key: EnvConfig.storageKeyApiKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveApiKey(String key) async {
    _discoveredModel = null;
    await _storage.write(key: EnvConfig.storageKeyApiKey, value: key.trim());
  }

  Future<void> clearApiKey() async {
    _discoveredModel = null;
    await _storage.delete(key: EnvConfig.storageKeyApiKey);
  }

  void clearCache() => _cache.clear();
  int get cacheCount => _cache.length;
}
