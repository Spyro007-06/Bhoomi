import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../core/localization/locale_provider.dart';
import '../core/localization/app_strings.dart';
import 'app_status_badge.dart';
import 'app_button.dart';

/// Data class for alternative predictions returned by Confidence Gate.
class PredictionItem {
  final String label;
  final double confidence;
  final String displayName;

  const PredictionItem({
    required this.label,
    required this.confidence,
    required this.displayName,
  });
}

/// Data class for Doubt Doctor visual candidates.
class CandidateSignature {
  final String label;
  final String name;
  final String visualSignature;
  final String? imageUrl;

  const CandidateSignature({
    required this.label,
    required this.name,
    required this.visualSignature,
    this.imageUrl,
  });
}

/// Specialized Confidence Gate Cards (F2, F4, F12, API_CONTRACT §6).
///
/// 3 Bands:
/// 1. ADVISE: Calm Forest Green ("I have enough information to guide you")
/// 2. CLARIFY (Doubt Doctor): Turmeric ("I need one more observation")
/// 3. ESCALATE: Muted Danger Red ("I am not confident enough to advise you. Let's get expert help.")
abstract class ConfidenceGateCard {
  /// Builds the Advise Band Card
  static Widget advise({
    required String topDiagnosis,
    required double confidence,
    required List<PredictionItem> alternatives,
    VoidCallback? onViewAdvisory,
  }) {
    return _AdviseGateCard(
      topDiagnosis: topDiagnosis,
      confidence: confidence,
      alternatives: alternatives,
      onViewAdvisory: onViewAdvisory,
    );
  }

  /// Builds the Clarify / Doubt Doctor Card
  static Widget clarify({
    required String question,
    String? questionLocalized,
    required List<CandidateSignature> candidates,
    required ValueChanged<String> onAnswerSelected, // 'yes' | 'no' | 'unknown'
  }) {
    return _ClarifyGateCard(
      question: question,
      questionLocalized: questionLocalized,
      candidates: candidates,
      onAnswerSelected: onAnswerSelected,
    );
  }

  /// Builds the Escalate Band Card
  static Widget escalate({
    required String reasonCode,
    required String reasonDescription,
    String? assignedTo,
    int queuePosition = 3,
    int etaMinutes = 45,
    VoidCallback? onCallHelpline,
  }) {
    return _EscalateGateCard(
      reasonCode: reasonCode,
      reasonDescription: reasonDescription,
      assignedTo: assignedTo,
      queuePosition: queuePosition,
      etaMinutes: etaMinutes,
      onCallHelpline: onCallHelpline,
    );
  }
}

// ---------------------------------------------------------------------------
// 1. ADVISE GATE CARD
// ---------------------------------------------------------------------------
class _AdviseGateCard extends ConsumerWidget {
  final String topDiagnosis;
  final double confidence;
  final List<PredictionItem> alternatives;
  final VoidCallback? onViewAdvisory;

