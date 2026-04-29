import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/services/camera_service.dart';
import 'package:noskipai/services/tts_service.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService();
});
