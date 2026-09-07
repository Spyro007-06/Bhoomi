import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/main.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/core/utils/audio_playback_service.dart';
import 'package:bhoomi/models/inspection_target.dart';
import 'package:bhoomi/models/voice_models.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/repositories/voice_repository.dart';
import 'package:bhoomi/widgets/farmer_voice_assistant.dart';
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


class FakeAudioPlayerWrapper implements AudioPlayerWrapper {
  PlayerState _state = PlayerState.stopped;
  final StreamController<PlayerState> _stateController = StreamController<PlayerState>.broadcast();
  final StreamController<void> _completeController = StreamController<void>.broadcast();

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
    _state = PlayerState.playing;
  }

  @override
  Future<void> pause() async {
    _state = PlayerState.paused;
  }

  @override
  Future<void> resume() async {
    _state = PlayerState.playing;
  }

  @override
  Future<void> stop() async {
    _state = PlayerState.stopped;
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
  String queryToReturn = 'सोयाबीनच्या पानांवर डाग दिसत आहेत';

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
      audioUrl: 'https://bhoomi-s3.gov.in/voice/phase6_advice.mp3',
      expiresIn: 600,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bhoomi Phase 6: Real-World Voice QA & Conversation Refinement Tests', () {
    test('1. Localized Listening Strings Quality across MR, HI, EN', () {
      final mr = const AppStrings(AppLanguage.marathi);
      final hi = const AppStrings(AppLanguage.hindi);
      final en = const AppStrings(AppLanguage.english);

      expect(mr.voiceListening, equals('Bhoomi ऐकत आहे...'));
      expect(hi.voiceListening, equals('Bhoomi सुन रही है...'));
      expect(en.voiceListening, equals('Bhoomi is listening...'));
    });

    test('2. InspectionTarget.unknown localized prompt & framing icons', () {
      final mr = const AppStrings(AppLanguage.marathi);
      final hi = const AppStrings(AppLanguage.hindi);
      final en = const AppStrings(AppLanguage.english);

      expect(
        InspectionTarget.unknown.getLocalizedPrompt(mr),
        equals('पिकाचा आणि बाधित भागाचा स्पष्ट फोटो दाखवा.'),
      );
      expect(
        InspectionTarget.unknown.getLocalizedPrompt(hi),
        equals('फसल और प्रभावित हिस्से की स्पष्ट फ़ोटो दिखाएं।'),
      );
      expect(
        InspectionTarget.unknown.getLocalizedPrompt(en),
        equals('Show a clear photo of the crop and affected area.'),
      );

      // Verify framing icons
      expect(InspectionTarget.leaf.framingIcon, equals(Icons.eco_rounded));
      expect(InspectionTarget.insect.framingIcon, equals(Icons.pest_control_rounded));
      expect(InspectionTarget.wholePlant.framingIcon, equals(Icons.nature_rounded));
      expect(InspectionTarget.unknown.framingIcon, equals(Icons.center_focus_strong_rounded));
    });

    testWidgets('3. Completed State CTA Hierarchy (Primary, Secondary, Tertiary)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();
      final fakePlayerWrapper = FakeAudioPlayerWrapper();
      final enStrings = const AppStrings(AppLanguage.english);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
            audioPlaybackServiceProvider.overrideWithValue(AudioPlaybackService(player: fakePlayerWrapper)),
            appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
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

      // Verify speaking state shows pause and ask again buttons
      expect(find.text(enStrings.voiceAskAgain), findsOneWidget);
      expect(find.text(enStrings.voicePauseAnswer), findsOneWidget);

      // Step 4: Simulate audio playback completion -> transitions to Completed state
      fakePlayerWrapper.triggerComplete();
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Completed State CTA Hierarchy:
      // PRIMARY: Ask Bhoomi again
      expect(find.text(enStrings.voiceAskAgainConversational), findsOneWidget);
      // SECONDARY: Show Crop
      expect(find.text(InspectionTarget.leaf.getLocalizedPrompt(enStrings)), findsOneWidget);
      // TERTIARY: Hear again & Read on screen
      expect(find.text(enStrings.voiceHearAgainConversational), findsOneWidget);
      expect(find.text(enStrings.voiceReadOnScreen), findsOneWidget);
    });

    testWidgets('4. Safe Context Boundary & Crop Topic Switching (Soybean -> Cotton)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();
      final enStrings = const AppStrings(AppLanguage.english);
      fakeVoiceRepo.queryToReturn = 'My soybean crop has leaf spots';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
            appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
          ],
          child: const BhoomiApp(
            homeOverride: Scaffold(
              body: FarmerVoiceAssistant(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Turn 1: Soybean query
      await tester.tap(find.text(enStrings.voiceHeroCta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(enStrings.voiceStopRecording));
      await tester.pump();
      await tester.pumpAndSettle();

      // Turn 2: Follow-up question ("What to do?")
      fakeVoiceRepo.queryToReturn = 'What should I do?';
      await tester.tap(find.text(enStrings.voiceAskAgain));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(enStrings.voiceStopRecording));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify context retained soybean
      expect(fakeVoiceRepo.lastTranscribeContext, contains('soybean'));

      // Turn 3: Topic switch to cotton
      fakeVoiceRepo.queryToReturn = 'My cotton crop is wilting';
      await tester.tap(find.text(enStrings.voiceAskAgain));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(enStrings.voiceStopRecording));
      await tester.pump();
      await tester.pumpAndSettle();

      // Turn 4: Follow-up question on cotton
      fakeVoiceRepo.queryToReturn = 'Which organic spray should I use?';
      await tester.tap(find.text(enStrings.voiceAskAgain));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(enStrings.voiceStopRecording));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify context switched to cotton and purged obsolete soybean context
      expect(fakeVoiceRepo.lastTranscribeContext, contains('cotton'));
      expect(fakeVoiceRepo.lastTranscribeContext, isNot(contains('soybean')));
    });

    testWidgets('5. Camera capture screen displays target framing icon & localized prompt', (tester) async {
      final strings = const AppStrings(AppLanguage.marathi);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
          ],
          child: MaterialApp(
            home: CameraCaptureScreen(
              inspectionTarget: InspectionTarget.insect,
              contextualGuidance: InspectionTarget.insect.getLocalizedPrompt(strings),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify insect framing icon and localized prompt are rendered
      expect(find.byIcon(Icons.pest_control_rounded), findsOneWidget);
      expect(find.text(strings.voiceShowInsectsContextual), findsOneWidget);
    });

    testWidgets('6. Dynamic text scaling audit at 2.0x on Voice Assistant', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeVoiceRepo = _FakeVoiceRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceRepositoryProvider.overrideWithValue(fakeVoiceRepo),
            appLanguageProvider.overrideWith((ref) => _MarathiLocaleNotifier()),
          ],
          child: const BhoomiApp(
            homeOverride: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: FarmerVoiceAssistant(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow occurs with 2.0x text scaling
      expect(tester.takeException(), isNull);
      expect(find.byType(FarmerVoiceAssistant), findsOneWidget);
    });
  });
}
