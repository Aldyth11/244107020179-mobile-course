import '../../features/chat/data/models/chat_models.dart';

class PiiSanitizer {
  const PiiSanitizer();

  SanitizationResult sanitize(String text) {
    String sanitized = text;
    final List<String> detected = [];

    // Deteksi NIK (16 digit angka berurutan)
    final nikRegex = RegExp(r'\b\d{16}\b');
    if (nikRegex.hasMatch(sanitized)) {
      detected.add('NIK (16 digit)');
      sanitized = sanitized.replaceAll(nikRegex, '[NIK_DISAMARKAN]');
    }

    // Deteksi Nomor HP Indonesia
    final phoneRegex = RegExp(r'(\+62|62|0)8[1-9][0-9]{6,10}\b');
    if (phoneRegex.hasMatch(sanitized)) {
      detected.add('Nomor HP');
      sanitized = sanitized.replaceAll(phoneRegex, '[NO_HP_DISAMARKAN]');
    }

    // Deteksi Email
    final emailRegex =
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b');
    if (emailRegex.hasMatch(sanitized)) {
      detected.add('Alamat Email');
      sanitized = sanitized.replaceAll(emailRegex, '[EMAIL_DISAMARKAN]');
    }

    return SanitizationResult(
      sanitizedText: sanitized,
      hasSensitiveData: detected.isNotEmpty,
      detectedItems: detected,
    );
  }
}
