// Matches schemas/medication.py MedicationResponse / response_utils.serialize_medication
// on the real backend. Dart property names `schedule`, `notes`, `active` and
// `userId` are kept (rather than renamed to times/instructions/is_active/patient_id)
// because other app code already reads them by these names; only the JSON wire
// keys are translated to/from the real backend field names.
class Medication {
  final int id;
  final int userId; // backend: patient_id
  final String name;
  final String dosage;
  final String frequency;
  final List<String> schedule; // backend: times (HH:MM strings)
  final String? notes; // backend: instructions
  final bool active; // backend: is_active
  final DateTime createdAt;
  final DateTime startDate; // backend: start_date (required on create)
  final DateTime? endDate;
  final String? disease;

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
    required this.startDate,
    this.endDate,
    this.disease,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as int,
      userId: json['patient_id'] as int,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      schedule: List<String>.from(json['times'] as List? ?? const []),
      notes: json['instructions'] as String?,
      active: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      disease: json['disease'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': schedule,
      'instructions': notes,
      'is_active': active,
      'created_at': createdAt.toIso8601String(),
      'start_date': _dateOnly(startDate),
      'end_date': endDate != null ? _dateOnly(endDate!) : null,
      'disease': disease,
    };
  }

  static String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Medication copyWith({
    int? id,
    int? userId,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? schedule,
    String? notes,
    bool? active,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    String? disease,
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      disease: disease ?? this.disease,
    );
  }
}
