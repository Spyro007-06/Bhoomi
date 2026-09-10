import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/utils/audio_playback_service.dart';
import '../../providers/repository_providers.dart';
import 'bhoomi_waveform.dart';

/// Standardized speaking playback card for Bhoomi voice output.
class BhoomiAudioPlayer extends ConsumerStatefulWidget {
  final String text;
  final String? audioUrl;
  final String? title;
  final VoidCallback? onCompleted;
  final VoidCallback? onReplay;

  const BhoomiAudioPlayer({
    super.key,
    required this.text,
    this.audioUrl,
    this.title,
    this.onCompleted,
    this.onReplay,
  });

  @override
  ConsumerState<BhoomiAudioPlayer> createState() => _BhoomiAudioPlayerState();
}

class _BhoomiAudioPlayerState extends ConsumerState<BhoomiAudioPlayer>
    with WidgetsBindingObserver {
  bool _isPlaying = false;
  bool _hasStarted = false;
  String? _resolvedAudioUrl;

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resolvedAudioUrl = widget.audioUrl;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToPlayerStreams();
      _startPlayback();
    });
  }

  void _listenToPlayerStreams() {
    final playbackService = ref.read(audioPlaybackServiceProvider);

    _stateSub?.cancel();
    _stateSub = playbackService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _completeSub?.cancel();
    _completeSub = playbackService.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        widget.onCompleted?.call();
      }
    });
  }

  Future<void> _startPlayback() async {
    final playbackService = ref.read(audioPlaybackServiceProvider);
    final voiceRepo = ref.read(voiceRepositoryProvider);
    final language = ref.read(appLanguageProvider);

    setState(() {
      _isPlaying = true;
      _hasStarted = true;
    });

    try {
      if (_resolvedAudioUrl != null && _resolvedAudioUrl!.isNotEmpty) {
        await playbackService.playUrl(_resolvedAudioUrl!);
        return;
      }

      final result = await voiceRepo.synthesize(
        text: widget.text,
        lang: language.localeIdentifier,
      );

      if (result.audioUrl.isNotEmpty) {
        _resolvedAudioUrl = result.audioUrl;
        await playbackService.playUrl(result.audioUrl);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    final playbackService = ref.read(audioPlaybackServiceProvider);
    if (_isPlaying) {
      await playbackService.pause();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      if (_hasStarted) {
        await playbackService.resume();
        if (mounted) setState(() => _isPlaying = true);
      } else {
        await _startPlayback();
      }
    }
  }

  Future<void> _replayAudio() async {
    final playbackService = ref.read(audioPlaybackServiceProvider);
    await playbackService.stop();
    widget.onReplay?.call();
    await _startPlayback();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isPlaying) {
        final playbackService = ref.read(audioPlaybackServiceProvider);
        playbackService.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateSub?.cancel();
    _completeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: _isPlaying ? AppColors.forest : AppColors.forest.withValues(alpha: 0.3),
          width: _isPlaying ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Bhoomi is speaking" + Live Waveform
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.forest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.pureWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.m12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? strings.voiceBhoomiSpeaking,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _isPlaying
                          ? strings.voicePlayingAudio
                          : strings.pauseSpokenSummary,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.fieldSlate,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isPlaying)
                const BhoomiWaveform(
                  color: AppColors.forest,
                  barCount: 4,
                  minHeight: 8,
                  maxHeight: 22,
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.m12),

          // Spoken Text Content
          Text(
            widget.text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.soilCharcoal,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppSpacing.l16),

          // Tactile Controls: Pause/Resume & Replay
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: AppRadius.button,
                  onTap: _togglePlayback,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s10,
                      horizontal: AppSpacing.m12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warmSurface,
                      borderRadius: AppRadius.button,
                      border: Border.all(color: AppColors.forest),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.forest,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.s6),
                        Text(
                          _isPlaying
                              ? strings.pauseSpokenSummary
                              : strings.listenSpokenSummary,
                          style: AppTypography.button.copyWith(
                            color: AppColors.forest,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m12),
              InkWell(
                borderRadius: AppRadius.button,
                onTap: _replayAudio,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.s10,
                    horizontal: AppSpacing.l16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warmSurface,
                    borderRadius: AppRadius.button,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.replay_rounded,
                          color: AppColors.fieldSlate, size: 20),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        strings.voiceReplayAnswer,
                        style: AppTypography.button.copyWith(
                          color: AppColors.soilCharcoal,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
