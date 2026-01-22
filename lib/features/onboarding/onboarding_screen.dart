import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/onboarding/models/onboarding_state.dart';
import '../../core/onboarding/onboarding_providers.dart';
import 'widgets/api_key_input_page.dart';
import 'widgets/onboarding_page_indicator.dart';
import 'widgets/tutorial_page.dart';
import 'widgets/welcome_page.dart';

/// Main onboarding screen that manages the onboarding flow.
///
/// This screen displays different pages based on the current [OnboardingStep]
/// and provides navigation between steps using the [OnboardingStateNotifier].
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates an [OnboardingScreen].
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the onboarding state on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingStateProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingStateProvider);

    // If onboarding is complete, this screen shouldn't be shown
    // The parent widget should handle navigation
    if (onboardingState.isComplete) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator at the top
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: OnboardingPageIndicator(
                currentStep: onboardingState.currentStep,
              ),
            ),
            // Main content area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentPage(onboardingState.currentStep),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the appropriate page widget based on the current step.
  Widget _buildCurrentPage(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => WelcomePage(
          key: const ValueKey('welcome'),
          onGetStarted: _handleNextStep,
        ),
      OnboardingStep.tutorial => TutorialPage(
          key: const ValueKey('tutorial'),
          onNext: _handleNextStep,
          onBack: _handlePreviousStep,
        ),
      OnboardingStep.apiKeyInput => ApiKeyInputPage(
          key: const ValueKey('apiKeyInput'),
          onComplete: _handleNextStep,
          onBack: _handlePreviousStep,
        ),
      OnboardingStep.complete => const SizedBox.shrink(
          key: ValueKey('complete'),
        ),
    };
  }

  /// Advances to the next step in the onboarding flow.
  Future<void> _handleNextStep() async {
    await ref.read(onboardingStateProvider.notifier).nextStep();
  }

  /// Goes back to the previous step in the onboarding flow.
  void _handlePreviousStep() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }
}
