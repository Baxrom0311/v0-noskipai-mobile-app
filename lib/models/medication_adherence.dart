class MedicationAdherence {
  final String id;
  final String medicationId;
  final String userId;
  final DateTime date;
  final String status; // 'taken', 'missed', 'skipped'
  final String scheduledTime;
  final String? notes;
  final DateTime createdAt;

  MedicationAdherence({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.date,
    required this.status,
    required this.scheduledTime,
    this.notes,
    required this.createdAt,
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) {
    return MedicationAdherence(
      id: json['id'] as String,
      medicationId: json['medication_id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      scheduledTime: json['scheduled_time'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_id': medicationId,
      'user_id': userId,
      'date': date.toIso8601String(),
      'status': status,
      'scheduled_time': scheduledTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
