# Onboarding Screen

Main container component that orchestrates the onboarding flow with page navigation, progress indicators, and state management integration.

**File**: [`lib/features/onboarding/onboarding_screen.dart`](../../../lib/features/onboarding/onboarding_screen.dart)

## Features

- Multi-page flow with PageView
- Controlled navigation (no swipe gestures)
- Progress indication
- Riverpod state management integration
- Responsive layout

## Implementation

```dart
class OnboardingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OnboardingPageIndicator(currentStep: state.step),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  WelcomePage(onNext: () => _navigateNext(ref)),
                  TutorialPage(
                    onNext: () => _navigateNext(ref),
                    onBack: () => _navigateBack(ref),
                  ),
                  ApiKeyInputPage(
                    onBack: () => _navigateBack(ref),
                    onComplete: () => _complete(ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Navigation Control

- **No Swipe**: PageView physics disabled for controlled flow
- **Button-Driven**: All navigation through explicit button taps
- **State-Synced**: PageView synced with OnboardingState

## Related Documentation

- [Onboarding System Overview](./overview.md)
- [Onboarding Controller](../../core-services/onboarding-controller.md)
