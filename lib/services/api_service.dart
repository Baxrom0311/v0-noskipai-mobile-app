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

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200) {
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('auth_token', response.data['access_token']);
      return response.data;
    }
    throw DioException(requestOptions: response.requestOptions, response: response);
  }

  Future<Map<String, dynamic>> register(
    String email, String password, String firstName, String lastName, String? phoneNumber,
  ) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
    });
    if (response.statusCode == 201) {
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('auth_token', response.data['access_token']);
      return response.data;
    }
    throw DioException(requestOptions: response.requestOptions, response: response);
  }

  Future<void> logout() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.remove('auth_token');
  }

  // --- Medications ---

  Future<List<dynamic>> getMedications() async {
    final response = await _dio.get('/medications');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> schedule,
    String? notes,
  }) async {
    final response = await _dio.post('/medications', data: {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'schedule': schedule,
      'notes': notes,
    });
    return response.data;
  }

  // --- Adherence ---

  Future<void> logAdherence(String medicationId, String status, String scheduledTime, DateTime date) async {
    await _dio.post('/adherence', data: {
      'medication_id': medicationId,
      'status': status,
      'scheduled_time': scheduledTime,
      'date': date.toIso8601String(),
    });
  }

  Future<List<dynamic>> getAdherenceHistory({required int days}) async {
    final response = await _dio.get('/adherence/history', queryParameters: {'days': days});
    return response.data['data'] ?? [];
  }

  // --- AI Chat ---

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

  Future<List<dynamic>> getMySafetySignals() async {
    final response = await _dio.get('/ai/my-safety-signals');
    return response.data['data'] ?? [];
  }
}
