import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/main.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/repositories/voice_repository.dart';
import 'package:bhoomi/repositories/asset_repository.dart';
import 'package:bhoomi/repositories/farm_repository.dart';
import 'package:bhoomi/repositories/alert_repository.dart';
import 'package:bhoomi/repositories/followup_repository.dart';
import 'package:bhoomi/repositories/timeline_repository.dart';
import 'package:bhoomi/models/voice_models.dart';
import 'package:bhoomi/models/asset_models.dart';
import 'package:bhoomi/models/farm_models.dart';
import 'package:bhoomi/models/alert_models.dart';
import 'package:bhoomi/models/followup_models.dart';
import 'package:bhoomi/models/timeline_models.dart';
import 'package:bhoomi/widgets/farmer_voice_assistant.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_button.dart';
import 'package:bhoomi/features/home/presentation/home_screen.dart';
import 'package:bhoomi/features/diagnose/presentation/camera_capture_screen.dart';

class _MarathiLocaleNotifier extends LocaleNotifier {
  _MarathiLocaleNotifier() : super() {
    state = AppLanguage.marathi;
  }
}

class _EnglishLocaleNotifier extends LocaleNotifier {
  _EnglishLocaleNotifier() : super() {
    state = AppLanguage.english;
  }
}

class _FakeVoiceRepo extends VoiceRepository {
  String transcriptionText;

  _FakeVoiceRepo({this.transcriptionText = 'टोमॅटोच्या पानांवर काळे ठिपके दिसत आहेत.'});

  @override
  Future<VoiceTranscribeResult> transcribe({
    required String assetId,
    String lang = 'mr-IN',
    String? context,
  }) async {
    return VoiceTranscribeResult(
      text: transcriptionText,
      confidence: 0.95,
      lang: lang,
    );
  }

  @override
  Future<VoiceSynthesizeResult> synthesize({
    required String text,
    String lang = 'mr-IN',
  }) async {
    return const VoiceSynthesizeResult(
      audioUrl: 'https://bhoomi-s3.gov.in/voice/synthesized.mp3',
      expiresIn: 600,
    );
  }
}

class _FakeAssetRepo extends AssetRepository {
  @override
  Future<PresignedAssetModel> presignAsset({
    required String kind,
    required String contentType,
    String? farmId,
  }) async {
    return const PresignedAssetModel(
      assetId: 'ast_1',
      uploadUrl: 'https://s3.example.com',
      expiresIn: 300,
    );
  }

  @override
  Future<void> uploadBinary({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
    void Function(int count, int total)? onProgress,
  }) async {}

  @override
  Future<String> uploadImage({
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    String? farmId,
    void Function(int count, int total)? onProgress,
  }) async => 'test_image_asset_123';

  @override
  Future<String> uploadAudio({
    required Uint8List bytes,
    String contentType = 'audio/wav',
    String? farmId,
    void Function(int count, int total)? onProgress,
  }) async => 'test_audio_asset_999';
}

class _FakeFarmRepo extends FarmRepository {
  @override
  Future<FarmSummaryModel> getFarmSummary(String farmId) async {
    return const FarmSummaryModel(
      farm: FarmModel(
        id: 'f_1',
        crop: 'Paddy',
        variety: 'Indrayani',
        growthStage: 'Tillering',
        region: 'Nashik',
      ),
      health: HealthModel(sentence: 'Crop health is good.', trend: 'stable'),
      activeProblemsCount: 0,
      pendingFollowUpsCount: 0,
      activeAlertsCount: 0,
    );
  }

  @override
  Future<FarmModel> createFarm({required String crop, String? variety, required String growthStage, required String region, required GeoPoint location}) =>
      throw UnimplementedError();

  @override
  Future<FarmModel> getFarm(String farmId) => throw UnimplementedError();

  @override
  Future<FarmModel> updateFarm(String farmId, Map<String, dynamic> updates) => throw UnimplementedError();
}

