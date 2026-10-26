import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/presentation/providers/chat_providers.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog(context: context, builder: (_) => const SettingsDialog());

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  late final TextEditingController _controller;
  bool _obscure = true;
  String? _testStatus;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadKey();
  }

  void _loadKey() async {
    final key = await ref.read(aiServiceProvider).getStoredApiKey() ?? '';
    if (mounted) _controller.text = key;
  }

  void _runTest() async {
    setState(() {
      _isTesting = true;
      _testStatus = null;
    });
    final res = await ref.read(aiServiceProvider).testConnection(_controller.text);
    if (mounted) setState(() { _isTesting = false; _testStatus = res; });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final privacyEnabled = ref.watch(privacyProtectionProvider);
    final aiService = ref.read(aiServiceProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.security, color: Color(0xFF1E3A8A)),
        SizedBox(width: 8),
        Text('Pengaturan AI & Privasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Google Gemini API Key', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Masukkan AIzaSy...',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _runTest,
              icon: _isTesting ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.network_check, size: 16),
              label: const Text('Tes Koneksi API', style: TextStyle(fontSize: 12)),
            ),
            if (_testStatus != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _testStatus!.startsWith('Koneksi Sukses') ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _testStatus!,
                  style: TextStyle(
                    fontSize: 11,
                    color: _testStatus!.startsWith('Koneksi Sukses') ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
            const Divider(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sanitasi Privasi (PII Masking)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Sensor NIK 16-digit, No HP, & email.', style: TextStyle(fontSize: 11)),
              value: privacyEnabled,
              activeThumbColor: const Color(0xFF1E3A8A),
              onChanged: (v) => ref.read(privacyProtectionProvider.notifier).setProtection(v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await aiService.clearApiKey();
            ref.invalidate(apiKeyProvider);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Hapus Key', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
          onPressed: () async {
            final key = _controller.text.trim();
            if (key.isNotEmpty) {
              await aiService.saveApiKey(key);
            } else {
              await aiService.clearApiKey();
            }
            ref.invalidate(apiKeyProvider);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