  const _AdviseGateCard({
    required this.topDiagnosis,
    required this.confidence,
    required this.alternatives,
    this.onViewAdvisory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStrings strings;
    try {
      strings = ref.watch(stringsProvider);
    } catch (_) {
      strings = AppStrings(AppLanguage.marathi);
    }

    final localizedTarget = strings.getLocalizedTargetName(topDiagnosis);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.forest, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l16,
              vertical: AppSpacing.m12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.cardValue),
                topRight: Radius.circular(AppRadius.cardValue),
              ),
            ),
            child: Row(
              children: [
                const AppStatusBadge.advise(),
                const SizedBox(width: AppSpacing.m12),
                Expanded(
                  child: Text(
                    strings.gateAdviseHeader,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.gateAdviseDetectedIssue,
                  style: AppTypography.captionSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.forest,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizedTarget,
                        style: AppTypography.sectionTitle.copyWith(
                          color: AppColors.soilCharcoal,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m12,
                        vertical: AppSpacing.s8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: AppRadius.chip,
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${(confidence * 100).toInt()}% ${strings.gateAdviseMatchBadge}',
                        style: AppTypography.badge.copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.l16),
                const Divider(height: 1, color: AppColors.subtleDivider),
                const SizedBox(height: AppSpacing.m12),

                // Alternatives List (Invariant 3: always show alternatives)
                Text(
                  strings.gateAdviseAlternativesHeader,
                  style: AppTypography.captionSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.fieldSlate,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                ...alternatives.map(
                  (alt) {
                    final altLocalized = strings.getLocalizedTargetName(alt.label);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              altLocalized,
                              style: AppTypography.body.copyWith(
                                color: AppColors.fieldSlate,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '${(alt.confidence * 100).toInt()}%',
                            style: AppTypography.captionSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.fieldSlate,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.l16),
                AppButton.primary(
                  label: strings.gateAdviseViewAdvisoryButton,
                  onPressed: onViewAdvisory,
                  isFullWidth: true,
                  trailingIcon: const Icon(Icons.arrow_forward_rounded, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. CLARIFY GATE CARD (DOUBT DOCTOR)
// ---------------------------------------------------------------------------
class _ClarifyGateCard extends ConsumerWidget {
  final String question;
  final String? questionLocalized;
  final List<CandidateSignature> candidates;
  final ValueChanged<String> onAnswerSelected;

  const _ClarifyGateCard({
    required this.question,
    this.questionLocalized,
    required this.candidates,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStrings strings;
    try {
      strings = ref.watch(stringsProvider);
    } catch (_) {
      strings = AppStrings(AppLanguage.marathi);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.turmeric, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l16,
              vertical: AppSpacing.m12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.cardValue),
                topRight: Radius.circular(AppRadius.cardValue),
              ),
            ),
            child: Row(
              children: [
                const AppStatusBadge.clarify(),
                const SizedBox(width: AppSpacing.m12),
                Expanded(
                  child: Text(
                    strings.gateClarifyHeader,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.gateClarifyPrompt,
                  style: AppTypography.subhead.copyWith(
                    color: AppColors.soilCharcoal,
                  ),
                ),
                const SizedBox(height: AppSpacing.m12),

                // Candidates side-by-side / column
                ...candidates.map(
                  (cand) {
                    final candLocalizedName = strings.getLocalizedTargetName(cand.label);
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                      padding: const EdgeInsets.all(AppSpacing.m12),
                      decoration: BoxDecoration(
                        color: AppColors.ricePaper,
                        borderRadius: AppRadius.button,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            color: AppColors.turmeric,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candLocalizedName,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.soilCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cand.visualSignature,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.fieldSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.l16),

                // Single physical observation question
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l16),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg.withValues(alpha: 0.5),
                    borderRadius: AppRadius.button,
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.warning,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Text(
                            strings.gateClarifyObservationHeader,
                            style: AppTypography.captionSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        question,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.soilCharcoal,
                        ),
                      ),
                      if (questionLocalized != null && questionLocalized!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs4),
                        Text(
                          questionLocalized!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.forest,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl24),

                // 3 Tactile Options: YES / NO / CAN'T TELL
                Row(
                  children: [
                    Expanded(
                      child: AppButton.primary(
                        label: strings.gateClarifyYes,
                        onPressed: () => onAnswerSelected('yes'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: AppButton.outline(
                        label: strings.gateClarifyNo,
                        onPressed: () => onAnswerSelected('no'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: AppButton.secondary(
                        label: strings.gateClarifyUnknown,
                        onPressed: () => onAnswerSelected('unknown'),
                        size: AppButtonSize.small,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. ESCALATE GATE CARD
// ---------------------------------------------------------------------------
class _EscalateGateCard extends ConsumerWidget {
  final String reasonCode;
  final String reasonDescription;
  final String? assignedTo;
  final int queuePosition;
  final int etaMinutes;
  final VoidCallback? onCallHelpline;

  const _EscalateGateCard({
    required this.reasonCode,
    required this.reasonDescription,
    this.assignedTo,
    required this.queuePosition,
    required this.etaMinutes,
    this.onCallHelpline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStrings strings;
    try {
      strings = ref.watch(stringsProvider);
    } catch (_) {
      strings = AppStrings(AppLanguage.marathi);
    }

    final effectiveAssigned = assignedTo ?? strings.gateEscalateDefaultAssigned;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.danger, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l16,
              vertical: AppSpacing.m12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.cardValue),
                topRight: Radius.circular(AppRadius.cardValue),
              ),
            ),
            child: Row(
              children: [
                const AppStatusBadge.escalate(),
                const SizedBox(width: AppSpacing.m12),
                Expanded(
                  child: Text(
                    strings.gateEscalateHeader,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.gateEscalatePrompt,
                  style: AppTypography.subhead.copyWith(
                    color: AppColors.soilCharcoal,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs4),
                Text(
                  strings.gateEscalatePromptSub,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.m12),

                // Reason Box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m12),
                  decoration: BoxDecoration(
                    color: AppColors.ricePaper,
                    borderRadius: AppRadius.button,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.danger, size: 20),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          reasonDescription,
                          style: AppTypography.body.copyWith(
                            fontSize: 14,
                            color: AppColors.soilCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.l16),

                // Case Details: Assigned to, Queue Position, ETA
                Row(
                  children: [
                    Expanded(
                      child: _buildCaseMetric(
                        title: strings.gateEscalateAssignedTo,
                        value: effectiveAssigned,
                        icon: Icons.person_pin_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: _buildCaseMetric(
                        title: strings.gateEscalateQueuePos,
                        value: strings.gateEscalateQueuePosValue(queuePosition),
                        icon: Icons.format_list_numbered_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: _buildCaseMetric(
                        title: strings.gateEscalateEstWait,
                        value: strings.gateEscalateEstWaitValue(etaMinutes),
                        icon: Icons.timer_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl24),

                AppButton.danger(
                  label: strings.gateEscalateCallHelpline,
                  onPressed: onCallHelpline,
                  isFullWidth: true,
                  leadingIcon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseMetric({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s8),
      decoration: BoxDecoration(
        color: AppColors.ricePaper,
        borderRadius: AppRadius.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.fieldSlate),
              const SizedBox(width: AppSpacing.xs4),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.captionSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.fieldSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.soilCharcoal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
