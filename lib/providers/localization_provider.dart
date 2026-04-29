import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationState {
  final String currentLocale;

  LocalizationState({this.currentLocale = 'en'});

  LocalizationState copyWith({String? currentLocale}) {
    return LocalizationState(
      currentLocale: currentLocale ?? this.currentLocale,
    );
  }
}

class LocalizationNotifier extends StateNotifier<LocalizationState> {
  LocalizationNotifier() : super(LocalizationState()) {
    _initLocale();
  }

  Future<void> _initLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('locale') ?? 'en';
      state = state.copyWith(currentLocale: locale);
    } catch (e) {
      // Use default locale
    }
  }

  Future<void> changeLocale(String locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', locale);
      state = state.copyWith(currentLocale: locale);
    } catch (e) {
      // Handle error
    }
  }
}

final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, LocalizationState>((ref) {
  return LocalizationNotifier();
});
