/// Widget tests for OnboardingScreen (Task 5.4)
///
/// Tests cover:
/// - Screen rendering based on current step
/// - Page indicator display
/// - Navigation flow between steps
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylesync/core/onboarding/models/onboarding_state.dart';
import 'package:stylesync/core/onboarding/onboarding_controller.dart';
import 'package:stylesync/core/onboarding/onboarding_providers.dart';
import 'package:stylesync/features/onboarding/onboarding_screen.dart';
import 'package:stylesync/features/onboarding/widgets/api_key_input_page.dart';
import 'package:stylesync/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:stylesync/features/onboarding/widgets/tutorial_page.dart';
import 'package:stylesync/features/onboarding/widgets/welcome_page.dart';

// =============================================================================
// Test Helpers
// =============================================================================

/// Creates a testable widget wrapped with necessary providers.
Widget createTestWidget({
  OnboardingState? initialState,
}) {
  return ProviderScope(
    overrides: [
      if (initialState != null)
        onboardingStateProvider.overrideWith((ref) {
          return TestOnboardingStateNotifier(initialState);
        }),
    ],
    child: const MaterialApp(
      home: OnboardingScreen(),
    ),
  );
}

/// Test notifier that allows setting initial state.
class TestOnboardingStateNotifier extends OnboardingStateNotifier {
  TestOnboardingStateNotifier(OnboardingState initialState)
      : super(TestOnboardingController()) {
    state = initialState;
  }
}

/// Mock controller for testing.
class TestOnboardingController implements OnboardingController {
  bool _isComplete = false;

  @override
  Future<bool> isOnboardingComplete() async => _isComplete;

  @override
  Future<void> markOnboardingComplete() async {
    _isComplete = true;
  }

  @override
  Future<void> resetOnboarding() async {
    _isComplete = false;
  }
}

