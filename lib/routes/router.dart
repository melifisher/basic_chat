import 'package:basic_chat/screens/document_search.dart';
import 'package:basic_chat/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';
import '../screens/chat_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const DocumentSearchScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const VoiceSettingsScreen(),
    ),
  ],
);
