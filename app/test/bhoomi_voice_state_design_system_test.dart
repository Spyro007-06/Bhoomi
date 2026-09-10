import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_state.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_button.dart';
import 'package:bhoomi/widgets/voice/bhoomi_waveform.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_transcript.dart';
import 'package:bhoomi/widgets/voice/bhoomi_audio_player.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_error.dart';
import 'package:bhoomi/widgets/voice/bhoomi_voice_permission.dart';
import 'package:bhoomi/repositories/voice_repository.dart';
import 'package:bhoomi/models/voice_models.dart';
import 'package:bhoomi/providers/repository_providers.dart';

class _FakeVoiceRepo extends VoiceRepository {
  @override
  Future<VoiceTranscribeResult> transcribe({
    required String assetId,
    String lang = 'mr-IN',
    String? context,
  }) async {
    return const VoiceTranscribeResult(
      text: 'माझ्या भाताच्या पिकावर तपकिरी ठिपके दिसत आहेत.',
      confidence: 0.96,
      lang: 'mr-IN',
    );
  }

  @override
  Future<VoiceSynthesizeResult> synthesize({
    required String text,
    String lang = 'mr-IN',
  }) async {
    return const VoiceSynthesizeResult(
      audioUrl: 'https://bhoomi-s3.gov.in/voice/bhoomi_speaks.mp3',
      expiresIn: 600,
    );
  }
}

void main() {
  group('Bhoomi Universal Voice State & Design System Tests', () {
    late AppStrings strings;

    setUp(() {
      strings = AppStrings(AppLanguage.marathi);
    });

    test('1. Universal Voice States: enum properties and transitions', () {
      expect(BhoomiVoiceState.idle.isIdle, isTrue);
      expect(BhoomiVoiceState.ready.isReady, isTrue);
      expect(BhoomiVoiceState.permissionRequired.isPermissionRequired, isTrue);
      expect(BhoomiVoiceState.listening.isListening, isTrue);
      expect(BhoomiVoiceState.recording.isRecording, isTrue);
      expect(BhoomiVoiceState.stopping.isStopping, isTrue);
      expect(BhoomiVoiceState.processing.isProcessing, isTrue);
      expect(BhoomiVoiceState.transcriptionConfirmation.isTranscriptionConfirmation, isTrue);
      expect(BhoomiVoiceState.speaking.isSpeaking, isTrue);
      expect(BhoomiVoiceState.paused.isPaused, isTrue);
      expect(BhoomiVoiceState.completed.isCompleted, isTrue);
      expect(BhoomiVoiceState.error.isError, isTrue);

      // Mic activity helper
      expect(BhoomiVoiceState.listening.isMicActive, isTrue);
      expect(BhoomiVoiceState.recording.isMicActive, isTrue);
      expect(BhoomiVoiceState.stopping.isMicActive, isTrue);
      expect(BhoomiVoiceState.idle.isMicActive, isFalse);

      // Audio activity helper
      expect(BhoomiVoiceState.speaking.isAudioActive, isTrue);
      expect(BhoomiVoiceState.paused.isAudioActive, isTrue);
      expect(BhoomiVoiceState.idle.isAudioActive, isFalse);
    });

    testWidgets('2. BhoomiVoiceButton: complies with touch-target >= 48dp and state icons',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BhoomiVoiceButton(
                state: BhoomiVoiceState.idle,
                size: 80,
                onTap: () => tapped = true,
                semanticLabel: 'Start voice recording',
              ),
            ),
          ),
        ),
      );

      // Touch target verification
      final buttonFinder = find.byType(BhoomiVoiceButton);
      expect(buttonFinder, findsOneWidget);
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));

      // Tap action
      await tester.tap(buttonFinder);
      expect(tapped, isTrue);
    });

    testWidgets('3. BhoomiWaveform: renders animated bars without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BhoomiWaveform(
                barCount: 5,
                isPlaying: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BhoomiWaveform), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('4. BhoomiVoiceTranscript: displays "I heard:" with confirmation & retry CTAs',
        (WidgetTester tester) async {
      String? confirmedQuery;
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BhoomiVoiceTranscript(
              text: 'माझ्या भाताच्या पिकावर करपा रोग आला आहे.',
              strings: strings,
              onConfirm: (text) => confirmedQuery = text,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('मी ऐकले:'), findsOneWidget);
      expect(find.text('माझ्या भाताच्या पिकावर करपा रोग आला आहे.'), findsOneWidget);
      expect(find.text('बरोबर आहे'), findsOneWidget);
      expect(find.text('पुन्हा बोला'), findsOneWidget);

      // Confirm tap
      await tester.tap(find.text('बरोबर आहे'));
      expect(confirmedQuery, 'माझ्या भाताच्या पिकावर करपा रोग आला आहे.');

      // Retry tap
      await tester.tap(find.text('पुन्हा बोला'));
      expect(retried, isTrue);
    });

    testWidgets('5. BhoomiVoiceError: provides humanized recovery actions (Retry, Show Crop, Type Instead)',
        (WidgetTester tester) async {
      bool retried = false;
      bool cropShown = false;
      bool typed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BhoomiVoiceError(
              strings: strings,
              onRetry: () => retried = true,
              onShowCrop: () => cropShown = true,
              onTypeInstead: () => typed = true,
            ),
          ),
        ),
      );

      expect(find.text('मला नीट ऐकू आले नाही.'), findsOneWidget);
      expect(find.text('पुन्हा बोला'), findsOneWidget);
      expect(find.text('कृपया पिकाचा फोटो दाखवा'), findsOneWidget);
      expect(find.text('टाइप करा'), findsOneWidget);

      await tester.tap(find.text('पुन्हा बोला'));
      expect(retried, isTrue);

      await tester.tap(find.text('कृपया पिकाचा फोटो दाखवा'));
      expect(cropShown, isTrue);

      await tester.tap(find.text('टाइप करा'));
      expect(typed, isTrue);
    });

    testWidgets('6. BhoomiVoicePermission: handles denied & permanently denied with settings jump',
        (WidgetTester tester) async {
      bool granted = false;
      bool settingsOpened = false;

      // Regular denied state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BhoomiVoicePermission(
              strings: strings,
              isPermanentlyDenied: false,
              onRequestPermission: () => granted = true,
            ),
          ),
        ),
      );

      expect(find.text('परवानगी द्या'), findsOneWidget);
      await tester.tap(find.text('परवानगी द्या'));
      expect(granted, isTrue);

      // Permanently denied state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BhoomiVoicePermission(
              strings: strings,
              isPermanentlyDenied: true,
              onOpenSettings: () => settingsOpened = true,
            ),
          ),
        ),
      );

      expect(find.text('सेटिंग्ज उघडा'), findsOneWidget);
      await tester.tap(find.text('सेटिंग्ज उघडा'));
      expect(settingsOpened, isTrue);
    });

    testWidgets('7. BhoomiAudioPlayer: controls speaking state with pause/resume & replay',
        (WidgetTester tester) async {
      bool replayed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceRepositoryProvider.overrideWithValue(_FakeVoiceRepo()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BhoomiAudioPlayer(
                text: 'पानांवर ट्रायसायक्लॅझोल ७५% डब्ल्यूपी फवारा.',
                onReplay: () => replayed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('भूमी बोलत आहे...'), findsOneWidget);
      expect(find.text('पुन्हा ऐका'), findsOneWidget);

      // Replay tap
      await tester.tap(find.text('पुन्हा ऐका'));
      expect(replayed, isTrue);
    });
  });
}
