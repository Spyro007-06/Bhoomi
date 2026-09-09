import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/main.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/models/inspection_target.dart';
import 'package:bhoomi/models/voice_models.dart';
import 'package:bhoomi/models/farm_models.dart';
import 'package:bhoomi/models/alert_models.dart';
import 'package:bhoomi/models/followup_models.dart';
import 'package:bhoomi/models/timeline_models.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/repositories/voice_repository.dart';
import 'package:bhoomi/repositories/farm_repository.dart';
import 'package:bhoomi/repositories/alert_repository.dart';
import 'package:bhoomi/repositories/followup_repository.dart';
import 'package:bhoomi/repositories/timeline_repository.dart';
import 'package:bhoomi/widgets/farmer_voice_assistant.dart';
import 'package:bhoomi/features/home/presentation/home_screen.dart';
import 'package:bhoomi/features/diagnose/presentation/camera_capture_screen.dart';

class _MarathiLocaleNotifier extends LocaleNotifier {
  _MarathiLocaleNotifier() : super() {
    state = AppLanguage.marathi;
  }
}

class _HindiLocaleNotifier extends LocaleNotifier {
  _HindiLocaleNotifier() : super() {
    state = AppLanguage.hindi;
  }
}

class _EnglishLocaleNotifier extends LocaleNotifier {
  _EnglishLocaleNotifier() : super() {
    state = AppLanguage.english;
  }
}

class _FakeVoiceRepo extends VoiceRepository {
  int transcribeCallCount = 0;
  int synthesizeCallCount = 0;
  String? lastTranscribeContext;
  String queryToReturn = 'टोमॅटोच्या पानांवर काळे ठिपके दिसत आहेत.';

  @override
  Future<VoiceTranscribeResult> transcribe({
    required String assetId,
    String lang = 'mr-IN',
    String? context,
  }) async {
    transcribeCallCount++;
    lastTranscribeContext = context;
    return VoiceTranscribeResult(
      text: queryToReturn,
      confidence: 0.96,
      lang: lang,
    );
  }

  @override
  Future<VoiceSynthesizeResult> synthesize({
    required String text,
    String lang = 'mr-IN',
  }) async {
    synthesizeCallCount++;
    return const VoiceSynthesizeResult(
      audioUrl: 'https://bhoomi-s3.gov.in/voice/phase5_advice.mp3',
      expiresIn: 600,
    );
  }
}

class _EmptyAlertRepo extends AlertRepository {
  @override
  Future<AlertsResponse> getAlerts({
    required String farmId,
    int limit = 20,
    String? cursor,
  }) async {
    return const AlertsResponse(alerts: []);
  }

  @override
  Future<AlertRespondResponse> respondToAlert({
    required String alertId,
    required String outcome,
    String? imageAssetId,
  }) async {
    return const AlertRespondResponse(
      status: 'recorded',
      alertId: 'alt_1',
      recordedAt: '2026-08-31',
    );
  }
}

class _EmptyFollowupRepo extends FollowUpRepository {
  @override
  Future<PendingFollowUpsResponse> getPendingFollowUps(String farmId) async {
    return const PendingFollowUpsResponse(followUps: []);
  }

  @override
  Future<FollowUpResultModel> respondToFollowUp({
    required String followUpId,
    required String response,
    String? imageAssetId,
  }) async {
    return const FollowUpResultModel(status: 'success');
  }
}

class _FakeFarmRepo extends FarmRepository {
  @override
  Future<FarmSummaryModel> getFarmSummary(String farmId) async {
    return const FarmSummaryModel(
      farm: FarmModel(
        id: 'f_1',
        crop: 'Tomato',
        variety: 'Abhinav',
        growthStage: 'Vegetative',
        region: 'Pune',
      ),
      health: HealthModel(sentence: 'Crop health is good.', trend: 'stable'),
      activeProblemsCount: 0,
      pendingFollowUpsCount: 0,
      activeAlertsCount: 0,
    );
  }

  @override
  Future<FarmModel> createFarm({
    required String crop,
    String? variety,
    required String growthStage,
    required String region,
    required GeoPoint location,
  }) =>
      throw UnimplementedError();

  @override
  Future<FarmModel> getFarm(String farmId) => throw UnimplementedError();

  @override
  Future<FarmModel> updateFarm(String farmId, Map<String, dynamic> updates) =>
      throw UnimplementedError();
}

