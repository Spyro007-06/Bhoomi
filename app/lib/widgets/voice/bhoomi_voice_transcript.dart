import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/localization/app_strings.dart';
import '../app_button.dart';
import '../app_text_field.dart';

/// Humanized Transcription Confirmation component for Bhoomi Voice interactions.
class BhoomiVoiceTranscript extends StatefulWidget {
  final String text;
  final ValueChanged<String>? onConfirm;
  final VoidCallback? onRetry;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onShowPhoto;
  final String? showPhotoLabel;
  final ValueChanged<String>? onTextChanged;
  final AppStrings strings;

  const BhoomiVoiceTranscript({
    super.key,
    required this.text,
    required this.strings,
    this.onConfirm,
    this.onRetry,
    this.onPlayAudio,
    this.onShowPhoto,
    this.showPhotoLabel,
    this.onTextChanged,
  });

  @override
  State<BhoomiVoiceTranscript> createState() => _BhoomiVoiceTranscriptState();
}

class _BhoomiVoiceTranscriptState extends State<BhoomiVoiceTranscript> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(BhoomiVoiceTranscript oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && !_isEditing) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveText = _controller.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "I heard:" Header + Edit toggle
        Container(
          padding: const EdgeInsets.all(AppSpacing.l16),
          decoration: BoxDecoration(
            color: AppColors.ricePaper,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over_rounded,
                          color: AppColors.forest, size: 20),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        widget.strings.voiceIHeard,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: AppRadius.chip,
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded,
                              color: AppColors.fieldSlate, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.strings.voiceEditQuestion,
                            style: AppTypography.captionSmall.copyWith(
                              color: AppColors.fieldSlate,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m12),

              if (_isEditing)
                AppTextField(
                  controller: _controller,
                  label: widget.strings.voiceIHeard,
                  onChanged: widget.onTextChanged,
                )
              else
                Text(
                  effectiveText.isNotEmpty
                      ? effectiveText
                      : widget.strings.voiceErrorNotUnderstood,
                  style: AppTypography.subheading.copyWith(
                    color: AppColors.soilCharcoal,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.l16),

        // Primary Action: "Sounds right" / "बरोबर आहे"
        AppButton.primary(
          label: widget.strings.voiceSoundsRight,
          size: AppButtonSize.large,
          onPressed: () {
            widget.onConfirm?.call(_controller.text.trim());
          },
          leadingIcon:
              const Icon(Icons.check_circle_rounded, color: Colors.white),
        ),

        const SizedBox(height: AppSpacing.m12),

        // Action 2 & 3: "Try again" & Optional "Play what I heard"
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: widget.strings.voiceTryAgain,
                onPressed: widget.onRetry,
                leadingIcon: const Icon(Icons.mic_rounded, size: 18),
              ),
            ),
            if (widget.onPlayAudio != null) ...[
              const SizedBox(width: AppSpacing.m12),
              Expanded(
                child: AppButton.outline(
                  label: widget.strings.voicePlayWhatIHear,
                  onPressed: widget.onPlayAudio,
                  leadingIcon: const Icon(Icons.volume_up_rounded, size: 18),
                ),
              ),
            ],
          ],
        ),

        // Contextual Multimodal Camera Action
        if (widget.onShowPhoto != null) ...[
          const SizedBox(height: AppSpacing.m12),
          AppButton.secondary(
            label: widget.showPhotoLabel ?? widget.strings.voiceShowAffectedLeaf,
            onPressed: widget.onShowPhoto,
            leadingIcon: const Icon(Icons.camera_alt_rounded, size: 20),
          ),
        ],
      ],
    );
  }
}
