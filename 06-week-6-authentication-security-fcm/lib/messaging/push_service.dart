import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/token_store.dart';
import '../providers/auth_provider.dart';
import '../providers/routes.dart';

// =============================================================================
// [PERINGATAN: TIDAK BOLEH MENGAKSES BuildContext]
// 1. Background Handler adalah Top-Level Function (di luar class).
// 2. Berjalan di Isolate terpisah tanpa akses ke Element Tree, Widget,
//    BuildContext, ataupun Riverpod ref secara langsung.
// 3. Wajib dianotasi @pragma('vm:entry-point') agar AOT compiler tidak
//    meng-tree-shake fungsi ini saat kompilasi rilis.
// =============================================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background processing hanya untuk logging / caching lokal ringan.
  // DILARANG: Navigator.of(context), ScaffoldMessenger.of(context), dll.
  debugPrint('[FCM Background] Pesan diterima: ${message.messageId}');
  debugPrint('[FCM Background] Data payload: ${message.data}');
}

/// Fungsi untuk mendaftarkan background message handler
void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Pending deep link untuk menyimpan route jika notifikasi di klik saat
/// router belum siap diinisialisasi
String? pendingDeepLink;

/// Provider Riverpod untuk PushService
final pushServiceProvider = Provider<PushService>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final dio = buildApiClient(tokenStore, authRepo);

  return PushService(
    messaging: FirebaseMessaging.instance,
    localNotifications: FlutterLocalNotificationsPlugin(),
    tokenStore: tokenStore,
    dio: dio,
  );
});

