enum ChatRole {
  user,
  assistant,
  system,
}

enum MessageStatus {
  sending,
  streaming,
  sent,
  error,
}

class ChatMessage {
  final String id;
  final String text;
  final ChatRole role;
  final DateTime timestamp;
  final MessageStatus status;
  final String? originalSanitizedText;
  final bool wasSanitized;
  final String? imagePath;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.originalSanitizedText,
    this.wasSanitized = false,
    this.imagePath,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    String? originalSanitizedText,
    bool? wasSanitized,
    String? imagePath,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      originalSanitizedText:
          originalSanitizedText ?? this.originalSanitizedText,
      wasSanitized: wasSanitized ?? this.wasSanitized,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class SanitizationResult {
  final String sanitizedText;
  final bool hasSensitiveData;
  final List<String> detectedItems;

  const SanitizationResult({
    required this.sanitizedText,
    required this.hasSensitiveData,
    required this.detectedItems,
  });
}
