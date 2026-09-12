import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_mode.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/farmer_profile_providers.dart';
import '../../../providers/farm_providers.dart';
import '../../../providers/feature_providers.dart';
import '../../../providers/storage_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/language_selector_button.dart';
import '../../referrals/presentation/referrals_screen.dart';
import '../../onboarding/presentation/farmer_farm_setup_screen.dart';
import '../../timeline/presentation/history_screen.dart';

/// More Options & Farmer Settings Screen.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(appLanguageProvider);
    final strings = ref.read(stringsProvider);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.warmSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: Text(
            strings.selectLanguagePrompt,
            style: AppTypography.subheading.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguage.values.map((lang) {
              final isSelected = lang == currentLang;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
                title: Text(
                  lang.label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? AppColors.forest : AppColors.soilCharcoal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.forest)
                    : null,
                onTap: () {
                  ref.read(appLanguageProvider.notifier).setLanguage(lang);
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final strings = ref.read(stringsProvider);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.warmSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: Text(
            strings.logoutConfirmTitle,
            style: AppTypography.subheading.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            strings.logoutConfirmDesc,
            style: AppTypography.bodySmall.copyWith(color: AppColors.fieldSlate),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l16,
            vertical: AppSpacing.m12,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: AppButton.ghost(
                    label: strings.cancel,
                    size: AppButtonSize.small,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: AppButton.danger(
                    label: strings.confirmLogout,
                    size: AppButtonSize.small,
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      // Local-only logout
                      await ref.read(authStateProvider.notifier).logout();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetDemoData(BuildContext context, WidgetRef ref) async {
    await ref.read(demoStoreProvider).reset();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(farmerProfileProvider.notifier).loadProfile(user.id);
    }
    ref.invalidate(activeFarmSummaryProvider);
    ref.invalidate(activeAlertsProvider);
    ref.invalidate(pendingFollowUpsProvider);
    ref.invalidate(farmTimelineProvider);
    ref.invalidate(problemDetailProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(stringsProvider).resetDemoData),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(farmerProfileProvider).profile;

    return Scaffold(
      backgroundColor: AppColors.ricePaper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          strings.navMore,
          style: AppTypography.subheading.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l20,
            vertical: AppSpacing.m16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Header Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.l16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.forest, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.forest,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.l16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name.isNotEmpty == true
                                ? profile!.name
                                : (user?.name ?? strings.profileSection),
                            style: AppTypography.subheading.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.phone ?? profile?.mobileNumber ?? '+91 XXXXX XXXXX',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.soilCharcoal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (profile?.region != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 14, color: AppColors.forest),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    profile!.region!,
                                    style: AppTypography.captionSmall.copyWith(
                                      color: AppColors.fieldSlate,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l20),

              if (AppModeConfig.isDemo) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      strings.demoModeLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
              ],

              // Menu Items Card
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    if (AppModeConfig.isDemo) ...[
                      ListTile(
                        leading: const Icon(Icons.restart_alt_rounded,
                            color: AppColors.forest),
                        title: Text(
                          strings.resetDemoData,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.soilCharcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.fieldSlate),
                        onTap: () => _resetDemoData(context, ref),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                    ],
                    // My Farm & Crop Profile
                    ListTile(
                      leading: const Icon(Icons.agriculture_rounded, color: AppColors.forest),
                      title: Text(
                        strings.myFarmOption,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.soilCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.fieldSlate),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const FarmerFarmSetupScreen(isFirstTimeOnboarding: false),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // KVK & Helpline Referrals
                    ListTile(
                      leading: const Icon(Icons.contact_phone_rounded, color: AppColors.forest),
                      title: Text(
                        strings.referralsOption,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.soilCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.fieldSlate),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReferralsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // Crop Check History
                    ListTile(
                      leading: const Icon(Icons.history_rounded, color: AppColors.forest),
                      title: Text(
                        strings.historyOption,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.soilCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.fieldSlate),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // Language Switcher
                    ListTile(
                      leading: const Icon(Icons.language_rounded, color: AppColors.forest),
                      title: Text(
                        strings.languageOption,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.soilCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            strings.language.label,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.fieldSlate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.fieldSlate),
                        ],
                      ),
                      onTap: () => _showLanguageDialog(context, ref),
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // About Bhoomi
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.forest),
                      title: Text(
                        strings.aboutOption,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.soilCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.fieldSlate),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: strings.aboutAppName,
                          applicationVersion: 'v2.0.0 (SIH26131)',
                          applicationLegalese: strings.aboutLegalese,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl32),

              // Local Logout Button
              AppButton.danger(
                label: strings.logoutButton,
                size: AppButtonSize.large,
                isFullWidth: true,
                onPressed: () => _showLogoutDialog(context, ref),
                leadingIcon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.l20),
            ],
          ),
        ),
      ),
    );
  }
}
