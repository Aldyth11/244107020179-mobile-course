import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';

class ChatMetricBar extends ConsumerWidget {
  const ChatMetricBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyActive = ref.watch(privacyProtectionProvider);
    final chatState = ref.watch(chatNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: privacyActive
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  privacyActive ? Icons.shield : Icons.shield_outlined,
                  size: 13,
                  color: privacyActive
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB91C1C),
                ),
                const SizedBox(width: 4),
                Text(
                  privacyActive ? 'PII Shield Aktif' : 'Shield Mati',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: privacyActive
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Req: ${chatState.requestCount} | Cache Hit: ${chatState.cacheHitCount}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
