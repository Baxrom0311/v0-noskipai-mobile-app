// Matches response_utils.serialize_adherence_log on the real backend. The
// backend has no standalone "date" field, and `patient_id`/`medication_id`
// are ints, not strings.
class MedicationAdherence {
  final int id;
  final int medicationId;
  final int patientId;
  final DateTime scheduledTime;
  final DateTime? takenAt;
  final String status; // 'taken' | 'late' | 'missed'
  final int delayMinutes;
  final String? notes;
  final String? mood;
  final String? sideEffects;
  final DateTime createdAt;

  MedicationAdherence({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.scheduledTime,
    this.takenAt,
    required this.status,
    required this.delayMinutes,
    this.notes,
    this.mood,
    this.sideEffects,
    required this.createdAt,
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) {
    return MedicationAdherence(
      id: json['id'] as int,
      medicationId: json['medication_id'] as int,
      patientId: json['patient_id'] as int,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      takenAt: json['taken_at'] != null ? DateTime.parse(json['taken_at'] as String) : null,
      status: json['status'] as String,
      delayMinutes: json['delay_minutes'] as int? ?? 0,
      notes: json['notes'] as String?,
      mood: json['mood'] as String?,
      sideEffects: json['side_effects'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_id': medicationId,
      'patient_id': patientId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'taken_at': takenAt?.toIso8601String(),
      'status': status,
      'delay_minutes': delayMinutes,
      'notes': notes,
      'mood': mood,
      'side_effects': sideEffects,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
