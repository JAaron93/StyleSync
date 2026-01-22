/// Widget tests for ApiKeyInputPage (Task 5.4)
///
/// Tests cover:
/// - API key input field rendering
/// - Project ID input field rendering
/// - Validation error display
/// - Loading state during validation
/// - Error message display on validation failure
/// - Back button functionality
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/core/byok/api_key_validator.dart';
import 'package:stylesync/core/byok/byok_manager.dart';
import 'package:stylesync/core/byok/models/api_key_config.dart';
import 'package:stylesync/core/byok/models/byok_error.dart';
import 'package:stylesync/core/byok/models/validation_result.dart';
import 'package:stylesync/core/storage/secure_storage_service.dart';
import 'package:stylesync/features/onboarding/widgets/api_key_input_page.dart';

// =============================================================================
// Mock Implementations
// =============================================================================

/// Mock BYOKManager for testing
class MockBYOKManager implements BYOKManager {
  bool shouldSucceed = true;
  bool shouldDelay = false;
  ValidationFailureType? failureType;
  String? errorMessage;

  @override
  Future<Result<void>> storeAPIKey(String apiKey, String projectId) async {
    if (shouldDelay) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (shouldSucceed) {
      return const Success(null);
    }
    final validationResult = ValidationFailure(
      type: failureType ?? ValidationFailureType.unauthorized,
      message: errorMessage ?? 'API key validation failed',
    );
    return Failure(ValidationError(
      errorMessage ?? 'API key validation failed',
      validationResult,
    ));
  }

  @override
  Future<Result<APIKeyConfig>> getAPIKey() async {
    return const Failure(NotFoundError());
  }

  @override
  Future<Result<void>> deleteAPIKey({bool deleteCloudBackup = false}) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> updateAPIKey(String newApiKey, String projectId,
      {String? passphrase}) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> enableCloudBackup(String passphrase) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> disableCloudBackup({bool deleteBackup = true}) async {
    return const Success(null);
  }

  @override
  Future<Result<APIKeyConfig>> restoreFromCloudBackup(String passphrase) async {
    return const Failure(NotFoundError());
  }

  @override
  Future<bool> hasStoredKey() async => false;

  @override
  Future<bool> isCloudBackupEnabled() async => false;

  @override
  Future<Result<void>> rotateBackupPassphrase(
    String oldPassphrase,
    String newPassphrase,
  ) async {
    return const Success(null);
  }
}

/// Mock SecureStorageService for testing
class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  SecureStorageBackend get backend => SecureStorageBackend.software;

  @override
  bool get requiresBiometric => false;
}

/// Mock APIKeyValidator for testing.
///
/// Delegates [validateFormat] to the real [APIKeyValidatorImpl] to ensure
/// tests use canonical validation rules. Only [validateFunctionality] is
/// stubbed for async test control.
class MockAPIKeyValidator implements APIKeyValidator {
  final APIKeyValidatorImpl _realValidator = APIKeyValidatorImpl();

  @override
  ValidationResult validateFormat(String apiKey) {
    return _realValidator.validateFormat(apiKey);
  }

  @override
  Future<ValidationResult> validateFunctionality(
    String apiKey,
    String projectId, {
    String region = 'us-central1',
  }) async {
    return const ValidationSuccess();
  }

  @override
  void dispose() {
    _realValidator.dispose();
  }
}

// =============================================================================
// Test Helpers
// =============================================================================

/// Valid API key for testing (format: AIza + 35 alphanumeric chars = 39 total)
const String validApiKey = 'AIzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

/// Valid project ID for testing
const String validProjectId = 'test-project-123';

/// Semantic finder for the API Key TextFormField (by hint text).
Finder findApiKeyField() =>
    find.widgetWithText(TextFormField, 'AIza...');

/// Semantic finder for the Project ID TextFormField (by hint text).
Finder findProjectIdField() =>
    find.widgetWithText(TextFormField, 'my-project-id');

/// Creates a testable ApiKeyInputPage widget with mock providers.
Widget createTestWidget({
  required VoidCallback onComplete,
  required VoidCallback onBack,
  MockBYOKManager? mockManager,
}) {
  final manager = mockManager ?? MockBYOKManager();

  return ProviderScope(
    overrides: [
      byokManagerProvider.overrideWithValue(manager),
      secureStorageServiceProvider.overrideWithValue(MockSecureStorageService()),
      apiKeyValidatorProvider.overrideWithValue(MockAPIKeyValidator()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ApiKeyInputPage(
          onComplete: onComplete,
          onBack: onBack,
        ),
      ),
    ),
  );
}

