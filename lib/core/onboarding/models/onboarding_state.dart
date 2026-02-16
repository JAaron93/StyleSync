/// Represents the different steps in the onboarding flow.
///
/// The onboarding process guides new users through the initial setup
/// of StyleSync, including welcome screens, tutorials, and API key configuration.
enum OnboardingStep {
  /// Initial welcome screen introducing the app.
  welcome,

  /// Tutorial screens explaining app features and usage.
  tutorial,

  /// Screen for entering and validating the user's API key (BYOK).
  apiKeyInput,

  /// Onboarding is complete; user can proceed to the main app.
  complete,
}

/// Represents the current state of the onboarding process.
///
/// This immutable class holds information about whether onboarding
/// has been completed and the current step in the flow.
///
/// [isComplete] is a computed property derived from [currentStep] to
/// guarantee state consistency - onboarding is complete iff the current
/// step is [OnboardingStep.complete].
class OnboardingState {
  /// Creates an [OnboardingState] instance.
  ///
  /// [currentStep] represents the current step in the onboarding flow.
  /// [error] contains any error that occurred during onboarding operations.
  const OnboardingState({
    required this.currentStep,
    this.error,
  });

  /// Creates an initial state for a new user who hasn't started onboarding.
  const OnboardingState.initial()
      : currentStep = OnboardingStep.welcome,
        error = null;

  /// Creates a state representing completed onboarding.
  const OnboardingState.completed()
      : currentStep = OnboardingStep.complete,
        error = null;

  /// Creates a state representing an error during onboarding.
  const OnboardingState.error(this.error)
      : currentStep = OnboardingStep.apiKeyInput;

  /// Whether the onboarding process has been completed.
  ///
  /// This is computed from [currentStep] to guarantee consistency:
  /// onboarding is complete iff the current step is [OnboardingStep.complete].
  bool get isComplete => currentStep == OnboardingStep.complete;

  /// The current step in the onboarding flow.
  final OnboardingStep currentStep;

  /// The error that occurred during onboarding, if any.
  final Object? error;

  /// Whether the state has an error.
  bool get hasError => error != null;

  /// Creates a copy of this state with the given fields replaced.
  OnboardingState copyWith({
    OnboardingStep? currentStep,
    Object? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.currentStep == currentStep &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(currentStep, error);

  @override
  String toString() =>
      'OnboardingState(currentStep: $currentStep, error: $error)';
}
