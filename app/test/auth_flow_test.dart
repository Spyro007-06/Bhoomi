import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/main.dart';
import 'package:bhoomi/core/storage/token_storage.dart';
import 'package:bhoomi/core/storage/secure_storage.dart';
import 'package:bhoomi/core/network/api_client.dart';
import 'package:bhoomi/core/network/api_config.dart';
import 'package:bhoomi/models/farmer_profile_models.dart';
import 'package:bhoomi/repositories/auth_repository.dart';
import 'package:bhoomi/repositories/farmer_profile_repository.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/features/onboarding/presentation/phone_auth_screen.dart';
import 'package:bhoomi/features/onboarding/presentation/otp_verify_screen.dart';
import 'package:bhoomi/features/onboarding/presentation/farmer_farm_setup_screen.dart';
import 'package:bhoomi/features/shell/presentation/main_app_shell.dart';
import 'package:bhoomi/widgets/app_button.dart';
import 'package:bhoomi/widgets/app_text_field.dart';
import 'package:bhoomi/providers/storage_providers.dart';

class MockInMemoryStorage extends SecureStorage {
  final Map<String, String> _map = {};
  @override
  Future<void> write({required String key, required String value}) async => _map[key] = value;
  @override
  Future<String?> read({required String key}) async => _map[key];
  @override
  Future<void> delete({required String key}) async => _map.remove(key);
}

class FakeAuthApiClient extends ApiClient {
  FakeAuthApiClient({required TokenStorage tokenStorage})
      : super(config: const ApiConfig(), tokenStorage: tokenStorage);

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dynamic options,
  }) async {
    if (path == '/auth/otp/request') {
      return {
        'request_id': 'req_mock_123',
        'expires_in': 300,
      };
    }
    if (path == '/auth/otp/verify') {
      if (data['otp'] == '123456') {
        return {
          'access_token': 'jwt_mock_access',
          'refresh_token': 'jwt_mock_refresh',
          'user': {
            'id': 'u_farmer_1',
            'phone': '+919876543210',
            'role': 'farmer',
          },
        };
      } else {
        throw Exception('INVALID_OTP');
      }
    }
    return {};
  }
}

/// Fake profile repository for controlling profile availability in tests.
class _FakeProfileRepository implements FarmerProfileRepository {
  final bool hasCompleteProfile;
  final String? profileUserId;

  _FakeProfileRepository({this.hasCompleteProfile = false, this.profileUserId});

  @override
  Future<FarmerProfile?> getProfile(String userId) async {
    if (hasCompleteProfile &&
        (profileUserId == null || userId == profileUserId)) {
      return FarmerProfile(
        farmerId: userId,
        name: 'श्रीकुमार / Shreekumar',
        mobileNumber: '+919876543210',
        preferredLanguage: 'mr',
        farmId: 'f_demo_01',
        latitude: 19.9975,
        longitude: 73.7898,
        region: 'Nashik, Maharashtra',
        farmArea: 2.5,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'canal',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        variety: 'Indrayani',
        growthStage: 'tillering',
        sowingDate: DateTime(2026, 6, 15),
        updatedAt: DateTime(2026, 9, 1),
      );
    }
    return null; // No profile → first-time user
  }