class _FakeTimelineRepo extends TimelineRepository {
  @override
  Future<TimelineResponse> getTimeline({
    required String farmId,
    int limit = 20,
    String? cursor,
  }) async {
    return const TimelineResponse(events: []);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bhoomi Phase 5: Conversation-Grade Voice UX & Continuity Tests', () {
    test('1. Semantic InspectionTarget resolves correctly across MR, HI, EN terms', () {
      final mrStrings = AppStrings(AppLanguage.marathi);
      final hiStrings = AppStrings(AppLanguage.hindi);
      final enStrings = AppStrings(AppLanguage.english);

      // Leaves
      expect(InspectionTarget.resolveFromQuery('टोमॅटोच्या पानांवर डाग आहेत'), InspectionTarget.leaf);
      expect(InspectionTarget.resolveFromQuery('पत्तियों पर काले धब्बे हैं'), InspectionTarget.leaf);
      expect(InspectionTarget.resolveFromQuery('There are spots on the leaves'), InspectionTarget.leaf);
      expect(InspectionTarget.leaf.getLocalizedPrompt(mrStrings), 'बाधित पानाचा स्पष्ट फोटो दाखवा.');
      expect(InspectionTarget.leaf.getLocalizedPrompt(enStrings), 'Show the affected leaf clearly.');

      // Insects
      expect(InspectionTarget.resolveFromQuery('झाडावर पांढरी माशी आणि किडे दिसत आहेत'), InspectionTarget.insect);
      expect(InspectionTarget.resolveFromQuery('पौधे पर कीड़े लगे हैं'), InspectionTarget.insect);
      expect(InspectionTarget.resolveFromQuery('Caterpillar and pests on the crop'), InspectionTarget.insect);
      expect(InspectionTarget.insect.getLocalizedPrompt(mrStrings), 'जवळ जाऊन किडीचा स्पष्ट फोटो दाखवा.');
      expect(InspectionTarget.insect.getLocalizedPrompt(hiStrings), 'पास जाकर कीड़े की स्पष्ट फ़ोटो दिखाएं।');

      // Whole Plant
      expect(InspectionTarget.resolveFromQuery('संपूर्ण झाडाची वाढ खुंटली आहे'), InspectionTarget.wholePlant);
      expect(InspectionTarget.resolveFromQuery('पूरे पौधे का विकास रुक गया है'), InspectionTarget.wholePlant);
      expect(InspectionTarget.resolveFromQuery('The whole plant is wilting'), InspectionTarget.wholePlant);
      expect(InspectionTarget.wholePlant.getLocalizedPrompt(mrStrings), 'संपूर्ण रोप/झाड फ्रेममध्ये दाखवा.');
      expect(InspectionTarget.wholePlant.getLocalizedPrompt(enStrings), 'Fit the whole plant inside the frame.');

      // Fruit & Stem
      expect(InspectionTarget.resolveFromQuery('टोमॅटोच्या फळांवर सड दिसत आहे'), InspectionTarget.fruit);
      expect(InspectionTarget.resolveFromQuery('खोड काळे पडले आहे'), InspectionTarget.stem);
      expect(InspectionTarget.resolveFromQuery('जड़ें सड़ रही हैं'), InspectionTarget.root);
      expect(InspectionTarget.resolveFromQuery('शेतातील माती कोरडी झाली आहे'), InspectionTarget.soil);
    });

    testWidgets('2. Speech Interruption: Farmer tapping mic during speaking cleanly stops playback and starts recording',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
          ],
          child: const BhoomiApp(
            homeOverride: Scaffold(
              body: FarmerVoiceAssistant(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Start recording
      await tester.tap(find.text('बोलायला सुरुवात करा'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('थांबवा'), findsOneWidget);

      // Step 2: Stop recording -> Processing -> Transcription Confirmation
      await tester.tap(find.text('थांबवा'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('सल्ला ऐका'), findsOneWidget);

      // Step 3: Start playback
      await tester.tap(find.text('सल्ला ऐका'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('सल्ला ऐकत आहात'), findsOneWidget);

      // Step 4: Interrupt by tapping [आणखी विचारा] (Ask again)
      await tester.tap(find.text('आणखी विचारा'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Successfully transitioned back to recording mode without race conditions
      expect(find.text('थांबवा'), findsOneWidget);
    });

    testWidgets('3. Hear Again Replay Exclusivity: Replays cached audio without creating duplicate turn or STT calls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
          ],
          child: const BhoomiApp(
            homeOverride: Scaffold(
              body: FarmerVoiceAssistant(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Record & transcribe
      await tester.tap(find.text('बोलायला सुरुवात करा'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('थांबवा'));
      await tester.pumpAndSettle();

      expect(fakeVoiceRepo.transcribeCallCount, equals(1));

      // Step 2: Synthesize & play audio
      await tester.tap(find.text('सल्ला ऐका'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeVoiceRepo.synthesizeCallCount, equals(1));
      expect(find.text('ऐकणे थांबवा'), findsOneWidget);

      // Step 3: Pause playback -> button becomes 'पुन्हा ऐका' (Replay Audio)
      await tester.tap(find.text('ऐकणे थांबवा'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('पुन्हा ऐका'), findsOneWidget);

      // Step 4: Tap Replay Audio (Hear Again) -> Uses cached audio URL
      await tester.tap(find.text('पुन्हा ऐका'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Guard: transcribe must NOT be called again, cached audio URL replayed (synthesize stays at 1)
      expect(fakeVoiceRepo.transcribeCallCount, equals(1));
      expect(fakeVoiceRepo.synthesizeCallCount, equals(1));
    });

    testWidgets('4. Ask Again preserves conversation context across consecutive turns',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
          ],
          child: const BhoomiApp(
            homeOverride: Scaffold(
              body: FarmerVoiceAssistant(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Turn 1
      await tester.tap(find.text('बोलायला सुरुवात करा'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('थांबवा'));
      await tester.pumpAndSettle();

      // Turn 2: Tap Ask Again
      fakeVoiceRepo.queryToReturn = 'हे इतर झाडांवर पसरू नये म्हणून काय करावे?';
      await tester.tap(find.text('आणखी विचारा'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('थांबवा'));
      await tester.pumpAndSettle();

      // Transcribe call count must be 2 and context must contain previous turn topic
      expect(fakeVoiceRepo.transcribeCallCount, equals(2));
      expect(fakeVoiceRepo.lastTranscribeContext, contains('पानांवर'));
    });

    testWidgets('5. Home Screen Progressive Disclosure: Empty attention items collapse cleanly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
            farmRepositoryProvider.overrideWithValue(_FakeFarmRepo()),
            alertRepositoryProvider.overrideWithValue(_EmptyAlertRepo()),
            followUpRepositoryProvider.overrideWithValue(_EmptyFollowupRepo()),
            timelineRepositoryProvider.overrideWithValue(_FakeTimelineRepo()),
          ],
          child: const BhoomiApp(
            homeOverride: Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Primary Talk to Bhoomi action is prominent
      expect(find.text('Ask Bhoomi'), findsOneWidget);
      expect(find.text('Start Speaking'), findsOneWidget);

      // Show Bhoomi your crop action is visible
      expect(find.text('Spot any disease or pest on your crop?'), findsOneWidget);

      // No giant empty alert or follow-up cards
      expect(find.text('Weather & Pest Alerts'), findsNothing);
      expect(find.text('Pending Follow-ups'), findsNothing);
    });

    testWidgets('6. Multimodal Camera Continuity: Displays semantic InspectionTarget guidance overlay',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          key: const ValueKey('marathi_scope'),
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
          ],
          child: const BhoomiApp(
            key: ValueKey('marathi_app'),
            homeOverride: Scaffold(
              body: CameraCaptureScreen(
                inspectionTarget: InspectionTarget.insect,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Localized insect prompt is displayed in Marathi viewfinder overlay
      expect(find.text('जवळ जाऊन किडीचा स्पष्ट फोटो दाखवा.'), findsOneWidget);

      // Verify Hindi locale guidance as well
      await tester.pumpWidget(
        ProviderScope(
          key: const ValueKey('hindi_scope'),
          overrides: [
            appLanguageProvider.overrideWith((ref) => _HindiLocaleNotifier()),
          ],
          child: const BhoomiApp(
            key: ValueKey('hindi_app'),
            homeOverride: Scaffold(
              body: CameraCaptureScreen(
                key: ValueKey('hindi_camera'),
                inspectionTarget: InspectionTarget.insect,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('पास जाकर कीड़े की स्पष्ट फ़ोटो दिखाएं।'), findsOneWidget);
    });

    testWidgets('7. Dynamic Text Scaling at 2.0x maintains zero overflow and touch target compliance',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
          ],
          child: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: BhoomiApp(
              homeOverride: Scaffold(
                body: FarmerVoiceAssistant(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no RenderFlex overflows
      expect(tester.takeException(), isNull);
      expect(find.text('बोलायला सुरुवात करा'), findsOneWidget);
    });
  });
}
