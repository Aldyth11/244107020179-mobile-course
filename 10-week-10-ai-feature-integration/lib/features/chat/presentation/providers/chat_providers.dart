import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ai_service.dart';
import 'chat_notifier.dart';
import 'chat_state.dart';

export 'chat_notifier.dart';
export 'chat_state.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final apiKeyProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(aiServiceProvider);
  return await service.getStoredApiKey();
});

class PrivacyProtectionNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setProtection(bool value) => state = value;
}

final privacyProtectionProvider =
    NotifierProvider<PrivacyProtectionNotifier, bool>(
  PrivacyProtectionNotifier.new,
);

class OfflineModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setMode(bool value) => state = value;
}

final offlineModeProvider =
    NotifierProvider<OfflineModeNotifier, bool>(
  OfflineModeNotifier.new,
);

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
