import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/localization/app_strings.dart';
import '../app_button.dart';

/// Accessible Permission Handler card for Bhoomi Voice interactions.
class BhoomiVoicePermission extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback? onRequestPermission;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onShowCrop;
  final VoidCallback? onTypeInstead;
  final VoidCallback? onCancel;
  final AppStrings strings;

  const BhoomiVoicePermission({
    super.key,
    required this.strings,
    this.isPermanentlyDenied = false,
    this.onRequestPermission,
    this.onOpenSettings,
    this.onShowCrop,
    this.onTypeInstead,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.m16),

        // Accessible high-contrast mic-off badge
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.turmeric.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_off_rounded,
              color: AppColors.turmeric,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m16),

        // Conversational Headline
        Text(
          isPermanentlyDenied
              ? strings.voicePermissionTitle
              : strings.voicePermissionNeedMic,
          style: AppTypography.subheading.copyWith(
            color: AppColors.soilCharcoal,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s8),

        // Explanatory Text
        Text(
          isPermanentlyDenied
              ? strings.voicePermissionPermanentlyDenied
              : strings.voicePermissionDesc,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.fieldSlate,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl28),

        // Primary CTA: [ Open Settings ] or [ Allow Microphone ]
        if (isPermanentlyDenied)
          AppButton.primary(
            label: strings.voiceOpenSettings,
            size: AppButtonSize.large,
            onPressed: onOpenSettings,
            leadingIcon: const Icon(Icons.settings_rounded, color: Colors.white),
          )
        else
          AppButton.primary(
            label: strings.voiceGrantPermission,
            size: AppButtonSize.large,
            onPressed: onRequestPermission,
            leadingIcon:
                const Icon(Icons.check_circle_rounded, color: Colors.white),
          ),

        // Secondary Multimodal Action: [ Show Crop ]
        if (onShowCrop != null) ...[
          const SizedBox(height: AppSpacing.s10),
          AppButton.secondary(
            label: strings.voiceShowCropContextual,
            size: AppButtonSize.normal,
            onPressed: onShowCrop,
            leadingIcon: const Icon(Icons.camera_alt_rounded, size: 20),
          ),
        ],

        // Tertiary Fallback: [ Type Instead ]
        if (onTypeInstead != null) ...[
          const SizedBox(height: AppSpacing.s10),
          AppButton.outline(
            label: strings.voiceTypeFallback,
            size: AppButtonSize.normal,
            onPressed: onTypeInstead,
            leadingIcon: const Icon(Icons.keyboard_rounded, size: 20),
          ),
        ],

        if (onCancel != null) ...[
          const SizedBox(height: AppSpacing.s8),
          Center(
            child: TextButton(
              onPressed: onCancel,
              child: Text(
                strings.cancel,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.fieldSlate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
