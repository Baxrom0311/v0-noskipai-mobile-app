class Medication {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> schedule; // Times in 24h format (e.g., ["08:00", "20:00"])
  final String? notes;
  final bool active;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.schedule,
    this.notes,
    required this.active,
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      schedule: List<String>.from(json['schedule'] as List),
      notes: json['notes'] as String?,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'schedule': schedule,
      'notes': notes,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? schedule,
    String? notes,
    bool? active,
    DateTime? createdAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      schedule: schedule ?? this.schedule,
      notes: notes ?? this.notes,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
