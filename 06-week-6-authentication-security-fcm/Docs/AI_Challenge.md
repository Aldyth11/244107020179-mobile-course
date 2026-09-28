# AI Challenge: Verification & Code Review Documentation

**Project:** Week 6 - Authentication, Security & FCM (Campus Notification App)  
**Author:** M. Aldyth Rafiasyah Fauzi  
**Class:** TI-2F / Network & Mobile App Development  

---

## 1. AI Prompt Used

> "Aplikasi Flutter Campus Notification App.  
> Stack: `firebase_messaging`, `flutter_local_notifications`, `flutter_secure_storage`, `go_router`, `Riverpod`.  
> Buatkan `PushService` dengan:
> - `requestPermission` + `getToken` + `onTokenRefresh` (kirim ke `POST /devices`)
> - `onMessage` (tampilkan local notification manual)
> - `onMessageOpenedApp` + `getInitialMessage` (navigasi ke `data.route`)
> - `subscribe`/`unsubscribe` topic `pengumuman-kampus`
> - `background handler` top-level dengan `@pragma('vm:entry-point')`  
> 
> Tandai bagian yang **BERBEDA** untuk Android 13+ vs iOS, dan bagian yang **tidak boleh mengakses BuildContext**."

---

## 2. Generated Code Implementation (`lib/messaging/push_service.dart`)

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

// -----------------------------------------------------------------------------
// [PENTING] Background Handler
// 1. Wajib berupa Top-Level Function (bukan method dalam class).
// 2. Wajib menggunakan annotation @pragma('vm:entry-point').
// 3. DILARANG mengakses BuildContext, Widget, atau Riverpod Provider di sini!
// -----------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hanya jalankan pemrosesan latar belakang ringan/logging aman.
  // Navigasi UI dilakukan saat notifikasi diklik oleh user.
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class PushService {
  /// 1. Request Permission
  /// - Android 13+ (API level 33): Membutuhkan izin POST_NOTIFICATIONS secara runtime.
  /// - iOS: Membutuhkan izin APNs (Alert, Badge, Sound) via FirebaseMessaging requestPermission.
  Future<bool> requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// 2. Inisialisasi Local Notification untuk Foreground Banner
  Future<void> initLocalNotifications() async {
    // Pengaturan Spesifik Platform
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(); // Khusus iOS / MacOS (Membutuhkan APNs setup)

    const channel = AndroidNotificationChannel(
      'pengumuman_channel',
      'Pengumuman Kampus',
      description: 'Channel untuk notifikasi pengumuman kampus',
      importance: Importance.high,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          pendingDeepLink = response.payload;
        }
      },
    );
  }

  /// 3. Token Lifecycle: Ambil, Kirim ke Backend (POST /devices), dan Listen Refresh
  Future<void> initFcmToken({
    required Future<void> Function(String token) sendTokenToBackend,
  }) async {
    // Ambil token awal
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await sendTokenToBackend(token);
    }

    // Listener rotasi token (Mencegah token basi di DB backend)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await sendTokenToBackend(newToken);
    });
  }

  /// 4. Handler Notifikasi Foreground & Background Click
  void listenMessages(void Function(String route) navigateTo) {
    // STATE 1: FOREGROUND
    // Firebase tidak memunculkan banner sistem bawaan saat app aktif.
    // Dihandle manual dengan FlutterLocalNotifications.
    FirebaseMessaging.onMessage.listen((message) async {
      final route = message.data['route'] ?? '/';
      const androidDetails = AndroidNotificationDetails(
        'pengumuman_channel',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      );

      await _local.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Pengumuman Baru',
        body: message.notification?.body ?? '',
        notificationDetails: const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    // STATE 2: BACKGROUND (App minimized -> Diklik pengguna)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = message.data['route'] ?? '/';
      navigateTo(route);
    });
  }

  /// 5. STATE 3: TERMINATED (App mati total -> Dibuka via Notifikasi)
  Future<void> handleTerminated(void Function(String route) navigateTo) async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final route = initialMessage.data['route'] ?? '/';
      navigateTo(route);
      return;
    }

    if (pendingDeepLink != null) {
      navigateTo(pendingDeepLink!);
      pendingDeepLink = null;
    }
  }

  /// 6. Topic Subscriptions
  Future<void> subscribeToCampusTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
  }

  Future<void> unsubscribeFromCampusTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
  }
}