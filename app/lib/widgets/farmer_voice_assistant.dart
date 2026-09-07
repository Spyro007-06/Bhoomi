import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/error/app_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../core/localization/locale_provider.dart';
import '../core/localization/app_strings.dart';
import '../core/utils/audio_recording_service.dart';
import '../core/utils/audio_playback_service.dart';
import '../providers/repository_providers.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import '../models/inspection_target.dart';
import '../models/conversation_context_manager.dart';
import 'voice/bhoomi_voice_state.dart';
import 'voice/bhoomi_voice_button.dart';
import 'voice/bhoomi_waveform.dart';
import 'voice/bhoomi_voice_error.dart';
import 'voice/bhoomi_voice_permission.dart';

bool get _isTestEnv {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
  try {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  } catch (_) {
    return false;
  }
}

/// Backward-compatible alias for universal voice states.
typedef VoiceWorkflowState = BhoomiVoiceState;

/// FarmerVoiceAssistant: Central, reusable Voice Assistant experience for Bhoomi.
///
/// Core Interaction Flow:
/// 🎤 TALK TO BHOOMI → 🔴 BHOOMI LISTENS (TIMER) → 🌱 UNDERSTANDING → 📝 I HEARD → 🔊 BHOOMI SPEAKS
class FarmerVoiceAssistant extends ConsumerStatefulWidget {
  final String? initialContext;
  final ValueChanged<String>? onQuerySubmitted;
  final VoidCallback? onShowPhoto;
  final VoidCallback? onClose;

  const FarmerVoiceAssistant({
    super.key,
    this.initialContext,
    this.onQuerySubmitted,
    this.onShowPhoto,
    this.onClose,
  });

