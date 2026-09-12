import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart';
import 'models/diagnosis_models.dart';
import 'models/gate_models.dart';
import 'features/doubt_doctor/presentation/doubt_doctor_screen.dart';
import 'core/utils/audio_playback_service.dart';

class MockAudioPlaybackService extends AudioPlaybackService {
  MockAudioPlaybackService() : super(player: MockAudioPlayerWrapper());
}

class MockAudioPlayerWrapper implements AudioPlayerWrapper {
  @override
  Future<void> play(Source source) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Stream<PlayerState> get onPlayerStateChanged => const Stream.empty();
  @override
  Stream<Duration> get onPositionChanged => const Stream.empty();
  @override
  Stream<Duration> get onDurationChanged => const Stream.empty();
  @override
  Stream<void> get onPlayerComplete => const Stream.empty();
  @override
  PlayerState get state => PlayerState.stopped;
  @override
  Future<void> dispose() async {}
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const sampleClarifyResponse = DiagnoseResponse(
    gate: GateDecision(
      outcome: 'clarify',
      confidence: 0.55,
      thresholdApplied: 0.15,
      reasonCode: 'AMBIGUOUS',
      alternatives: [
        Prediction(label: 'blast', confidence: 0.55),
        Prediction(label: 'brown_spot', confidence: 0.50),
      ],
      isStub: false,
    ),
    problemId: 'p_prob_77',
    clarification: ClarificationModel(
      cueId: 'cue_leaf_underside_4',
      question: 'Do you see grey mold on underside?',
      questionLocalized: 'पानाच्या मागील बाजूस करडी बुरशी दिसते का?',
      candidates: [
        CandidateModel(
          label: 'blast',
          signature: 'Diamond lesions with grey centre',
        ),
        CandidateModel(
          label: 'brown_spot',
          signature: 'Round spots with yellow halo',
        ),
      ],
      answers: ['yes', 'no', 'unknown'],
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        audioPlaybackServiceProvider.overrideWithValue(MockAudioPlaybackService()),
      ],
      child: const BhoomiApp(
        homeOverride: DoubtDoctorScreen(response: sampleClarifyResponse),
      ),
    ),
  );
}
