import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/models/chat_models.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1E3A8A) : (message.status == MessageStatus.error ? const Color(0xFFFEE2E2) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 4, offset: Offset(0, 2))],
                border: !isUser && message.status != MessageStatus.error ? Border.all(color: const Color(0xFFE2E8F0)) : null,
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.wasSanitized) _buildSanitizedBadge(),
                  if (message.status == MessageStatus.streaming && message.text.isEmpty)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('CampusBot sedang berpikir...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  else if (isUser)
                    SelectableText(
                      message.text,
                      style: const TextStyle(fontSize: 14, height: 1.45, color: Colors.white),
                    )
                  else
                    MarkdownBody(
                      data: message.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: message.status == MessageStatus.error ? const Color(0xFF991B1B) : const Color(0xFF0F172A),
                        ),
                        strong: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        listBullet: const TextStyle(fontSize: 14, color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
                        blockSpacing: 10,
                        listIndent: 16,
                      ),
                    ),
                  const SizedBox(height: 4),
                  _buildFooter(context, isUser),
                ],
              ),
            ),
          ),
          if (isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildSanitizedBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(4)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, size: 11, color: Colors.amber),
          SizedBox(width: 4),
          Text('Data sensitif disamarkan oleh sistem', style: TextStyle(fontSize: 10, color: Color(0xFF78350F), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 10, color: isUser ? Colors.white70 : const Color(0xFF94A3B8)),
        ),
        if (!isUser && message.text.isNotEmpty) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teks respons disalin ke clipboard!'), duration: Duration(seconds: 1)),
              );
            },
            child: const Icon(Icons.copy, size: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ],
    );
  }
}
