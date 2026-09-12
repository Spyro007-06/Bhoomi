import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhoomi/core/theme/app_theme.dart';
import 'package:bhoomi/core/localization/locale_provider.dart';
import 'package:bhoomi/core/localization/app_strings.dart';
import 'package:bhoomi/widgets/farm_health_card.dart';
import 'package:bhoomi/widgets/risk_card.dart';
import 'package:bhoomi/widgets/stub_banner.dart';
import 'package:bhoomi/widgets/voice_action_button.dart';
import 'package:bhoomi/widgets/advisory_ipm_card.dart';
import 'package:bhoomi/widgets/pesticide_veto_card.dart';
import 'package:bhoomi/widgets/app_text_field.dart';
import 'package:bhoomi/features/showcase/design_showcase_screen.dart';

void main() {
  group('Design Showcase Screen & Reusable Components Tests', () {
    testWidgets('Renders all 11 required design elements without error',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final notifier = LocaleNotifier(null);
      notifier.state = AppLanguage.english;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DesignShowcaseScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Check Stub Banner
      expect(find.byType(StubBanner), findsOneWidget);
      expect(find.text('DEMONSTRATION MODE'), findsOneWidget);

      // 2. Check Action Buttons
      expect(find.text('1. Primary Button (मुख्य बटण)'), findsOneWidget);
      expect(find.text('2. Secondary Button (दुय्यम बटण)'), findsOneWidget);
      expect(find.text('3. Danger Button (धोका / थांबवा)'), findsOneWidget);

      // 3. Check Input Field
      expect(find.byType(AppTextField), findsOneWidget);
      expect(find.text('Observed Crop Symptoms (पिकावरील लक्षणे)'), findsOneWidget);

      // 4. Check Voice Action Button
      await tester.scrollUntilVisible(find.byType(VoiceActionButton), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(VoiceActionButton), findsOneWidget);

      // 5. Check Farm Health Card
      await tester.scrollUntilVisible(find.byType(FarmHealthCard), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(FarmHealthCard), findsOneWidget);
      expect(find.text('FIELD HEALTH STATUS'), findsOneWidget);
      expect(find.text('One open problem, being monitored.'), findsOneWidget);

      // 6. Check Risk Alert Card
      await tester.scrollUntilVisible(find.byType(RiskCard), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RiskCard), findsOneWidget);
      expect(find.text('HIGH RISK'), findsOneWidget);
      expect(find.text('What to Inspect in Field:'), findsOneWidget);
      expect(find.text("I'll Inspect Field"), findsOneWidget);

      // 7. Check Confidence Gate Card (starts on Advise)
      await tester.scrollUntilVisible(find.text('Sufficient confidence for treatment guidance'), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sufficient confidence for treatment guidance'), findsOneWidget);
      expect(find.textContaining('Paddy Blast'), findsWidgets);

      // 8. Check Advisory IPM Card
      await tester.scrollUntilVisible(find.byType(AdvisoryIpmCard), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AdvisoryIpmCard), findsOneWidget);
      expect(find.text('What to Avoid First (Crucial):'), findsOneWidget);
      expect(find.text('Cultural Management'), findsOneWidget);
      expect(find.text('Biological Management'), findsOneWidget);
      expect(find.text('Chemical Management'), findsOneWidget);

      // 9. Check Pesticide Veto Card
      await tester.scrollUntilVisible(find.byType(PesticideVetoCard), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(PesticideVetoCard), findsOneWidget);
      expect(find.text('DO NOT SPRAY — VETO VERDICT'), findsOneWidget);
      expect(find.text('This is a fungicide. Your problem is an insect pest.'), findsOneWidget);
    });

    testWidgets('Voice button cycles through states correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final notifier = LocaleNotifier(null);
      notifier.state = AppLanguage.english;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DesignShowcaseScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.scrollUntilVisible(find.byType(VoiceActionButton), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('बोलण्यासाठी टॅप करा'), findsOneWidget);

      // Tap to start listening
      await tester.tap(find.byType(VoiceActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ऐकत आहे... थांबवण्यासाठी टॅप करा'), findsOneWidget);

      // Tap to stop listening -> transcribing
      await tester.tap(find.byType(VoiceActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('प्रक्रिया करत आहे...'), findsOneWidget);

      // Tap -> playback
      await tester.tap(find.byType(VoiceActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('आवाज सुरू आहे'), findsOneWidget);
    });

    testWidgets('Confidence gate tab switcher toggles between Advise, Clarify, and Escalate',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final notifier = LocaleNotifier(null);
      notifier.state = AppLanguage.english;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DesignShowcaseScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll down to Confidence Gate header
      await tester.scrollUntilVisible(find.text('7. Confidence Gate UI (3 Bands)'), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));

      // Initial state is Advise
      expect(find.text('Sufficient confidence for treatment guidance'), findsOneWidget);

      // Switch to Clarify (Doubt Doctor)
      await tester.tap(find.text('Clarify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Doubt Doctor · Clarification Needed'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text("Can't Tell"), findsOneWidget);

      // Switch to Escalate
      await tester.tap(find.text('Escalate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Direct Agronomist Referral'), findsOneWidget);
      expect(find.text('Call Kisan Helpline'), findsOneWidget);
    });

    testWidgets('Chemical action in Advisory IPM card expands and collapses',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final notifier = LocaleNotifier(null);
      notifier.state = AppLanguage.english;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DesignShowcaseScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll to Advisory IPM Card
      await tester.scrollUntilVisible(find.byType(AdvisoryIpmCard), 300, scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 300));

      // Chemical details (dosage) should be collapsed initially
      expect(find.text('Dosage:'), findsNothing);

      // Tap chemical section to expand
      await tester.tap(find.text('Chemical Management'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Dosage:'), findsOneWidget);
      expect(find.text('0.6 g per litre of water'), findsOneWidget);
    });
  });
}
