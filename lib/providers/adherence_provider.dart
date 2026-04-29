import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/services/api_service.dart';
import 'package:noskipai/models/medication_adherence.dart';

class AdherenceState {
  final List<MedicationAdherence> history;
  final double weeklyRate;
  final double monthlyRate;
  final bool isLoading;
  final String? error;

  AdherenceState({
    this.history = const [],
    this.weeklyRate = 0.0,
    this.monthlyRate = 0.0,
    this.isLoading = false,
    this.error,
  });

  AdherenceState copyWith({
    List<MedicationAdherence>? history,
    double? weeklyRate,
    double? monthlyRate,
    bool? isLoading,
    String? error,
  }) {
    return AdherenceState(
      history: history ?? this.history,
      weeklyRate: weeklyRate ?? this.weeklyRate,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdherenceNotifier extends StateNotifier<AdherenceState> {
  final ApiService apiService;

  AdherenceNotifier(this.apiService) : super(AdherenceState());

  Future<void> fetchAdherenceHistory({int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await apiService.getAdherenceHistory(days: days);
      final history = (data as List)
          .map((item) => MedicationAdherence.fromJson(item as Map<String, dynamic>))
          .toList();

      // Calculate rates
      final taken = history.where((h) => h.status == 'taken').length;
      final total = history.length;
      final rate = total > 0 ? taken / total : 0.0;

      state = state.copyWith(
        history: history,
        monthlyRate: rate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logAdherence({
    required String medicationId,
    required String status,
    required String scheduledTime,
    required DateTime date,
  }) async {
    try {
      await apiService.logAdherence(
        medicationId,
        status,
        scheduledTime,
        date,
      );
      // Refresh history after logging
      await fetchAdherenceHistory();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final adherenceProvider =
    StateNotifierProvider<AdherenceNotifier, AdherenceState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AdherenceNotifier(apiService);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
