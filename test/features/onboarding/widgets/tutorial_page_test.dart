/// Widget tests for TutorialPage (Task 5.4)
///
/// Tests cover:
/// - Tutorial title rendering
/// - Step-by-step instructions display
/// - Links to Google Cloud Console
/// - Free vs Paid tier explanation
/// - Back and Next button functionality
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/features/onboarding/widgets/tutorial_page.dart';

// =============================================================================
// Test Helpers
// =============================================================================

/// Creates a testable TutorialPage widget.
Widget createTestWidget({
  required VoidCallback onNext,
  required VoidCallback onBack,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TutorialPage(
        onNext: onNext,
        onBack: onBack,
      ),
    ),
  );
}

// =============================================================================
// Widget Tests
// =============================================================================

void main() {
  group('TutorialPage', () {
    // =========================================================================
    // Title and Description Tests
    // =========================================================================

    group('Title and description', () {
      testWidgets('renders tutorial title "How to Get Your Gemini API Key"',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('How to Get Your Gemini API Key'), findsOneWidget,
            reason: 'Tutorial title should be displayed');
      });

      testWidgets('renders description about Vertex AI',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(
            find.textContaining('Gemini AI through Vertex AI'),
            findsOneWidget,
            reason: 'Description about Vertex AI should be displayed');
      });

      testWidgets('renders important notice about Google Cloud',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Important'), findsOneWidget,
            reason: 'Important notice title should be displayed');
        expect(
            find.textContaining('Google Cloud project'),
            findsOneWidget,
            reason: 'Notice about Google Cloud project should be displayed');
      });
    });

    // =========================================================================
    // Step-by-Step Instructions Tests
    // =========================================================================

    group('Step-by-step instructions', () {
      testWidgets('displays Step 1: Create a Google Cloud Project',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Create a Google Cloud Project'), findsOneWidget,
            reason: 'Step 1 title should be displayed');
        expect(find.text('Open Google Cloud Console'), findsOneWidget,
            reason: 'Step 1 link should be displayed');
      });

      testWidgets('displays Step 2: Enable Vertex AI API',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Enable Vertex AI API'), findsWidgets,
            reason: 'Step 2 title and link should be displayed');
        expect(
            find.textContaining('enable the Vertex AI API'),
            findsOneWidget,
            reason: 'Step 2 description should be displayed');
      });

      testWidgets('displays Step 3: Create an API Key',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Create an API Key'), findsOneWidget,
            reason: 'Step 3 title should be displayed');
        expect(find.text('Create API Key'), findsOneWidget,
            reason: 'Step 3 link should be displayed');
      });

      testWidgets('displays step numbers 1, 2, 3',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('step-number-1')), findsOneWidget,
            reason: 'Step number 1 should be displayed');
        expect(find.byKey(const ValueKey('step-number-2')), findsOneWidget,
            reason: 'Step number 2 should be displayed');
        expect(find.byKey(const ValueKey('step-number-3')), findsOneWidget,
            reason: 'Step number 3 should be displayed');
      });
    });

    // =========================================================================
    // Links Tests
    // =========================================================================

    group('Links to Google Cloud Console', () {
      testWidgets('shows link to Open Google Cloud Console',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Open Google Cloud Console'), findsOneWidget,
            reason: 'Link to Google Cloud Console should be displayed');
      });

      testWidgets('shows link to Enable Vertex AI API',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // "Enable Vertex AI API" appears twice - once as title and once as link
        expect(find.text('Enable Vertex AI API'), findsNWidgets(2),
            reason: 'Enable Vertex AI API should appear as title and link');
      });

      testWidgets('shows link to Create API Key',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Create API Key'), findsOneWidget,
            reason: 'Link to Create API Key should be displayed');
      });

      testWidgets('links have open_in_new icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // There should be 3 open_in_new icons for the 3 links
        expect(find.byIcon(Icons.open_in_new_rounded), findsNWidgets(3),
            reason: 'Each link should have an open_in_new icon');
      });
    });

    // =========================================================================
    // Pricing & Quotas Tests
    // =========================================================================

    group('Free vs Paid tier differences', () {
      testWidgets('displays Pricing & Quotas section',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Pricing & Quotas'), findsOneWidget,
            reason: 'Pricing & Quotas section should be displayed');
      });

      testWidgets('displays Free Tier information',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Free Tier'), findsOneWidget,
            reason: 'Free Tier should be displayed');
        expect(
            find.textContaining('Limited requests per minute'),
            findsOneWidget,
            reason: 'Free Tier description should be displayed');
      });

      testWidgets('displays Paid / Billing Enabled information',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Paid / Billing Enabled'), findsOneWidget,
            reason: 'Paid tier should be displayed');
        expect(
            find.textContaining('Higher quotas'),
            findsOneWidget,
            reason: 'Paid tier description should be displayed');
      });

      testWidgets('displays upgrade note',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(
            find.textContaining('start with the free tier'),
            findsOneWidget,
            reason: 'Upgrade note should be displayed');
      });

      testWidgets('displays wallet icon for pricing section',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget,
            reason: 'Wallet icon should be displayed for pricing section');
      });
    });

    // =========================================================================
    // Navigation Button Tests
    // =========================================================================

    group('Navigation buttons', () {
      testWidgets('Back button is visible', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Back'), findsOneWidget,
            reason: 'Back button should be visible');
      });

      testWidgets('Next button is visible', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Next'), findsOneWidget,
            reason: 'Next button should be visible');
      });

      testWidgets('tapping Back button calls onBack callback',
          (WidgetTester tester) async {
        bool backCalled = false;

        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {
            backCalled = true;
          },
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        expect(backCalled, isTrue,
            reason: 'onBack callback should be called when Back is tapped');
      });

      testWidgets('tapping Next button calls onNext callback',
          (WidgetTester tester) async {
        bool nextCalled = false;

        await tester.pumpWidget(createTestWidget(
          onNext: () {
            nextCalled = true;
          },
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(nextCalled, isTrue,
            reason: 'onNext callback should be called when Next is tapped');
      });

      testWidgets('Back button is OutlinedButton',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byType(OutlinedButton), findsOneWidget,
            reason: 'Back button should be an OutlinedButton');
      });

      testWidgets('Next button is FilledButton',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // FilledButton.icon creates an internal widget type that implements
        // FilledButton semantics. Verify the button exists via semantics.
        expect(
          tester.getSemantics(find.text('Next')),
          matchesSemantics(
            isButton: true,
            hasTapAction: true,
            hasFocusAction: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
          ),
          reason: 'Next button should have button semantics',
        );
      });

      testWidgets('Back button has back arrow icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget,
            reason: 'Back button should have back arrow icon');
      });

      testWidgets('Next button has forward arrow icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget,
            reason: 'Next button should have forward arrow icon');
      });
    });

    // =========================================================================
    // Layout Tests
    // =========================================================================

    group('Layout', () {
      testWidgets('uses SingleChildScrollView for scrollability',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget,
            reason: 'TutorialPage content should be scrollable');
      });

      testWidgets('navigation buttons are present',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // Both Back and Next buttons should be present
        expect(find.text('Back'), findsOneWidget,
            reason: 'Back button should be present');
        expect(find.text('Next'), findsOneWidget,
            reason: 'Next button should be present');
      });

      testWidgets('info icon is displayed for important notice',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onNext: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget,
            reason: 'Info icon should be displayed for important notice');
      });
    });
  });
}
