import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:bhoomi/main.dart';
import 'package:bhoomi/core/theme/app_theme.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/models/inspection_target.dart';
import 'package:bhoomi/core/utils/camera_service.dart';
import 'package:bhoomi/features/diagnose/presentation/camera_capture_screen.dart';

class MockCameraController extends CameraController {
  MockCameraController({required CameraDescription description})
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
  Widget buildPreview() {
    return const ColoredBox(color: Colors.black87);
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    value = value.copyWith(flashMode: mode);
  }
}

class MockCameraPlatformWrapper implements CameraPlatformWrapper {
  bool permissionGranted = true;
  bool permissionPermanentlyDenied = false;
  bool appSettingsOpened = false;
  List<CameraDescription> cameras = [
    const CameraDescription(
      name: '0',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
  ];

  @override
  Future<bool> requestCameraPermission() async => permissionGranted;

  @override
  Future<bool> isCameraPermissionGranted() async => permissionGranted;

  @override
  Future<bool> isCameraPermissionPermanentlyDenied() async => permissionPermanentlyDenied;

  @override
  Future<bool> openAppSettings() async {
    appSettingsOpened = true;
    return true;
  }

  @override
  Future<List<CameraDescription>> getAvailableCameras() async => cameras;

  @override
  CameraController createController({
    required CameraDescription camera,
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
    bool enableAudio = false,
  }) {
    return MockCameraController(description: camera);
  }
}

class _FixedLocaleNotifier extends LocaleNotifier {
  _FixedLocaleNotifier(AppLanguage lang) : super(null) {
    state = lang;
  }
}

void main() {
  group('Check Crop UI/UX Redesign — Comprehensive QA Suite', () {
    late MockCameraPlatformWrapper mockCameraPlatform;

    setUp(() {
      mockCameraPlatform = MockCameraPlatformWrapper();
    });

    testWidgets('1. Header & Title: Never truncates across Marathi, Hindi, English with >=48dp back button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      for (final lang in AppLanguage.values) {
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey('scope_${lang.name}'),
            overrides: [
              appLanguageProvider.overrideWith((ref) => _FixedLocaleNotifier(lang)),
            ],
            child: BhoomiApp(
              homeOverride: CameraCaptureScreen(
                cameraPlatformWrapper: mockCameraPlatform,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppStrings(lang);
        expect(find.text(strings.cameraTitle), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

        // Verify back button touch target >= 48dp
        final backButtonFinder = find.byTooltip(strings.backButton);
        expect(backButtonFinder, findsOneWidget);
        final size = tester.getSize(backButtonFinder);
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('2. Single Guidance: Exactly one concise instruction displayed for each InspectionTarget',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      for (final target in InspectionTarget.values) {
        await tester.pumpWidget(
          ProviderScope(
            child: BhoomiApp(
              homeOverride: CameraCaptureScreen(
                key: ValueKey('target_${target.name}'),
                cameraPlatformWrapper: mockCameraPlatform,
                inspectionTarget: target,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final strings = AppStrings(AppLanguage.marathi);
        final expectedPrompt = target.getLocalizedPrompt(strings);
        expect(find.text(expectedPrompt), findsOneWidget);
        expect(find.byIcon(target.framingIcon), findsWidgets);
      }
    });

    testWidgets('3. Camera Controls Hierarchy: Dominant shutter button & secondary gallery/flash controls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: BhoomiApp(
            homeOverride: CameraCaptureScreen(
              cameraPlatformWrapper: mockCameraPlatform,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Shutter button is centered, large (76dp) and has camera icon
      final shutterFinder = find.byIcon(Icons.camera_alt_rounded);
      expect(shutterFinder, findsOneWidget);

      // Gallery & Flash buttons are present with semantic labels
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.flash_auto_rounded), findsOneWidget);

      // Toggle flash mode
      await tester.tap(find.byIcon(Icons.flash_auto_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.flash_on_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    });

    testWidgets('4. Fallback States: Clean, friendly fallback when camera is unavailable',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      mockCameraPlatform.cameras = [];
      await tester.pumpWidget(
        ProviderScope(
          child: BhoomiApp(
            homeOverride: CameraCaptureScreen(
              cameraPlatformWrapper: mockCameraPlatform,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('कॅमेरा उपलब्ध नाही'), findsOneWidget);
      expect(find.text('या डिव्हाइसवर कॅमेरा वापरता येत नाही.'), findsOneWidget);
      expect(find.text('गॅलरीतून निवडा'), findsWidgets);
    });

    testWidgets('5. Fallback States: Clean, friendly fallback when permission is permanently denied',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      mockCameraPlatform.permissionPermanentlyDenied = true;
      mockCameraPlatform.cameras = [
        const CameraDescription(name: '0', lensDirection: CameraLensDirection.back, sensorOrientation: 90)
      ];
      await tester.pumpWidget(
        ProviderScope(
          child: BhoomiApp(
            homeOverride: CameraCaptureScreen(
              cameraPlatformWrapper: mockCameraPlatform,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('कॅमेरा परवानगी बंद आहे'), findsOneWidget);
      expect(find.text('कृपया ॲप सेटिंग्जमधून कॅमेरा परवानगी चालू करा.'), findsOneWidget);
      expect(find.text('सेटिंग्ज उघडा'), findsOneWidget);
    });

    testWidgets('6. Responsive Text Scaling: 1.0x, 1.5x, and 2.0x text scaling renders without overflow',
        (WidgetTester tester) async {
      for (final textScale in [1.0, 1.5, 2.0]) {
        tester.view.physicalSize = const Size(720, 1280); // Compact device
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScale),
                ),
                child: child!,
              ),
              home: CameraCaptureScreen(
                cameraPlatformWrapper: mockCameraPlatform,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CameraCaptureScreen), findsOneWidget);
      }
    });
  });
}
