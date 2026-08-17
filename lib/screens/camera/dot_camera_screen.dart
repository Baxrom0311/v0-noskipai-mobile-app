import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:noskipai/config/app_theme.dart';
import 'package:noskipai/providers/services_provider.dart';
import 'package:noskipai/widgets/gradient_card.dart';

class DOTCameraScreen extends ConsumerStatefulWidget {
  final String medicationName;

  const DOTCameraScreen({
    Key? key,
    required this.medicationName,
  }) : super(key: key);

  @override
  ConsumerState<DOTCameraScreen> createState() => _DOTCameraScreenState();
}

class _DOTCameraScreenState extends ConsumerState<DOTCameraScreen> {
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isPhotoTaken = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraService = ref.read(cameraServiceProvider);
      final controller = await cameraService.initializeCamera();
      
      if (controller != null && mounted) {
        setState(() {
          _cameraController = controller;
          _isInitializing = false;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final cameraService = ref.read(cameraServiceProvider);
      final image = await cameraService.takePicture();
      
      if (image != null && mounted) {
        setState(() => _isPhotoTaken = true);
        
        // Show confirmation dialog
        _showPhotoConfirmation(image.path);
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  void _showPhotoConfirmation(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        title: const Text('Confirm Medication Intake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(imagePath),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              'You took ${widget.medicationName}. Is this correct?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isPhotoTaken = false);
            },
            child: const Text('Retake'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directly Observed Therapy'),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: Text('Failed to initialize camera'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CameraPreview(_cameraController!),
              // Camera overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: CameraOverlayPainter(),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.cardBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Taking Photo of: ${widget.medicationName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Please position the medication clearly in frame and ensure good lighting.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  onPressed: _takePhoto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CameraOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const radius = 80.0;

    // Draw circle overlay
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw corner markers
    const cornerLength = 20.0;
    const cornerStroke = 4.0;
    
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = cornerStroke;

    // Top-left
    canvas.drawLine(
      Offset(centerX - radius - cornerLength, centerY - radius),
      Offset(centerX - radius, centerY - radius),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - radius, centerY - radius - cornerLength),
      Offset(centerX - radius, centerY - radius),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(centerX + radius + cornerLength, centerY - radius),
      Offset(centerX + radius, centerY - radius),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + radius, centerY - radius - cornerLength),
      Offset(centerX + radius, centerY - radius),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(centerX - radius - cornerLength, centerY + radius),
      Offset(centerX - radius, centerY + radius),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - radius, centerY + radius + cornerLength),
      Offset(centerX - radius, centerY + radius),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(centerX + radius + cornerLength, centerY + radius),
      Offset(centerX + radius, centerY + radius),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + radius, centerY + radius + cornerLength),
      Offset(centerX + radius, centerY + radius),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CameraOverlayPainter oldDelegate) => false;
}