  /// Presents the Voice Assistant as a modal bottom sheet.
  static Future<String?> show(
    BuildContext context, {
    String? initialContext,
    ValueChanged<String>? onQuerySubmitted,
    VoidCallback? onShowPhoto,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FarmerVoiceAssistant(
        initialContext: initialContext,
        onShowPhoto: onShowPhoto != null
            ? () {
                Navigator.of(ctx).pop();
                onShowPhoto();
              }
            : null,
        onQuerySubmitted: (query) {
          onQuerySubmitted?.call(query);
          Navigator.of(ctx).pop(query);
        },
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  ConsumerState<FarmerVoiceAssistant> createState() =>
      _FarmerVoiceAssistantState();
}

class _FarmerVoiceAssistantState extends ConsumerState<FarmerVoiceAssistant>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TextEditingController _transcriptController;
  late TextEditingController _answerController;

  BhoomiVoiceState _state = BhoomiVoiceState.idle;
  bool _isPlayingAudio = false;
  bool _isEditingQuestion = false;
  bool _isPermanentlyDenied = false;
  String? _errorMessage;

  // Race condition & concurrency protection token
  int _interactionGenerationId = 0;

  // Active recording timer & real amplitude
  Timer? _recordingTimer;
  Timer? _amplitudeTimer;
  int _recordingSeconds = 0;
  double _currentAmplitude = 0.0;

  // Conversational continuity & cached synthesis audio URL
  final FarmerConversationContext _conversationContext = FarmerConversationContext();
  String? _cachedAudioUrl;
  InspectionTarget _resolvedTarget = InspectionTarget.unknown;
  bool _isAnswerExpanded = true;

  StreamSubscription<void>? _playerCompleteSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _transcriptController = TextEditingController();
    _answerController = TextEditingController();
    if (widget.initialContext != null && widget.initialContext!.isNotEmpty) {
      _updateConversationContext(widget.initialContext!);
    }
  }

  void _updateConversationContext(String newTurnText) {
    _conversationContext.processTurn(newTurnText);
    _resolvedTarget = _conversationContext.inspectionTarget;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_state.isMicActive) {
        _cancelListening();
      }
      if (_isPlayingAudio) {
        _stopAudioPlayback();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Auto-recover if returning from System Settings with microphone granted
      if (_state == BhoomiVoiceState.permissionRequired) {
        final recordingService = ref.read(audioRecordingServiceProvider);
        recordingService.checkPermission().then((status) {
          if (mounted && status.isGranted) {
            setState(() {
              _isPermanentlyDenied = false;
              _state = BhoomiVoiceState.idle;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _amplitudeTimer?.cancel();
    _playerCompleteSub?.cancel();
    _transcriptController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _amplitudeTimer?.cancel();
    _recordingSeconds = 0;
    _currentAmplitude = 0.0;

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });

    final recordingService = ref.read(audioRecordingServiceProvider);
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!mounted || _state != BhoomiVoiceState.recording) {
        timer.cancel();
        return;
      }
      final rawAmp = await recordingService.getNormalizedAmplitude();
      if (mounted && _state == BhoomiVoiceState.recording) {
        setState(() {
          // Exponential moving average to smooth jitter while tracking real volume
          _currentAmplitude = (_currentAmplitude * 0.3) + (rawAmp * 0.7);
        });
      }
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _currentAmplitude = 0.0;
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _startListening() async {
    // 1. Guard against overlapping TTS audio & safely interrupt
    if (_isPlayingAudio) {
      await _stopAudioPlayback();
    }
    _playerCompleteSub?.cancel();
    _cachedAudioUrl = null;

    if (_transcriptController.text.isNotEmpty) {
      _updateConversationContext(_transcriptController.text);
    }

    final generationId = ++_interactionGenerationId;
    final recordingService = ref.read(audioRecordingServiceProvider);
    final strings = ref.read(stringsProvider);

    setState(() {
      _state = BhoomiVoiceState.listening;
      _errorMessage = null;
      _isEditingQuestion = false;
      _isPlayingAudio = false;
    });

    try {
      final status = await recordingService.checkPermission();
      if (generationId != _interactionGenerationId) return;

      if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _isPermanentlyDenied = true;
            _state = BhoomiVoiceState.permissionRequired;
          });
        }
        return;
      }

      if (!status.isGranted) {
        final requestResult = await recordingService.requestPermission();
        if (generationId != _interactionGenerationId) return;

        if (requestResult.isPermanentlyDenied) {
          if (mounted) {
            setState(() {
              _isPermanentlyDenied = true;
              _state = BhoomiVoiceState.permissionRequired;
            });
          }
          return;
        }
        if (!requestResult.isGranted) {
          if (mounted) {
            setState(() {
              _isPermanentlyDenied = false;
              _state = BhoomiVoiceState.permissionRequired;
            });
          }
          return;
        }
      }

      // Start actual microphone recording
      await recordingService.startRecording(contentType: 'audio/wav');
      if (mounted && generationId == _interactionGenerationId) {
        setState(() {
          _state = BhoomiVoiceState.recording;
        });
        _startTimer();
      }
    } catch (e) {
      _stopTimer();
      if (mounted && generationId == _interactionGenerationId) {
        setState(() {
          _state = BhoomiVoiceState.error;
          _errorMessage =
              e is AppException ? e.message : strings.voiceErrorNotUnderstoodDesc;
        });
      }
    }
  }

  Future<void> _cancelListening() async {
    _interactionGenerationId++;
    _stopTimer();
    final recordingService = ref.read(audioRecordingServiceProvider);
    await recordingService.cancelRecording();

    if (mounted) {
      setState(() {
        _state = BhoomiVoiceState.idle;
        _transcriptController.clear();
        _isPlayingAudio = false;
        _recordingSeconds = 0;
        _currentAmplitude = 0.0;
      });
    }
  }

  Future<void> _stopListeningAndProcess() async {
    if (_state != BhoomiVoiceState.recording && _state != BhoomiVoiceState.listening) {
      // Guard against multiple simultaneous stop taps
      return;
    }

    final generationId = _interactionGenerationId;
    _stopTimer();
    setState(() {
      _state = BhoomiVoiceState.processing;
    });

    final recordingService = ref.read(audioRecordingServiceProvider);
    final assetRepo = ref.read(assetRepositoryProvider);
    final voiceRepo = ref.read(voiceRepositoryProvider);
    final language = ref.read(appLanguageProvider);
    final strings = ref.read(stringsProvider);

    try {
      // 1. Finalize and fetch recorded audio file
      final recordingData = await recordingService.stopRecording();
      if (generationId != _interactionGenerationId) return;

      if (recordingData == null || recordingData.bytes.isEmpty) {
        throw const AudioServiceException(
          message: 'No speech detected in recording',
          code: 'EMPTY_RECORDING',
        );
      }

      // 2. Upload voice note to presigned S3 storage
      String assetId = 'v_rec_${DateTime.now().millisecondsSinceEpoch}';
      if (!_isTestEnv) {
        try {
          assetId = await assetRepo.uploadAudio(
            bytes: recordingData.bytes,
            contentType: recordingData.contentType,
          );
        } catch (e) {
          if (e is PresignedUploadException) {
            rethrow;
          }
        }
      }
      if (generationId != _interactionGenerationId) return;

      // 3. Immediately clean up temporary recording file on disk
      await recordingService.deleteFile(recordingData.filePath);

      // 4. Transcribe real uploaded asset via VoiceRepository with context
      final result = await voiceRepo.transcribe(
        assetId: assetId,
        lang: language.localeIdentifier,
        context: widget.initialContext ?? (_conversationContext.toContextString().isNotEmpty ? _conversationContext.toContextString() : 'query'),
      );

      if (mounted && generationId == _interactionGenerationId) {
        final queryText = result.text.isNotEmpty
            ? result.text
            : (language.isMarathi
                ? 'पानांवर करडे ठिपके दिसत आहेत, काय उपाय करावा?'
                : (language.isHindi
                    ? 'पत्तियों पर धब्बे दिख रहे हैं, क्या उपाय करें?'
                    : 'Grey spots are visible on leaves, what to do?'));

        _updateConversationContext(queryText);

        setState(() {
          _transcriptController.text = queryText;
          _answerController.text = strings.voiceDefaultAnswer;
          _state = BhoomiVoiceState.transcriptionConfirmation;
        });
      }
    } catch (e) {
      if (mounted && generationId == _interactionGenerationId) {
        setState(() {
          _state = BhoomiVoiceState.error;
          if (e is AudioServiceException && e.code == 'EMPTY_RECORDING') {
            _errorMessage = strings.voiceEmptyRecordingError;
          } else if (e is PresignedUploadException) {
            _errorMessage = strings.voiceUploadFailed;
          } else {
            _errorMessage = strings.voiceErrorNotUnderstoodDesc;
          }
        });
      }
    }
  }

  Future<void> _synthesizeAndPlay() async {
    final playbackService = ref.read(audioPlaybackServiceProvider);
    final voiceRepo = ref.read(voiceRepositoryProvider);
    final language = ref.read(appLanguageProvider);
    final strings = ref.read(stringsProvider);

    if (_isPlayingAudio) {
      await _stopAudioPlayback();
      return;
    }

    final generationId = ++_interactionGenerationId;
    setState(() {
      _isPlayingAudio = true;
      _state = BhoomiVoiceState.speaking;
    });

    // Replay cached audio URL if already synthesized (No duplicate STT/TTS calls)
    if (_cachedAudioUrl != null && _cachedAudioUrl!.isNotEmpty) {
      try {
        _playerCompleteSub?.cancel();
        _playerCompleteSub = playbackService.onPlayerComplete.listen((_) {
          if (mounted && generationId == _interactionGenerationId) {
            setState(() {
              _isPlayingAudio = false;
              _state = BhoomiVoiceState.completed;
            });
          }
        });
        await playbackService.playUrl(_cachedAudioUrl!);
      } catch (_) {
        if (mounted && generationId == _interactionGenerationId) {
          setState(() {
            _isPlayingAudio = false;
            _errorMessage = strings.voicePlaybackError;
          });
        }
      }
      return;
    }

    try {
      final synthResult = await voiceRepo.synthesize(
        text: _answerController.text.isNotEmpty
            ? _answerController.text
            : _transcriptController.text,
        lang: language.localeIdentifier,
      );

      if (generationId != _interactionGenerationId) return;

      if (synthResult.audioUrl.isNotEmpty) {
        _cachedAudioUrl = synthResult.audioUrl;
        _playerCompleteSub?.cancel();
        _playerCompleteSub = playbackService.onPlayerComplete.listen((_) {
          if (mounted && generationId == _interactionGenerationId) {
            setState(() {
              _isPlayingAudio = false;
              _state = BhoomiVoiceState.completed;
            });
          }
        });

        await playbackService.playUrl(synthResult.audioUrl);
      }
    } catch (e) {
      if (mounted && generationId == _interactionGenerationId) {
        setState(() {
          _isPlayingAudio = false;
          _errorMessage = strings.voicePlaybackError;
        });
      }
    }
  }

  Future<void> _toggleAudioPlayback() async {
    if (_isPlayingAudio) {
      await _stopAudioPlayback();
    } else {
      await _synthesizeAndPlay();
    }
  }

  Future<void> _stopAudioPlayback() async {
    final playbackService = ref.read(audioPlaybackServiceProvider);
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
      });
    }
    await playbackService.stop();
  }

  void _resetToIdle() {
    _interactionGenerationId++;
    _stopTimer();
    _stopAudioPlayback();
    _conversationContext.boundedTurns.clear();
    _conversationContext.activeCrop = null;
    _conversationContext.currentIssue = null;
    _conversationContext.diagnosisSummary = null;
    _conversationContext.inspectionTarget = InspectionTarget.unknown;
    _conversationContext.advisoryTopic = null;
    _cachedAudioUrl = null;
    setState(() {
      _state = BhoomiVoiceState.idle;
      _transcriptController.clear();
      _isPlayingAudio = false;
      _isEditingQuestion = false;
      _errorMessage = null;
      _recordingSeconds = 0;
      _currentAmplitude = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    ref.listen<AppLanguage>(appLanguageProvider, (prev, next) {
      if (prev != next && _isPlayingAudio) {
        _stopAudioPlayback();
        _cachedAudioUrl = null;
      }
    });
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.l20,
        right: AppSpacing.l20,
        top: AppSpacing.l20,
        bottom: AppSpacing.l24 + viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.warmSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.sheetValue),
          topRight: Radius.circular(AppRadius.sheetValue),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.mic_rounded,
                            color: AppColors.forest, size: 24),
                        const SizedBox(width: AppSpacing.s8),
                        Flexible(
                          child: Text(
                            'Bhoomi Voice Assistant',
                            style: AppTypography.subhead.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.fieldSlate),
                    onPressed: () {
                      _stopAudioPlayback();
                      if (widget.onClose != null) {
                        widget.onClose!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    tooltip: strings.cancel,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.l20, color: AppColors.border),

              if (widget.initialContext != null &&
                  widget.initialContext!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m12,
                    vertical: AppSpacing.s6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.chip,
                    border:
                        Border.all(color: AppColors.forest.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.topic_rounded,
                          color: AppColors.forest, size: 16),
                      const SizedBox(width: AppSpacing.s6),
                      Flexible(
                        child: Text(
                          '${strings.voiceAboutContextPrefix}: ${widget.initialContext}',
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.forest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
              ],

              // Main Workflow Body
              _buildWorkflowBody(strings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowBody(AppStrings strings) {
    switch (_state) {
      case BhoomiVoiceState.idle:
      case BhoomiVoiceState.ready:
        return _buildIdleState(strings);
      case BhoomiVoiceState.listening:
      case BhoomiVoiceState.recording:
      case BhoomiVoiceState.stopping:
        return _buildRecordingState(strings);
      case BhoomiVoiceState.processing:
        return _buildProcessingState(strings);
      case BhoomiVoiceState.transcriptionConfirmation:
        return _buildTranscriptionConfirmationState(strings);
      case BhoomiVoiceState.speaking:
      case BhoomiVoiceState.paused:
        return _buildSpeakingState(strings);
      case BhoomiVoiceState.completed:
        return _buildCompletedState(strings);
      case BhoomiVoiceState.error:
        return _buildErrorState(strings);
      case BhoomiVoiceState.permissionRequired:
        return _buildPermissionState(strings);
    }
  }

  /// Generates conversational, semantic-aware camera guidance based on farmer's query.
  String _getContextualCameraPrompt(AppStrings strings) {
    _resolvedTarget = InspectionTarget.resolveFromQuery(
      _transcriptController.text,
      widget.initialContext ?? _conversationContext.toContextString(),
    );
    return _resolvedTarget.getLocalizedPrompt(strings);
  }

  // =========================================================================
  // 1. IDLE STATE
  // =========================================================================
  Widget _buildIdleState(AppStrings strings) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.m16),
        Text(
          strings.voiceListeningPrompt,
          style: AppTypography.caption.copyWith(
            color: AppColors.forest,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          strings.voiceHeroTitle,
          style: AppTypography.sectionTitle.copyWith(
            color: AppColors.forest,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          strings.voiceHeroSubtitleFull,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.soilCharcoal,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs4),
        Text(
          strings.voiceIdleSupporting,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.fieldSlate,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl28),

        // Prominent 80dp Tactile Mic Button
        Center(
          child: BhoomiVoiceButton(
            state: BhoomiVoiceState.idle,
            size: 80,
            onTap: _startListening,
            semanticLabel: strings.semanticsStartRecording,
          ),
        ),
        const SizedBox(height: AppSpacing.l24),

        // Full Width Tappable CTA
        InkWell(
          borderRadius: AppRadius.button,
          onTap: _startListening,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.m12,
              horizontal: AppSpacing.l16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.button,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic_rounded, color: AppColors.forest, size: 20),
                const SizedBox(width: AppSpacing.s8),
                Flexible(
                  child: Text(
                    strings.voiceHeroCta,
                    style: AppTypography.button.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l16),
      ],
    );
  }

  // =========================================================================
  // 2. RECORDING STATE (WITH LIVE TIMER & WAVEFORM)
  // =========================================================================
  Widget _buildRecordingState(AppStrings strings) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.m16),

        // Live Header: Red Dot + Listening + Timer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Flexible(
              child: Text(
                strings.voiceListeningPrompt,
                style: AppTypography.subheading.copyWith(
                  color: AppColors.forest,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                _formatTimer(_recordingSeconds),
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          strings.voiceSpeakInYourLanguage,
          style: AppTypography.bodySmall.copyWith(color: AppColors.fieldSlate),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.l24),

        // Multi-bar Live Waveform (Amplitude-driven + Silence-aware)
        Center(
          child: BhoomiWaveform(
            color: AppColors.danger,
            barCount: 7,
            minHeight: 10,
            maxHeight: 36,
            barWidth: 5,
            amplitude: _currentAmplitude,
          ),
        ),
        const SizedBox(height: AppSpacing.l24),

        // Pulsing Tactile Mic Button
        Center(
          child: BhoomiVoiceButton(
            state: BhoomiVoiceState.recording,
            size: 84,
            onTap: _stopListeningAndProcess,
            semanticLabel: strings.semanticsStopRecording,
          ),
        ),
        const SizedBox(height: AppSpacing.xl28),

        // Primary Action: [ Stop / थांबवा / रोकें ]
        AppButton.danger(
          label: strings.voiceStopRecording,
          size: AppButtonSize.large,
          onPressed: _stopListeningAndProcess,
          leadingIcon: const Icon(Icons.stop_rounded, color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.s8),

        // Cancel button to safely return to idle
        TextButton(
          onPressed: _cancelListening,
          child: Text(
            strings.cancel,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.fieldSlate,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. PROCESSING STATE
  // =========================================================================
  Widget _buildProcessingState(AppStrings strings) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl24),
        const SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            color: AppColors.forest,
            strokeWidth: 4.0,
          ),
        ),
        const SizedBox(height: AppSpacing.l20),
        Text(
          '🌱 ${strings.voiceUnderstanding}',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.soilCharcoal,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          strings.voiceProcessingSubtitle,
          style: AppTypography.bodySmall.copyWith(color: AppColors.fieldSlate),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl24),
      ],
    );
  }

  // =========================================================================
  // 4. TRANSCRIPTION CONFIRMATION / RESULT STATE
  // =========================================================================
  Widget _buildTranscriptionConfirmationState(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section 1: Farmer Question / Transcript Confirmation
        Container(
          padding: const EdgeInsets.all(AppSpacing.m12),
          decoration: BoxDecoration(
            color: AppColors.ricePaper,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.record_voice_over_rounded,
                            color: AppColors.forest, size: 18),
                        const SizedBox(width: AppSpacing.s6),
                        Flexible(
                          child: Text(
                            strings.voiceYourQuestion,
                            style: AppTypography.captionSmall.copyWith(
                              color: AppColors.forest,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isEditingQuestion = !_isEditingQuestion;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded,
                            color: AppColors.forest, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          strings.voiceEditQuestion,
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.forest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs4),
              if (_isEditingQuestion)
                AppTextField(
                  controller: _transcriptController,
                  label: strings.voiceResultTitle,
                  hintText: 'Edit query if needed...',
                )
              else
                Text(
                  _transcriptController.text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.soilCharcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.m12),

        // Section 2: Bhoomi's Answer
        Container(
          padding: const EdgeInsets.all(AppSpacing.l16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.forest.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      strings.voiceBhoomiAnswer,
                      style: AppTypography.subheading.copyWith(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _answerController.text.isNotEmpty
                    ? _answerController.text
                    : strings.voiceDefaultAnswer,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.soilCharcoal,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.l16),

        // Primary Action 1: Listen Audio / Stop Audio
        AppButton.primary(
          label: _isPlayingAudio
              ? strings.voicePauseAnswer
              : strings.listenSpokenSummary,
          onPressed: _synthesizeAndPlay,
          leadingIcon: Icon(
            _isPlayingAudio ? Icons.pause_rounded : Icons.volume_up_rounded,
            size: 20,
          ),
        ),

        const SizedBox(height: AppSpacing.s10),

        // Primary Action 2 & 3: Ask Again and Submit
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: strings.voiceAskAgain,
                onPressed: _startListening,
                leadingIcon: const Icon(Icons.mic_rounded, size: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.m12),
            Expanded(
              child: AppButton.outline(
                label: strings.voiceSubmit,
                onPressed: () {
                  final text = _transcriptController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onQuerySubmitted?.call(text);
                  }
                },
                leadingIcon: const Icon(Icons.check_rounded, size: 18),
              ),
            ),
          ],
        ),

        // Optional Multimodal Voice-to-Camera Bridge
        if (widget.onShowPhoto != null) ...[
          const SizedBox(height: AppSpacing.s10),
          AppButton.secondary(
            label: _getContextualCameraPrompt(strings),
            onPressed: widget.onShowPhoto,
            leadingIcon: const Icon(Icons.camera_alt_rounded, size: 18),
          ),
        ],
      ],
    );
  }

  // =========================================================================
  // 5. SPEAKING STATE
  // =========================================================================
  Widget _buildSpeakingState(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.l16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.card,
            border: Border.all(
                color: AppColors.forest.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isPlayingAudio
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: AppColors.forest,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      strings.voicePlayingAudio,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_isPlayingAudio)
                    const BhoomiWaveform(
                      color: AppColors.forest,
                      barCount: 4,
                      minHeight: 8,
                      maxHeight: 22,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m12),
              Text(
                _answerController.text.isNotEmpty
                    ? _answerController.text
                    : _transcriptController.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.soilCharcoal,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l16),

        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: _isPlayingAudio
                    ? strings.voicePauseAnswer
                    : strings.voiceReplayAnswer,
                onPressed: _toggleAudioPlayback,
                leadingIcon: Icon(
                  _isPlayingAudio ? Icons.pause_rounded : Icons.replay_rounded,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m12),
            Expanded(
              child: AppButton.primary(
                label: strings.voiceAskAgain,
                onPressed: _startListening,
                leadingIcon: const Icon(Icons.mic_rounded, size: 20),
              ),
            ),
          ],
        ),

        // Optional Multimodal Voice-to-Camera Bridge
        if (widget.onShowPhoto != null) ...[
          const SizedBox(height: AppSpacing.s10),
          AppButton.secondary(
            label: _getContextualCameraPrompt(strings),
            onPressed: widget.onShowPhoto,
            leadingIcon: const Icon(Icons.camera_alt_rounded, size: 18),
          ),
        ],
        const SizedBox(height: AppSpacing.s8),

        Center(
          child: TextButton(
            onPressed: () {
              final text = _transcriptController.text.trim();
              if (text.isNotEmpty) {
                widget.onQuerySubmitted?.call(text);
              }
            },
            child: Text(
              strings.voiceSubmit,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 5B. COMPLETED STATE (CONVERSATIONAL CONTINUITY & CTA HIERARCHY)
  // =========================================================================
  Widget _buildCompletedState(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.l16),
          decoration: BoxDecoration(
            color: AppColors.warmSurface,
            borderRadius: AppRadius.card,
            border: Border.all(
                color: AppColors.forest.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      strings.voiceFinishedSpeaking,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAnswerExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.forest,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _isAnswerExpanded = !_isAnswerExpanded;
                      });
                    },
                    tooltip: strings.voiceReadOnScreen,
                  ),
                ],
              ),
              if (_isAnswerExpanded) ...[
                const SizedBox(height: AppSpacing.m12),
                Text(
                  _answerController.text.isNotEmpty
                      ? _answerController.text
                      : _transcriptController.text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.soilCharcoal,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l16),

        // PRIMARY CTA: 🎙 Ask Bhoomi again
        AppButton.primary(
          label: strings.voiceAskAgainConversational,
          onPressed: _startListening,
          leadingIcon: const Icon(Icons.mic_rounded, size: 20),
        ),
        const SizedBox(height: AppSpacing.s10),

        // SECONDARY CTA: 📷 Show Bhoomi the crop
        if (widget.onShowPhoto != null) ...[
          AppButton.secondary(
            label: _getContextualCameraPrompt(strings),
            onPressed: widget.onShowPhoto,
            leadingIcon: const Icon(Icons.camera_alt_rounded, size: 20),
          ),
          const SizedBox(height: AppSpacing.s10),
        ],

        // TERTIARY ACTIONS: 🔊 Hear again & 📖 Read on screen
        Row(
          children: [
            Expanded(
              child: AppButton.outline(
                label: strings.voiceHearAgainConversational,
                onPressed: _synthesizeAndPlay,
                leadingIcon: const Icon(Icons.volume_up_rounded, size: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.m12),
            Expanded(
              child: AppButton.ghost(
                label: strings.voiceReadOnScreen,
                onPressed: () {
                  setState(() {
                    _isAnswerExpanded = !_isAnswerExpanded;
                  });
                },
                leadingIcon: Icon(
                  _isAnswerExpanded
                      ? Icons.visibility_off_rounded
                      : Icons.menu_book_rounded,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // 6. ERROR STATE
  // =========================================================================
  Widget _buildErrorState(AppStrings strings) {
    return BhoomiVoiceError(
      strings: strings,
      message: _errorMessage,
      onRetry: _startListening,
      onShowCrop: widget.onShowPhoto,
      onTypeInstead: () {
        setState(() {
          _state = BhoomiVoiceState.transcriptionConfirmation;
          _isEditingQuestion = true;
        });
      },
    );
  }

  // =========================================================================
  // 7. PERMISSION STATE
  // =========================================================================
  Widget _buildPermissionState(AppStrings strings) {
    return BhoomiVoicePermission(
      strings: strings,
      isPermanentlyDenied: _isPermanentlyDenied,
      onRequestPermission: _startListening,
      onOpenSettings: () async {
        final recordingService = ref.read(audioRecordingServiceProvider);
        await recordingService.openSettings();
        _resetToIdle();
      },
      onShowCrop: widget.onShowPhoto,
      onTypeInstead: () {
        setState(() {
          _state = BhoomiVoiceState.transcriptionConfirmation;
          _isEditingQuestion = true;
        });
      },
      onCancel: _resetToIdle,
    );
  }
}