  @override
  Future<FarmerProfile> saveProfile(FarmerProfile profile) async {
    return profile.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> deleteProfile(String userId) async {}
}

void main() {
  group('Authentication Flow Tests (Step 3)', () {
    late MockInMemoryStorage memoryStorage;
    late TokenStorage tokenStorage;
    late FakeAuthApiClient fakeClient;
    late AuthRepository authRepository;

    setUp(() {
      memoryStorage = MockInMemoryStorage();
      tokenStorage = TokenStorage(storage: memoryStorage);
      fakeClient = FakeAuthApiClient(tokenStorage: tokenStorage);
      authRepository = AuthRepositoryImpl(
        apiClient: fakeClient,
        tokenStorage: tokenStorage,
      );
    });

    testWidgets('PhoneAuthScreen renders branding, +91 prefix, and inputs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
          ],
          child: const BhoomiApp(homeOverride: PhoneAuthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Check Branding & Inputs
      expect(find.text('भूमीमध्ये आपले स्वागत आहे'), findsOneWidget);
      expect(find.text('🇮🇳 +91'), findsOneWidget);
      expect(find.byType(AppTextField), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('OTP पाठवा'), findsOneWidget);
    });

    testWidgets('Validates 10-digit phone number and Send OTP button state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
          ],
          child: const BhoomiApp(homeOverride: PhoneAuthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: Send OTP button is disabled (< 10 digits)
      final sendButton = tester.widget<AppButton>(find.byType(AppButton));
      expect(sendButton.onPressed, isNull);

      // Enter 9 digits
      await tester.enterText(find.byType(TextField), '987654321');
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);

      // Enter 10th digit
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();
      expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNotNull);
    });

    testWidgets(
        'Full OTP verification: returning user with complete profile → MainAppShell',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Inject a fake profile repo that returns a complete profile for u_farmer_1
      final fakeProfileRepo = _FakeProfileRepository(
        hasCompleteProfile: true,
        profileUserId: 'u_farmer_1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            farmerProfileRepositoryProvider.overrideWithValue(fakeProfileRepo),
            secureStorageProvider.overrideWithValue(memoryStorage),
          ],
          child: const BhoomiApp(),
        ),
      );
      await tester.pumpAndSettle();

      // If on LandingScreen, tap Start to enter PhoneAuthScreen
      if (find.text('सुरू करा').evaluate().isNotEmpty) {
        await tester.tap(find.text('सुरू करा'));
        await tester.pumpAndSettle();
      }

      // Initially on PhoneAuthScreen
      expect(find.byType(PhoneAuthScreen), findsOneWidget);

      // Enter 10-digit phone number
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      // Tap Send OTP
      await tester.tap(find.text('OTP पाठवा'));
      await tester.pumpAndSettle();

      // Navigated to OtpVerifyScreen
      expect(find.byType(OtpVerifyScreen), findsOneWidget);
      expect(find.text('नंबर पडताळणी करा'), findsOneWidget);
      expect(find.text('पडताळणी करा'), findsOneWidget);

      // Enter 6-digit OTP
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      // Tap Verify OTP and allow async profile load + navigation to settle
      await tester.tap(find.text('पडताळणी करा'));
      await tester.pumpAndSettle();

      // Returning farmer with complete profile → MainAppShell
      expect(find.byType(MainAppShell), findsOneWidget);
      expect(await tokenStorage.hasValidSession(), isTrue);
      expect(await tokenStorage.getAccessToken(), 'jwt_mock_access');
    });

    testWidgets('Displays error on invalid OTP entry',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
          ],
          child: const BhoomiApp(
            homeOverride: OtpVerifyScreen(
              phoneNumber: '+919876543210',
              requestId: 'req_123',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter wrong OTP
      await tester.enterText(find.byType(TextField), '999999');
      await tester.pumpAndSettle();

      // Tap Verify
      await tester.tap(find.text('पडताळणी करा'));
      await tester.pumpAndSettle();

      // Error message is displayed
      expect(find.text('दिलेला OTP चुकीचा आहे. कृपया तपासून पुन्हा टाका.'), findsOneWidget);
    });

    testWidgets(
        'Full OTP verification: first-time user (no profile) → FarmerFarmSetupScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Inject a fake profile repo that returns null (no saved profile)
      final fakeProfileRepo =
          _FakeProfileRepository(hasCompleteProfile: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            farmerProfileRepositoryProvider.overrideWithValue(fakeProfileRepo),
            secureStorageProvider.overrideWithValue(memoryStorage),
          ],
          child: const BhoomiApp(),
        ),
      );
      await tester.pumpAndSettle();

      // If on LandingScreen, tap Start to enter PhoneAuthScreen
      if (find.text('सुरू करा').evaluate().isNotEmpty) {
        await tester.tap(find.text('सुरू करा'));
        await tester.pumpAndSettle();
      }

      // Enter 10-digit phone number
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      // Tap Send OTP
      await tester.tap(find.text('OTP पाठवा'));
      await tester.pumpAndSettle();

      // Enter 6-digit OTP
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      // Tap Verify OTP and allow async profile load + navigation to settle
      await tester.tap(find.text('पडताळणी करा'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // First-time user with no saved profile → onboarding setup screen
      expect(find.byType(FarmerFarmSetupScreen), findsOneWidget);
      expect(await tokenStorage.hasValidSession(), isTrue);
    });
  });
}