class _FakeAlertRepo extends AlertRepository {
  @override
  Future<AlertsResponse> getAlerts({required String farmId, int limit = 20, String? cursor}) async {
    return const AlertsResponse(alerts: [
      AlertModel(
        id: 'alt_1',
        farmId: 'f_1',
        triggerType: 'weather_pest',
        target: 'stem_borer',
        riskLevel: 'high',
        reason: 'High humidity risk',
        createdAt: '2026-09-07T00:00:00Z',
        inspectionTasks: ['Check the lower stems on 10 plants'],
      ),
    ]);
  }

  @override
  Future<AlertRespondResponse> respondToAlert({required String alertId, required String outcome, String? imageAssetId}) async {
    return const AlertRespondResponse(status: 'recorded', alertId: 'alt_1', recordedAt: '2026-08-31');
  }
}

class _FakeFollowupRepo extends FollowUpRepository {
  @override
  Future<PendingFollowUpsResponse> getPendingFollowUps(String farmId) async {
    return const PendingFollowUpsResponse(followUps: []);
  }

  @override
  Future<FollowUpResultModel> respondToFollowUp({required String followUpId, required String response, String? imageAssetId}) async {
    return const FollowUpResultModel(status: 'success');
  }
}

class _FakeTimelineRepo extends TimelineRepository {
  @override
  Future<TimelineResponse> getTimeline({required String farmId, int limit = 20, String? cursor}) async {
    return const TimelineResponse(events: []);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bhoomi Phase 4: Conversational Voice UX & Home Experience Tests', () {
    testWidgets('1. Voice Assistant flows to Completed state with clear continuation CTAs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool cameraHandoffCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(_FakeVoiceRepo()),
            assetRepositoryProvider.overrideWithValue(_FakeAssetRepo()),
          ],
          child: BhoomiApp(
            homeOverride: Scaffold(
              body: FarmerVoiceAssistant(
                initialContext: 'पानांवरील करपा',
                onShowPhoto: () {
                  cameraHandoffCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Tap to record
      expect(find.text('Bhoomi Voice Assistant'), findsOneWidget);
      await tester.tap(find.byType(BhoomiVoiceButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Step 2: Stop recording
      expect(find.text('थांबवा'), findsOneWidget);
      await tester.tap(find.text('थांबवा'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Step 3: Transcription confirmation state
      expect(find.text('तुमचा प्रश्न'), findsOneWidget);
      expect(find.text('टोमॅटोच्या पानांवर काळे ठिपके दिसत आहेत.'), findsOneWidget);

      // Verify contextual leaf camera recommendation was generated
      expect(find.text('बाधित पानाचा स्पष्ट फोटो दाखवा.'), findsOneWidget);

      // Step 4: Play advisory audio
      await tester.tap(find.text('सल्ला ऐका (Listen)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('सल्ला ऐकत आहात'), findsOneWidget);

      // Tap Show Crop -> invokes camera handoff
      await tester.tap(find.text('बाधित पानाचा स्पष्ट फोटो दाखवा.'));
      await tester.pump();
      expect(cameraHandoffCalled, isTrue);

      // Tap Ask Again -> returns to listening mode cleanly
      await tester.tap(find.text('आणखी विचारा'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('थांबवा'), findsOneWidget);
    });

    testWidgets('2. Contextual camera recommendation dynamically adapts to insect/pest queries',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(
              _FakeVoiceRepo(transcriptionText: 'कपाशीवर पांढरी माशी आणि किडीचा प्रादुर्भाव आहे.'),
            ),
            assetRepositoryProvider.overrideWithValue(_FakeAssetRepo()),
          ],
          child: BhoomiApp(
            homeOverride: Scaffold(
              body: FarmerVoiceAssistant(
                onShowPhoto: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Record & Stop
      await tester.tap(find.byType(BhoomiVoiceButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('थांबवा'), findsOneWidget);
      await tester.tap(find.text('थांबवा'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Contextual prompt should be for insects
      expect(find.text('जवळ जाऊन किडीचा स्पष्ट फोटो दाखवा.'), findsOneWidget);
    });

    testWidgets('3. Home Screen strictly implements Talk -> Show -> Today Attention -> Farm Data hierarchy',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool cameraTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
            farmRepositoryProvider.overrideWithValue(_FakeFarmRepo()),
            alertRepositoryProvider.overrideWithValue(_FakeAlertRepo()),
            followUpRepositoryProvider.overrideWithValue(_FakeFollowupRepo()),
            timelineRepositoryProvider.overrideWithValue(_FakeTimelineRepo()),
          ],
          child: BhoomiApp(
            homeOverride: Scaffold(
              body: HomeScreen(
                onCheckCropPressed: () {
                  cameraTapped = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Section 1: Hero Talk to Bhoomi
      expect(find.text('Ask Bhoomi'), findsOneWidget);
      expect(find.text('Ask anything about your crop'), findsOneWidget);

      // Section 2: Show Bhoomi your crop
      expect(find.text('Spot any disease or pest on your crop?'), findsOneWidget);
      expect(find.text('Take photo to check now'), findsOneWidget);

      // Section 3: Alerts Header
      expect(find.text('Weather & Pest Alerts'), findsOneWidget);

      // Tap Show Crop banner
      await tester.tap(find.text('Take photo to check now'));
      await tester.pump();
      expect(cameraTapped, isTrue);
    });

    testWidgets('4. CameraCaptureScreen displays contextualGuidance from voice interaction',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
          ],
          child: const BhoomiApp(
            homeOverride: Scaffold(
              body: CameraCaptureScreen(
                contextualGuidance: 'Can you show me the affected leaves?',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Can you show me the affected leaves?'), findsOneWidget);
    });

    testWidgets('5. Multilingual Localization synchronization (Marathi, Hindi, English)',
        (WidgetTester tester) async {
      final stringsMr = AppStrings(AppLanguage.marathi);
      final stringsHi = AppStrings(AppLanguage.hindi);
      final stringsEn = AppStrings(AppLanguage.english);

      // Verify Finished Speaking
      expect(stringsMr.voiceFinishedSpeaking, 'भूमीचे बोलणे पूर्ण झाले.');
      expect(stringsHi.voiceFinishedSpeaking, 'भूमी का बोलना पूरा हुआ।');
      expect(stringsEn.voiceFinishedSpeaking, 'Bhoomi has finished speaking.');

      // Verify Ask Again Conversational
      expect(stringsMr.voiceAskAgainConversational, 'भूमीला पुन्हा विचारा');
      expect(stringsHi.voiceAskAgainConversational, 'भूमी से फिर पूछें');
      expect(stringsEn.voiceAskAgainConversational, 'Ask Bhoomi again');

      // Verify Contextual Prompts
      expect(stringsMr.voiceShowLeavesContextual, 'बाधित पानाचा स्पष्ट फोटो दाखवा.');
      expect(stringsHi.voiceShowLeavesContextual, 'प्रभावित पत्ते की स्पष्ट फ़ोटो दिखाएं।');
      expect(stringsEn.voiceShowLeavesContextual, 'Show the affected leaf clearly.');

      expect(stringsMr.voiceShowInsectsContextual, 'जवळ जाऊन किडीचा स्पष्ट फोटो दाखवा.');
      expect(stringsHi.voiceShowInsectsContextual, 'पास जाकर कीड़े की स्पष्ट फ़ोटो दिखाएं।');
      expect(stringsEn.voiceShowInsectsContextual, 'Move closer so the insect is visible.');

      expect(stringsMr.voiceShowPlantContextual, 'संपूर्ण रोप/झाड फ्रेममध्ये दाखवा.');
      expect(stringsHi.voiceShowPlantContextual, 'पूरे पौधे को फ्रेम के अंदर दिखाएं।');
      expect(stringsEn.voiceShowPlantContextual, 'Fit the whole plant inside the frame.');
    });

    testWidgets('6. Dynamic text scaling at 2.0x maintains accessibility with zero overflows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            farmRepositoryProvider.overrideWithValue(_FakeFarmRepo()),
            alertRepositoryProvider.overrideWithValue(_FakeAlertRepo()),
            followUpRepositoryProvider.overrideWithValue(_FakeFollowupRepo()),
            timelineRepositoryProvider.overrideWithValue(_FakeTimelineRepo()),
          ],
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: const BhoomiApp(
              homeOverride: Scaffold(
                body: HomeScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
