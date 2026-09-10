import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/core/utils/audio_playback_service.dart';
import 'package:bhoomi/models/inspection_target.dart';
import 'package:bhoomi/models/conversation_context_manager.dart';
import 'package:bhoomi/models/voice_models.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/repositories/voice_repository.dart';
import 'package:bhoomi/widgets/farmer_voice_assistant.dart';
import 'package:bhoomi/widgets/app_button.dart';

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

class FakeAudioPlayerWrapper implements AudioPlayerWrapper {
  PlayerState _state = PlayerState.stopped;
  final StreamController<PlayerState> _stateController = StreamController<PlayerState>.broadcast();
  final StreamController<void> _completeController = StreamController<void>.broadcast();
  int stopCallCount = 0;
  int playCallCount = 0;

  void triggerComplete() {
    _state = PlayerState.completed;
    _completeController.add(null);
  }

  @override
  PlayerState get state => _state;

  @override
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;

  @override
  Stream<Duration> get onPositionChanged => const Stream.empty();

  @override
  Stream<Duration> get onDurationChanged => const Stream.empty();

  @override
  Stream<void> get onPlayerComplete => _completeController.stream;

  @override
  Future<void> play(Source source) async {
    playCallCount++;
    _state = PlayerState.playing;
    _stateController.add(PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    _state = PlayerState.paused;
    _stateController.add(PlayerState.paused);
  }

  @override
  Future<void> resume() async {
    _state = PlayerState.playing;
    _stateController.add(PlayerState.playing);
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    _state = PlayerState.stopped;
    _stateController.add(PlayerState.stopped);
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> dispose() async {
    _stateController.close();
    _completeController.close();
  }
}

class _FakeVoiceRepo extends VoiceRepository {
  int transcribeCallCount = 0;
  int synthesizeCallCount = 0;
  String? lastTranscribeContext;
  String queryToReturn = 'सोयाबीनच्या पानांवर करडे डाग दिसत आहेत';

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
      confidence: 0.98,
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
      audioUrl: 'https://bhoomi-s3.gov.in/voice/phase7_advisory.mp3',
      expiresIn: 600,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bhoomi Phase 7: Farmer UX Hardening, Context Safety & Acceptance Tests', () {
    test('1. Semantic Context Preservation across Turn 1 -> Turn 2 -> Turn 3', () {
      final contextManager = FarmerConversationContext();

      // Turn 1: Initial problem
      contextManager.processTurn('My soybean leaves have spots.');
      expect(contextManager.activeCrop, equals('soybean'));
      expect(contextManager.currentIssue, equals('leaf spots'));
      expect(contextManager.inspectionTarget, equals(InspectionTarget.leaf));
      expect(contextManager.boundedTurns.length, equals(1));

      // Turn 2: Follow-up question without re-stating crop
      contextManager.processTurn('What caused it?');
      expect(contextManager.activeCrop, equals('soybean')); // Preserved!
      expect(contextManager.currentIssue, equals('leaf spots')); // Preserved!
      expect(contextManager.inspectionTarget, equals(InspectionTarget.leaf)); // Preserved!
      expect(contextManager.boundedTurns.length, equals(2));

      // Turn 3: Actionable follow-up
      contextManager.processTurn('What should I do?');
      expect(contextManager.activeCrop, equals('soybean')); // Preserved!
      expect(contextManager.currentIssue, equals('leaf spots')); // Preserved!
      expect(contextManager.boundedTurns.length, equals(3));

      final assembled = contextManager.toContextString();
      expect(assembled, contains('Crop: soybean'));
      expect(assembled, contains('Issue: leaf spots'));
      expect(assembled, contains('Target: leaf'));
      expect(assembled, contains('What caused it? -> What should I do?'));
    });

    test('2. Crop Topic Switching Safety (Mention vs Comparison vs Explicit Switch)', () {
      final contextManager = FarmerConversationContext();
      contextManager.processTurn('My soybean crop is showing yellowing.');
      expect(contextManager.activeCrop, equals('soybean'));
      expect(contextManager.currentIssue, equals('yellowing'));

      // 2A: Crop mention in general context (no switch trigger)
      contextManager.processTurn('My farm has soybean and cotton.');
      expect(contextManager.activeCrop, equals('soybean')); // Should NOT switch!

      // 2B: Comparison question across crops
      contextManager.processTurn('Does the disease on soybean also affect cotton?');
      expect(contextManager.activeCrop, equals('soybean')); // Should NOT switch!

      // 2C: Marathi comparison question
      contextManager.processTurn('हा रोग कापसावर पण पसरतो का?');
      expect(contextManager.activeCrop, equals('soybean')); // Should NOT switch!

      // 2D: Explicit Crop Switch
      contextManager.processTurn('Now tell me about my cotton crop.');
      expect(contextManager.activeCrop, equals('cotton')); // Switched safely!
      expect(contextManager.currentIssue, isNull); // Old issue purged!
      expect(contextManager.boundedTurns.length, equals(1));

      // 2E: Ambiguous query retains new active crop
      contextManager.processTurn('Leaves have rust on them.');
      expect(contextManager.activeCrop, equals('cotton')); // Preserved cotton
      expect(contextManager.currentIssue, equals('rust'));

      // 2F: Explicit Switch in Marathi after diagnosis
      contextManager.recordDiagnosis(
        diagnosis: 'Cotton Rust',
        issue: 'rust',
        target: InspectionTarget.leaf,
      );
      expect(contextManager.diagnosisSummary, equals('Cotton Rust'));

      contextManager.processTurn('आता मला गव्हाबद्दल सांगा.');
      expect(contextManager.activeCrop, equals('wheat'));
      expect(contextManager.diagnosisSummary, isNull); // Purged old diagnosis!
      expect(contextManager.currentIssue, isNull); // Purged old issue!
    });

    test('3. InspectionTarget Functional Framing Prompts & Iconography across MR, HI, EN', () {
      final mr = const AppStrings(AppLanguage.marathi);
      final hi = const AppStrings(AppLanguage.hindi);
      final en = const AppStrings(AppLanguage.english);

      // Leaf
      expect(InspectionTarget.leaf.getLocalizedPrompt(en), equals('Show the affected leaf clearly.'));
      expect(InspectionTarget.leaf.getLocalizedPrompt(mr), equals('बाधित पानाचा स्पष्ट फोटो दाखवा.'));
      expect(InspectionTarget.leaf.getLocalizedPrompt(hi), equals('प्रभावित पत्ते की स्पष्ट फ़ोटो दिखाएं।'));
      expect(InspectionTarget.leaf.framingIcon, equals(Icons.eco_rounded));

      // Insect
      expect(InspectionTarget.insect.getLocalizedPrompt(en), equals('Move closer so the insect is visible.'));
      expect(InspectionTarget.insect.getLocalizedPrompt(mr), equals('जवळ जाऊन किडीचा स्पष्ट फोटो दाखवा.'));
      expect(InspectionTarget.insect.getLocalizedPrompt(hi), equals('पास जाकर कीड़े की स्पष्ट फ़ोटो दिखाएं।'));
      expect(InspectionTarget.insect.framingIcon, equals(Icons.pest_control_rounded));

      // Whole Plant
      expect(InspectionTarget.wholePlant.getLocalizedPrompt(en), equals('Fit the whole plant inside the frame.'));
      expect(InspectionTarget.wholePlant.getLocalizedPrompt(mr), equals('संपूर्ण रोप/झाड फ्रेममध्ये दाखवा.'));
      expect(InspectionTarget.wholePlant.getLocalizedPrompt(hi), equals('पूरे पौधे को फ्रेम के अंदर दिखाएं।'));
      expect(InspectionTarget.wholePlant.framingIcon, equals(Icons.nature_rounded));

      // Unknown
      expect(InspectionTarget.unknown.getLocalizedPrompt(en), equals('Show a clear photo of the crop and affected area.'));
      expect(InspectionTarget.unknown.getLocalizedPrompt(mr), equals('पिकाचा आणि बाधित भागाचा स्पष्ट फोटो दाखवा.'));
      expect(InspectionTarget.unknown.getLocalizedPrompt(hi), equals('फसल और प्रभावित हिस्से की स्पष्ट फ़ोटो दिखाएं।'));
      expect(InspectionTarget.unknown.framingIcon, equals(Icons.center_focus_strong_rounded));

      // Fruit / Stem / Root / Soil
      expect(InspectionTarget.fruit.getLocalizedPrompt(en), equals('Show the affected fruit or pod clearly.'));
      expect(InspectionTarget.stem.getLocalizedPrompt(en), equals('Show the affected stem or branch clearly.'));
      expect(InspectionTarget.root.getLocalizedPrompt(en), equals('Show the roots clearly after gentle cleaning.'));
      expect(InspectionTarget.soil.getLocalizedPrompt(en), equals('Show the soil surface and moisture condition clearly.'));
    });

    test('4. Photo Capture Continuity & Localized Feedback Strings', () {
      final mr = const AppStrings(AppLanguage.marathi);
      final hi = const AppStrings(AppLanguage.hindi);
      final en = const AppStrings(AppLanguage.english);

      expect(mr.checkingPhotoTitle, equals('धन्यवाद. मी आता फोटो तपासत आहे...'));
      expect(hi.checkingPhotoTitle, equals('धन्यवाद। मैं अभी फ़ोटो की जाँच कर रही हूँ...'));
      expect(en.checkingPhotoTitle, equals("Thank you. I'm checking the photo now."));
    });

    testWidgets('5. Voice Speaking Interruption Semantics (Pause vs Ask Bhoomi Audio Exclusivity)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();
      final fakePlayerWrapper = FakeAudioPlayerWrapper();
      final enStrings = const AppStrings(AppLanguage.english);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
            audioPlaybackServiceProvider.overrideWithValue(
              AudioPlaybackService(player: fakePlayerWrapper),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FarmerVoiceAssistant(
                initialContext: 'Soybean',
                onQuerySubmitted: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Start recording
      await tester.tap(find.text(enStrings.voiceHeroCta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(enStrings.voiceStopRecording), findsOneWidget);

      // Step 2: Stop recording to process
      await tester.tap(find.text(enStrings.voiceStopRecording));
      await tester.pump();
      await tester.pumpAndSettle();

      // Step 3: From Confirmation, tap "Listen to Advice" / Synthesize
      await tester.tap(find.text(enStrings.listenSpokenSummary));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify speaking state is active and audio player played
      expect(fakePlayerWrapper.playCallCount, greaterThanOrEqualTo(1));
      expect(find.text(enStrings.voicePlayingAudio), findsOneWidget);

      // Verify [ Pause ] button is visible
      final pauseBtn = find.text(enStrings.voicePauseAnswer);
      expect(pauseBtn, findsOneWidget);

      // Verify [ Ask Bhoomi again ] button is present
      final askAgainBtn = find.text(enStrings.voiceAskAgain);
      expect(askAgainBtn, findsOneWidget);

      // Tap [ Ask Bhoomi again ] to interrupt speaking and start listening
      await tester.tap(askAgainBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify audio playback was immediately stopped
      expect(fakePlayerWrapper.stopCallCount, greaterThanOrEqualTo(1));
    });

    testWidgets('6. Language Change during Audio Playback Stops Previous Audio', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();
      final fakePlayerWrapper = FakeAudioPlayerWrapper();
      final enStrings = const AppStrings(AppLanguage.english);

      final container = ProviderContainer(
        overrides: [
          appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
          voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
          audioPlaybackServiceProvider.overrideWithValue(
            AudioPlaybackService(player: fakePlayerWrapper),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: FarmerVoiceAssistant(
                initialContext: 'Paddy',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Start recording
      await tester.tap(find.text(enStrings.voiceHeroCta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2: Stop recording to process
      await tester.tap(find.text(enStrings.voiceStopRecording));
      await tester.pump();
      await tester.pumpAndSettle();

      // Step 3: Start speaking playback
      await tester.tap(find.text(enStrings.listenSpokenSummary));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(fakePlayerWrapper.playCallCount, greaterThanOrEqualTo(1));

      // Change language via provider container
      final prevStopCount = fakePlayerWrapper.stopCallCount;
      container.read(appLanguageProvider.notifier).setLanguage(AppLanguage.hindi);
      await tester.pumpAndSettle();

      // Verify stop was called to ensure audio exclusivity
      expect(fakePlayerWrapper.stopCallCount, greaterThan(prevStopCount));
    });

    testWidgets('7. Extreme Dynamic Text Scaling Audit at 2.0x for Completed & Action Cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();
      final fakePlayerWrapper = FakeAudioPlayerWrapper();
      final mrStrings = const AppStrings(AppLanguage.marathi);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
            audioPlaybackServiceProvider.overrideWithValue(
              AudioPlaybackService(player: fakePlayerWrapper),
            ),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 800),
              textScaler: TextScaler.linear(2.0), // 2.0x Large Accessibility Scale
            ),
            child: const MaterialApp(
              home: Scaffold(
                body: FarmerVoiceAssistant(
                  initialContext: 'सोयाबीन',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Start recording
      await tester.tap(find.text(mrStrings.voiceHeroCta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2: Stop recording to process
      await tester.tap(find.text(mrStrings.voiceStopRecording));
      await tester.pump();
      await tester.pumpAndSettle();

      // Step 3: Listen audio (scroll into view if needed)
      final listenFinder = find.text(mrStrings.listenSpokenSummary);
      await tester.ensureVisible(listenFinder);
      await tester.tap(listenFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Step 4: Complete audio
      fakePlayerWrapper.triggerComplete();
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify all completed actions render without RenderFlex overflow
      expect(tester.takeException(), isNull);
      expect(find.byType(AppButton), findsWidgets);
    });
  });
}
