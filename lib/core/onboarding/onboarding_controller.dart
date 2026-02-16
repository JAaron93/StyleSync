import 'models/onboarding_persistence_exception.dart';

/// Abstract interface for managing onboarding state and persistence.
///
/// The [OnboardingController] is responsible for tracking whether a user
/// has completed the onboarding flow and persisting this state across
/// app sessions. Implementations should ensure safe concurrent async access
/// and reliable persistence.
///
/// Example usage:
/// ```dart
/// final controller = ref.read(onboardingControllerProvider);
/// if (await controller.isOnboardingComplete()) {
///   // Navigate to main app
/// } else {
///   // Show onboarding flow
/// }
/// ```
abstract class OnboardingController {
  /// Checks whether the user has completed the onboarding process.
  ///
  /// Returns `true` if the user has previously completed onboarding
  /// and should be taken directly to the main app. Returns `false`
  /// if the user needs to go through the onboarding flow.
  ///
  /// This method reads from persistent storage and should be called
  /// during app initialization to determine the initial route.
  Future<bool> isOnboardingComplete();

  /// Marks the onboarding process as complete.
  ///
  /// This should be called when the user successfully finishes all
  /// onboarding steps. The completion state is persisted so that
  /// the onboarding flow is not shown again on subsequent app launches.
  ///
  /// Throws [OnboardingPersistenceException] if the persistence operation fails,
  /// such as when the storage backend is unavailable or the write operation
  /// is rejected by the storage layer.
  ///
  /// Implementations should throw [OnboardingPersistenceException] with
  /// `operation: 'markOnboardingComplete'` for consistent error handling.
  Future<void> markOnboardingComplete();

  /// Resets the onboarding state, allowing the flow to be shown again.
  ///
  /// This is useful for:
  /// - Testing purposes
  /// - Allowing users to re-experience the onboarding from settings
  /// - Clearing user data on logout
  ///
  /// After calling this method, [isOnboardingComplete] will return `false`.
  Future<void> resetOnboarding();
}
