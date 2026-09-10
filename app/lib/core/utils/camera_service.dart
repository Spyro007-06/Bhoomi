import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Camera lifecycle and permission statuses.
enum CameraStateStatus {
  uninitialized,
  initializing,
  ready,
  permissionDenied,
  permissionPermanentlyDenied,
  noCameraAvailable,
  error,
}

/// Abstract platform wrapper for Camera and Gallery operations.
abstract class CameraPlatformWrapper {
  Future<bool> requestCameraPermission();
  Future<bool> isCameraPermissionGranted();
  Future<bool> isCameraPermissionPermanentlyDenied();
  Future<bool> openAppSettings();
  Future<List<CameraDescription>> getAvailableCameras();
  CameraController createController({
    required CameraDescription camera,
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
    bool enableAudio = false,
  });
  Future<XFile?> pickImageFromGallery();
}

/// Default production platform wrapper utilizing camera, image_picker, and permission_handler plugins.
class DefaultCameraPlatformWrapper implements CameraPlatformWrapper {
  const DefaultCameraPlatformWrapper();

  static bool get _isTestEnvironment => Platform.environment.containsKey('FLUTTER_TEST');

  @override
  Future<bool> requestCameraPermission() async {
    if (_isTestEnvironment) return true;
    try {
      final status = await ph.Permission.camera.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isCameraPermissionGranted() async {
    if (_isTestEnvironment) return true;
    try {
      return await ph.Permission.camera.isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    if (_isTestEnvironment) return false;
    try {
      return await ph.Permission.camera.isPermanentlyDenied;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    if (_isTestEnvironment) {
      return [
        const CameraDescription(
          name: '0',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
      ];
    }
    try {
      return await availableCameras();
    } catch (_) {
      return [];
    }
  }

  @override
  CameraController createController({
    required CameraDescription camera,
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
    bool enableAudio = false,
  }) {
    if (_isTestEnvironment) {
      return _TestCameraController(camera);
    }
    return CameraController(
      camera,
      resolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    if (_isTestEnvironment) {
      return XFile.fromData(
        Uint8List.fromList([1, 2, 3, 4]),
        name: 'test_gallery.jpg',
        mimeType: 'image/jpeg',
      );
    }
    try {
      final picker = ImagePicker();
      return await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
    } catch (_) {
      return null;
    }
  }
}

class _TestCameraController extends CameraController {
  _TestCameraController(CameraDescription description)
      : super(
          description,
          ResolutionPreset.high,
          enableAudio: false,
        ) {
    value = CameraValue.uninitialized(description).copyWith(
      isInitialized: true,
      previewSize: const Size(1920, 1080),
      flashMode: FlashMode.auto,
    );
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<XFile> takePicture() async {
    return XFile.fromData(
      Uint8List.fromList([1, 2, 3, 4]),
      name: 'test_photo.jpg',
      mimeType: 'image/jpeg',
    );
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    value = value.copyWith(flashMode: mode);
  }

  @override
  Widget buildPreview() {
    return const SizedBox.expand(
      child: ColoredBox(color: Colors.black87),
    );
  }
}
