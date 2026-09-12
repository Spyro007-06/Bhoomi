import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhoomi/core/config/app_mode.dart';
import 'package:bhoomi/core/config/demo_config.dart';
import 'package:bhoomi/core/demo/demo_store.dart';
import 'package:bhoomi/core/demo/demo_repositories.dart';
import 'package:bhoomi/core/storage/secure_storage.dart';
import 'package:bhoomi/core/storage/token_storage.dart';

class TestSecureStorage extends SecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _store[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestSecureStorage storage;
  late TokenStorage tokenStorage;
  late DemoStore demoStore;

  setUp(() {
    storage = TestSecureStorage();
    tokenStorage = TokenStorage(storage: storage);
    demoStore = DemoStore(storage: storage);
  });

  group('Demo Mode Configuration', () {
    test('defaults to Demo Mode for presentations and standalone APKs', () {
      expect(AppModeConfig.isDemo, isTrue);
      expect(AppModeConfig.isProduction, isFalse);
      expect(AppModeConfig.mode, equals(AppMode.demo));
    });

    test('exposes deterministic demo credentials and persona', () {
      expect(DemoConfig.demoOtp, equals('123456'));
      expect(DemoConfig.demoFarmerName, equals('Arun Kumar'));
      expect(DemoConfig.demoPhone, equals('+919876543210'));
      expect(DemoConfig.demoFarmName, equals('Green Valley Farm'));
    });
  });

  group('Demo Authentication Flow', () {
    test('requestOtp succeeds without backend', () async {
      final authRepo = DemoAuthRepository(tokenStorage: tokenStorage, store: demoStore);
      final res = await authRepo.requestOtp(phone: '+919876543210');
      expect(res.requestId, isNotEmpty);
      expect(res.expiresIn, greaterThan(0));
    });

    test('verifyOtp succeeds with demo OTP 123456 and persists session', () async {
      final authRepo = DemoAuthRepository(tokenStorage: tokenStorage, store: demoStore);
      final res = await authRepo.verifyOtp(requestId: 'req_001', otp: '123456');

      expect(res.user.name, equals('Arun Kumar'));
      expect(res.user.phone, equals('+919876543210'));
      expect(await authRepo.isAuthenticated(), isTrue);

      final currentUser = await authRepo.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser!.name, equals('Arun Kumar'));
    });

    test('verifyOtp rejects invalid OTP in demo mode', () async {
      final authRepo = DemoAuthRepository(tokenStorage: tokenStorage, store: demoStore);
      expect(
        () => authRepo.verifyOtp(requestId: 'req_001', otp: '999999'),
        throwsA(isA<Exception>()),
      );
    });

    test('logout clears session from local storage', () async {
      final authRepo = DemoAuthRepository(tokenStorage: tokenStorage, store: demoStore);
      await authRepo.verifyOtp(requestId: 'req_001', otp: '123456');
      expect(await authRepo.isAuthenticated(), isTrue);

      await authRepo.logout();
      expect(await authRepo.isAuthenticated(), isFalse);
    });
  });

  group('Demo Farm and Farmer Profile', () {
    test('returns realistic demo farmer profile and persists edits', () async {
      final profileRepo = DemoFarmerProfileRepository(store: demoStore);
      final initial = await profileRepo.getProfile('u_arun_01');

      expect(initial, isNotNull);
      expect(initial!.name, equals('Arun Kumar'));
      expect(initial.region, equals('Tamil Nadu'));
      expect(initial.farmArea, equals(4.5));
      expect(initial.currentCrop, equals('tomato'));

      // Edit profile
      final updated = initial.copyWith(name: 'Arun K. Updated');
      await profileRepo.saveProfile(updated);

      final reloaded = await profileRepo.getProfile('u_arun_01');
      expect(reloaded!.name, equals('Arun K. Updated'));
    });

    test('returns Green Valley Farm and summary with health indicators', () async {
      final farmRepo = DemoFarmRepository(store: demoStore);
      final farm = await farmRepo.getFarm(DemoConfig.demoFarmId);

      expect(farm.crop, equals('tomato'));
      expect(farm.variety, equals('Arka Rakshak'));
      expect(farm.growthStage, equals('flowering'));
      expect(farm.region, equals('Tamil Nadu'));

      final summary = await farmRepo.getFarmSummary(DemoConfig.demoFarmId);
      expect(summary.health.trend, equals('stable'));
      expect(summary.openProblems, equals(1));
    });
  });

  group('Demo Check Crop & Diagnosis Flow', () {
    test('presigns and uploads binary without cloud storage', () async {
      final assetRepo = DemoAssetRepository();
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final assetId = await assetRepo.uploadImage(bytes: bytes);
      expect(assetId, equals('demo_asset_tomato_001'));
    });

    test('diagnose returns Early Blight clarification question', () async {
      final diagRepo = DemoDiagnosisRepository(store: demoStore);
      final response = await diagRepo.diagnose(
        farmId: DemoConfig.demoFarmId,
        imageAssetId: 'demo_asset_tomato_001',
      );

      expect(response.isClarify, isTrue);
      expect(response.clarification, isNotNull);
      expect(
        response.clarification!.question,
        contains('Are the brown spots mainly appearing on the older lower leaves?'),
      );
    });

    test('Doubt Doctor submission resolves to Early Blight diagnosis', () async {
      final ddRepo = DemoDoubtDoctorRepository(store: demoStore);
      final result = await ddRepo.submitAnswer(
        problemId: 'p_tomato_blight_01',
        cueId: 'cue_tomato_leaf_spots_01',
        answer: 'yes',
      );

      expect(result.resolved, isTrue);
      expect(result.diagnosis, isNotNull);
      expect(result.diagnosis!.label, contains('Early Blight'));
      expect(result.diagnosis!.confidence, equals(0.92));
      expect(result.advisory, isNotNull);
      expect(result.advisory!.ladder, isNotEmpty);
      expect(result.citations, isNotEmpty);
    });
  });

  group('Demo Risk Alerts, Follow-ups, and Timeline', () {
    test('loads high rainfall, fungal disease, and pest risk alerts', () async {
      final alertRepo = DemoAlertRepository(store: demoStore);
      final response = await alertRepo.getAlerts(farmId: DemoConfig.demoFarmId);

      expect(response.alerts.length, equals(3));
      expect(response.alerts[0].riskLevel, equals('high'));
      expect(response.alerts[0].target, equals('heavy_rainfall'));
      expect(
        response.alerts[0].inspectionTasks.first,
        contains('Heavy rainfall is expected'),
      );

      // Responding to alert updates state
      final ack = await alertRepo.respondToAlert(
        alertId: response.alerts[0].id,
        outcome: 'nothing_found',
      );
      expect(ack.outcome, equals('nothing_found'));
    });

    test('loads 7-day leaf spread follow-up and records response', () async {
      final fuRepo = DemoFollowUpRepository(store: demoStore);
      final pending = await fuRepo.getPendingFollowUps(DemoConfig.demoFarmId);

      expect(pending.followups, isNotEmpty);
      expect(pending.followups.first.target, equals('early_blight'));
      expect(pending.followups.first.dueAt, contains('2026-09-17'));

      final result = await fuRepo.respondToFollowUp(
        followUpId: pending.followups.first.id,
        response: 'improved',
      );
      expect(result.severityChange?.to, equals('early'));
    });

    test('timeline contains chronological audit events', () async {
      final tlRepo = DemoTimelineRepository(store: demoStore);
      final timeline = await tlRepo.getTimeline(farmId: DemoConfig.demoFarmId);

      expect(timeline.events, isNotEmpty);
      expect(timeline.events.any((e) => e.title.contains('Crop image submitted')), isTrue);
      expect(timeline.events.any((e) => e.title.contains('Early Blight detected')), isTrue);
      expect(timeline.events.any((e) => e.title.contains('Treatment recommendation')), isTrue);
      expect(timeline.events.any((e) => e.title.contains('Doubt Doctor clarification')), isTrue);
      expect(timeline.events.any((e) => e.title.contains('Field Follow-Up Scheduled')), isTrue);
    });
  });

  group('Demo Advisory and Voice Features', () {
    test('queryAdvisory returns offline heavy rainfall & disease guidance', () async {
      final advRepo = DemoAdvisoryRepository();
      final res = await advRepo.queryAdvisory(
        farmId: DemoConfig.demoFarmId,
        queryText: 'What should I do after heavy rainfall?',
      );

      expect(res.retrieved, isTrue);
      expect(res.spokenSummary, contains('Check field drainage'));
      expect(res.advisory?.ladder, isNotEmpty);
    });

    test('transcribe returns offline mock transcription for voice questions', () async {
      final voiceRepo = DemoVoiceRepository();
      final res = await voiceRepo.transcribe(assetId: 'demo_asset_voice_001');

      expect(res.text, equals('Why are the leaves of my tomato plant turning yellow?'));
      expect(res.confidence, greaterThan(0.9));
    });
  });

  group('Demo Data Reset', () {
    test('reset restores initial fixtures cleanly', () async {
      final profileRepo = DemoFarmerProfileRepository(store: demoStore);
      final profile = await profileRepo.getProfile('u_arun_01');
      await profileRepo.saveProfile(profile!.copyWith(name: 'Changed Name'));

      var modified = await profileRepo.getProfile('u_arun_01');
      expect(modified!.name, equals('Changed Name'));

      // Perform reset
      await demoStore.reset();

      final restored = await profileRepo.getProfile('u_arun_01');
      expect(restored!.name, equals('Arun Kumar'));
    });
  });
}
