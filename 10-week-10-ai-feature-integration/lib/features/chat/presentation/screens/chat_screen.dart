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

  void _handleSend([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: ChatAppBar(
        onOpenSettings: () => SettingsDialog.show(context),
        onClearChat: () => ref.read(chatNotifierProvider.notifier).clearChat(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ChatMetricBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageBubble(message: chatState.messages[index]);
                },
              ),
            ),
            QuickPromptsBar(
              prompts: _quickPrompts,
              onSelectPrompt: (p) => _handleSend(p),
            ),
            ChatInputBar(
              controller: _textController,
              isLoading: chatState.isLoading,
              onSend: () => _handleSend(),
              onOpenOcr: () {
                ImageAnalysisModal.show(
                  context,
                  onSelectAnalysis: ({required prompt, required base64Image, displayFileName}) {
                    ref.read(chatNotifierProvider.notifier).sendImageAnalysis(
                          prompt: prompt,
                          base64Image: base64Image,
                          displayFileName: displayFileName,
                        );
                    _scrollToBottom();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
