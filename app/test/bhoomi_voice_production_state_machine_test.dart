import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/core/utils/audio_recording_service.dart';
import 'package:bhoomi/core/utils/audio_playback_service.dart';
import 'package:bhoomi/providers/repository_providers.dart';
import 'package:bhoomi/widgets/farmer_voice_assistant.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_button.dart';
import 'package:bhoomi/widgets/voice/bhoomi_waveform.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_transcript.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_error.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_permission.dart';
import 'package:bhoomi/repositories/voice_repository.dart';
import 'package:bhoomi/models/voice_models.dart';

class _EnglishLocaleNotifier extends LocaleNotifier {
  _EnglishLocaleNotifier() : super() {
    state = AppLanguage.english;
  }
}

class _FakeVoiceRepo extends VoiceRepository {
  @override
  Future<VoiceTranscribeResult> transcribe({
    required String assetId,
    String lang = 'en-IN',
    String? context,
  }) async {
    return const VoiceTranscribeResult(
      text: 'There are brown spots on my leaves.',
      confidence: 0.95,
      lang: 'en-IN',
    );
  }

  @override
  Future<VoiceSynthesizeResult> synthesize({
    required String text,
    String lang = 'en-IN',
  }) async {
    return const VoiceSynthesizeResult(
      audioUrl: 'https://bhoomi-s3.gov.in/voice/bhoomi_speaks.mp3',
      expiresIn: 600,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bhoomi Phase 3 Production Voice State Machine & Interaction QA', () {
    test('1. AudioRecordingService: Concurrency & Amplitude Guarantees', () async {
      final service = AudioRecordingService();

      // Starts recording
      final path = await service.startRecording();
      expect(path, isNotEmpty);
      expect(service.isCurrentlyRecording, isTrue);

      // Guard: Second start call should not throw or duplicate
      final dupPath = await service.startRecording();
      expect(dupPath, equals(path));

      // Amplitude check
      final amp = await service.getNormalizedAmplitude();
      expect(amp, inInclusiveRange(0.0, 1.0));

      // Stops recording
      final data = await service.stopRecording();
      expect(data, isNotNull);
      expect(data!.bytes, isNotEmpty);
      expect(service.isCurrentlyRecording, isFalse);

      // Guard: Stopping already stopped recording returns null safely
      final dupStop = await service.stopRecording();
      expect(dupStop, isNull);
    });

    test('2. AudioPlaybackService: Exclusivity and State Tracking', () async {
      final service = AudioPlaybackService();
      expect(service.isPlaying, isFalse);

      await service.playUrl('https://s3.bhoomi.farm/audio/test.wav');
      expect(service.isPlaying, isTrue);

      await service.pause();
      expect(service.isPlaying, isFalse);

      await service.resume();
      expect(service.isPlaying, isTrue);

      await service.stop();
      expect(service.isPlaying, isFalse);
    });

    testWidgets('3. BhoomiWaveform: Dynamic Amplitude & Silence Awareness', (tester) async {
      // Test Silence Amplitude (0.0) -> Rests at minHeight
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BhoomiWaveform(
              amplitude: 0.0,
              minHeight: 6.0,
              maxHeight: 28.0,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(BhoomiWaveform), findsOneWidget);

      // Test Loud Amplitude (0.9)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BhoomiWaveform(
              amplitude: 0.9,
              minHeight: 6.0,
              maxHeight: 28.0,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(BhoomiWaveform), findsOneWidget);
    });

    testWidgets('4. FarmerVoiceAssistant: Full Voice-First Recording & Processing Journey',
        (tester) async {
      String? submittedQuery;
      bool cameraHandoffTriggered = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => _EnglishLocaleNotifier()),
            voiceRepositoryProvider.overrideWithValue(_FakeVoiceRepo()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FarmerVoiceAssistant(
                initialContext: 'rice_blast',
                onQuerySubmitted: (q) => submittedQuery = q,
                onShowPhoto: () => cameraHandoffTriggered = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // State 1: IDLE / Ready
      expect(find.text('Bhoomi Voice Assistant'), findsOneWidget);
      expect(find.byType(BhoomiVoiceButton), findsOneWidget);

      // Tap Mic to start recording -> Transitions to RECORDING
      await tester.tap(find.byType(BhoomiVoiceButton));
      await tester.pump();

      // State 2: RECORDING (Shows Live Timer & Stop CTA)
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);

      // Tap Stop -> Transitions to PROCESSING -> TRANSCRIPTION_CONFIRMATION
      await tester.tap(find.text('Stop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // State 3: TRANSCRIPTION_CONFIRMATION
      expect(find.text('Your Question'), findsOneWidget);
      expect(find.text("Ask Another Question"), findsOneWidget);
      expect(find.text("Submit Query"), findsOneWidget);

      // Test Contextual Camera Handoff Action (detected 'leaves')
      expect(find.text('Show the affected leaf clearly.'), findsOneWidget);
      await tester.tap(find.text('Show the affected leaf clearly.'));
      await tester.pump();
      expect(cameraHandoffTriggered, isTrue);

      // Test Confirm Action
      await tester.tap(find.text("Submit Query"));
      await tester.pump();
      expect(submittedQuery, isNotNull);
    });

    testWidgets('5. Language Synchronization: Marathi, Hindi, English Locales', (tester) async {
      // Marathi test
      final mrStrings = AppStrings(AppLanguage.marathi);
      expect(mrStrings.voiceIHeard, equals('मी ऐकले:'));
      expect(mrStrings.voiceTapToStop, equals('थांबवण्यासाठी टॅप करा'));
      expect(mrStrings.voiceSoundsRight, equals('बरोबर आहे'));
      expect(mrStrings.voiceShowAffectedLeaf, equals('बाधित पान दाखवा'));

      // Hindi test
      final hiStrings = AppStrings(AppLanguage.hindi);
      expect(hiStrings.voiceIHeard, equals('मैंने सुना:'));
      expect(hiStrings.voiceTapToStop, equals('रोकने के लिए टैप करें'));
      expect(hiStrings.voiceSoundsRight, equals('सही है'));
      expect(hiStrings.voiceShowAffectedLeaf, equals('प्रभावित पत्ता दिखाएं'));

      // English test
      final enStrings = AppStrings(AppLanguage.english);
      expect(enStrings.voiceIHeard, equals('I heard:'));
      expect(enStrings.voiceTapToStop, equals('Tap to stop'));
      expect(enStrings.voiceSoundsRight, equals('Sounds right'));
      expect(enStrings.voiceShowAffectedLeaf, equals('Show me the affected leaf'));
    });

    testWidgets('6. Accessibility & 2.0x Dynamic Text Scaling Audit', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: BhoomiVoiceTranscript(
                    text: 'पानांवर करड्या रंगाचे ठिपके पडले आहेत',
                    strings: AppStrings(AppLanguage.marathi),
                    onConfirm: (_) {},
                    onRetry: () {},
                    onShowPhoto: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verifies no render overflow or clipping under 2.0x scale
      expect(tester.takeException(), isNull);
      expect(find.text('मी ऐकले:'), findsOneWidget);
      expect(find.text('बरोबर आहे'), findsOneWidget);
      expect(find.text('बाधित पान दाखवा'), findsOneWidget);
    });

    testWidgets('7. BhoomiVoicePermission: Permission Handling & App Settings Recovery',
        (tester) async {
      bool tryAgainPressed = false;
      bool showCropPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BhoomiVoicePermission(
              isPermanentlyDenied: false,
              strings: AppStrings(AppLanguage.english),
              onRequestPermission: () => tryAgainPressed = true,
              onShowCrop: () => showCropPressed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('I need microphone access to hear you.'), findsOneWidget);
      expect(find.text('Grant Permission'), findsOneWidget);

      await tester.tap(find.text('Grant Permission'));
      await tester.pump();
      expect(tryAgainPressed, isTrue);

      expect(find.text('Please show me the crop'), findsOneWidget);
      await tester.tap(find.text('Please show me the crop'));
      await tester.pump();
      expect(showCropPressed, isTrue);
    });

    testWidgets('8. BhoomiVoiceError: Humanized Error Recovery Options', (tester) async {
      bool retried = false;
      bool typed = false;
      bool cropShown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BhoomiVoiceError(
              message: "Please speak slowly and clearly.",
              strings: AppStrings(AppLanguage.english),
              onRetry: () => retried = true,
              onTypeInstead: () => typed = true,
              onShowCrop: () => cropShown = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text("I couldn't hear you clearly."), findsOneWidget);
      expect(find.text("Please speak slowly and clearly."), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Please show me the crop'), findsOneWidget);
      expect(find.text('Type instead'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(retried, isTrue);

      await tester.tap(find.text('Type instead'));
      await tester.pump();
      expect(typed, isTrue);

      await tester.tap(find.text('Please show me the crop'));
      await tester.pump();
      expect(cropShown, isTrue);
    });
  });
}
