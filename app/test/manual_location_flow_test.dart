import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/core/utils/location_service.dart';
import 'package:bhoomi/core/theme/app_theme.dart';
import 'package:bhoomi/models/farmer_profile_models.dart';
import 'package:bhoomi/models/farm_models.dart';
import 'package:bhoomi/models/auth_models.dart';
import 'package:bhoomi/providers/farmer_profile_providers.dart';
import 'package:bhoomi/providers/auth_providers.dart';
import 'package:bhoomi/providers/farm_providers.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/providers/storage_providers.dart';
import 'package:bhoomi/repositories/farmer_profile_repository.dart';
import 'package:bhoomi/repositories/auth_repository.dart';
import 'package:bhoomi/repositories/farm_repository.dart';
import 'package:bhoomi/features/onboarding/presentation/farmer_farm_setup_screen.dart';
import 'package:bhoomi/features/onboarding/presentation/farm_setup_screen.dart';
import 'package:bhoomi/core/storage/token_storage.dart';
import 'package:bhoomi/core/storage/secure_storage.dart';
import 'package:bhoomi/repositories/farmer_profile_repository.dart';

class _MockStorage extends SecureStorage {
  final Map<String, String> _map = {};
  @override
  Future<void> write({required String key, required String value}) async => _map[key] = value;
  @override
  Future<String?> read({required String key}) async => _map[key];
  @override
  Future<void> delete({required String key}) async => _map.remove(key);
}

// Test Fakes
class _FakeProfileRepository implements FarmerProfileRepository {
  FarmerProfile? savedProfile;

  @override
  Future<FarmerProfile?> getProfile(String userId) async => savedProfile;

  @override
  Future<FarmerProfile> saveProfile(FarmerProfile profile) async {
    savedProfile = profile;
    return profile;
  }

  @override
  Future<void> deleteProfile(String userId) async {
    savedProfile = null;
  }
}

class _FakeAuthRepository implements AuthRepository {
  final UserModel _user = const UserModel(id: 'u_test_farmer', phone: '+919876543210', role: 'farmer');

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<UserModel?> getCurrentUser() async => _user;

  @override
  Future<OtpRequestResponse> requestOtp({required String phone}) async =>
      const OtpRequestResponse(requestId: 'req_fake', expiresIn: 300);

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String requestId,
    required String otp,
  }) async => OtpVerifyResponse(
        accessToken: 'token_fake',
        refreshToken: 'refresh_fake',
        user: _user,
      );

  @override
  Future<OtpVerifyResponse> loginAsDemo() async => OtpVerifyResponse(
        accessToken: 'token_demo',
        refreshToken: 'refresh_demo',
        user: _user,
      );

  @override
  Future<void> logout() async {}
}

class _FakeFarmRepository implements FarmRepository {
  FarmModel? lastFarm;

  @override
  Future<FarmModel> createFarm({
    required String crop,
    String? variety,
    required String growthStage,
    required String region,
    required GeoPoint location,
  }) async {
    lastFarm = FarmModel(
      id: 'f_manual_test_1',
      crop: crop,
      variety: variety,
      growthStage: growthStage,
      region: region,
      location: location,
    );
    return lastFarm!;
  }

  @override
  Future<FarmModel> getFarm(String farmId) async => lastFarm!;
  @override
  Future<FarmSummaryModel> getFarmSummary(String farmId) async =>
      throw UnimplementedError();
  @override
  Future<FarmModel> updateFarm(String farmId, Map<String, dynamic> updates) async =>
      throw UnimplementedError();
}

class _DisabledLocationService extends LocationService {
  @override
  Future<LocationResult> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return const LocationResult(
      status: LocationServiceStatus.denied,
      errorMessage: 'GPS permission denied',
    );
  }
}

