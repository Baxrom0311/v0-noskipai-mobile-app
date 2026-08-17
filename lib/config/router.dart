import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/providers/auth_provider.dart';
import 'package:noskipai/screens/auth/login_screen.dart';
import 'package:noskipai/screens/auth/register_screen.dart';
import 'package:noskipai/screens/dashboard/dashboard_screen.dart';
import 'package:noskipai/screens/medications/medications_screen.dart';
import 'package:noskipai/screens/chat/chat_screen.dart';
import 'package:noskipai/screens/settings/settings_screen.dart';
import 'package:noskipai/screens/safety/safety_signals_screen.dart';

class AppRouter {
  // Ensures checkAuth() (which hydrates the token from persisted storage) is
  // only run once per app lifetime, on the first redirect evaluation, rather
  // than on every navigation attempt.
  static bool _authChecked = false;

  static const _authRoutes = ['/login', '/register'];

  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      // The router is created (and its routes/redirect evaluated) from
      // within the widget tree built under the app's ProviderScope, so we
      // can read the existing authProvider straight from the container
      // without needing a ref threaded in from main.dart.
      final container = ProviderScope.containerOf(context, listen: false);

      if (!_authChecked) {
        _authChecked = true;
        // Hydrate the auth state from persisted storage (e.g. a stored
        // token from a previous session) before making a redirect decision.
        await container.read(authProvider.notifier).checkAuth();
      }

      final authState = container.read(authProvider);
      final isAuthenticated = authState.token != null;
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !isAuthRoute) {
        // Unauthenticated user deep-linking (or navigating) to a protected
        // route — send them to login instead.
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        // Already-authenticated user landing on /login or /register (e.g. a
        // returning user with a valid stored token) — skip straight to the
        // dashboard.
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/medications', builder: (context, state) => const MedicationsScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/safety-signals', builder: (context, state) => const SafetySignalsScreen()),
    ],
  );
}
