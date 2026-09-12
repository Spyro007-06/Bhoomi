import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_mode.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../models/farm_models.dart';
import '../../../providers/farm_providers.dart';
import '../../../providers/feature_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../core/constants/crop_constants.dart';
import '../../../models/farmer_profile_models.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/farm_health_card.dart';
import '../../../widgets/risk_card.dart';
import '../../../widgets/followup_card.dart';
import '../../onboarding/presentation/farmer_farm_setup_screen.dart';
import '../../../providers/farmer_profile_providers.dart';
import '../../timeline/presentation/problem_detail_screen.dart';
import '../../../widgets/farmer_voice_assistant.dart';
import '../../../widgets/language_selector_button.dart';

/// Central Home Dashboard for Bhoomi Farmer App.
class HomeScreen extends ConsumerWidget {
  final VoidCallback? onCheckCropPressed;

  const HomeScreen({
    super.key,
    this.onCheckCropPressed,
  });

  String _getGreeting(dynamic strings, String? farmerName) {
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? strings.greetingMorning
        : (hour < 17 ? strings.greetingAfternoon : strings.greetingEvening);
    if (farmerName != null && farmerName.trim().isNotEmpty) {
      final firstName = farmerName.trim().split(' ').first;
      return '$timeGreeting, $firstName';
    }
    return timeGreeting;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final activeFarmId = ref.watch(activeFarmIdProvider);
    final summaryAsync = ref.watch(activeFarmSummaryProvider);
    final profile = ref.watch(farmerProfileProvider).profile;

    final farmIdForFeatures = activeFarmId ?? 'f_1';
    final alertsAsync = ref.watch(activeAlertsProvider(farmIdForFeatures));
    final followupsAsync = ref.watch(pendingFollowUpsProvider(farmIdForFeatures));
    final timelineAsync = ref.watch(farmTimelineProvider(farmIdForFeatures));

    return Scaffold(
      backgroundColor: AppColors.ricePaper,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forest,
          onRefresh: () async {
            ref.invalidate(activeFarmSummaryProvider);
            ref.invalidate(activeAlertsProvider(farmIdForFeatures));
            ref.invalidate(pendingFollowUpsProvider(farmIdForFeatures));
            ref.invalidate(farmTimelineProvider(farmIdForFeatures));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l20,
              vertical: AppSpacing.l20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header: Personal Greeting, Bhoomi Partner Info & Global Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(strings, profile?.name),
                            style: AppTypography.subheading.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile != null
                                ? '${profile.farmArea ?? 2.5} ${FarmAreaUnit.fromKey(profile.farmAreaUnit).localizedLabel(strings.language.code)} · ${CropType.fromKey(profile.currentCrop).getLocalizedName(strings)} · 📍 ${strings.getLocalizedRegion(profile.region)}'
                                : '${strings.appName} · ${strings.greetingPartnerSubtitle}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.fieldSlate,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (AppModeConfig.isDemo) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.forest.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          strings.demoModeLabel,
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.forest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                    ],
                    // Global Language Selector Button
                    const LanguageSelectorButton(),
                  ],
                ),
                const SizedBox(height: AppSpacing.l20),

