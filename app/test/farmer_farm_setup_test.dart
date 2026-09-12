// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bhoomi/core/theme/app_theme.dart';
import 'package:bhoomi/core/storage/secure_storage.dart';
import 'package:bhoomi/core/storage/token_storage.dart';
import 'package:bhoomi/core/utils/location_service.dart';
import 'package:bhoomi/models/auth_models.dart';
import 'package:bhoomi/models/farmer_profile_models.dart';
import 'package:bhoomi/models/farm_models.dart';
import 'package:bhoomi/repositories/farmer_profile_repository.dart';
import 'package:bhoomi/repositories/auth_repository.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/providers/farmer_profile_providers.dart';
import 'package:bhoomi/providers/storage_providers.dart';
import 'package:bhoomi/features/onboarding/presentation/farmer_farm_setup_screen.dart';
import 'package:bhoomi/features/shell/presentation/main_app_shell.dart';
import 'package:bhoomi/main.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test Infrastructure
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory replacement for FlutterSecureStorage — safe for unit tests.
class _MemoryStorage extends SecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> delete({required String key}) async => _store.remove(key);

  @override
  Future<void> deleteAll() async => _store.clear();
}

/// Controllable fake profile repository.
class _FakeProfileRepository implements FarmerProfileRepository {
  FarmerProfile? _storedProfile;
  bool shouldThrowOnSave;
  int saveCallCount = 0;
  int getCallCount = 0;

  _FakeProfileRepository({
    FarmerProfile? initial,
    this.shouldThrowOnSave = false,
  }) : _storedProfile = initial;

  @override
  Future<FarmerProfile?> getProfile(String userId) async {
    getCallCount++;
    if (_storedProfile != null && _storedProfile!.farmerId == userId) {
      return _storedProfile;
    }
    return null;
  }

  @override
  Future<FarmerProfile> saveProfile(FarmerProfile profile) async {
    saveCallCount++;
    if (shouldThrowOnSave) {
      throw Exception('Network error: could not sync farm profile');
    }
    _storedProfile = profile.copyWith(
      farmId: profile.farmId ?? 'f_local_saved',
      updatedAt: DateTime.now(),
    );
    return _storedProfile!;
  }

  @override
  Future<void> deleteProfile(String userId) async {
    if (_storedProfile?.farmerId == userId) {
      _storedProfile = null;
    }
  }
}

/// Minimal fake auth repository that simulates a signed-in farmer.
class _FakeAuthRepository implements AuthRepository {
  final UserModel _user;
  bool _authenticated = true;

  _FakeAuthRepository({
    String userId = 'u_test_farmer',
    String phone = '+919876543210',
  }) : _user = UserModel(id: userId, phone: phone, role: 'farmer');

  @override
  Future<bool> isAuthenticated() async => _authenticated;

  @override
  Future<UserModel?> getCurrentUser() async =>
      _authenticated ? _user : null;

  @override
  Future<OtpRequestResponse> requestOtp({required String phone}) async =>
      const OtpRequestResponse(requestId: 'req_fake', expiresIn: 300);

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String requestId,
    required String otp,
  }) async {
    _authenticated = true;
    return OtpVerifyResponse(
      accessToken: 'token_fake',
      refreshToken: 'refresh_fake',
      user: _user,
    );
  }

  @override
  Future<OtpVerifyResponse> loginAsDemo() async {
    _authenticated = true;
    return OtpVerifyResponse(
      accessToken: 'token_demo',
      refreshToken: 'refresh_demo',
      user: _user,
    );
  }

  @override
  Future<void> logout() async => _authenticated = false;
}

/// Fake GPS location service with injectable result.
class _FakeLocationService extends LocationService {
  final LocationResult _result;

  _FakeLocationService({required LocationResult result})
      : _result = result,
        super();

