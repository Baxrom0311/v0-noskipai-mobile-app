import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/services/api_service.dart';
import 'package:noskipai/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noskipai/providers/services_provider.dart';

// Auth State Notifier
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  static const _sentinel = Object();

  AuthState copyWith({
    Object? user = _sentinel,
    Object? token = _sentinel,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return AuthState(
      user: identical(user, _sentinel) ? this.user : user as User?,
      token: identical(token, _sentinel) ? this.token : token as String?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService apiService;

  AuthNotifier(this.apiService) : super(AuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiService.login(phone, password);
      final user = User.fromJson(response['user']);
      final token = response['access_token'];

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(
    String fullName,
    String phone,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiService.register(
        fullName: fullName,
        phone: phone,
        password: password,
      );
      final user = User.fromJson(response['user']);
      final token = response['access_token'];
      
      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await apiService.logout();
    state = AuthState();
  }

  Future<void> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        state = state.copyWith(token: token);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});
