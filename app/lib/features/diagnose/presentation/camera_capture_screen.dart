import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/utils/camera_service.dart';
import '../../../core/utils/image_compression_service.dart';
import '../../../core/error/app_exception.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/language_selector_button.dart';
import '../../../models/inspection_target.dart';
import 'diagnosis_controller.dart';
import 'image_preview_screen.dart';

/// Redesigned, farmer-centric Camera Capture Screen for Crop Diagnosis.
///
/// Provides a clear, uncluttered viewfinder with a single contextual guidance instruction,
/// dominant primary capture button, secondary gallery/flash actions, and friendly
/// non-technical fallback states.
class CameraCaptureScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final CameraPlatformWrapper? cameraPlatformWrapper;
  final ImageCompressor? imageCompressor;
  final CameraController? cameraControllerOverride;
  final String? contextualGuidance;
  final InspectionTarget? inspectionTarget;
  final String? conversationContext;

  const CameraCaptureScreen({
    super.key,
    this.onBack,
    this.cameraPlatformWrapper,
    this.imageCompressor,
    this.cameraControllerOverride,
    this.contextualGuidance,
    this.inspectionTarget,
    this.conversationContext,
  });

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  CameraStateStatus _cameraStatus = CameraStateStatus.uninitialized;
  String? _errorMessage;
  bool _isProcessingCapture = false;
  FlashMode _currentFlashMode = FlashMode.auto;

  late final CameraPlatformWrapper _cameraPlatform;
  late final ImageCompressor _imageCompressor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraPlatform = widget.cameraPlatformWrapper ?? const DefaultCameraPlatformWrapper();
    _imageCompressor = widget.imageCompressor ?? const DefaultImageCompressor();

    if (widget.cameraControllerOverride != null) {
      _cameraController = widget.cameraControllerOverride;
      _cameraStatus = CameraStateStatus.ready;
    } else {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.cameraControllerOverride == null) {
      _cameraController?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.cameraControllerOverride != null) return;

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Free camera hardware resources while app is backgrounded
      controller.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() => _cameraStatus = CameraStateStatus.uninitialized);
      }
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize camera upon user returning to app
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (!mounted) return;
    setState(() {
      _cameraStatus = CameraStateStatus.initializing;
      _errorMessage = null;
    });

    try {
      // 1. Check & request camera runtime permission
      final isPermanentlyDenied = await _cameraPlatform.isCameraPermissionPermanentlyDenied();
      if (isPermanentlyDenied) {
        if (mounted) {
          setState(() => _cameraStatus = CameraStateStatus.permissionPermanentlyDenied);
        }
        return;
      }

      var isGranted = await _cameraPlatform.isCameraPermissionGranted();
      if (!isGranted) {
        isGranted = await _cameraPlatform.requestCameraPermission();
      }

      if (!isGranted) {
        final permDeniedForever = await _cameraPlatform.isCameraPermissionPermanentlyDenied();
        if (mounted) {
          setState(() {
            _cameraStatus = permDeniedForever
                ? CameraStateStatus.permissionPermanentlyDenied
                : CameraStateStatus.permissionDenied;
          });
        }
        return;
      }

      // 2. Discover available cameras on device
      final cameras = await _cameraPlatform.getAvailableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraStatus = CameraStateStatus.noCameraAvailable);
        }
        return;
      }

      // 3. Select back/rear camera if available, otherwise first camera
      final selectedCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // 4. Dispose previous controller if any
      await _cameraController?.dispose();

      // 5. Initialize camera controller
      final controller = _cameraPlatform.createController(
        camera: selectedCamera,
        resolutionPreset: ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _cameraStatus = CameraStateStatus.ready;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraStatus = CameraStateStatus.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _onCapturePressed() async {
    if (_isProcessingCapture) return;

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      final strings = ref.read(stringsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.cameraInitializing)),
      );
      return;
    }

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    setState(() => _isProcessingCapture = true);

    try {
      // 1. Capture real photograph through camera hardware
      final xFile = await controller.takePicture();
      final rawBytes = await xFile.readAsBytes();

      if (rawBytes.isEmpty) {
        throw const CameraServiceException(
          message: 'Captured image was empty. Please try again.',
        );
      }

      // 2. Compress photo for optimal network transmission and ML diagnosis accuracy
      final compressedBytes = await _imageCompressor.compress(bytes: rawBytes);

      // 3. Clean up temporary photo file on disk
      try {
        final path = xFile.path;
        if (path.isNotEmpty) {
          final tempFile = File(path);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      } catch (_) {}

      // 4. Update Riverpod diagnosis state
      ref.read(diagnosisControllerProvider.notifier).setImage(compressedBytes);

      setState(() => _isProcessingCapture = false);

      // 5. Navigate to preview and confirmation screen
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imageBytes: compressedBytes),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingCapture = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      FlashMode nextMode;
      switch (_currentFlashMode) {
        case FlashMode.auto:
          nextMode = FlashMode.always;
          break;
        case FlashMode.always:
          nextMode = FlashMode.off;
          break;
        case FlashMode.off:
        default:
          nextMode = FlashMode.auto;
          break;
      }
      await controller.setFlashMode(nextMode);
      if (mounted) {
        setState(() => _currentFlashMode = nextMode);
      }
    } catch (_) {
      // Flash mode not supported by device hardware
    }
  }

  void _onGalleryPressed() {
    final strings = ref.read(stringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.galleryButton),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final singleInstruction = widget.contextualGuidance ??
        widget.inspectionTarget?.getLocalizedPrompt(strings) ??
        strings.cameraInstruction;

    return Scaffold(
      backgroundColor: AppColors.soilCharcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: strings.backButton,
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: strings.backButton,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        title: Text(
          strings.cameraTitle,
          style: AppTypography.screenTitle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          LanguageSelectorButton(isDarkBackground: true),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ONE Concise Guidance Header (No duplicate banners or scanner text)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l16,
                vertical: AppSpacing.s8,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l16,
                  vertical: AppSpacing.s10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.inspectionTarget?.framingIcon ?? Icons.eco_rounded,
                      color: AppColors.primaryLight,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.m12),
                    Expanded(
                      child: Text(
                        singleInstruction,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Camera Viewfinder (Clean framing, rounded corners, no scanner reticles)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m16,
                  vertical: AppSpacing.s8,
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          _buildCameraViewfinderContent(strings),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Controls Bar (Dominant capture with secondary actions)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l24,
                vertical: AppSpacing.m16,
              ),
              color: Colors.black.withValues(alpha: 0.45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Secondary Gallery Button
                  Semantics(
                    label: strings.galleryButton,
                    button: true,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        iconSize: 24,
                        icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                        onPressed: _onGalleryPressed,
                      ),
                    ),
                  ),

                  // Dominant Primary Shutter Capture Button (76dp)
                  Semantics(
                    label: strings.semanticsCapturePhoto,
                    button: true,
                    child: GestureDetector(
                      onTap: _isProcessingCapture ? null : _onCapturePressed,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ricePaper,
                          border: Border.all(color: AppColors.forest, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.forest,
                            ),
                            child: _isProcessingCapture
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Secondary Flash Mode Toggle Button
                  Semantics(
                    label: strings.semanticsToggleFlash,
                    button: true,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        iconSize: 24,
                        icon: Icon(
                          _currentFlashMode == FlashMode.always
                              ? Icons.flash_on_rounded
                              : (_currentFlashMode == FlashMode.off
                                  ? Icons.flash_off_rounded
                                  : Icons.flash_auto_rounded),
                          color: Colors.white,
                        ),
                        onPressed: _toggleFlash,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraViewfinderContent(dynamic strings) {
    if (_cameraStatus == CameraStateStatus.ready &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize?.height ?? 1,
              height: _cameraController!.value.previewSize?.width ?? 1,
              child: _cameraController!.buildPreview(),
            ),
          ),
          // Subtle, calm watermark icon indicating inspection target without fake AI lines
          Center(
            child: Icon(
              widget.inspectionTarget?.framingIcon ?? Icons.eco_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ],
      );
    }

    if (_cameraStatus == CameraStateStatus.initializing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 3,
            ),
            const SizedBox(height: AppSpacing.m16),
            Text(
              strings.cameraInitializing,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_cameraStatus == CameraStateStatus.permissionDenied) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l24, vertical: AppSpacing.m16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.turmeric.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.turmeric,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.m16),
            Text(
              strings.cameraPermissionRequired,
              style: AppTypography.subheading.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              strings.cameraPermissionRequiredDesc,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l20),
            AppButton.primary(
              label: strings.grantPermissionButton,
              onPressed: _initializeCamera,
            ),
          ],
        ),
      );
    }

    if (_cameraStatus == CameraStateStatus.permissionPermanentlyDenied) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l24, vertical: AppSpacing.m16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.turmeric.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.turmeric,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.m16),
            Text(
              strings.cameraPermissionDeniedForever,
              style: AppTypography.subheading.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              strings.cameraPermissionDeniedForeverDesc,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l20),
            AppButton.primary(
              label: strings.openSettingsButton,
              onPressed: () => _cameraPlatform.openAppSettings(),
            ),
          ],
        ),
      );
    }

    if (_cameraStatus == CameraStateStatus.noCameraAvailable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l24, vertical: AppSpacing.m16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.turmeric.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                color: AppColors.turmeric,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.m16),
            Text(
              strings.cameraUnavailable,
              style: AppTypography.subheading.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              strings.cameraUnavailableDesc,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l20),
            AppButton.primary(
              label: strings.galleryButton,
              onPressed: _onGalleryPressed,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l24, vertical: AppSpacing.m16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.danger.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.m16),
          Text(
            strings.cameraError,
            style: AppTypography.subheading.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            _errorMessage ?? strings.cameraErrorDesc,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.l20),
          AppButton.primary(
            label: strings.tryAgainButton,
            onPressed: _initializeCamera,
          ),
        ],
      ),
    );
  }
}
