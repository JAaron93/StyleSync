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
class OnboardingState {
  /// Creates an [OnboardingState] instance.
  ///
  /// [isComplete] indicates whether the user has finished onboarding.
  /// [currentStep] represents the current step in the onboarding flow.
  const OnboardingState({
    required this.isComplete,
    required this.currentStep,
  });

  /// Creates an initial state for a new user who hasn't started onboarding.
  const OnboardingState.initial()
      : isComplete = false,
        currentStep = OnboardingStep.welcome;

  /// Creates a state representing completed onboarding.
  const OnboardingState.completed()
      : isComplete = true,
        currentStep = OnboardingStep.complete;

  /// Whether the onboarding process has been completed.
  final bool isComplete;

  /// The current step in the onboarding flow.
  final OnboardingStep currentStep;

  /// Creates a copy of this state with the given fields replaced.
  OnboardingState copyWith({
    bool? isComplete,
    OnboardingStep? currentStep,
  }) {
    return OnboardingState(
      isComplete: isComplete ?? this.isComplete,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.isComplete == isComplete &&
        other.currentStep == currentStep;
  }

  @override
  int get hashCode => Object.hash(isComplete, currentStep);

  @override
  String toString() =>
      'OnboardingState(isComplete: $isComplete, currentStep: $currentStep)';
}
