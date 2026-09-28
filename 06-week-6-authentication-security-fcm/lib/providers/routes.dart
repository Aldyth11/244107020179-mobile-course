/// Definisi rute terpusat untuk GoRouter dan Deep Linking FCM
abstract class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String announcement = '/pengumuman/:id';

  /// Helper untuk membangun path rute pengumuman dengan ID tertentu
  static String announcementDetail(String id) => '/pengumuman/$id';
}

/// Fungsi murni (pure function) untuk memparsing RemoteMessage.data atau Map payload
/// menjadi string route yang valid tanpa bergantung pada Firebase SDK.
String routeFromMessage(Map<dynamic, dynamic> data) {
  final route = data['route']?.toString() ?? '/';
  if (route.isEmpty) return '/';
  return route.startsWith('/') ? route : '/$route';
}
