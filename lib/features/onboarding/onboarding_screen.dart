import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/onboarding/models/onboarding_error.dart';
import '../../core/onboarding/models/onboarding_persistence_exception.dart';
import '../../core/onboarding/models/onboarding_state.dart';
import '../../core/onboarding/onboarding_providers.dart';
import 'widgets/api_key_input_page.dart';
import 'widgets/onboarding_page_indicator.dart';
import 'widgets/tutorial_page.dart';
import 'widgets/welcome_page.dart';

/// Default generic error message when no user-friendly message is available.
const String _genericErrorMessage = 'Something went wrong. Please try again.';

/// Maximum allowed length for user-facing error messages.
const int _maxMessageLength = 200;

/// Patterns that indicate a message contains technical details.
final RegExp _technicalPatterns = RegExp(
  r'(Exception|Error|Stack|Trace|null|undefined|\{|\}|\[|\]|0x[0-9a-fA-F]+|\bat\b.*:\d+)',
  caseSensitive: false,
);

/// Checks if the given message is safe and user-friendly for display.
///
/// Returns `true` if the message is non-empty, within length limits,
/// and doesn't contain technical patterns.
bool _isUserFriendlyMessage(String? message) {
  if (message == null || message.trim().isEmpty) {
    return false;
  }
  if (message.length > _maxMessageLength) {
    return false;
  }
  if (_technicalPatterns.hasMatch(message)) {
    return false;
  }
  return true;
}

/// Formats an [OnboardingError] into a user-friendly message.
///
/// Maps known error types to readable strings and falls back to the
/// error's message or a generic message for unknown errors.
/// The raw error is logged internally for debugging purposes.
///
/// This ensures technical details like stack traces or exception types
/// are never exposed to users.
String formatOnboardingError(OnboardingError? error) {
  if (error == null) {
    return 'An unexpected error occurred. Please try again.';
  }

  // Log the raw error for debugging (internal use only)
  debugPrint('Onboarding error: $error (original: ${error.originalError})');

  final originalError = error.originalError;

  // Map known original error types to user-friendly messages
  if (originalError is OnboardingPersistenceException) {
    // Storage-related errors
    return 'Unable to save your progress. Please check your device storage and try again.';
  }

  if (originalError is FormatException) {
    return 'Invalid data format. Please try again.';
  }

  if (originalError is StateError) {
    return 'The app encountered an issue. Please restart and try again.';
  }

  // Handle network-related errors by type name (to avoid direct dependency)
  if (originalError != null) {
    final errorTypeName = originalError.runtimeType.toString();
    if (errorTypeName.contains('SocketException') ||
        errorTypeName.contains('TimeoutException') ||
        errorTypeName.contains('HttpException')) {
      return 'Network error. Please check your connection and try again.';
    }
  }

  // Use the OnboardingError's message as fallback if it's user-friendly
  if (_isUserFriendlyMessage(error.message)) {
    return error.message;
  }

  return _genericErrorMessage;
}

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

    // Show error UI if there's an error
    if (onboardingState.hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to complete onboarding',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  formatOnboardingError(onboardingState.error),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(onboardingStateProvider.notifier).clearError();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
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
