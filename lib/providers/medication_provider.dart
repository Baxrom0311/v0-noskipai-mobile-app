import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/services/api_service.dart';
import 'package:noskipai/models/medication.dart';

class MedicationState {
  final List<Medication> medications;
  final bool isLoading;
  final String? error;

  MedicationState({
    this.medications = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  final ApiService apiService;

  MedicationNotifier(this.apiService) : super(MedicationState());

  Future<void> fetchMedications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await apiService.getMedications();
      final medications = (data as List)
          .map((m) => Medication.fromJson(m as Map<String, dynamic>))
          .toList();
      
      state = state.copyWith(
        medications: medications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> schedule,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiService.addMedication(
        name: name,
        dosage: dosage,
        frequency: frequency,
        schedule: schedule,
        notes: notes,
      );
      
      final newMedication = Medication.fromJson(response);
      state = state.copyWith(
        medications: [...state.medications, newMedication],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MedicationNotifier(apiService);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
