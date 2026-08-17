import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noskipai/config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  late Dio _dio;
  late SharedPreferences _prefs;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _prefs = await SharedPreferences.getInstance();
          final token = _prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _prefs.remove('auth_token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // --- Auth ---
  //
  // Backend ground truth (routers/auth.py, schemas/user.py):
  //   POST /auth/login  body: {phone, password}            (phone must match +998XXXXXXXXX)
  //   POST /auth/register body: UserCreate {full_name, phone, password, role,
  //                              age?, gender?, language, timezone}
  //   Both return {"data": {"user": {...}, "access_token": "...", "token_type": "bearer"}}

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('auth_token', data['access_token'] as String);
      return data;
    }
    throw DioException(requestOptions: response.requestOptions, response: response);
  }

  /// [role] must be one of 'patient' | 'family' | 'doctor' per UserCreate.
  /// Defaults to 'patient' since the current registration UI is patient-facing
  /// and does not collect a role.
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String password,
    String role = 'patient',
    int? age,
    String? gender,
    String language = 'uz',
    String timezone = 'Asia/Tashkent',
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'full_name': fullName,
      'phone': phone,
      'password': password,
      'role': role,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      'language': language,
      'timezone': timezone,
    });
    if (response.statusCode == 201) {
      final data = response.data['data'] as Map<String, dynamic>;
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('auth_token', data['access_token'] as String);
      return data;
    }
    throw DioException(requestOptions: response.requestOptions, response: response);
  }

  Future<void> logout() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.remove('auth_token');
  }

  // --- Medications ---
  //
  // Backend ground truth (routers/medications.py, schemas/medication.py):
  //   POST /medications body: MedicationCreate {name, dosage, frequency,
  //     times: [ "HH:MM", ... ], start_date: "YYYY-MM-DD", end_date?, instructions?, disease?}
  //   GET  /medications -> {"data": [Medication, ...]}
  //   Responses wrap the medication object as {"data": {...}}.

  Future<List<dynamic>> getMedications() async {
    final response = await _dio.get('/medications');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> schedule,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
    String? disease,
  }) async {
    final response = await _dio.post('/medications', data: {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': schedule,
      'start_date': _formatDate(startDate),
      if (endDate != null) 'end_date': _formatDate(endDate),
      if (notes != null) 'instructions': notes,
      if (disease != null) 'disease': disease,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // --- Adherence ---
  //
  // Backend ground truth (routers/adherence.py, schemas/adherence.py):
  //   POST /adherence/log    body: AdherenceLogCreate {medication_id, scheduled_time,
  //                                 taken_at, mood?, side_effects?, notes?}
  //   POST /adherence/missed body: AdherenceMissedCreate {medication_id, scheduled_time, notes?}
  //   GET  /adherence/history -> {"data": [AdherenceLog, ...]}

  Future<void> logAdherence(
    String medicationId,
    String status,
    String scheduledTime,
    DateTime date,
  ) async {
    final medId = int.parse(medicationId);
    if (status == 'missed') {
      await _dio.post('/adherence/missed', data: {
        'medication_id': medId,
        'scheduled_time': scheduledTime,
      });
    } else {
      await _dio.post('/adherence/log', data: {
        'medication_id': medId,
        'scheduled_time': scheduledTime,
        'taken_at': date.toIso8601String(),
      });
    }
  }

  Future<List<dynamic>> getAdherenceHistory({required int days}) async {
    final response = await _dio.get('/adherence/history', queryParameters: {'days': days});
    return response.data['data'] ?? [];
  }

  // --- AI Chat ---
  // Confirmed against routers/ai.py (prefix "/ai"): paths below are already correct.

  Future<Map<String, dynamic>> sendChatMessage(String content) async {
    final response = await _dio.post('/ai/chat', data: {'message': content});
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getChatHistory() async {
    final response = await _dio.get('/ai/chat/history');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> submitFeedback({
    required String messageContent,
    required String rating,
    String? comment,
  }) async {
    final response = await _dio.post('/ai/feedback', data: {
      'message_content': messageContent,
      'rating': rating,
      'comment': comment,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  // --- Safety Signals ---
  // Confirmed against routers/ai.py: GET /ai/my-safety-signals -> {"data": [...]}.

  Future<List<dynamic>> getMySafetySignals() async {
    final response = await _dio.get('/ai/my-safety-signals');
    return response.data['data'] ?? [];
  }
}
