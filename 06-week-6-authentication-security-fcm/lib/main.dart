import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registrasi handler background (Top-Level & pragma entry-point)
  registerBackgroundHandler();

  runApp(const ProviderScope(child: MyApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isLoggedIn = authState.value ?? false;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // Route Guard: Belum login selalu diarahkan ke /login
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.login;
      }
      if (isLoggedIn && isLoggingIn) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (context, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pushService = ref.read(pushServiceProvider);
      final router = ref.read(routerProvider);
      void navigateTo(String route) => router.go(route);

      // Inisialisasi permission & local notification
      await pushService.requestPermission();
      await pushService.initLocalNotifications(onSelectNotification: navigateTo);

      // Inisialisasi FCM Token Lifecycle (getToken + onTokenRefresh -> POST /devices)
      await pushService.initTokenLifecycle();

      // Listen notifikasi (Foreground, Background / OpenedApp, & Terminated)
      pushService.setupMessageHandlers(navigateTo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notification App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}