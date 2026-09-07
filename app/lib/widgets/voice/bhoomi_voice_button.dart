import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'bhoomi_voice_state.dart';

bool get _isTestEnv {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
  try {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  } catch (_) {
    return false;
  }
}

/// Central tactile microphone button for Bhoomi Voice-First interactions.
///
/// Sizes:
/// - Hero / Standard: 72–80dp
/// - Compact: 48dp (minimum touch target compliant)
class BhoomiVoiceButton extends StatefulWidget {
  final BhoomiVoiceState state;
  final VoidCallback? onTap;
  final double size;
  final String semanticLabel;

  const BhoomiVoiceButton({
    super.key,
    this.state = BhoomiVoiceState.idle,
    this.onTap,
    this.size = 76.0,
    this.semanticLabel = 'Voice action',
  });

  @override
  State<BhoomiVoiceButton> createState() => _BhoomiVoiceButtonState();
}

class _BhoomiVoiceButtonState extends State<BhoomiVoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateAnimationForState();
  }

  @override
  void didUpdateWidget(BhoomiVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _updateAnimationForState();
    }
  }

  void _updateAnimationForState() {
    if ((widget.state.isMicActive || widget.state.isSpeaking) && !_isTestEnv) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _buttonColor {
    switch (widget.state) {
      case BhoomiVoiceState.idle:
      case BhoomiVoiceState.ready:
        return AppColors.forest;
      case BhoomiVoiceState.listening:
      case BhoomiVoiceState.recording:
      case BhoomiVoiceState.stopping:
        return AppColors.danger;
      case BhoomiVoiceState.processing:
        return AppColors.forest;
      case BhoomiVoiceState.speaking:
        return AppColors.forest;
      case BhoomiVoiceState.paused:
      case BhoomiVoiceState.completed:
        return AppColors.forest;
      case BhoomiVoiceState.permissionRequired:
      case BhoomiVoiceState.error:
        return AppColors.turmeric;
      case BhoomiVoiceState.transcriptionConfirmation:
        return AppColors.forest;
    }
  }

  IconData get _buttonIcon {
    switch (widget.state) {
      case BhoomiVoiceState.idle:
      case BhoomiVoiceState.ready:
      case BhoomiVoiceState.permissionRequired:
      case BhoomiVoiceState.error:
        return Icons.mic_rounded;
      case BhoomiVoiceState.listening:
      case BhoomiVoiceState.recording:
      case BhoomiVoiceState.stopping:
        return Icons.stop_rounded;
      case BhoomiVoiceState.processing:
        return Icons.hourglass_top_rounded;
      case BhoomiVoiceState.transcriptionConfirmation:
        return Icons.check_rounded;
      case BhoomiVoiceState.speaking:
        return Icons.pause_rounded;
      case BhoomiVoiceState.paused:
        return Icons.play_arrow_rounded;
      case BhoomiVoiceState.completed:
        return Icons.replay_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.size * 0.48;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = (widget.state.isMicActive || widget.state.isSpeaking)
              ? _pulseAnimation.value
              : 1.0;

          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _buttonColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _buttonColor.withValues(alpha: 0.35),
                      blurRadius: widget.state.isMicActive ? 18.0 * scale : 12.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.state.isProcessing
                      ? SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: const CircularProgressIndicator(
                            color: AppColors.pureWhite,
                            strokeWidth: 3.0,
                          ),
                        )
                      : Icon(
                          _buttonIcon,
                          color: AppColors.pureWhite,
                          size: iconSize,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
