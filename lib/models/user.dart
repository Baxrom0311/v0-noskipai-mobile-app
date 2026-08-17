// Matches schemas/user.py UserResponse / response_utils.serialize_user on the
// real backend. The backend has no separate first/last name or email field —
// only a single `full_name` and a `phone` (+998XXXXXXXXX) used for login.
class User {
  final int id;
  final String fullName;
  final String phone;
  final String? telegramId;
  final String role;
  final int? age;
  final String? gender;
  final String language;
  final String timezone;
  final bool privacyMode;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.telegramId,
    required this.role,
    this.age,
    this.gender,
    required this.language,
    required this.timezone,
    required this.privacyMode,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      telegramId: json['telegram_id'] as String?,
      role: json['role'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      language: json['language'] as String? ?? 'uz',
      timezone: json['timezone'] as String? ?? 'Asia/Tashkent',
      privacyMode: json['privacy_mode'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'telegram_id': telegramId,
      'role': role,
      'age': age,
      'gender': gender,
      'language': language,
      'timezone': timezone,
      'privacy_mode': privacyMode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? telegramId,
    String? role,
    int? age,
    String? gender,
    String? language,
    String? timezone,
    bool? privacyMode,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      telegramId: telegramId ?? this.telegramId,
      role: role ?? this.role,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      privacyMode: privacyMode ?? this.privacyMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
