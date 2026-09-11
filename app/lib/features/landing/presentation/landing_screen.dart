import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/language_selector_button.dart';
import '../../onboarding/presentation/phone_auth_screen.dart';

/// Launch Landing & Welcome Screen for Bhoomi.
/// Open background artwork with a bottom gradient fade — no hard panels or boxes.
/// Content floats naturally over the imagery.
class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onStartPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PhoneAuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C2B14),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. FULL-BLEED BACKGROUND ARTWORK
          _buildBackgroundArtwork(),

          // 2. BOTTOM GRADIENT FADE — natural, no hard card edge
          _buildBottomGradientOverlay(),

          // 3. FOREGROUND CONTENT
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTopBranding(strings),
                              const Spacer(flex: 3),
                              _buildBottomContent(strings),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BACKGROUND
  // ---------------------------------------------------------------------------
  Widget _buildBackgroundArtwork() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/bhoomi_farmer_hero.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFBE8C8),
                  Color(0xFFE2EED8),
                  Color(0xFF0F3819),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM GRADIENT — replaces hard dark card
  // ---------------------------------------------------------------------------
  Widget _buildBottomGradientOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 360,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.30, 1.0],
            colors: [
              Color(0x000B2E15),
              Color(0xD00B2E15),
              Color(0xF80B2E15),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BRANDING
  // ---------------------------------------------------------------------------
  Widget _buildTopBranding(AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.m12,
        left: AppSpacing.l20,
        right: AppSpacing.l20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/images/bhoomi_logo_mark.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF1B5E20),
                    size: 30,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          Text(
            strings.landingTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF114216),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.1,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 3),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 22, height: 1.5, color: const Color(0xFF2E7D32)),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  strings.landingTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Container(width: 22, height: 1.5, color: const Color(0xFF2E7D32)),
              ],
            ),
          ),
          const SizedBox(height: 2),

          Text(
            strings.landingSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF235528),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM CONTENT — floats over gradient, no enclosing card
  // ---------------------------------------------------------------------------
  Widget _buildBottomContent(AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l24,
        0,
        AppSpacing.l24,
        AppSpacing.m16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hero message — clean text over gradient
          Text(
            strings.landingHeroMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.93),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: -0.1,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l20),

          // THREE PILLARS — inline, no surrounding box
          _buildPillarRow(strings),
          const SizedBox(height: AppSpacing.l24),

          // CTA BUTTON
          _buildStartButton(strings),
          const SizedBox(height: AppSpacing.m12),

          // LANGUAGE SELECTOR
          const Center(child: LanguageSelectorButton(isDarkBackground: true)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PILLAR ROW — three columns with icons + text, separated by subtle fades
  // ---------------------------------------------------------------------------
  Widget _buildPillarRow(AppStrings strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPillarItem(
          icon: Icons.mic_rounded,
          title: strings.landingTalkTitle,
          subtitle: strings.landingTalkSubtitle,
          hasAccent: true,
        ),
        _buildPillarSeparator(),
        _buildPillarItem(
          icon: Icons.photo_camera_rounded,
          title: strings.landingShowTitle,
          subtitle: strings.landingShowSubtitle,
          hasAccent: false,
        ),
        _buildPillarSeparator(),
        _buildPillarItem(
          icon: Icons.volume_up_rounded,
          title: strings.landingListenTitle,
          subtitle: strings.landingListenSubtitle,
          hasAccent: false,
        ),
      ],
    );
  }

  Widget _buildPillarItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasAccent,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: hasAccent ? const Color(0xFFFFD54F) : const Color(0xFF81C784),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF9ECFA1),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarSeparator() {
    return Container(
      width: 1,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CTA BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildStartButton(AppStrings strings) {
    return Semantics(
      button: true,
      label: strings.landingSemanticsStart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _onStartPressed,
          child: Ink(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF66BB6A),
                  Color(0xFF43A047),
                  Color(0xFF2E7D32),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFA5D6A7).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF43A047).withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      strings.landingStartButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
