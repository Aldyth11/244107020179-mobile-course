import '../../data/models/chat_models.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final int requestCount;
  final int cacheHitCount;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.requestCount = 0,
    this.cacheHitCount = 0,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    int? requestCount,
    int? cacheHitCount,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      requestCount: requestCount ?? this.requestCount,
      cacheHitCount: cacheHitCount ?? this.cacheHitCount,
    );
  }
}
