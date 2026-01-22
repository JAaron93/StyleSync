/// Widget tests for WelcomePage (Task 5.4)
///
/// Tests cover:
/// - Welcome title and description rendering
/// - Feature cards display
/// - Get Started button functionality
library;

import 'package:flutter/material.dart';
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

        // Scroll to make the button visible
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        // Tap the Get Started button
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

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

        // Find the Column that contains the main content
        final columnFinder = find.byType(Column);
        expect(columnFinder, findsWidgets,
            reason: 'Should have Column for layout');
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
      testWidgets('all text is readable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        // Verify key text elements are present and readable
        expect(find.text('Welcome to StyleSync'), findsOneWidget);
        expect(find.text('Your AI-powered personal stylist'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);
      });

      testWidgets('button is tappable', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onGetStarted: () {},
        ));
        await tester.pumpAndSettle();

        // Verify button can be found and tapped
        final buttonFinder = find.text('Get Started');
        expect(buttonFinder, findsOneWidget);
        
        // Scroll to make the button visible before tapping
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        
        // Ensure button is in the widget tree and tappable
        await tester.tap(buttonFinder);
        await tester.pump();
      });
    });
  });
}