void main() {
  group('LocationService Regional Estimation Tests', () {
    test('estimates coordinates accurately for Tamil Nadu regions', () {
      final cbe = LocationService.estimateCoordinatesForRegion('Coimbatore, Tamil Nadu');
      expect(cbe.lat, closeTo(11.0168, 0.01));
      expect(cbe.lng, closeTo(76.9558, 0.01));

      final chennai = LocationService.estimateCoordinatesForRegion('Chennai');
      expect(chennai.lat, closeTo(13.0827, 0.01));

      final madurai = LocationService.estimateCoordinatesForRegion('Madurai, TN');
      expect(madurai.lat, closeTo(9.9252, 0.01));
    });

    test('estimates coordinates accurately for Maharashtra regions', () {
      final nashik = LocationService.estimateCoordinatesForRegion('Nashik, Maharashtra');
      expect(nashik.lat, closeTo(19.9975, 0.01));
      expect(nashik.lng, closeTo(73.7898, 0.01));

      final pune = LocationService.estimateCoordinatesForRegion('Pune');
      expect(pune.lat, closeTo(18.5204, 0.01));

      final nagpur = LocationService.estimateCoordinatesForRegion('Nagpur');
      expect(nagpur.lat, closeTo(21.1458, 0.01));
    });

    test('estimates coordinates accurately for Karnataka and other regions', () {
      final dharwad = LocationService.estimateCoordinatesForRegion('Dharwad, Karnataka');
      expect(dharwad.lat, closeTo(15.4589, 0.01));

      final blr = LocationService.estimateCoordinatesForRegion('Bengaluru, KA');
      expect(blr.lat, closeTo(12.9716, 0.01));

      final hyd = LocationService.estimateCoordinatesForRegion('Hyderabad');
      expect(hyd.lat, closeTo(17.3850, 0.01));
    });

    test('falls back safely for unknown custom regions', () {
      final fallback = LocationService.estimateCoordinatesForRegion('My Rural Village');
      expect(fallback.lat, isNotNull);
      expect(fallback.lng, isNotNull);
    });
  });

  group('FarmerFarmSetupScreen — Manual Location Flow', () {
    testWidgets('allows farmer to switch to manual location and save without GPS',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final profileRepo = _FakeProfileRepository();
      final authRepo = _FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            farmerProfileRepositoryProvider.overrideWithValue(profileRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: FarmerFarmSetupScreen(
              isFirstTimeOnboarding: true,
              locationService: _DisabledLocationService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name
      final nameFields = find.byType(TextField);
      expect(nameFields, findsWidgets);
      await tester.enterText(nameFields.first, 'Karthik');
      await tester.pumpAndSettle();

      // Switch to manual mode by tapping the manual mode toggle
      final manualToggle = find.textContaining('मॅन्युअली प्रविष्ट करा');
      expect(manualToggle, findsWidgets);
      await tester.tap(manualToggle.first);
      await tester.pumpAndSettle();

      // Tap the Coimbatore suggestion chip
      final cbeChip = find.text('Coimbatore, Tamil Nadu');
      expect(cbeChip, findsOneWidget);
      await tester.tap(cbeChip);
      await tester.pumpAndSettle();

      // Scroll to and tap save button
      final saveBtn = find.textContaining('जतन');
      await tester.scrollUntilVisible(saveBtn, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(saveBtn.last);
      await tester.pumpAndSettle();

      // Verify profile was saved with Coimbatore coordinates without requiring GPS
      expect(profileRepo.savedProfile, isNotNull);
      expect(profileRepo.savedProfile!.name, 'Karthik');
      expect(profileRepo.savedProfile!.region, 'Coimbatore, Tamil Nadu');
      expect(profileRepo.savedProfile!.latitude, closeTo(11.0168, 0.01));
      expect(profileRepo.savedProfile!.longitude, closeTo(76.9558, 0.01));
    });
  });

  group('FarmSetupScreen — Manual Location Flow', () {
    testWidgets('allows creating farm with manual location entry',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final farmRepo = _FakeFarmRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            farmRepositoryProvider.overrideWithValue(farmRepo),
            tokenStorageProvider.overrideWithValue(TokenStorage(storage: _MockStorage())),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: FarmSetupScreen(
              locationService: _DisabledLocationService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to manual mode
      final manualTab = find.textContaining('मॅन्युअली');
      expect(manualTab, findsWidgets);
      await tester.tap(manualTab.first);
      await tester.pumpAndSettle();

      // Tap suggestion chip for Pune
      final puneChip = find.text('Pune, Maharashtra');
      expect(puneChip, findsOneWidget);
      await tester.tap(puneChip);
      await tester.pumpAndSettle();

      // Save farm
      final saveBtn = find.textContaining('शेत जतन करा');
      await tester.scrollUntilVisible(saveBtn, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(saveBtn.last);
      await tester.pumpAndSettle();

      // Verify farm was created with Pune coordinates
      expect(farmRepo.lastFarm, isNotNull);
      expect(farmRepo.lastFarm!.region, 'Pune, Maharashtra');
      expect(farmRepo.lastFarm!.location?.lat, closeTo(18.5204, 0.01));
      expect(farmRepo.lastFarm!.location?.lng, closeTo(73.8567, 0.01));
    });
  });
}
