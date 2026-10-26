import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_models.dart';
import '../../data/services/ai_service.dart';
import 'chat_providers.dart';

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => ChatState(messages: [
        ChatMessage(
          id: 'initial_welcome',
          text: 'Halo! Saya CampusBot AI Polinema. Tanyakan informasi jadwal, perpustakaan, UKT, beasiswa, atau unggah foto dokumen/KTM.',
          role: ChatRole.assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ),
      ]);

  AiService get _aiService => ref.read(aiServiceProvider);

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final useSanitization = ref.read(privacyProtectionProvider);
    final forceOffline = ref.read(offlineModeProvider);
    final sanitization = useSanitization
        ? _aiService.sanitizePrompt(trimmed)
        : SanitizationResult(sanitizedText: trimmed, hasSensitiveData: false, detectedItems: []);

    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      role: ChatRole.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      wasSanitized: sanitization.hasSensitiveData,
      originalSanitizedText: sanitization.sanitizedText,
    );
    final aiMsgId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    final initialAi = ChatMessage(
      id: aiMsgId,
      text: '',
      role: ChatRole.assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.streaming,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, initialAi],
      isLoading: true,
      requestCount: state.requestCount + 1,
    );

    try {
      final fullResponse = await _aiService.ask(trimmed, useSanitization: useSanitization, forceOffline: forceOffline);
      if (fullResponse.startsWith('[Cached]')) {
        state = state.copyWith(cacheHitCount: state.cacheHitCount + 1);
      }
      await _streamResponse(aiMsgId, fullResponse);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _setError(aiMsgId, 'Gagal memproses pesan: $e');
    }
  }

  Future<void> _streamResponse(String aiMsgId, String fullResponse) async {
    final words = fullResponse.split(' ');
    String streamed = '';
    for (int i = 0; i < words.length; i += 3) {
      final chunkEnd = (i + 3 < words.length) ? i + 3 : words.length;
      final chunk = words.sublist(i, chunkEnd).join(' ');
      streamed += (streamed.isEmpty ? '' : ' ') + chunk;
      final isLast = chunkEnd >= words.length;
      final updated = state.messages.map((m) {
        return m.id == aiMsgId
            ? m.copyWith(text: streamed, status: isLast ? MessageStatus.sent : MessageStatus.streaming)
            : m;
      }).toList();
      state = state.copyWith(messages: updated);
      if (!isLast && words.length < 150) {
        await Future.delayed(const Duration(milliseconds: 15));
      }
    }
  }

  Future<void> sendImageAnalysis({
    required String prompt,
    required String base64Image,
    String? displayFileName,
  }) async {
    final userMsg = ChatMessage(
      id: 'user_img_${DateTime.now().millisecondsSinceEpoch}',
      text: '[Dokumen/Foto: ${displayFileName ?? "Citra Kampus"}] $prompt',
      role: ChatRole.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    final aiMsgId = 'ai_img_${DateTime.now().millisecondsSinceEpoch}';
    final initialAi = ChatMessage(
      id: aiMsgId,
      text: 'Sedang menganalisis dokumen/citra...',
      role: ChatRole.assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.streaming,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, initialAi],
      isLoading: true,
      requestCount: state.requestCount + 1,
    );

    try {
      final result = await _aiService.understandImage(prompt: prompt, base64Image: base64Image);
      final updated = state.messages.map((m) => m.id == aiMsgId ? m.copyWith(text: result, status: MessageStatus.sent) : m).toList();
      state = state.copyWith(messages: updated, isLoading: false);
    } catch (e) {
      _setError(aiMsgId, 'Gagal menganalisis citra: $e');
    }
  }

  void _setError(String aiMsgId, String error) {
    final updated = state.messages.map((m) => m.id == aiMsgId ? m.copyWith(text: error, status: MessageStatus.error) : m).toList();
    state = state.copyWith(messages: updated, isLoading: false, errorMessage: error);
  }

  void clearChat() {
    _aiService.clearCache();
    state = ChatState(
      messages: [
        ChatMessage(
          id: 'initial_welcome',
          text: 'Riwayat obrolan dibersihkan. Ada yang bisa CampusBot bantu lagi?',
          role: ChatRole.assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ),
      ],
      requestCount: 0,
      cacheHitCount: 0,
    );
  }
}
