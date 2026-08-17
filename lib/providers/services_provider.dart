import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/services/api_service.dart';
import 'package:noskipai/services/camera_service.dart';
import 'package:noskipai/services/tts_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService();
});