// =============================================================================
// Widget Tests
// =============================================================================

void main() {
  group('ApiKeyInputPage', () {
    // =========================================================================
    // Input Field Tests
    // =========================================================================

    group('Input fields', () {
      testWidgets('renders API key input field', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('API Key'), findsOneWidget,
            reason: 'API Key label should be displayed');
        expect(find.byType(TextFormField), findsNWidgets(2),
            reason: 'Should have two text form fields (API key and Project ID)');
      });

      testWidgets('renders Project ID input field',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Google Cloud Project ID'), findsOneWidget,
            reason: 'Project ID label should be displayed');
      });

      testWidgets('API key field has hint text', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('AIza...'), findsOneWidget,
            reason: 'API key field should have hint text');
      });

      testWidgets('Project ID field has hint text',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('my-project-id'), findsOneWidget,
            reason: 'Project ID field should have hint text');
      });

      testWidgets('API key field has key icon', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.key_rounded), findsOneWidget,
            reason: 'API key field should have key icon');
      });

      testWidgets('Project ID field has folder icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.folder_rounded), findsOneWidget,
            reason: 'Project ID field should have folder icon');
      });

      testWidgets('API key field has visibility toggle',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.visibility_rounded), findsOneWidget,
            reason: 'API key field should have visibility toggle');
      });

      testWidgets('can toggle API key visibility',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // Initially should show visibility icon (key is hidden)
        expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off_rounded), findsNothing);

        // Tap to toggle visibility
        await tester.tap(find.byIcon(Icons.visibility_rounded));
        await tester.pumpAndSettle();

        // Now should show visibility_off icon (key is visible)
        expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
        expect(find.byIcon(Icons.visibility_rounded), findsNothing);
      });
    });

    // =========================================================================
    // Validation Error Tests
    // =========================================================================

    group('Validation errors', () {
      testWidgets('shows validation error for empty API key',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // Tap verify button without entering anything
        await tester.tap(find.text('Verify & Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your API key'), findsOneWidget,
            reason: 'Should show error for empty API key');
      });

      testWidgets('shows validation error for invalid API key format',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // Enter invalid API key
        await tester.enterText(
          findApiKeyField(),
          'invalid-key',
        );
        await tester.enterText(
          findProjectIdField(),
          validProjectId,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pumpAndSettle();

        expect(find.textContaining('API key must start with "AIza"'), findsOneWidget,
            reason: 'Should show error for invalid API key format');
      });

      testWidgets('shows validation error for empty Project ID',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // Enter valid API key but no project ID
        await tester.enterText(
          findApiKeyField(),
          validApiKey,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your Project ID'), findsOneWidget,
            reason: 'Should show error for empty Project ID');
      });

      testWidgets('shows validation error for short API key',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        // Enter short API key
        await tester.enterText(
          findApiKeyField(),
          'AIzashort',
        );
        await tester.enterText(
          findProjectIdField(),
          validProjectId,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pumpAndSettle();

        // Look for the specific error message, not the helper text
        expect(find.text('API key must be exactly 39 characters'), findsOneWidget,
            reason: 'Should show error for short API key');
      });
    });

    // =========================================================================
    // Loading State Tests
    // =========================================================================

    group('Loading state', () {
      testWidgets('shows loading state during validation',
          (WidgetTester tester) async {
        final mockManager = MockBYOKManager()
          ..shouldSucceed = true
          ..shouldDelay = true;

        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
          mockManager: mockManager,
        ));
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(
          findApiKeyField(),
          validApiKey,
        );
        await tester.enterText(
          findProjectIdField(),
          validProjectId,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pump(); // Don't settle - we want to see loading state

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget,
            reason: 'Should show loading indicator during validation');
        expect(find.text('Verifying...'), findsOneWidget,
            reason: 'Should show "Verifying..." text during validation');

        // Complete the pending timer to avoid test failure
        await tester.pumpAndSettle();
      });

      testWidgets('disables buttons during loading',
          (WidgetTester tester) async {
        final mockManager = MockBYOKManager()
          ..shouldSucceed = true
          ..shouldDelay = true;

        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
          mockManager: mockManager,
        ));
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(
          findApiKeyField(),
          validApiKey,
        );
        await tester.enterText(
          findProjectIdField(),
          validProjectId,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pump();

        // Back button should be disabled
        final backButton = tester.widget<OutlinedButton>(
          find.ancestor(
            of: find.text('Back'),
            matching: find.byType(OutlinedButton),
          ),
        );
        expect(backButton.onPressed, isNull,
            reason: 'Back button should be disabled during loading');

        // Complete the pending timer to avoid test failure
        await tester.pumpAndSettle();
      });
    });

    // =========================================================================
    // Error Message Tests
    // =========================================================================

    group('Error messages on validation failure', () {
      testWidgets('shows error message on validation failure',
          (WidgetTester tester) async {
        final mockManager = MockBYOKManager()
          ..shouldSucceed = false
          ..failureType = ValidationFailureType.unauthorized
          ..errorMessage = 'Invalid API key';

        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
          mockManager: mockManager,
        ));
        await tester.pumpAndSettle();

        // Enter valid format credentials
        await tester.enterText(
          findApiKeyField(),
          validApiKey,
        );
        await tester.enterText(
          findProjectIdField(),
          validProjectId,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Invalid API key'), findsOneWidget,
            reason: 'Should show error message on validation failure');
      });

      testWidgets('shows error card with appropriate icon',
          (WidgetTester tester) async {
        final mockManager = MockBYOKManager()
          ..shouldSucceed = false
          ..failureType = ValidationFailureType.networkError
          ..errorMessage = 'Network error occurred';

        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
          mockManager: mockManager,
        ));
        await tester.pumpAndSettle();

        // Enter valid format credentials
        await tester.enterText(
          findApiKeyField(),
          validApiKey,
        );
        await tester.enterText(
          findProjectIdField(),
          validProjectId,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pumpAndSettle();

        // Should show network error icon
        expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget,
            reason: 'Should show network error icon');
      });
    });

    // =========================================================================
    // Success Flow Tests
    // =========================================================================

    group('Success flow', () {
      testWidgets('calls onComplete on successful validation',
          (WidgetTester tester) async {
        bool completeCalled = false;
        final mockManager = MockBYOKManager()..shouldSucceed = true;

        await tester.pumpWidget(createTestWidget(
          onComplete: () {
            completeCalled = true;
          },
          onBack: () {},
          mockManager: mockManager,
        ));
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(
          findApiKeyField(),
          validApiKey,
        );
        await tester.enterText(
          findProjectIdField(),
          validProjectId,
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verify & Continue'));
        await tester.pumpAndSettle();

        expect(completeCalled, isTrue,
            reason: 'onComplete should be called on successful validation');
      });
    });

    // =========================================================================
    // Navigation Button Tests
    // =========================================================================

    group('Navigation buttons', () {
      testWidgets('Back button is visible', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Back'), findsOneWidget,
            reason: 'Back button should be visible');
      });

      testWidgets('Verify & Continue button is visible',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Verify & Continue'), findsOneWidget,
            reason: 'Verify & Continue button should be visible');
      });

      testWidgets('tapping Back button calls onBack callback',
          (WidgetTester tester) async {
        bool backCalled = false;

        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {
            backCalled = true;
          },
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        expect(backCalled, isTrue,
            reason: 'onBack callback should be called when Back is tapped');
      });

      testWidgets('Back button has back arrow icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget,
            reason: 'Back button should have back arrow icon');
      });

      testWidgets('Verify button has check icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_rounded), findsOneWidget,
            reason: 'Verify button should have check icon');
      });
    });

    // =========================================================================
    // Security Notice Tests
    // =========================================================================

    group('Security notice', () {
      testWidgets('displays security notice', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Your API Key is Secure'), findsOneWidget,
            reason: 'Security notice title should be displayed');
        expect(
            find.textContaining('stored securely on your device'),
            findsOneWidget,
            reason: 'Security notice description should be displayed');
      });

      testWidgets('displays shield icon for security notice',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.shield_rounded), findsOneWidget,
            reason: 'Shield icon should be displayed for security notice');
      });
    });

    // =========================================================================
    // Layout Tests
    // =========================================================================

    group('Layout', () {
      testWidgets('renders title "Enter Your API Key"',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Enter Your API Key'), findsOneWidget,
            reason: 'Page title should be displayed');
      });

      testWidgets('uses Form widget for validation',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byType(Form), findsOneWidget,
            reason: 'Should use Form widget for validation');
      });

      testWidgets('uses SingleChildScrollView for scrollability',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget,
            reason: 'Content should be scrollable');
      });

      testWidgets('displays helper text for API key format',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(
            find.textContaining('starts with "AIza"'),
            findsOneWidget,
            reason: 'API key format helper text should be displayed');
      });

      testWidgets('displays helper text for Project ID',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          onComplete: () {},
          onBack: () {},
        ));
        await tester.pumpAndSettle();

        expect(
            find.textContaining('Google Cloud Console'),
            findsOneWidget,
            reason: 'Project ID helper text should be displayed');
      });
    });
  });
}
