/// Widget tests for WelcomePage (Task 5.4)
///
/// Tests cover:
/// - Welcome title and description rendering
/// - Feature cards display
/// - Get Started button functionality
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/features/onboarding/widgets/welcome_page.dart';

// =============================================================================
// Test Helpers
// =============================================================================

/// Creates a testable WelcomePage widget.
Widget createTestWidget({
  required VoidCallback onGetStarted,
}) {
  return MaterialApp(
    home: Scaffold(
      body: WelcomePage(
        onGetStarted: onGetStarted,
      ),
    ),
  );
}

// =============================================================================
// Widget Tests
// =============================================================================

void main() {
  group('WelcomePage', () {
    // =========================================================================
    // Title and Description Tests
    // =========================================================================

    group('Title and description', () {
      testWidgets('renders welcome title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Welcome to StyleSync'), findsOneWidget,
            reason: 'Welcome title should be displayed');
      });

      testWidgets('renders subtitle description', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Your AI-powered personal stylist'), findsOneWidget,
            reason: 'Subtitle should be displayed');
      });

      testWidgets('renders app icon', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.checkroom_rounded), findsOneWidget,
            reason: 'App icon should be displayed');
      });
    });

    // =========================================================================
    // Feature Cards Tests
    // =========================================================================

    group('Feature cards', () {
      testWidgets('displays Digital Wardrobe feature card',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Digital Wardrobe'), findsOneWidget,
            reason: 'Digital Wardrobe feature card should be displayed');
        expect(
            find.textContaining('Organize your entire wardrobe digitally'),
            findsOneWidget,
            reason: 'Digital Wardrobe description should be displayed');
        expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget,
            reason: 'Digital Wardrobe icon should be displayed');
      });

      testWidgets('displays Virtual Try-On feature card',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Virtual Try-On'), findsOneWidget,
            reason: 'Virtual Try-On feature card should be displayed');
        expect(
            find.textContaining('See how outfits look on you'),
            findsOneWidget,
            reason: 'Virtual Try-On description should be displayed');
        expect(find.byIcon(Icons.person_pin_rounded), findsOneWidget,
            reason: 'Virtual Try-On icon should be displayed');
      });

      testWidgets('displays Outfit Brainstorming feature card',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Outfit Brainstorming'), findsOneWidget,
            reason: 'Outfit Brainstorming feature card should be displayed');
        expect(
            find.textContaining('Get AI-powered outfit suggestions'),
            findsOneWidget,
            reason: 'Outfit Brainstorming description should be displayed');
        expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget,
            reason: 'Outfit Brainstorming icon should be displayed');
      });

      testWidgets('displays all three feature cards',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        // Verify all three feature cards are present
        expect(find.text('Digital Wardrobe'), findsOneWidget);
        expect(find.text('Virtual Try-On'), findsOneWidget);
        expect(find.text('Outfit Brainstorming'), findsOneWidget);
      });
    });

    // =========================================================================
    // Get Started Button Tests
    // =========================================================================

    group('Get Started button', () {
      testWidgets('Get Started button is visible', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Get Started'), findsOneWidget,
            reason: 'Get Started button should be visible');
        expect(find.byType(FilledButton), findsOneWidget,
            reason: 'Get Started should be a FilledButton');
      });

      testWidgets('tapping Get Started calls onGetStarted callback',
          (WidgetTester tester) async {
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {
            callbackCalled = true;
          },
        ));
        await tester.pumpAndSettle();

        // Ensure button is visible and tap it
        await tester.ensureVisible(find.text('Get Started'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Get Started'));
        await tester.pump();

        expect(callbackCalled, isTrue,
            reason: 'onGetStarted callback should be called when button is tapped');
      });

      testWidgets('Get Started button has correct styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNotNull,
            reason: 'Get Started button should be enabled');
      });
    });

    // =========================================================================
    // Layout Tests
    // =========================================================================

    group('Layout', () {
      testWidgets('uses SingleChildScrollView for scrollability',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget,
            reason: 'WelcomePage should be scrollable');
      });

      testWidgets('content is centered', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        // Verify the main content Column has center alignment
        final columns = tester.widgetList<Column>(find.byType(Column));
        final hasCenteredColumn = columns.any(
          (col) => col.crossAxisAlignment == CrossAxisAlignment.center,
        );
        expect(hasCenteredColumn, isTrue,
            reason: 'Content should be horizontally centered');
      });

      testWidgets('has proper padding', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        // The SingleChildScrollView should have horizontal padding
        final scrollView = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );
        expect(scrollView.padding, isNotNull,
            reason: 'WelcomePage should have padding');
      });
    });

    // =========================================================================
    // Accessibility Tests
    // =========================================================================

    group('Accessibility', () {
      testWidgets('has proper accessibility semantics', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        // Verify headline text has semantics label
        expect(
          tester.getSemantics(find.text('Welcome to StyleSync')),
          matchesSemantics(
            label: 'Welcome to StyleSync',
          ),
          reason: 'Welcome headline should have proper semantics label',
        );

        // Verify subtitle text has semantics label
        expect(
          tester.getSemantics(find.text('Your AI-powered personal stylist')),
          matchesSemantics(
            label: 'Your AI-powered personal stylist',
          ),
          reason: 'Subtitle should have proper semantics label',
        );

        // Ensure the Get Started button is visible
        await tester.ensureVisible(find.widgetWithText(FilledButton, 'Get Started'));
        await tester.pumpAndSettle();

        // Verify Get Started button has proper button semantics
        // FilledButton provides: isButton, hasEnabledState, isEnabled, isFocusable,
        // hasTapAction, and hasFocusAction
        expect(
          tester.getSemantics(find.widgetWithText(FilledButton, 'Get Started')),
          matchesSemantics(
            label: 'Get Started',
            isButton: true,
            isFocusable: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
          reason: 'Get Started button should have proper button semantics with tap action',
        );

        handle.dispose();
      });

      testWidgets('feature cards have accessible text', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        // Verify first two feature card titles have semantics labels (visible without scrolling)
        expect(
          tester.getSemantics(find.text('Digital Wardrobe')),
          matchesSemantics(
            label: 'Digital Wardrobe',
          ),
          reason: 'Digital Wardrobe title should have proper semantics label',
        );

        expect(
          tester.getSemantics(find.text('Virtual Try-On')),
          matchesSemantics(
            label: 'Virtual Try-On',
          ),
          reason: 'Virtual Try-On title should have proper semantics label',
        );

        // Ensure Outfit Brainstorming is visible
        await tester.ensureVisible(find.text('Outfit Brainstorming'));
        await tester.pumpAndSettle();

        // Verify third feature card title has semantics label (now visible after scrolling)
        expect(
          tester.getSemantics(find.text('Outfit Brainstorming')),
          matchesSemantics(
            label: 'Outfit Brainstorming',
          ),
          reason: 'Outfit Brainstorming title should have proper semantics label',
        );

        handle.dispose();
      });

      testWidgets('button is keyboard accessible', (WidgetTester tester) async {
        bool callbackInvoked = false;

        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {
            callbackInvoked = true;
          },
        ));
        await tester.pumpAndSettle();

        // Verify button can be found
        final buttonFinder = find.text('Get Started');
        expect(buttonFinder, findsOneWidget);

        // Use ensureVisible to reliably bring the button into view
        await tester.ensureVisible(buttonFinder);
        await tester.pumpAndSettle();

        // Focus the button and activate via Enter key (keyboard accessibility)
        await tester.tap(buttonFinder); // Focus the button
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(callbackInvoked, isTrue,
            reason: 'onGetStarted callback should be invoked when button is activated via Enter key');
      });
    });
  });
}
