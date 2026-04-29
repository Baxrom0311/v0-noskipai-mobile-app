import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:noskipai/screens/auth/login_screen.dart';
import 'package:noskipai/screens/auth/register_screen.dart';
import 'package:noskipai/screens/dashboard/dashboard_screen.dart';
import 'package:noskipai/screens/medications/medications_screen.dart';
import 'package:noskipai/screens/chat/chat_screen.dart';
import 'package:noskipai/screens/settings/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/medications',
        builder: (context, state) => const MedicationsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
