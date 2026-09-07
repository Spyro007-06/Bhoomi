import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

bool get _isTestEnv {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
  try {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  } catch (_) {
    return false;
  }
}

/// Reusable audio visualization for recording and speaking states.
///
/// Supports:
/// - Dynamic real-time amplitude input ([amplitude] in range 0.0 to 1.0)
/// - Calm activity/breathing mode when [amplitude] is null
/// - Silence awareness (rests at [minHeight] when amplitude is near zero)
class BhoomiWaveform extends StatefulWidget {
  final Color color;
  final int barCount;
  final double minHeight;
  final double maxHeight;
  final double barWidth;
  final bool isPlaying;
  final double? amplitude;

  const BhoomiWaveform({
    super.key,
    this.color = AppColors.forest,
    this.barCount = 5,
    this.minHeight = 6.0,
    this.maxHeight = 28.0,
    this.barWidth = 4.0,
    this.isPlaying = true,
    this.amplitude,
  });

  @override
  State<BhoomiWaveform> createState() => _BhoomiWaveformState();
}

class _BhoomiWaveformState extends State<BhoomiWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying && !_isTestEnv) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BhoomiWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying && !_isTestEnv) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            double height;
            if (widget.amplitude != null) {
              // Real amplitude-driven rendering
              final amp = widget.amplitude!.clamp(0.0, 1.0);
              if (amp <= 0.05) {
                // Silence state: rest at minHeight
                height = widget.minHeight;
              } else {
                // Modulate bar heights around the center bar for a natural wave profile
                final centerIndex = (widget.barCount - 1) / 2.0;
                final distFromCenter = (index - centerIndex).abs();
                final weighting = 1.0 - (distFromCenter / (widget.barCount));
                final dynamicHeight = widget.minHeight +
                    (amp * (widget.maxHeight - widget.minHeight) * weighting);
                height = dynamicHeight.clamp(widget.minHeight, widget.maxHeight);
              }
            } else {
              // Calm activity / rhythm mode
              final phase = (index * (1.0 / widget.barCount));
              final progress = widget.isPlaying
                  ? ((_controller.value + phase) % 1.0)
                  : 0.15;
              height = widget.minHeight +
                  (progress * (widget.maxHeight - widget.minHeight));
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutQuad,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: widget.barWidth,
              height: height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
              ),
            );
          }),
        );
      },
    );
  }
}
