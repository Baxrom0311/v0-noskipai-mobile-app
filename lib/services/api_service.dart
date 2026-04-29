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

    // Add interceptor for JWT token
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
            // Token expired, handle logout
            _prefs.remove('auth_token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        _prefs = await SharedPreferences.getInstance();
        await _prefs.setString('auth_token', response.data['access_token']);
        return response.data;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Login failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String? phoneNumber,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        },
      );
      
      if (response.statusCode == 201) {
        _prefs = await SharedPreferences.getInstance();
        await _prefs.setString('auth_token', response.data['access_token']);
        return response.data;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Registration failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMedications() async {
    try {
      final response = await _dio.get('/medications');
      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to fetch medications',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> schedule,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/medications',
        data: {
          'name': name,
          'dosage': dosage,
          'frequency': frequency,
          'schedule': schedule,
          'notes': notes,
        },
      );
      
      if (response.statusCode == 201) {
        return response.data;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to add medication',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logAdherence(
    String medicationId,
    String status,
    String scheduledTime,
    DateTime date,
  ) async {
    try {
      final response = await _dio.post(
        '/adherence',
        data: {
          'medication_id': medicationId,
          'status': status,
          'scheduled_time': scheduledTime,
          'date': date.toIso8601String(),
        },
      );
      
      if (response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to log adherence',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAdherenceHistory({
    required int days,
  }) async {
    try {
      final response = await _dio.get(
        '/adherence/history',
        queryParameters: {'days': days},
      );
      
      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to fetch adherence history',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendChatMessage(String content) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {
          'content': content,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to send message',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getChatHistory() async {
    try {
      final response = await _dio.get('/chat/history');
      
      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to fetch chat history',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _prefs.remove('auth_token');
    } catch (e) {
      rethrow;
    }
  }
}
