import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/settings_dialog.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_metric_bar.dart';
import '../widgets/image_analysis_modal.dart';
import '../widgets/quick_prompts_bar.dart';

/// Optimized Chat Screen:
/// 1. Removes root ref.watch(chatNotifierProvider) to avoid full screen rebuilds.
/// 2. Uses targeted Consumer widgets with fine-grained .select() selectors.
/// 3. Isolates ListView and ChatInputBar rebuild scopes.
/// 4. Eliminates inline anonymous function allocations in build() tree.
/// 5. Uses RepaintBoundary and const constructors to preserve raster cache.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _quickPrompts = [
    'Jadwal perkuliahan hari ini?',
    'Lokasi dan jam buka perpustakaan?',
    'Bagaimana cara bayar UKT?',
    'Informasi beasiswa yang tersedia?',
    'Uji Privasi: Tolong cek NIK 3507041203010002 dan HP 081234567890',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _handlePresetPrompt(String presetText) {
    if (presetText.isEmpty) return;
    ref.read(chatNotifierProvider.notifier).sendMessage(presetText);
    _scrollToBottom();
  }

  void _handleOpenSettings() {
    SettingsDialog.show(context);
  }

  void _handleClearChat() {
    ref.read(chatNotifierProvider.notifier).clearChat();
  }

  void _handleOpenOcr() {
    ImageAnalysisModal.show(
      context,
      onSelectAnalysis: ({
        required String prompt,
        required String base64Image,
        String? displayFileName,
      }) {
        ref.read(chatNotifierProvider.notifier).sendImageAnalysis(
              prompt: prompt,
              base64Image: base64Image,
              displayFileName: displayFileName,
            );
        _scrollToBottom();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // PENTING: Jangan menonton seluruh chatNotifierProvider di tingkat root Scaffold!
    // Ini mencegah rebuild seluruh layar saat streaming token atau update latency.

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: ChatAppBar(
        onOpenSettings: _handleOpenSettings,
        onClearChat: _handleClearChat,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ChatMetricBar(),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  // Hanya rebuild ListView ketika list pesan berubah
                  final messages = ref.watch(
                    chatNotifierProvider.select((s) => s.messages),
                  );

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    addRepaintBoundaries: true,
                                        itemBuilder: (context, index) {
                      final msg = messages[index];
                      return ChatMessageBubble(
                        key: ValueKey(msg.id),
                        message: msg,
                      );
                    },
                  );
                },
              ),
            ),
            QuickPromptsBar(
              prompts: _quickPrompts,
              onSelectPrompt: _handlePresetPrompt,
            ),
            Consumer(
              builder: (context, ref, child) {
                // Hanya rebuild input bar saat status isLoading berubah
                final isLoading = ref.watch(
                  chatNotifierProvider.select((s) => s.isLoading),
                );

                return ChatInputBar(
                  controller: _textController,
                  isLoading: isLoading,
                  onSend: _handleSend,
                  onOpenOcr: _handleOpenOcr,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