                // =========================================================================
                // 2. PRIMARY VOICE AREA: 🎤 TALK TO BHOOMI (MAIN INTERACTION HERO)
                // =========================================================================
                Semantics(
                  label: '${strings.voiceHeroTitle}. ${strings.voiceHeroSubtitleFull}',
                  button: true,
                  child: InkWell(
                    borderRadius: AppRadius.card,
                    onTap: () => FarmerVoiceAssistant.show(
                      context,
                      onShowPhoto: () => onCheckCropPressed?.call(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l16,
                        vertical: AppSpacing.l20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warmSurface,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: AppColors.forest, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forest.withValues(alpha: 0.16),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 68dp Interactive Tactile Microphone
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.forest,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.forest.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic_rounded,
                              color: AppColors.pureWhite,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m12),

                          // Clear Hierarchy: Title + Subtitle
                          Text(
                            strings.voiceHeroTitle,
                            style: AppTypography.sectionTitle.copyWith(
                              color: AppColors.forest,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs4),
                          Text(
                            strings.voiceHeroSubtitleFull,
                            style: AppTypography.body.copyWith(
                              color: AppColors.soilCharcoal,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.l16),

                          // Prominent Primary CTA Action Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.m12,
                              horizontal: AppSpacing.l16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.forest,
                              borderRadius: AppRadius.button,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                                const SizedBox(width: AppSpacing.s8),
                                Flexible(
                                  child: Text(
                                    strings.voiceHeroCta,
                                    style: AppTypography.button.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.l16),

                // =========================================================================
                // 3. SECONDARY CROP CHECK ACTION: 📷 SHOW BHOOMI YOUR CROP
                // =========================================================================
                GestureDetector(
                  onTap: onCheckCropPressed,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.l16),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: AppRadius.card,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forest.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.l16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.checkCropBannerTitle,
                                style: AppTypography.subheading.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strings.checkCropBannerAction,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.l24),

                // =========================================================================
                // 3. TODAY'S ATTENTION (ACTIONABLE ALERTS & FOLLOW-UPS)
                // =========================================================================
                alertsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (alertsRes) {
                    if (alertsRes.alerts.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final topAlert = alertsRes.alerts.first;
                    final tasks = topAlert.inspectionTasks.isNotEmpty
                        ? topAlert.inspectionTasks
                        : [strings.defaultInspectionTask];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.recentAlertsHeader,
                          style: AppTypography.subheading.copyWith(
                            color: AppColors.soilCharcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m12),
                        RiskCard(
                          target: topAlert.target,
                          riskLevel: topAlert.riskLevel,
                          reason: topAlert.reason,
                          inspectionTasks: tasks,
                          triggerType: topAlert.triggerType,
                          onInspectNow: () async {
                            try {
                              await ref.read(alertRepositoryProvider).respondToAlert(
                                    alertId: topAlert.id,
                                    outcome: 'found',
                                  );
                              ref.invalidate(activeAlertsProvider(farmIdForFeatures));
                            } catch (_) {}
                          },
                        ),
                        const SizedBox(height: AppSpacing.l24),
                      ],
                    );
                  },
                ),

                followupsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (followupsRes) {
                    if (followupsRes.followUps.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final topFollowup = followupsRes.followUps.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.pendingFollowupsHeader,
                          style: AppTypography.subheading.copyWith(
                            color: AppColors.soilCharcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m12),
                        FollowUpCard(
                          question: strings.getLocalizedFollowupQuestion(topFollowup.question),
                          target: topFollowup.target ?? 'treatment',
                          onResponse: (response) async {
                            try {
                              await ref.read(followUpRepositoryProvider).respondToFollowUp(
                                    followUpId: topFollowup.id,
                                    response: response,
                                  );
                              ref.invalidate(pendingFollowUpsProvider(farmIdForFeatures));
                            } catch (_) {}
                          },
                        ),
                        const SizedBox(height: AppSpacing.l24),
                      ],
                    );
                  },
                ),

                // =========================================================================
                // 5. FARM STATUS & SUPPORTING MEMORY
                // =========================================================================
                if (activeFarmId == null || activeFarmId.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.l16),
                    backgroundColor: AppColors.warmSurface,
                    border: Border.all(color: AppColors.turmeric, width: 1.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_location_alt_rounded, color: AppColors.turmeric, size: 24),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: Text(
                                strings.noFarmSetupTitle,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.soilCharcoal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          strings.noFarmSetupDesc,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.fieldSlate),
                        ),
                        const SizedBox(height: AppSpacing.m12),
                        AppButton.secondary(
                          label: strings.setupFarmButton,
                          size: AppButtonSize.small,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FarmerFarmSetupScreen(isFirstTimeOnboarding: false),
                              ),
                            );
                          },
                          leadingIcon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  )
                else
                  summaryAsync.when(
                    data: (summary) {
                      if (summary != null) {
                        return FarmHealthCard(
                          health: HealthModel(
                            sentence: strings.getLocalizedHealthSentence(summary.health.sentence),
                            trend: summary.health.trend,
                          ),
                          cropName: '${CropType.fromKey(summary.farm.crop).getLocalizedName(strings)} (${summary.farm.variety ?? "Indrayani"})',
                          growthStage: strings.getLocalizedGrowthStage(summary.farm.growthStage),
                          region: strings.getLocalizedRegion(summary.farm.region),
                          openProblems: summary.openProblems,
                          pendingFollowups: summary.pendingFollowups,
                          activeAlerts: summary.activeAlerts,
                        );
                      }
                      return FarmHealthCard(
                        health: HealthModel(
                          sentence: strings.healthSentenceDefault,
                          trend: 'stable',
                        ),
                        cropName: '${strings.cropPaddy} (Indrayani)',
                        growthStage: strings.growthStageTillering,
                        region: strings.getLocalizedRegion('Nashik'),
                      );
                    },
                    loading: () => FarmHealthCard(
                      health: HealthModel(
                        sentence: strings.loading,
                        trend: 'stable',
                      ),
                      cropName: strings.cropPaddy,
                      growthStage: '...',
                      region: '...',
                    ),
                    error: (_, __) => FarmHealthCard(
                      health: HealthModel(
                        sentence: strings.healthSentenceDefault,
                        trend: 'stable',
                      ),
                      cropName: strings.cropPaddy,
                      growthStage: strings.growthStageTillering,
                      region: strings.getLocalizedRegion('Maharashtra'),
                    ),
                  ),

                const SizedBox(height: AppSpacing.l24),

                // Section 6: Recent Activity (Timeline Snippet)
                Text(
                  strings.homeRecentActivityHeader,
                  style: AppTypography.subheading.copyWith(
                    color: AppColors.soilCharcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.m12),
                timelineAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (timelineRes) {
                    if (timelineRes.events.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.l16),
                        child: Text(
                          strings.noHistoryMessage,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.fieldSlate),
                        ),
                      );
                    }

                    return Column(
                      children: timelineRes.events.take(2).map((ev) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: ev.problemId != null
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProblemDetailScreen(problemId: ev.problemId!),
                                      ),
                                    );
                                  }
                                : null,
                            child: AppCard(
                              padding: const EdgeInsets.all(AppSpacing.l16),
                              child: Row(
                                children: [
                                  const Icon(Icons.history_rounded, color: AppColors.forest, size: 22),
                                  const SizedBox(width: AppSpacing.m12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                           ev.id == 'tl_demo_01'
                                               ? strings.timelineAdvisoryTitle
                                               : (ev.id == 'tl_demo_02'
                                                   ? strings.timelineDiagnosisTitle
                                                   : (ev.id == 'tl_demo_03'
                                                       ? strings.timelineAlertTitle
                                                       : ev.title)),
                                           style: AppTypography.bodyMedium.copyWith(
                                             fontWeight: FontWeight.w700,
                                           ),
                                         ),
                                        Text(
                                          ev.timestamp.length >= 10 ? ev.timestamp.substring(0, 10) : ev.timestamp,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.fieldSlate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (ev.problemId != null)
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.fieldSlate, size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xl32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
