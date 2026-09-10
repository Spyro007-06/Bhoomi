import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/localization/app_strings.dart';
import '../app_button.dart';

/// Human-friendly conversational error state for Bhoomi Voice interactions.
class BhoomiVoiceError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onShowCrop;
  final VoidCallback? onTypeInstead;
  final AppStrings strings;

  const BhoomiVoiceError({
    super.key,
    required this.strings,
    this.message,
    this.onRetry,
    this.onShowCrop,
    this.onTypeInstead,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.m16),

        // Gentle friendly emoji
        const Center(
          child: Text('🌾', style: TextStyle(fontSize: 44)),
        ),
        const SizedBox(height: AppSpacing.m12),

        // Conversational Headline
        Text(
          strings.voiceCouldNotHear,
          style: AppTypography.subheading.copyWith(
            color: AppColors.soilCharcoal,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s8),

        // Friendly supporting explanation
        Text(
          message ?? strings.voiceErrorNotUnderstoodDesc,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.fieldSlate,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl28),

        // 1. Primary Action: [ Try Again / पुन्हा बोला ]
        AppButton.primary(
          label: strings.voiceTryAgain,
          size: AppButtonSize.large,
          onPressed: onRetry,
          leadingIcon: const Icon(Icons.mic_rounded, color: Colors.white),
        ),

        // 2. Secondary Multimodal Action: [ Show Crop / पिकाचा फोटो दाखवा ]
        if (onShowCrop != null) ...[
          const SizedBox(height: AppSpacing.s10),
          AppButton.secondary(
            label: strings.voiceShowCropContextual,
            size: AppButtonSize.normal,
            onPressed: onShowCrop,
            leadingIcon: const Icon(Icons.camera_alt_rounded, size: 20),
          ),
        ],

        // 3. Fallback: [ Type Instead / लिहून सांगा ]
        if (onTypeInstead != null) ...[
          const SizedBox(height: AppSpacing.s10),
          AppButton.outline(
            label: strings.voiceTypeFallback,
            size: AppButtonSize.normal,
            onPressed: onTypeInstead,
            leadingIcon: const Icon(Icons.keyboard_rounded, size: 20),
          ),
        ],
      ],
    );
  }
}