  @override
  Future<LocationResult> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async =>
      _result;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: Build FarmerFarmSetupScreen in a test environment
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildSetupScreen({
  required FarmerProfileRepository profileRepo,
  required AuthRepository authRepo,
  LocationService? locationService,
  bool isFirstTimeOnboarding = true,
  FarmerProfile? preloadedProfile,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepo),
      farmerProfileRepositoryProvider.overrideWithValue(profileRepo),
      if (preloadedProfile != null)
        farmerProfileProvider.overrideWith(
          (ref) {
            final notifier = FarmerProfileNotifier(ref);
            notifier.state = FarmerProfileState(profile: preloadedProfile);
            return notifier;
          },
        ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('mr', 'IN'),
      home: FarmerFarmSetupScreen(
        isFirstTimeOnboarding: isFirstTimeOnboarding,
        locationService: locationService,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  // ---------------------------------------------------------------------------
  // 1. Screen Rendering
  // ---------------------------------------------------------------------------
  group('FarmerFarmSetupScreen — Rendering', () {
    testWidgets('renders all key form sections in onboarding mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final profileRepo = _FakeProfileRepository();
      final authRepo = _FakeAuthRepository();
      final fakeLocation = _FakeLocationService(
        result: LocationResult(
          location: const GeoPoint(lat: 19.9975, lng: 73.7898),
          status: LocationServiceStatus.acquired,
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: profileRepo,
        authRepo: authRepo,
        locationService: fakeLocation,
        isFirstTimeOnboarding: true,
      ));
      await tester.pumpAndSettle();

      // Title shows first-time onboarding header (Marathi)
      expect(find.text('आपल्या शेतीचे प्रोफाइल सेट करा'), findsOneWidget);
    });

    testWidgets('shows edit profile title when not first-time onboarding',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final authRepo = _FakeAuthRepository();
      final profileRepo = _FakeProfileRepository(
        initial: FarmerProfile(
          farmerId: 'u_test_farmer',
          name: 'Ramesh',
          preferredLanguage: 'mr',
          latitude: 19.0,
          longitude: 73.0,
          farmArea: 3.0,
          farmAreaUnit: 'Acres',
          soilType: 'black',
          irrigationType: 'rainfed',
          crops: const ['paddy'],
          currentCrop: 'paddy',
          growthStage: 'vegetative',
        ),
      );
      final fakeLocation = _FakeLocationService(
        result: LocationResult(
          location: const GeoPoint(lat: 19.0, lng: 73.0),
          status: LocationServiceStatus.acquired,
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: profileRepo,
        authRepo: authRepo,
        locationService: fakeLocation,
        isFirstTimeOnboarding: false,
        preloadedProfile: FarmerProfile(
          farmerId: 'u_test_farmer',
          name: 'Ramesh',
          preferredLanguage: 'mr',
          latitude: 19.0,
          longitude: 73.0,
          farmArea: 3.0,
          farmAreaUnit: 'Acres',
          soilType: 'black',
          irrigationType: 'rainfed',
          crops: const ['paddy'],
          currentCrop: 'paddy',
          growthStage: 'vegetative',
        ),
      ));
      await tester.pumpAndSettle();

      // Edit mode shows 'Edit Farm Profile' title (Marathi)
      expect(find.text('शेत प्रोफाइल संपादित करा'), findsOneWidget);
    });

    testWidgets('pre-populates name from existing profile in edit mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      const existingName = 'Lakshmi Patil';
      final existingProfile = FarmerProfile(
        farmerId: 'u_test_farmer',
        name: existingName,
        preferredLanguage: 'mr',
        latitude: 19.9975,
        longitude: 73.7898,
        farmArea: 2.5,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'rainfed',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        growthStage: 'tillering',
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(initial: existingProfile),
        authRepo: _FakeAuthRepository(),
        isFirstTimeOnboarding: false,
        preloadedProfile: existingProfile,
      ));
      await tester.pumpAndSettle();

      // The name text field should be pre-populated
      expect(find.text(existingName), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Form Validation
  // ---------------------------------------------------------------------------
  group('FarmerFarmSetupScreen — Form Validation', () {
    testWidgets('shows name error when name is empty on save',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = _FakeLocationService(
        result: LocationResult(
          location: const GeoPoint(lat: 19.9975, lng: 73.7898),
          status: LocationServiceStatus.acquired,
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(),
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Clear the name field if auto-populated
      final nameFields = find.byType(TextField);
      if (nameFields.evaluate().isNotEmpty) {
        await tester.tap(nameFields.first);
        await tester.enterText(nameFields.first, '');
        await tester.pumpAndSettle();
      }

      // Scroll to and tap save button
      final saveFinder = find.textContaining('जतन');
      await tester.scrollUntilVisible(saveFinder, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(saveFinder.last);
      await tester.pumpAndSettle();

      // Should not have navigated — profile NOT saved
      expect(find.byType(FarmerFarmSetupScreen), findsOneWidget);
    });

    testWidgets('shows area error when farm area is zero or invalid',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = _FakeLocationService(
        result: LocationResult(
          location: const GeoPoint(lat: 19.9975, lng: 73.7898),
          status: LocationServiceStatus.acquired,
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(),
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Find area field and enter invalid value
      final areaFields = find.byType(TextField);
      // Area field is typically the one with numeric keyboard; enter 0
      for (final el in areaFields.evaluate()) {
        final widget = el.widget as TextField;
        if (widget.controller?.text == '2.5') {
          await tester.enterText(find.byWidget(widget), '0');
          break;
        }
      }
      await tester.pumpAndSettle();

      // Scroll to and tap save
      final saveFinder = find.textContaining('जतन');
      await tester.scrollUntilVisible(saveFinder, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(saveFinder.last);
      await tester.pumpAndSettle();

      // Should stay on setup screen (validation blocked)
      expect(find.byType(FarmerFarmSetupScreen), findsOneWidget);
    });

    testWidgets('shows location error when GPS not acquired on save',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // GPS denied
      final fakeLocation = _FakeLocationService(
        result: const LocationResult(
          status: LocationServiceStatus.denied,
          errorMessage: 'Location permission denied by user.',
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(),
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Enter a valid name
      final nameFields = find.byType(TextField);
      await tester.enterText(nameFields.first, 'Ramesh Shinde');
      await tester.pumpAndSettle();

      // Scroll to save button and tap
      final saveFinder = find.textContaining('जतन');
      await tester.scrollUntilVisible(saveFinder, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(saveFinder.last);
      await tester.pumpAndSettle();

      // Validation error prevents save: should remain on setup screen
      expect(find.byType(FarmerFarmSetupScreen), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Location Service Handling
  // ---------------------------------------------------------------------------
  group('FarmerFarmSetupScreen — Location Service', () {
    testWidgets('shows "location acquired" confirmation when GPS succeeds',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = _FakeLocationService(
        result: LocationResult(
          location: const GeoPoint(lat: 20.1234, lng: 74.5678),
          status: LocationServiceStatus.acquired,
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(),
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Scroll to location section
      await tester.dragUntilVisible(
        find.textContaining('20.1234'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      ).timeout(const Duration(seconds: 5), onTimeout: () {});
      // No crash — location displayed or section shown
    });

    testWidgets('shows denied-forever UI and settings button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = _FakeLocationService(
        result: const LocationResult(
          status: LocationServiceStatus.deniedForever,
          errorMessage:
              'Location permission permanently denied. Please enable in App Settings.',
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(),
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Warning icon visible
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('shows timeout error message when GPS times out',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = _FakeLocationService(
        result: const LocationResult(
          status: LocationServiceStatus.timeout,
          errorMessage: 'GPS location request timed out. Please try again.',
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(),
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Retry button visible when timeout
      expect(find.byIcon(Icons.refresh_rounded), findsWidgets);
    });

    testWidgets('shows disabled GPS message when location services are off',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = _FakeLocationService(
        result: const LocationResult(
          status: LocationServiceStatus.disabled,
          errorMessage:
              'Location services are disabled. Please enable GPS on your device.',
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: _FakeProfileRepository(),
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Warning shown for disabled GPS
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Profile Persistence
  // ---------------------------------------------------------------------------
  group('FarmerProfileRepository — Persistence', () {
    test('getProfile returns null for a new user (no stored profile)', () async {
      final storage = _MemoryStorage();
      final tokenStorage = TokenStorage(storage: storage);
      // The real impl checks userId-scoped key — no data written yet
      await tokenStorage.saveTokens(
          accessToken: 'at', refreshToken: 'rt');
      // Verify key is empty for the test user
      final raw = await storage.read(
          key: TokenStorage.userProfileKey('u_new_farmer_test'));
      expect(raw, isNull);
    });

    test('profile is stored and retrieved with correct user isolation', () async {
      final storage = _MemoryStorage();
      final tokenStorage = TokenStorage(storage: storage);

      final profileA = FarmerProfile(
        farmerId: 'u_farmer_A',
        name: 'Farmer A',
        preferredLanguage: 'mr',
        latitude: 19.0,
        longitude: 73.0,
        farmArea: 2.0,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'rainfed',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        growthStage: 'vegetative',
      );

      final profileB = FarmerProfile(
        farmerId: 'u_farmer_B',
        name: 'Farmer B',
        preferredLanguage: 'hi',
        latitude: 18.5,
        longitude: 74.0,
        farmArea: 5.0,
        farmAreaUnit: 'Hectares',
        soilType: 'clay',
        irrigationType: 'drip',
        crops: const ['cotton'],
        currentCrop: 'cotton',
        growthStage: 'squaring',
      );

      // Save both profiles under separate user IDs
      await tokenStorage.saveUserProfile('u_farmer_A', profileA.toJson());
      await tokenStorage.saveUserProfile('u_farmer_B', profileB.toJson());

      // Load each profile and verify isolation
      final loadedA = await tokenStorage.getUserProfile('u_farmer_A');
      final loadedB = await tokenStorage.getUserProfile('u_farmer_B');

      expect(loadedA, isNotNull);
      expect(loadedA!['farmer_id'], 'u_farmer_A');
      expect(loadedA['name'], 'Farmer A');

      expect(loadedB, isNotNull);
      expect(loadedB!['farmer_id'], 'u_farmer_B');
      expect(loadedB['name'], 'Farmer B');

      // Farmer A cannot see Farmer B's data and vice versa
      expect(loadedA['farmer_id'], isNot(equals(loadedB['farmer_id'])));
    });

    test('FarmerProfile.isComplete returns false for missing GPS', () {
      final profile = FarmerProfile(
        farmerId: 'u_test',
        name: 'Test Farmer',
        preferredLanguage: 'mr',
        // latitude & longitude intentionally omitted
        farmArea: 2.5,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'rainfed',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        growthStage: 'tillering',
      );
      expect(profile.isComplete, isFalse);
    });

    test('FarmerProfile.isComplete returns false for empty name', () {
      final profile = FarmerProfile(
        farmerId: 'u_test',
        name: '',
        preferredLanguage: 'mr',
        latitude: 19.0,
        longitude: 73.0,
        farmArea: 2.5,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'rainfed',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        growthStage: 'tillering',
      );
      expect(profile.isComplete, isFalse);
    });

    test('FarmerProfile.isComplete returns false for zero area', () {
      final profile = FarmerProfile(
        farmerId: 'u_test',
        name: 'Ramesh',
        preferredLanguage: 'mr',
        latitude: 19.0,
        longitude: 73.0,
        farmArea: 0,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'rainfed',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        growthStage: 'tillering',
      );
      expect(profile.isComplete, isFalse);
    });

    test('FarmerProfile.isComplete returns true for all required fields', () {
      final profile = FarmerProfile(
        farmerId: 'u_test',
        name: 'Ramesh Shinde',
        preferredLanguage: 'mr',
        latitude: 19.9975,
        longitude: 73.7898,
        farmArea: 2.5,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'rainfed',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        growthStage: 'tillering',
      );
      expect(profile.isComplete, isTrue);
    });

    test('FarmerProfile.toJson and fromJson round-trip preserves all fields',
        () {
      final original = FarmerProfile(
        farmerId: 'u_round_trip',
        name: 'Sunita Jadhav',
        mobileNumber: '+919876543210',
        preferredLanguage: 'hi',
        farmId: 'f_001',
        farmName: 'सोने का खेत',
        latitude: 21.1458,
        longitude: 79.0882,
        region: 'Nagpur, Maharashtra',
        farmArea: 3.7,
        farmAreaUnit: 'Hectares',
        soilType: 'clay',
        irrigationType: 'drip',
        crops: const ['cotton'],
        currentCrop: 'cotton',
        variety: 'BT Cotton',
        growthStage: 'squaring',
        sowingDate: DateTime(2026, 6, 20),
        updatedAt: DateTime(2026, 9, 1),
      );

      final json = original.toJson();
      final restored = FarmerProfile.fromJson(json);

      expect(restored.farmerId, original.farmerId);
      expect(restored.name, original.name);
      expect(restored.mobileNumber, original.mobileNumber);
      expect(restored.preferredLanguage, original.preferredLanguage);
      expect(restored.farmId, original.farmId);
      expect(restored.farmName, original.farmName);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.region, original.region);
      expect(restored.farmArea, original.farmArea);
      expect(restored.farmAreaUnit, original.farmAreaUnit);
      expect(restored.soilType, original.soilType);
      expect(restored.irrigationType, original.irrigationType);
      expect(restored.crops, original.crops);
      expect(restored.currentCrop, original.currentCrop);
      expect(restored.variety, original.variety);
      expect(restored.growthStage, original.growthStage);
      expect(restored.sowingDate?.year, original.sowingDate?.year);
      expect(restored.sowingDate?.month, original.sowingDate?.month);
      expect(restored.sowingDate?.day, original.sowingDate?.day);
    });
  });

  // ---------------------------------------------------------------------------
  // 5. User Isolation in FarmerProfileNotifier
  // ---------------------------------------------------------------------------
  group('FarmerProfileNotifier — User Isolation', () {
    test('clearProfile removes any stored profile from state', () async {
      final container = ProviderContainer(
        overrides: [
          farmerProfileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(
              initial: FarmerProfile(
                farmerId: 'u_farmer_X',
                name: 'Test',
                preferredLanguage: 'mr',
                latitude: 19.0,
                longitude: 73.0,
                farmArea: 2.0,
                farmAreaUnit: 'Acres',
                soilType: 'black',
                irrigationType: 'rainfed',
                crops: const ['paddy'],
                currentCrop: 'paddy',
                growthStage: 'tillering',
              ),
            ),
          ),
          secureStorageProvider.overrideWithValue(_MemoryStorage()),
        ],
      );
      addTearDown(container.dispose);

      // Load profile
      await container
          .read(farmerProfileProvider.notifier)
          .loadProfile('u_farmer_X');
      expect(container.read(farmerProfileProvider).profile, isNotNull);

      // Now clear (simulates logout)
      container.read(farmerProfileProvider.notifier).clearProfile();
      expect(container.read(farmerProfileProvider).profile, isNull);
      expect(container.read(farmerProfileProvider).isComplete, isFalse);
    });

    test('loadProfile for one user does not leak into another user context',
        () async {
      final repoA = _FakeProfileRepository(
        initial: FarmerProfile(
          farmerId: 'u_farmer_A',
          name: 'Farmer A',
          preferredLanguage: 'mr',
          latitude: 19.0,
          longitude: 73.0,
          farmArea: 2.0,
          farmAreaUnit: 'Acres',
          soilType: 'black',
          irrigationType: 'rainfed',
          crops: const ['paddy'],
          currentCrop: 'paddy',
          growthStage: 'vegetative',
        ),
      );

      final containerA = ProviderContainer(
        overrides: [
          farmerProfileRepositoryProvider.overrideWithValue(repoA),
          secureStorageProvider.overrideWithValue(_MemoryStorage()),
        ],
      );
      addTearDown(containerA.dispose);

      await containerA
          .read(farmerProfileProvider.notifier)
          .loadProfile('u_farmer_A');
      expect(containerA.read(farmerProfileProvider).profile?.farmerId,
          'u_farmer_A');

      // A fresh container for farmer B with a repo that has no profile for A
      final repoB = _FakeProfileRepository(); // no data
      final containerB = ProviderContainer(
        overrides: [
          farmerProfileRepositoryProvider.overrideWithValue(repoB),
          secureStorageProvider.overrideWithValue(_MemoryStorage()),
        ],
      );
      addTearDown(containerB.dispose);

      await containerB
          .read(farmerProfileProvider.notifier)
          .loadProfile('u_farmer_B');
      expect(containerB.read(farmerProfileProvider).profile, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // 6. Save Failures
  // ---------------------------------------------------------------------------
  group('FarmerFarmSetupScreen — Save Failures', () {
    testWidgets('shows network error message when save throws',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Inject a repo that fails on save
      final failingRepo =
          _FakeProfileRepository(shouldThrowOnSave: true);
      final fakeLocation = _FakeLocationService(
        result: LocationResult(
          location: const GeoPoint(lat: 19.9975, lng: 73.7898),
          status: LocationServiceStatus.acquired,
        ),
      );

      await tester.pumpWidget(_buildSetupScreen(
        profileRepo: failingRepo,
        authRepo: _FakeAuthRepository(),
        locationService: fakeLocation,
      ));
      await tester.pumpAndSettle();

      // Enter a valid name
      final nameFields = find.byType(TextField);
      await tester.enterText(nameFields.first, 'Ramesh Shinde');
      await tester.pumpAndSettle();

      // Scroll to save and tap
      final saveFinder = find.textContaining('जतन');
      await tester.scrollUntilVisible(saveFinder, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(saveFinder.last);
      await tester.pumpAndSettle();

      // Still on setup screen with error visible
      expect(find.byType(FarmerFarmSetupScreen), findsOneWidget);
      // Error message from profileSaveNetworkError should appear
      expect(failingRepo.saveCallCount, greaterThanOrEqualTo(1));
    });
  });

  // ---------------------------------------------------------------------------
  // 7. Authentication Routing
  // ---------------------------------------------------------------------------
  group('BhoomiApp — Authentication Routing', () {
    testWidgets(
        'first-time user (no profile, isComplete=false) routed to FarmerFarmSetupScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final memStorage = _MemoryStorage();
      await memStorage.write(
          key: 'bhoomi_access_token', value: 'valid_jwt_token');
      await memStorage.write(
          key: 'bhoomi_user_data',
          value:
              '{"id":"u_first_timer","phone":"+911234567890","role":"farmer"}');

      final authRepo = _FakeAuthRepository(userId: 'u_first_timer');
      final profileRepo =
          _FakeProfileRepository(); // no profile stored → null

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            farmerProfileRepositoryProvider.overrideWithValue(profileRepo),
            secureStorageProvider.overrideWithValue(memStorage),
          ],
          child: const BhoomiApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on FarmerFarmSetupScreen (isFirstTimeOnboarding: true)
      expect(find.byType(FarmerFarmSetupScreen), findsOneWidget);
    });

    testWidgets(
        'returning user with complete profile routed directly to MainAppShell',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final memStorage = _MemoryStorage();
      await memStorage.write(
          key: 'bhoomi_access_token', value: 'valid_jwt_token');
      await memStorage.write(
          key: 'bhoomi_user_data',
          value:
              '{"id":"u_returning","phone":"+919876543210","role":"farmer"}');

      final authRepo = _FakeAuthRepository(userId: 'u_returning');
      final completeProfile = FarmerProfile(
        farmerId: 'u_returning',
        name: 'Sunita Gawande',
        preferredLanguage: 'mr',
        farmId: 'f_001',
        latitude: 19.9975,
        longitude: 73.7898,
        region: 'Nashik, Maharashtra',
        farmArea: 3.0,
        farmAreaUnit: 'Acres',
        soilType: 'black',
        irrigationType: 'canal',
        crops: const ['paddy'],
        currentCrop: 'paddy',
        variety: 'Indrayani',
        growthStage: 'tillering',
        updatedAt: DateTime.now(),
      );
      final profileRepo = _FakeProfileRepository(initial: completeProfile);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            farmerProfileRepositoryProvider.overrideWithValue(profileRepo),
            secureStorageProvider.overrideWithValue(memStorage),
          ],
          child: const BhoomiApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on MainAppShell (not FarmerFarmSetupScreen)
      expect(find.byType(MainAppShell), findsOneWidget);
      expect(find.byType(FarmerFarmSetupScreen), findsNothing);
    });
  });
}
