import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/core/theme/app_theme.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/core/constants/app_constants.dart';
import 'package:bhoomi/widgets/risk_card.dart';
import 'package:bhoomi/widgets/confidence_gate_card.dart';
import 'package:bhoomi/widgets/pesticide_veto_card.dart';
import 'package:bhoomi/widgets/advisory_ipm_card.dart';
import 'package:bhoomi/widgets/followup_card.dart';

Widget _createLocalizedHarness({
  required Widget child,
  required AppLanguage language,
}) {
  final notifier = LocaleNotifier(null);
  notifier.state = language;

  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => notifier),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  group('Safety-Critical Localization & Content Consistency Tests (P4 Hardening)', () {
    // =========================================================================
    // 1. TARGET DISPLAY NAME RESOLVER TESTS
    // =========================================================================
    test('Target display name resolver maps all common pests/diseases across mr, hi, en', () {
      // Marathi (Primary)
      expect(AppConstants.getLocalizedTarget('blast', lang: 'mr'), 'भातावरील करपा');
      expect(AppConstants.getLocalizedTarget('brown_spot', lang: 'mr'), 'तपकिरी ठिपके');
      expect(AppConstants.getLocalizedTarget('bacterial_leaf_blight', lang: 'mr'), 'जीवाणूजन्य करपा');
      expect(AppConstants.getLocalizedTarget('yellow_stem_borer', lang: 'mr'), 'खोडकिडा');
      expect(AppConstants.getLocalizedTarget('brown_planthopper', lang: 'mr'), 'तुडतुडे (तपकिरी मावा)');
      expect(AppConstants.getLocalizedTarget('treatment', lang: 'mr'), 'पीक उपचार');

      // Hindi
      expect(AppConstants.getLocalizedTarget('blast', lang: 'hi'), 'धान का झुलसा रोग');
      expect(AppConstants.getLocalizedTarget('brown_spot', lang: 'hi'), 'भूरा धब्बा रोग');
      expect(AppConstants.getLocalizedTarget('bacterial_leaf_blight', lang: 'hi'), 'जीवाणु पत्ती झुलसा');
      expect(AppConstants.getLocalizedTarget('yellow_stem_borer', lang: 'hi'), 'तने का पीला छेदक');
      expect(AppConstants.getLocalizedTarget('brown_planthopper', lang: 'hi'), 'भूरा माहू / फुदका');
      expect(AppConstants.getLocalizedTarget('treatment', lang: 'hi'), 'फसल उपचार');

      // English
      expect(AppConstants.getLocalizedTarget('blast', lang: 'en'), 'Paddy Blast');
      expect(AppConstants.getLocalizedTarget('brown_spot', lang: 'en'), 'Brown Spot');
      expect(AppConstants.getLocalizedTarget('bacterial_leaf_blight', lang: 'en'), 'Bacterial Leaf Blight (BLB)');
      expect(AppConstants.getLocalizedTarget('yellow_stem_borer', lang: 'en'), 'Yellow Stem Borer');
      expect(AppConstants.getLocalizedTarget('brown_planthopper', lang: 'en'), 'Brown Planthopper (BPH)');
      expect(AppConstants.getLocalizedTarget('treatment', lang: 'en'), 'Crop Treatment');

      // Unknown Target fallback (safe capitalization, never snake_case)
      expect(AppConstants.getLocalizedTarget('unknown_leaf_blight', lang: 'mr'), 'Unknown Leaf Blight');
      expect(AppConstants.getLocalizedTarget(null, lang: 'mr'), 'पिकाची समस्या');
      expect(AppConstants.getLocalizedTarget('', lang: 'hi'), 'फसल की समस्या');
      expect(AppConstants.getLocalizedTarget(null, lang: 'en'), 'Crop Issue');
    });

    // =========================================================================
    // 2. RISK CARD LOCALIZATION TESTS (mr, hi, en)
    // =========================================================================
    for (final lang in AppLanguage.values) {
      testWidgets('RiskCard renders 100% localized in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: const RiskCard(
              target: 'blast',
              riskLevel: 'high',
              triggerType: 'spread',
              reason: 'Rainfall test reason',
              inspectionTasks: ['Check upper leaves'],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.riskCardTriggerSpread), findsOneWidget);
        expect(find.text(strings.getLocalizedTargetName('blast')), findsOneWidget);
        expect(find.text(strings.riskCardWhyHeader), findsOneWidget);
        expect(find.text(strings.riskCardGoLookHeader), findsOneWidget);
        expect(find.text(strings.riskCardInspectNowAction), findsOneWidget);
      });
    }

    // =========================================================================
    // 3. CONFIDENCE GATE CARDS LOCALIZATION TESTS (Advise, Clarify, Escalate)
    // =========================================================================
    for (final lang in AppLanguage.values) {
      testWidgets('ConfidenceGateCard.advise renders 100% localized in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: ConfidenceGateCard.advise(
              topDiagnosis: 'blast',
              confidence: 0.92,
              alternatives: const [
                PredictionItem(label: 'brown_spot', confidence: 0.08, displayName: 'Brown Spot'),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.gateAdviseHeader), findsOneWidget);
        expect(find.text(strings.gateAdviseDetectedIssue), findsOneWidget);
        expect(find.text(strings.getLocalizedTargetName('blast')), findsOneWidget);
        expect(find.textContaining(strings.gateAdviseMatchBadge), findsOneWidget);
        expect(find.text(strings.gateAdviseAlternativesHeader), findsOneWidget);
        expect(find.text(strings.getLocalizedTargetName('brown_spot')), findsOneWidget);
        expect(find.text(strings.gateAdviseViewAdvisoryButton), findsOneWidget);
      });

      testWidgets('ConfidenceGateCard.clarify renders 100% localized in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: ConfidenceGateCard.clarify(
              question: 'Do you see grey mold on leaf underside?',
              candidates: const [
                CandidateSignature(label: 'blast', name: 'Blast', visualSignature: 'Diamond spot'),
                CandidateSignature(label: 'brown_spot', name: 'Brown Spot', visualSignature: 'Round spot'),
              ],
              onAnswerSelected: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.gateClarifyHeader), findsOneWidget);
        expect(find.text(strings.gateClarifyPrompt), findsOneWidget);
        expect(find.text(strings.getLocalizedTargetName('blast')), findsOneWidget);
        expect(find.text(strings.getLocalizedTargetName('brown_spot')), findsOneWidget);
        expect(find.text(strings.gateClarifyObservationHeader), findsOneWidget);
        expect(find.text(strings.gateClarifyYes), findsOneWidget);
        expect(find.text(strings.gateClarifyNo), findsOneWidget);
        expect(find.text(strings.gateClarifyUnknown), findsOneWidget);
      });

      testWidgets('ConfidenceGateCard.escalate renders 100% localized in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: ConfidenceGateCard.escalate(
              reasonCode: 'LOW_CONFIDENCE',
              reasonDescription: 'Ambiguous visual patterns detected.',
              queuePosition: 4,
              etaMinutes: 30,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.gateEscalateHeader), findsOneWidget);
        expect(find.text(strings.gateEscalatePrompt), findsOneWidget);
        expect(find.text(strings.gateEscalatePromptSub), findsOneWidget);
        expect(find.text(strings.gateEscalateAssignedTo), findsOneWidget);
        expect(find.text(strings.gateEscalateQueuePos), findsOneWidget);
        expect(find.text(strings.gateEscalateQueuePosValue(4)), findsOneWidget);
        expect(find.text(strings.gateEscalateEstWait), findsOneWidget);
        expect(find.text(strings.gateEscalateEstWaitValue(30)), findsOneWidget);
        expect(find.text(strings.gateEscalateCallHelpline), findsOneWidget);
      });
    }

    // =========================================================================
    // 4. PESTICIDE VETO CARD LOCALIZATION & SAFETY TESTS
    // =========================================================================
    for (final lang in AppLanguage.values) {
      testWidgets('PesticideVetoCard renders 100% localized for WRONG_CLASS in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: const PesticideVetoCard(
              activeIngredient: 'carbendazim',
              concentration: '50% WP',
              formulation: 'wettable powder',
              verdictCode: 'WRONG_CLASS',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.pesticideVerdictTitleVeto), findsOneWidget);
        expect(find.text(strings.pesticideLabelOcrHeader), findsOneWidget);
        expect(find.text(strings.pesticideActiveIngredient), findsOneWidget);
        expect(find.text(strings.pesticideConcentrationForm), findsOneWidget);
        expect(find.text(strings.pesticideRegulatoryVerdictHeader), findsOneWidget);
        expect(find.text(strings.getLocalizedVerdictMessage('WRONG_CLASS')), findsOneWidget);
        expect(find.text(strings.pesticideSafetyRule), findsOneWidget);
        expect(find.text(strings.pesticideRetakePhoto), findsOneWidget);
        expect(find.text(strings.pesticideAskExpert), findsOneWidget);
      });

      testWidgets('PesticideVetoCard renders NO_OBJECTION_FOUND in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: const PesticideVetoCard(
              activeIngredient: 'tricyclazole',
              concentration: '75% WP',
              formulation: 'wettable powder',
              verdictCode: 'NO_OBJECTION_FOUND',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.pesticideVerdictTitleNoObjection), findsOneWidget);
        expect(find.text(strings.getLocalizedVerdictMessage('NO_OBJECTION_FOUND')), findsOneWidget);
        expect(find.text(strings.pesticideAcknowledgeAndFollow), findsOneWidget);
      });
    }

    // =========================================================================
    // 5. ADVISORY IPM CARD LOCALIZATION & MANDATORY ORDERING TESTS
    // =========================================================================
    for (final lang in AppLanguage.values) {
      testWidgets('AdvisoryIpmCard renders 100% localized and strict IPM order in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: const AdvisoryIpmCard(
              possibleIssue: 'blast',
              whatToAvoid: 'Avoid urea now.',
              whatToCheck: 'Check spindle lesions.',
              ladder: [
                LadderRung(tier: 'cultural', action: 'Drain field.'),
                LadderRung(tier: 'biological', action: 'Apply Pseudomonas.'),
                LadderRung(
                  tier: 'chemical',
                  action: 'Tricyclazole 75% WP',
                  dosage: '0.6 g/L',
                  phiDays: 30,
                  reentryHours: 24,
                ),
              ],
              expertTrigger: 'Escalate if >25% leaf area affected.',
              citations: [
                AdvisoryCitation(docId: 'c1', title: 'ICAR Manual', reviewedOn: '2025-11-01'),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.advisoryCardHeader), findsOneWidget);
        expect(find.text(strings.getLocalizedTargetName('blast')), findsOneWidget);
        expect(find.text(strings.advisoryWhatToAvoidHeader), findsOneWidget);
        expect(find.text(strings.advisoryWhatToCheckHeader), findsOneWidget);
        expect(find.text(strings.advisoryIpmLadderHeader), findsOneWidget);
        expect(find.text(strings.advisoryStep1Title), findsOneWidget);
        expect(find.text(strings.advisoryStep1Subtitle), findsOneWidget);
        expect(find.text(strings.advisoryStep2Title), findsOneWidget);
        expect(find.text(strings.advisoryStep2Subtitle), findsOneWidget);
        expect(find.text(strings.advisoryStep3Title), findsOneWidget);
        expect(find.text(strings.advisoryStep3Subtitle), findsOneWidget);
        expect(find.text(strings.advisoryLastResortBadge), findsOneWidget);

        // Chemical dosage collapsed initially
        expect(find.text(strings.advisoryDosageLabel), findsNothing);

        // Expand chemical section
        await tester.tap(find.text(strings.advisoryStep3Title));
        await tester.pumpAndSettle();

        expect(find.text(strings.advisoryDosageLabel), findsOneWidget);
        expect(find.text(strings.advisoryPhiLabel), findsOneWidget);
        expect(find.text(strings.advisoryPhiDaysText(30)), findsOneWidget);
        expect(find.text(strings.advisoryReentryLabel), findsOneWidget);
        expect(find.text(strings.advisoryReentryHoursText(24)), findsOneWidget);
        expect(find.text(strings.advisoryExpertTriggerHeader), findsOneWidget);
        expect(find.textContaining(strings.advisorySourcePrefix), findsOneWidget);
        expect(find.textContaining(strings.advisoryReviewedPrefix), findsOneWidget);
      });
    }

    // =========================================================================
    // 6. FOLLOW-UP CARD LOCALIZATION TESTS
    // =========================================================================
    for (final lang in AppLanguage.values) {
      testWidgets('FollowUpCard renders 100% localized in ${lang.name}', (WidgetTester tester) async {
        final strings = AppStrings(lang);

        await tester.pumpWidget(
          _createLocalizedHarness(
            language: lang,
            child: const FollowUpCard(
              question: 'How is the crop?',
              target: 'blast',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(strings.followupCheckinHeader), findsOneWidget);
        expect(find.text(strings.getLocalizedTargetName('blast')), findsOneWidget);
        expect(find.text(strings.followupOptionImproved), findsOneWidget);
        expect(find.text(strings.followupOptionNoChange), findsOneWidget);
        expect(find.text(strings.followupOptionGotWorse), findsOneWidget);
      });
    }
  });
}
