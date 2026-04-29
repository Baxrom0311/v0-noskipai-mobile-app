import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _imagePicker = ImagePicker();
  late CameraController _cameraController;
  List<CameraDescription> cameras = [];

  Future<void> initializeCameras() async {
    cameras = await availableCameras();
  }

  Future<CameraController?> initializeCamera() async {
    if (cameras.isEmpty) {
      await initializeCameras();
    }

    try {
      final camera = cameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
      );

      await _cameraController.initialize();
      return _cameraController;
    } catch (e) {
      print('Error initializing camera: $e');
      return null;
    }
  }

  CameraController get cameraController => _cameraController;

  Future<XFile?> takePicture() async {
    try {
      final image = await _cameraController.takePicture();
      return image;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<void> disposeCameraController() async {
    if (_cameraController.value.isInitialized) {
      await _cameraController.dispose();
    }
  }
}
