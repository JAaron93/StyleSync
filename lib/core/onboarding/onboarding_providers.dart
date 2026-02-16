import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/onboarding_state.dart';
import 'onboarding_controller.dart';
import 'onboarding_controller_impl.dart';

/// Provider for the [OnboardingController] instance.
///
/// This provider creates and manages a singleton instance of
/// [OnboardingControllerImpl] that can be used throughout the app
/// to check and update onboarding state.
///
/// Example usage:
/// ```dart
/// final controller = ref.read(onboardingControllerProvider);
/// await controller.markOnboardingComplete();
/// ```
final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingControllerImpl();
});

/// Provider that checks if onboarding has been completed.
///
/// This is a [FutureProvider] that asynchronously checks the onboarding
/// completion status. It's useful for determining the initial route
/// during app startup.
///
/// **Important:** This provider is intended for **initial app routing only**.
/// It is cached after the first read and is **not reactive** to runtime
/// onboarding state changes (e.g., when [OnboardingStateNotifier.nextStep]
/// completes the onboarding flow).
///
/// For reactive updates during the onboarding flow, use [onboardingStateProvider]
/// instead, which provides real-time state changes via [OnboardingStateNotifier].
///
/// Example usage:
/// ```dart
/// final isComplete = ref.watch(isOnboardingCompleteProvider);
/// return isComplete.when(
///   data: (complete) => complete ? MainScreen() : OnboardingScreen(),
///   loading: () => SplashScreen(),
///   error: (e, s) => ErrorScreen(error: e),
/// );
/// ```
///
/// See also:
/// - [onboardingStateProvider] for reactive onboarding state during the flow
/// - [OnboardingStateNotifier] for managing onboarding state transitions
final isOnboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final controller = ref.read(onboardingControllerProvider);
  return controller.isOnboardingComplete();
});

/// Notifier that manages the current onboarding state.
///
/// This [StateNotifier] provides reactive state management for the
/// onboarding flow, allowing UI components to respond to state changes
/// and update the current step.
class OnboardingStateNotifier extends StateNotifier<OnboardingState> {
  /// Creates an [OnboardingStateNotifier] with the given controller.
  OnboardingStateNotifier(this._controller)
      : super(const OnboardingState.initial());

  final OnboardingController _controller;

  /// Initializes the state by checking if onboarding is already complete.
  ///
  /// This should be called when the onboarding flow is first displayed
  /// to ensure the state reflects the persisted completion status.
  ///
  /// If the storage check fails, the state is set to an error state
  /// allowing the UI to react accordingly.
  Future<void> initialize() async {
    try {
      final isComplete = await _controller.isOnboardingComplete();
      if (isComplete) {
        state = const OnboardingState.completed();
      }
    } catch (e) {
      state = OnboardingState.error(e);
    }
  }

  /// Advances to the next step in the onboarding flow.
  ///
  /// If the current step is [OnboardingStep.apiKeyInput], this will
  /// mark onboarding as complete and persist the state.
  Future<void> nextStep() async {
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        state = state.copyWith(currentStep: OnboardingStep.tutorial);
        break;
      case OnboardingStep.tutorial:
        state = state.copyWith(currentStep: OnboardingStep.apiKeyInput);
        break;
      case OnboardingStep.apiKeyInput:
        try {
          await _controller.markOnboardingComplete();
          state = const OnboardingState.completed();
        } catch (e) {
          state = OnboardingState.error(e);
        }
        break;
      case OnboardingStep.complete:
        // Already complete, no action needed
        break;
    }
  }

  /// Goes back to the previous step in the onboarding flow.
  ///
  /// Has no effect if already at the first step (welcome).
  void previousStep() {
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        // Already at first step, no action needed
        break;
      case OnboardingStep.tutorial:
        state = state.copyWith(currentStep: OnboardingStep.welcome);
        break;
      case OnboardingStep.apiKeyInput:
        state = state.copyWith(currentStep: OnboardingStep.tutorial);
        break;
      case OnboardingStep.complete:
        // Cannot go back from complete state
        break;
    }
  }

  /// Resets the onboarding state to the initial welcome step.
  ///
  /// This clears the persisted onboarding completion status and returns
  /// the state to the welcome step. Useful for testing or allowing users
  /// to re-experience the onboarding flow.
  Future<void> reset() async {
    await _controller.resetOnboarding();
    state = const OnboardingState.initial();
  }

  /// Skips directly to a specific step.
  ///
  /// This is useful for testing or allowing users to skip
  /// certain parts of the onboarding flow.
  void skipToStep(OnboardingStep step) {
    if (step == OnboardingStep.complete) {
      // Use nextStep() to properly mark completion
      return;
    }
    state = state.copyWith(currentStep: step);
  }

  /// Clears any error in the current state.
  ///
  /// This returns the state to the apiKeyInput step, allowing
  /// the user to retry after an error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for the [OnboardingStateNotifier].
///
/// This provider creates a [StateNotifierProvider] that manages the
/// onboarding flow state. Use this provider in UI components to
/// react to onboarding state changes.
///
/// **Important:** The notifier must be explicitly initialized to sync
/// with persisted state. Call [initialize] once when the onboarding
/// screen loads, before relying on the state values.
///
/// Example usage:
/// ```dart
/// // In a StatefulWidget's initState or via ref.listen:
/// await ref.read(onboardingStateProvider.notifier).initialize();
///
/// // Then watch the state in build:
/// final onboardingState = ref.watch(onboardingStateProvider);
///
/// // Check current step
/// if (onboardingState.currentStep == OnboardingStep.welcome) {
///   // Show welcome screen
/// }
///
/// // Advance to next step
/// await ref.read(onboardingStateProvider.notifier).nextStep();
/// ```
///
/// See also:
/// - [OnboardingStateNotifier.initialize] for the initialization method
/// - [OnboardingStateNotifier.nextStep] for advancing the flow
final onboardingStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, OnboardingState>((ref) {
  final controller = ref.read(onboardingControllerProvider);
  return OnboardingStateNotifier(controller);
});
