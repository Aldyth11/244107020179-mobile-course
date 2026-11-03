import 'package:flutter/material.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

class AppRoutes {
  static const String chat = '/';

  static Map<String, WidgetBuilder> get routes => {
        chat: (context) => const ChatScreen(),
      };
}
