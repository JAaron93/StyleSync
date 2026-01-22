import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, expectLater;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylesync/core/onboarding/onboarding_controller.dart';
import 'package:stylesync/core/onboarding/onboarding_controller_impl.dart';

// =============================================================================
// Property 1: Onboarding Persistence
// =============================================================================
//
// For any user who successfully completes the onboarding flow, subsequent app
// launches should not display the onboarding flow again, and the user's
// onboarding status should persist across app restarts.
//
// Validates: Requirements 1.7
// =============================================================================

// =============================================================================
// Custom Generators
// =============================================================================

/// Generator for positive integers representing number of operations (1-10)
Generator<int> smallPositiveIntGenerator({int max = 10}) {
  return (random, size) {
    final value = random.nextInt(max) + 1;
    return Shrinkable(value, () sync* {});
  };
}

/// Generator for operation sequences (true = markComplete, false = reset)
Generator<List<bool>> operationSequenceGenerator({int maxLength = 10}) {
  return (random, size) {
    final length = random.nextInt(maxLength) + 1;
    final operations = List.generate(length, (_) => random.nextBool());
    return Shrinkable(operations, () sync* {});
  };
}

// =============================================================================
// Extension for glados generators
// =============================================================================

extension OnboardingGenerators on Any {
  Generator<int> get smallPositiveInt => smallPositiveIntGenerator();
  Generator<List<bool>> get operationSequence => operationSequenceGenerator();
}

// =============================================================================
// Test Helpers
// =============================================================================

/// Creates a fresh OnboardingController instance.
/// This simulates an "app restart" by creating a new controller instance
/// that reads from the same SharedPreferences storage.
Future<OnboardingController> createController() async {
  final prefs = await SharedPreferences.getInstance();
  return OnboardingControllerImpl(sharedPreferences: prefs);
}

/// Clears the SharedPreferences mock storage between tests.
void resetMockStorage() {
  SharedPreferences.setMockInitialValues({});
}

// =============================================================================
// Property-Based Tests
// =============================================================================

