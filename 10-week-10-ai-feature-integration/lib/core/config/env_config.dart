class EnvConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String defaultModel = 'gemini-3.1-flash-lite';

  static const List<String> candidateModels = [
    'gemini-3.1-flash-lite',
    'gemini-3-flash',
    'gemini-3.8-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.6-flash',
    'gemini-2.5-flash',
  ];

  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const String defaultSystemPrompt =
      'Kamu asisten kampus ramah untuk mahasiswa Politeknik Negeri Malang (POLINEMA). '
      'Berikan jawaban dalam Bahasa Indonesia yang sopan, solutif, ringkas, dan tertata rapi. '
      'Gunakan poin-poin yang jelas dengan jarak antar poin yang nyaman dibaca di layar HP. '
      'Hindari paragraf yang terlalu padat atau bertele-tele. '
      'Jangan pernah meminta atau membocorkan data pribadi mahasiswa.';

  static const String storageKeyApiKey = 'ai_api_key';
}