// =============================================================================
// Widget Tests
// =============================================================================

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingScreen', () {
    // =========================================================================
    // Screen Rendering Tests
    // =========================================================================

    group('Screen rendering based on current step', () {
      testWidgets('renders WelcomePage when step is welcome',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.welcome,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(WelcomePage), findsOneWidget,
            reason: 'WelcomePage should be displayed when step is welcome');
        expect(find.byType(TutorialPage), findsNothing,
            reason: 'TutorialPage should not be displayed');
        expect(find.byType(ApiKeyInputPage), findsNothing,
            reason: 'ApiKeyInputPage should not be displayed');
      });

      testWidgets('renders TutorialPage when step is tutorial',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.tutorial,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(TutorialPage), findsOneWidget,
            reason: 'TutorialPage should be displayed when step is tutorial');
        expect(find.byType(WelcomePage), findsNothing,
            reason: 'WelcomePage should not be displayed');
        expect(find.byType(ApiKeyInputPage), findsNothing,
            reason: 'ApiKeyInputPage should not be displayed');
      });

      testWidgets('renders ApiKeyInputPage when step is apiKeyInput',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.apiKeyInput,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(ApiKeyInputPage), findsOneWidget,
            reason:
                'ApiKeyInputPage should be displayed when step is apiKeyInput');
        expect(find.byType(WelcomePage), findsNothing,
            reason: 'WelcomePage should not be displayed');
        expect(find.byType(TutorialPage), findsNothing,
            reason: 'TutorialPage should not be displayed');
      });

      testWidgets('shows loading indicator when onboarding is complete',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState.completed(),
        ));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget,
            reason:
                'Should show loading indicator when onboarding is complete');
      });
    });

    // =========================================================================
    // Page Indicator Tests
    // =========================================================================

    group('Page indicator', () {
      testWidgets('shows page indicator with correct number of dots',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.welcome,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingPageIndicator), findsOneWidget,
            reason: 'Page indicator should be displayed');

        // The indicator should have 3 dots (welcome, tutorial, apiKeyInput)
        final dotsCount = find
            .descendant(
              of: find.byType(OnboardingPageIndicator),
              matching: find.byType(AnimatedContainer),
            )
            .evaluate()
            .length;
        expect(dotsCount, equals(3),
            reason: 'Page indicator should have 3 dots for onboarding steps');

        final indicator = tester.widget<OnboardingPageIndicator>(
          find.byType(OnboardingPageIndicator),
        );
        expect(indicator.currentStep, equals(OnboardingStep.welcome),
            reason: 'Page indicator should show welcome as current step');
      });

      testWidgets('page indicator highlights current step - welcome',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.welcome,
          ),
        ));
        await tester.pumpAndSettle();

        final indicator = tester.widget<OnboardingPageIndicator>(
          find.byType(OnboardingPageIndicator),
        );
        expect(indicator.currentStep, equals(OnboardingStep.welcome),
            reason: 'Current step should be welcome');
      });

      testWidgets('page indicator highlights current step - tutorial',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.tutorial,
          ),
        ));
        await tester.pumpAndSettle();

        final indicator = tester.widget<OnboardingPageIndicator>(
          find.byType(OnboardingPageIndicator),
        );
        expect(indicator.currentStep, equals(OnboardingStep.tutorial),
            reason: 'Current step should be tutorial');
      });

      testWidgets('page indicator highlights current step - apiKeyInput',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.apiKeyInput,
          ),
        ));
        await tester.pumpAndSettle();

        final indicator = tester.widget<OnboardingPageIndicator>(
          find.byType(OnboardingPageIndicator),
        );
        expect(indicator.currentStep, equals(OnboardingStep.apiKeyInput),
            reason: 'Current step should be apiKeyInput');
      });
    });

    // =========================================================================
    // Layout Tests
    // =========================================================================

    group('Layout', () {
      testWidgets('has SafeArea for proper padding',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.welcome,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(SafeArea), findsOneWidget,
            reason: 'OnboardingScreen should use SafeArea');
      });

      testWidgets('uses Scaffold as root widget', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.welcome,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget,
            reason: 'OnboardingScreen should use Scaffold');
      });

      testWidgets('uses AnimatedSwitcher for page transitions',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.welcome,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedSwitcher), findsOneWidget,
            reason: 'OnboardingScreen should use AnimatedSwitcher for transitions');
      });
    });

    // =========================================================================
    // Navigation Flow Tests
    // =========================================================================

    group('Navigation flow', () {
      testWidgets('navigates from welcome to tutorial when Get Started is tapped',
          (WidgetTester tester) async {
        // Set up mock SharedPreferences for the controller
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify we start on welcome page
        expect(find.byType(WelcomePage), findsOneWidget,
            reason: 'Should start on WelcomePage');

        // Ensure the Get Started button is visible
        await tester.ensureVisible(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Tap Get Started button
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Verify we're now on tutorial page
        expect(find.byType(TutorialPage), findsOneWidget,
            reason: 'Should navigate to TutorialPage after tapping Get Started');
      });

      testWidgets('navigates from tutorial to apiKeyInput when Next is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.tutorial,
          ),
        ));
        await tester.pumpAndSettle();

        // Verify we're on tutorial page
        expect(find.byType(TutorialPage), findsOneWidget,
            reason: 'Should be on TutorialPage');

        // Tap Next button
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        // Verify we're now on apiKeyInput page
        expect(find.byType(ApiKeyInputPage), findsOneWidget,
            reason: 'Should navigate to ApiKeyInputPage after tapping Next');
      });

      testWidgets('navigates from tutorial back to welcome when Back is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.tutorial,
          ),
        ));
        await tester.pumpAndSettle();

        // Verify we're on tutorial page
        expect(find.byType(TutorialPage), findsOneWidget,
            reason: 'Should be on TutorialPage');

        // Tap Back button
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        // Verify we're now on welcome page
        expect(find.byType(WelcomePage), findsOneWidget,
            reason: 'Should navigate back to WelcomePage after tapping Back');
      });

      testWidgets('navigates from apiKeyInput back to tutorial when Back is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.apiKeyInput,
          ),
        ));
        await tester.pumpAndSettle();

        // Verify we're on apiKeyInput page
        expect(find.byType(ApiKeyInputPage), findsOneWidget,
            reason: 'Should be on ApiKeyInputPage');

        // Tap Back button
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        // Verify we're now on tutorial page
        expect(find.byType(TutorialPage), findsOneWidget,
            reason: 'Should navigate back to TutorialPage after tapping Back');
      });
    });

    // =========================================================================
    // Key-based Widget Tests
    // =========================================================================

    group('Widget keys', () {
      testWidgets('WelcomePage has correct ValueKey',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.welcome,
          ),
        ));
        await tester.pumpAndSettle();

        final welcomePage = tester.widget<WelcomePage>(find.byType(WelcomePage));
        expect(welcomePage.key, equals(const ValueKey('welcome')),
            reason: 'WelcomePage should have ValueKey("welcome")');
      });

      testWidgets('TutorialPage has correct ValueKey',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.tutorial,
          ),
        ));
        await tester.pumpAndSettle();

        final tutorialPage =
            tester.widget<TutorialPage>(find.byType(TutorialPage));
        expect(tutorialPage.key, equals(const ValueKey('tutorial')),
            reason: 'TutorialPage should have ValueKey("tutorial")');
      });

      testWidgets('ApiKeyInputPage has correct ValueKey',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          initialState: const OnboardingState(
            currentStep: OnboardingStep.apiKeyInput,
          ),
        ));
        await tester.pumpAndSettle();

        final apiKeyPage =
            tester.widget<ApiKeyInputPage>(find.byType(ApiKeyInputPage));
        expect(apiKeyPage.key, equals(const ValueKey('apiKeyInput')),
            reason: 'ApiKeyInputPage should have ValueKey("apiKeyInput")');
      });
    });
  });
}