void main() {
  setUp(() {
    resetMockStorage();
  });

  group('Property 1: Onboarding Persistence', () {
    // =========================================================================
    // Property 1.1: Persistence after completion
    // =========================================================================
    
    group('Persistence after completion', () {
      Glados(any.smallPositiveInt).test(
        'After markOnboardingComplete(), isOnboardingComplete() returns true',
        (iterations) async {
          resetMockStorage();
          final controller = await createController();
          
          // Mark onboarding as complete
          await controller.markOnboardingComplete();
          
          // Verify it returns true on subsequent calls
          for (var i = 0; i < iterations; i++) {
            final isComplete = await controller.isOnboardingComplete();
            expect(isComplete, isTrue,
                reason: 'isOnboardingComplete() should return true after '
                    'markOnboardingComplete() on call #${i + 1}');
          }
        },
      );

      Glados(any.smallPositiveInt).test(
        'isOnboardingComplete() is consistent within same controller instance',
        (checkCount) async {
          resetMockStorage();
          final controller = await createController();
          
          // Initially should be false
          final initialResults = <bool>[];
          for (var i = 0; i < checkCount; i++) {
            initialResults.add(await controller.isOnboardingComplete());
          }
          expect(initialResults.every((r) => r == false), isTrue,
              reason: 'All initial checks should return false');
          
          // After marking complete, should be true
          await controller.markOnboardingComplete();
          
          final afterCompleteResults = <bool>[];
          for (var i = 0; i < checkCount; i++) {
            afterCompleteResults.add(await controller.isOnboardingComplete());
          }
          expect(afterCompleteResults.every((r) => r == true), isTrue,
              reason: 'All checks after completion should return true');
        },
      );
    });

    // =========================================================================
    // Property 1.2: Persistence across controller instances (app restarts)
    // =========================================================================
    
    group('Persistence across controller instances (simulated app restarts)', () {
      Glados(any.smallPositiveInt).test(
        'Completion status persists across new controller instances',
        (restartCount) async {
          resetMockStorage();
          
          // Create initial controller and mark complete
          final initialController = await createController();
          await initialController.markOnboardingComplete();
          
          // Verify persistence across multiple "app restarts"
          for (var i = 0; i < restartCount; i++) {
            final newController = await createController();
            final isComplete = await newController.isOnboardingComplete();
            expect(isComplete, isTrue,
                reason: 'Onboarding should remain complete after restart #${i + 1}');
          }
        },
      );

      Glados(any.smallPositiveInt).test(
        'Incomplete status persists across new controller instances',
        (restartCount) async {
          resetMockStorage();
          
          // Create initial controller but don't mark complete
          await createController();
          
          // Verify incomplete status persists across multiple "app restarts"
          for (var i = 0; i < restartCount; i++) {
            final newController = await createController();
            final isComplete = await newController.isOnboardingComplete();
            expect(isComplete, isFalse,
                reason: 'Onboarding should remain incomplete after restart #${i + 1}');
          }
        },
      );

      Glados(any.smallPositiveInt).test(
        'State is correctly read by new controller after completion',
        (restartCount) async {
          resetMockStorage();
          
          // First controller marks complete
          final controller1 = await createController();
          expect(await controller1.isOnboardingComplete(), isFalse,
              reason: 'Initial state should be incomplete');
          
          await controller1.markOnboardingComplete();
          expect(await controller1.isOnboardingComplete(), isTrue,
              reason: 'Should be complete after marking');
          
          // Subsequent controllers should all see complete state
          for (var i = 0; i < restartCount; i++) {
            final newController = await createController();
            expect(await newController.isOnboardingComplete(), isTrue,
                reason: 'New controller #${i + 1} should see complete state');
          }
        },
      );
    });

    // =========================================================================
    // Property 1.3: Reset functionality
    // =========================================================================
    
    group('Reset functionality', () {
      Glados(any.smallPositiveInt).test(
        'After resetOnboarding(), isOnboardingComplete() returns false',
        (iterations) async {
          resetMockStorage();
          final controller = await createController();
          
          // First mark as complete
          await controller.markOnboardingComplete();
          expect(await controller.isOnboardingComplete(), isTrue,
              reason: 'Should be complete before reset');
          
          // Reset
          await controller.resetOnboarding();
          
          // Verify it returns false on subsequent calls
          for (var i = 0; i < iterations; i++) {
            final isComplete = await controller.isOnboardingComplete();
            expect(isComplete, isFalse,
                reason: 'isOnboardingComplete() should return false after '
                    'resetOnboarding() on call #${i + 1}');
          }
        },
      );

      Glados(any.smallPositiveInt).test(
        'Reset persists across controller instances',
        (restartCount) async {
          resetMockStorage();
          
          // Create controller, mark complete, then reset
          final controller = await createController();
          await controller.markOnboardingComplete();
          await controller.resetOnboarding();
          
          // Verify reset persists across "app restarts"
          for (var i = 0; i < restartCount; i++) {
            final newController = await createController();
            final isComplete = await newController.isOnboardingComplete();
            expect(isComplete, isFalse,
                reason: 'Reset should persist after restart #${i + 1}');
          }
        },
      );

      Glados(any.smallPositiveInt).test(
        'Can complete again after reset',
        (cycles) async {
          resetMockStorage();
          final controller = await createController();
          
          for (var i = 0; i < cycles; i++) {
            // Mark complete
            await controller.markOnboardingComplete();
            expect(await controller.isOnboardingComplete(), isTrue,
                reason: 'Should be complete in cycle #${i + 1}');
            
            // Reset
            await controller.resetOnboarding();
            expect(await controller.isOnboardingComplete(), isFalse,
                reason: 'Should be incomplete after reset in cycle #${i + 1}');
          }
        },
      );
    });

    // =========================================================================
    // Property 1.4: Idempotency
    // =========================================================================
    
    group('Idempotency', () {
      Glados(any.smallPositiveInt).test(
        'Calling markOnboardingComplete() multiple times has same effect as once',
        (callCount) async {
          resetMockStorage();
          final controller = await createController();
          
          // Call markOnboardingComplete multiple times
          for (var i = 0; i < callCount; i++) {
            await controller.markOnboardingComplete();
          }
          
          // Should still be complete
          expect(await controller.isOnboardingComplete(), isTrue,
              reason: 'Should be complete after $callCount calls');
          
          // New controller should also see complete
          final newController = await createController();
          expect(await newController.isOnboardingComplete(), isTrue,
              reason: 'New controller should see complete state');
        },
      );

      Glados(any.smallPositiveInt).test(
        'Calling resetOnboarding() multiple times has same effect as once',
        (callCount) async {
          resetMockStorage();
          final controller = await createController();
          
          // First mark as complete
          await controller.markOnboardingComplete();
          
          // Call resetOnboarding multiple times
          for (var i = 0; i < callCount; i++) {
            await controller.resetOnboarding();
          }
          
          // Should still be incomplete
          expect(await controller.isOnboardingComplete(), isFalse,
              reason: 'Should be incomplete after $callCount reset calls');
          
          // New controller should also see incomplete
          final newController = await createController();
          expect(await newController.isOnboardingComplete(), isFalse,
              reason: 'New controller should see incomplete state');
        },
      );

      Glados(any.operationSequence).test(
        'Final state depends only on last operation type',
        (operations) async {
          resetMockStorage();
          final controller = await createController();
          
          // Execute all operations
          for (final isMarkComplete in operations) {
            if (isMarkComplete) {
              await controller.markOnboardingComplete();
            } else {
              await controller.resetOnboarding();
            }
          }
          
          // Final state should match the last operation
          final lastOperation = operations.last;
          final expectedComplete = lastOperation;
          
          expect(await controller.isOnboardingComplete(), expectedComplete,
              reason: 'Final state should be ${expectedComplete ? "complete" : "incomplete"} '
                  'based on last operation');
          
          // Verify persistence
          final newController = await createController();
          expect(await newController.isOnboardingComplete(), expectedComplete,
              reason: 'Persisted state should match final state');
        },
      );
    });

    // =========================================================================
    // Property 1.5: Initial state
    // =========================================================================
    
    group('Initial state', () {
      Glados(any.smallPositiveInt).test(
        'Fresh storage always starts with incomplete state',
        (checkCount) async {
          resetMockStorage();
          
          for (var i = 0; i < checkCount; i++) {
            resetMockStorage(); // Fresh storage each time
            final controller = await createController();
            final isComplete = await controller.isOnboardingComplete();
            expect(isComplete, isFalse,
                reason: 'Fresh storage should have incomplete state (check #${i + 1})');
          }
        },
      );
    });

    // =========================================================================
    // Property 1.6: State transitions
    // =========================================================================
    
    group('State transitions', () {
      Glados2(any.smallPositiveInt, any.smallPositiveInt).test(
        'Complete -> Reset -> Complete cycle works correctly',
        (completeCalls, resetCalls) async {
          resetMockStorage();
          final controller = await createController();
          
          // Initial state
          expect(await controller.isOnboardingComplete(), isFalse,
              reason: 'Initial state should be incomplete');
          
          // Mark complete multiple times
          for (var i = 0; i < completeCalls; i++) {
            await controller.markOnboardingComplete();
          }
          expect(await controller.isOnboardingComplete(), isTrue,
              reason: 'Should be complete after marking');
          
          // Reset multiple times
          for (var i = 0; i < resetCalls; i++) {
            await controller.resetOnboarding();
          }
          expect(await controller.isOnboardingComplete(), isFalse,
              reason: 'Should be incomplete after reset');
          
          // Mark complete again
          await controller.markOnboardingComplete();
          expect(await controller.isOnboardingComplete(), isTrue,
              reason: 'Should be complete after re-marking');
          
          // Verify persistence
          final newController = await createController();
          expect(await newController.isOnboardingComplete(), isTrue,
              reason: 'Final complete state should persist');
        },
      );
    });
  });

  // ===========================================================================
  // Edge Case Tests (non-property-based)
  // ===========================================================================
  
  group('Edge Cases', () {
    setUp(() {
      resetMockStorage();
    });

    test('isOnboardingComplete() returns false for fresh storage', () async {
      final controller = await createController();
      final isComplete = await controller.isOnboardingComplete();
      expect(isComplete, isFalse,
          reason: 'Fresh storage should return false for isOnboardingComplete()');
    });

    test('markOnboardingComplete() followed by isOnboardingComplete() returns true', () async {
      final controller = await createController();
      await controller.markOnboardingComplete();
      final isComplete = await controller.isOnboardingComplete();
      expect(isComplete, isTrue,
          reason: 'Should return true after marking complete');
    });

    test('resetOnboarding() on fresh storage does not throw', () async {
      final controller = await createController();
      // This should not throw even though there's nothing to reset
      await expectLater(
        controller.resetOnboarding(),
        completes,
        reason: 'resetOnboarding() should complete without error on fresh storage',
      );
    });

    test('Multiple controllers can coexist and see same state', () async {
      final controller1 = await createController();
      final controller2 = await createController();
      
      // Both should see incomplete initially
      expect(await controller1.isOnboardingComplete(), isFalse);
      expect(await controller2.isOnboardingComplete(), isFalse);
      
      // Mark complete via controller1
      await controller1.markOnboardingComplete();
      
      // Both should see complete (after re-reading from storage)
      expect(await controller1.isOnboardingComplete(), isTrue);
      // Note: controller2 needs to re-read from SharedPreferences
      // Since SharedPreferences is a singleton, this should work
      expect(await controller2.isOnboardingComplete(), isTrue,
          reason: 'Second controller should see updated state');
    });

    test('Rapid state changes are handled correctly', () async {
      final controller = await createController();
      
      // Rapidly toggle state
      await controller.markOnboardingComplete();
      await controller.resetOnboarding();
      await controller.markOnboardingComplete();
      await controller.resetOnboarding();
      await controller.markOnboardingComplete();
      
      // Final state should be complete
      expect(await controller.isOnboardingComplete(), isTrue,
          reason: 'Final state should be complete after rapid changes');
      
      // Verify persistence
      final newController = await createController();
      expect(await newController.isOnboardingComplete(), isTrue,
          reason: 'Persisted state should be complete');
    });
  });
}