class PushService {
  PushService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    TokenStore? tokenStore,
    Dio? dio,
  })  : _messaging = messaging,
        _local = localNotifications,
        _tokenStore = tokenStore ?? TokenStore(),
        _dio = dio;

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin? _local;
  final TokenStore _tokenStore;
  final Dio? _dio;

  FirebaseMessaging get messaging => _messaging ?? FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin get local =>
      _local ?? FlutterLocalNotificationsPlugin();

  static const String campusTopic = 'pengumuman-kampus';
  static const String channelId = 'pengumuman_channel';
  static const String channelName = 'Pengumuman Kampus';
  static const String channelDescription =
      'Channel notifikasi resmi pengumuman kampus';

  // ===========================================================================
  // 1. REQUEST PERMISSION
  // ===========================================================================
  // [BERBEDA: ANDROID 13+ vs iOS]
  // - Android 13+ (API level 33): Izin runtime POST_NOTIFICATIONS wajib diminta
  //   secara eksplisit melalui requestPermission() atau sistem permission dialog.
  // - Android <= 12: Izin notifikasi otomatis diberikan saat instalasi aplikasi.
  // - iOS: Membutuhkan otorisasi APNs (Apple Push Notification service) untuk
  //   alert, badge, sound, dan criticalAlert. Dapat berupa provisional atau authorized.
  // ===========================================================================
  Future<bool> requestPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
    return isGranted;
  }

  // ===========================================================================
  // 2. INIT LOCAL NOTIFICATIONS (FOREGROUND BANNER)
  // ===========================================================================
  // [BERBEDA: ANDROID 13+ vs iOS]
  // - Android: Wajib membuat AndroidNotificationChannel dengan Importance High / Max
  //   agar notifikasi dapat tampil sebagai Heads-Up banner di bagian atas layar.
  // - iOS: Menggunakan DarwinInitializationSettings dan mengonfigurasi
  //   DarwinNotificationDetails (presentAlert, presentBadge, presentSound).
  // ===========================================================================
  Future<void> initLocalNotifications({
    void Function(String route)? onSelectNotification,
  }) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // [BERBEDA: ANDROID] Pembuatan Notification Channel di Android
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // [BERBEDA: iOS] Mengatur opsi presentasi foreground iOS
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          if (onSelectNotification != null) {
            onSelectNotification(payload);
          } else {
            pendingDeepLink = payload;
          }
        }
      },
    );
  }

  // ===========================================================================
  // 3. TOKEN LIFECYCLE (getToken + onTokenRefresh -> POST /devices)
  // ===========================================================================
  // [PERINGATAN: TIDAK BOLEH MENGAKSES BuildContext]
  // Callback onTokenRefresh berjalan secara asynchronous saat Firebase
  // merotasi token (misal restore backup atau install ulang). Tidak ada BuildContext
  // di dalam listener ini. Penyimpanan token ke Secure Storage dan sinkronisasi
  // ke backend dilakukan melalui layer service / repository secara headless.
  // ===========================================================================
  Future<void> initTokenLifecycle({
    Future<void> Function(String token)? customSendDeviceToken,
  }) async {
    // 3a. Dapatkan token FCM awal
    try {
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Initial Device Token: $token');
        if (customSendDeviceToken != null) {
          await customSendDeviceToken(token);
        } else {
          await sendDeviceToken(token);
        }
      }
    } catch (e) {
      debugPrint('[FCM] Error mendapatkan token: $e');
    }

    // 3b. Listener saat token dirotasi / diperbarui oleh Firebase
    messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token diperbarui (onTokenRefresh): $newToken');
      if (customSendDeviceToken != null) {
        await customSendDeviceToken(newToken);
      } else {
        await sendDeviceToken(newToken);
      }
    });
  }

  /// Mengirimkan FCM device token ke endpoint backend POST /devices
  /// serta menyimpannya secara aman di FlutterSecureStorage
  Future<void> sendDeviceToken(String token) async {
    // 1. Simpan di secure storage
    await _tokenStore.saveFcmToken(token);

    // 2. Kirim ke REST backend POST /devices
    if (_dio != null) {
      try {
        final platformName = !kIsWeb ? Platform.operatingSystem : 'web';
        final response = await _dio.post(
          '/devices',
          data: {
            'fcm_token': token,
            'device_type': platformName,
          },
        );
        debugPrint('[FCM -> Backend] POST /devices status: ${response.statusCode}');
      } catch (e) {
        debugPrint('[FCM -> Backend] Gagal mengirim token ke /devices: $e');
      }
    }
  }

  // ===========================================================================
  // 4. ON MESSAGE (Foreground Notification Handler)
  // ===========================================================================
  // [BERBEDA: ANDROID 13+ vs iOS]
  // - Pada saat aplikasi sedang di foreground (aktif), FCM SDK default di Android
  //   TIDAK menampilkan banner notifikasi di status bar. Kita harus menampilkannya
  //   secara manual menggunakan FlutterLocalNotificationsPlugin.
  // - Pada iOS, jika setForegroundNotificationPresentationOptions diaktifkan,
  //   sistem iOS dapat menampilkan banner langsung, namun notifikasi lokal tetap
  //   berguna jika ingin memodifikasi tampilan / aksi klik.
  // ===========================================================================
  void listenOnMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('[FCM onMessage] Pesan foreground masuk: ${message.messageId}');

      final route = routeFromMessage(message.data);
      final notification = message.notification;

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await local.show(
        id: message.hashCode,
        title: notification?.title ?? 'Pengumuman Baru',
        body: notification?.body ?? message.data['body'] ?? '',
        notificationDetails: notificationDetails,
        payload: route,
      );
    });
  }

  // ===========================================================================
  // 5. NAVIGATION HANDLING (onMessageOpenedApp + getInitialMessage)
  // ===========================================================================
  // [PERINGATAN: TIDAK BOLEH MENGAKSES BuildContext LANGSUNG]
  // Navigasi dilakukan dengan mengoper callback navigasi (seperti `router.go(route)`
  // dari GoRouter) atau menyimpan rute ke pendingDeepLink jika router belum terpasang.
  // Jangan melakukan Navigator.of(context) di dalam callback stream asynchronous!
  // ===========================================================================

  /// State 2: Background (Aplikasi diminimalkan -> Notifikasi diklik pengguna)
  void listenOnMessageOpenedApp(void Function(String route) navigateTo) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM onMessageOpenedApp] Notifikasi diklik dari background');
      final route = routeFromMessage(message.data);
      navigateTo(route);
    });
  }

  /// State 3: Terminated (Aplikasi mati total -> Dibuka via Notifikasi)
  Future<void> handleInitialMessage(void Function(String route) navigateTo) async {
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM getInitialMessage] Aplikasi dibuka dari terminated via notifikasi');
      final route = routeFromMessage(initialMessage.data);
      navigateTo(route);
      return;
    }

    if (pendingDeepLink != null) {
      navigateTo(pendingDeepLink!);
      pendingDeepLink = null;
    }
  }

  /// Helper untuk menyatukan semua listener pesan (Foreground, Background, Terminated)
  void setupMessageHandlers(void Function(String route) navigateTo) {
    listenOnMessage();
    listenOnMessageOpenedApp(navigateTo);
    handleInitialMessage(navigateTo);
  }

  // ===========================================================================
  // 6. TOPIC SUBSCRIPTION (pengumuman-kampus)
  // ===========================================================================
  Future<void> subscribeCampusTopic() async {
    await messaging.subscribeToTopic(campusTopic);
    debugPrint('[FCM Topic] Berhasil subscribe ke topic: $campusTopic');
  }

  Future<void> unsubscribeCampusTopic() async {
    await messaging.unsubscribeFromTopic(campusTopic);
    debugPrint('[FCM Topic] Berhasil unsubscribe dari topic: $campusTopic');
  }
}