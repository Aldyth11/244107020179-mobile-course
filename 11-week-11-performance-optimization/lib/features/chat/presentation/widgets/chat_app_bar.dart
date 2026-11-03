import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/env_config.dart';
import '../providers/chat_providers.dart';

class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onClearChat;

  const ChatAppBar({
    super.key,
    required this.onOpenSettings,
    required this.onClearChat,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineModeProvider);

    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CampusBot AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOffline ? Colors.orange : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isOffline ? 'Mode Offline' : EnvConfig.defaultModel,
                    style: TextStyle(
                      fontSize: 11,
                      color: isOffline ? Colors.orange[800] : Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: isOffline ? 'Ganti ke Mode Online' : 'Ganti ke Mode Offline',
          icon: Icon(
            isOffline ? Icons.cloud_off : Icons.cloud_done,
            color: isOffline ? Colors.orange : const Color(0xFF1E3A8A),
          ),
          onPressed: () => ref.read(offlineModeProvider.notifier).toggle(),
        ),
        IconButton(
          tooltip: 'Pengaturan API & Privasi',
          icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E3A8A)),
          onPressed: onOpenSettings,
        ),
        IconButton(
          tooltip: 'Hapus Chat',
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
          onPressed: onClearChat,
        ),
      ],
    );
  }
}
