import 'package:flutter/material.dart';

import '../../../core/onboarding/models/onboarding_state.dart';

/// A page indicator showing the current step in the onboarding flow.
///
/// Displays dots for each step (welcome, tutorial, apiKeyInput) with
/// the current step highlighted.
class OnboardingPageIndicator extends StatelessWidget {
  /// Creates an [OnboardingPageIndicator].
  ///
  /// [currentStep] is the current step in the onboarding flow.
  const OnboardingPageIndicator({
    super.key,
    required this.currentStep,
  });

  /// The current step in the onboarding flow.
  final OnboardingStep currentStep;

  /// The steps to display in the indicator.
  /// Excludes [OnboardingStep.complete] as it's not a visible step.
  static const List<OnboardingStep> _visibleSteps = [
    OnboardingStep.welcome,
    OnboardingStep.tutorial,
    OnboardingStep.apiKeyInput,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = _visibleSteps.indexOf(currentStep);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_visibleSteps.length, (index) {
        final isActive = index == currentIndex;
        final isCompleted = index < currentIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          // Key enables test discovery via find.byKey('indicator_dot_$index')
          child: AnimatedContainer(
            key: Key('indicator_dot_$index'),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

/// An alternative page indicator with step labels.
///
/// Shows step numbers and labels below the dots for more context.
class OnboardingPageIndicatorWithLabels extends StatelessWidget {
  /// Creates an [OnboardingPageIndicatorWithLabels].
  ///
  /// [currentStep] is the current step in the onboarding flow.
  const OnboardingPageIndicatorWithLabels({
    super.key,
    required this.currentStep,
  });

  /// The current step in the onboarding flow.
  final OnboardingStep currentStep;

  /// Step information for display.
  static const List<_StepInfo> _steps = [
    _StepInfo(step: OnboardingStep.welcome, label: 'Welcome'),
    _StepInfo(step: OnboardingStep.tutorial, label: 'Tutorial'),
    _StepInfo(step: OnboardingStep.apiKeyInput, label: 'API Key'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex =
        _steps.indexWhere((info) => info.step == currentStep);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        final stepInfo = _steps[index];
        final isActive = index == currentIndex;
        final isCompleted = index < currentIndex;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step indicator
              Row(
                children: [
                  // Line before (except for first item)
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted || isActive
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  // Circle
                  AnimatedContainer(
                    key: Key('labeled_indicator_circle_$index'),
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary
                          : isCompleted
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 3,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: colorScheme.onPrimary,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  // Line after (except for last item)
                  if (index < _steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Label
              Text(
                stepInfo.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive || isCompleted
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Information about a step for display purposes.
class _StepInfo {
  const _StepInfo({
    required this.step,
    required this.label,
  });

  final OnboardingStep step;
  final String label;
}
