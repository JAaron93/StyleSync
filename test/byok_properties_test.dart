import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:http/http.dart' as http;
import 'package:stylesync/core/byok/api_key_validator.dart';
import 'package:stylesync/core/byok/byok_manager.dart';
import 'package:stylesync/core/byok/models/api_key_config.dart';
import 'package:stylesync/core/byok/models/validation_result.dart';
import 'package:stylesync/core/storage/secure_storage_service.dart';

// =============================================================================
// Custom Generators for API Keys and Project IDs
// =============================================================================

/// Generator function for valid API keys (format: AIza + 35 alphanumeric chars = 39 total)
Generator<String> validAPIKeyGenerator() {
  return (random, size) {
    const validChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-';
    final suffix = List.generate(
      35,
      (_) => validChars[random.nextInt(validChars.length)],
    ).join();
    return Shrinkable('AIza$suffix', () sync* {});
  };
}

/// Generator function for invalid API keys (various invalid formats)
Generator<String> invalidAPIKeyGenerator() {
  return (random, size) {
    final invalidType = random.nextInt(6);
    String key;
    switch (invalidType) {
      case 0:
        // Empty string
        key = '';
        break;
      case 1:
        // Wrong prefix
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        final wrongPrefix = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
        final suffix = List.generate(35, (_) => chars[random.nextInt(chars.length)]).join();
        key = '$wrongPrefix$suffix';
        break;
      case 2:
        // Too short (less than 39 chars)
        final shortLength = random.nextInt(30);
        key = 'AIza${List.generate(shortLength, (_) => 'a').join()}';
        break;
      case 3:
        // Too long (more than 39 chars)
        final extraLength = random.nextInt(20) + 1;
        key = 'AIza${List.generate(35 + extraLength, (_) => 'a').join()}';
        break;
      case 4:
        // Invalid characters
        key = 'AIza${List.generate(35, (_) => '@').join()}';
        break;
      case 5:
        // Whitespace only
        key = '   ';
        break;
      default:
        key = '';
    }
    return Shrinkable(key, () sync* {});
  };
}

/// Generator function for valid project IDs (alphanumeric with hyphens, 6-30 chars)
Generator<String> validProjectIdGenerator() {
  return (random, size) {
    const validChars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final length = random.nextInt(25) + 6; // 6-30 chars
    final parts = <String>[];
    var currentPart = '';
    
    for (var i = 0; i < length; i++) {
      if (random.nextInt(5) == 0 && currentPart.isNotEmpty && i < length - 1) {
        parts.add(currentPart);
        currentPart = '';
      } else {
        currentPart += validChars[random.nextInt(validChars.length)];
      }
    }
    if (currentPart.isNotEmpty) {
      parts.add(currentPart);
    }
    
    final projectId = parts.join('-');
    return Shrinkable(projectId, () sync* {});
  };
}

/// Generator function for HTTP status codes that indicate validation failures
Generator<int> httpErrorCodeGenerator() {
  return (random, size) {
    const errorCodes = [401, 403, 404, 429, 500, 502, 503];
    final code = errorCodes[random.nextInt(errorCodes.length)];
    return Shrinkable(code, () sync* {});
  };
}

// =============================================================================
// Mock HTTP Client for Testing
// =============================================================================

/// Mock HTTP client that returns configurable responses
class MockHttpClient extends http.BaseClient {
  final int statusCode;
  final String responseBody;
  final bool shouldTimeout;
  final bool shouldThrowSocketException;
  int callCount = 0;

  MockHttpClient({
    this.statusCode = 200,
    this.responseBody = '{"models": []}',
    this.shouldTimeout = false,
    this.shouldThrowSocketException = false,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    callCount++;
    
    if (shouldTimeout) {
      throw TimeoutException('Request timed out');
    }
    
    if (shouldThrowSocketException) {
      throw const SocketException('Network unreachable');
    }
    
    final response = http.Response(responseBody, statusCode);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      statusCode,
      headers: response.headers,
    );
  }
}

// =============================================================================
// Mock Secure Storage for Testing
// =============================================================================

/// In-memory mock implementation of SecureStorageService
class MockSecureStorage implements SecureStorageService {
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

  /// Check if a key exists in storage
  bool containsKey(String key) => _storage.containsKey(key);

  /// Get all stored keys
  Set<String> get keys => _storage.keys.toSet();

  /// Clear storage for test isolation
  void clear() => _storage.clear();
}

// =============================================================================
// Extension for glados generators
// =============================================================================

extension APIKeyGenerators on Any {
  Generator<String> get validAPIKey => validAPIKeyGenerator();
  Generator<String> get invalidAPIKey => invalidAPIKeyGenerator();
  Generator<String> get validProjectId => validProjectIdGenerator();
  Generator<int> get httpErrorCode => httpErrorCodeGenerator();
}

// =============================================================================
// Property-Based Tests
// =============================================================================

void main() {
  group('Property 2: API Key Validation Pipeline', () {
    // =========================================================================
    // Format Validation Properties
    // =========================================================================
    
    group('Format Validation', () {
      late APIKeyValidatorImpl validator;

      setUp(() {
        validator = APIKeyValidatorImpl();
      });

      tearDown(() {
        validator.dispose();
      });

      Glados(any.validAPIKey).test(
        'Valid API keys pass format validation',
        (apiKey) {
          final result = validator.validateFormat(apiKey);
          expect(result, isA<ValidationSuccess>(),
              reason: 'Valid API key "$apiKey" should pass format validation');
        },
      );

      Glados(any.invalidAPIKey).test(
        'Invalid API keys fail format validation',
        (apiKey) {
          final result = validator.validateFormat(apiKey);
          expect(result, isA<ValidationFailure>(),
              reason: 'Invalid API key "$apiKey" should fail format validation');
        },
      );

      Glados(any.validAPIKey).test(
        'Format validation is idempotent',
        (apiKey) {
          final result1 = validator.validateFormat(apiKey);
          final result2 = validator.validateFormat(apiKey);
          
          expect(result1.runtimeType, equals(result2.runtimeType),
              reason: 'Format validation should be idempotent');
        },
      );

      Glados(any.validAPIKey).test(
        'Valid API keys have correct structure',
        (apiKey) {
          expect(apiKey.startsWith('AIza'), isTrue,
              reason: 'Valid API key should start with "AIza"');
          expect(apiKey.length, equals(39),
              reason: 'Valid API key should be 39 characters');
        },
      );

      Glados(any.lowercaseLetters).test(
        'Keys with wrong prefix fail format validation',
        (randomPrefix) {
          if (randomPrefix.isEmpty) return;
          final wrongPrefixKey = '${randomPrefix.substring(0, randomPrefix.length.clamp(0, 4))}${'a' * 35}';
          
          final result = validator.validateFormat(wrongPrefixKey);
          expect(result, isA<ValidationFailure>(),
              reason: 'Key with wrong prefix should fail');
          
          if (result is ValidationFailure) {
            expect(
              result.type,
              anyOf(
                ValidationFailureType.invalidFormat,
                ValidationFailureType.malformedKey,
              ),
              reason: 'Should be invalidFormat or malformedKey',
            );
          }
        },
      );
    });

    // =========================================================================
    // Functional Validation Properties
    // =========================================================================
    
    group('Functional Validation', () {
      Glados2(any.validAPIKey, any.validProjectId).test(
        'Successful API call returns ValidationSuccess',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(
            statusCode: 200,
            responseBody: '{"models": [{"name": "test-model"}]}',
          );
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationSuccess>(),
              reason: 'HTTP 200 should result in ValidationSuccess');
          expect(mockClient.callCount, equals(1),
              reason: 'Should make exactly one HTTP call');
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'HTTP 401 returns unauthorized failure',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(
            statusCode: 401,
            responseBody: '{"error": {"message": "Invalid API key"}}',
          );
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationFailure>(),
              reason: 'HTTP 401 should result in ValidationFailure');
          
          if (result is ValidationFailure) {
            expect(result.type, equals(ValidationFailureType.unauthorized),
                reason: 'HTTP 401 should be unauthorized type');
            expect(result.errorCode, equals('401'));
          }
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'HTTP 403 with API not enabled returns apiNotEnabled failure',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(
            statusCode: 403,
            responseBody: '{"error": {"message": "API not enabled for project"}}',
          );
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationFailure>(),
              reason: 'HTTP 403 should result in ValidationFailure');
          
          if (result is ValidationFailure) {
            expect(result.type, equals(ValidationFailureType.apiNotEnabled),
                reason: 'HTTP 403 with API not enabled message should be apiNotEnabled type');
          }
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'HTTP 403 without API not enabled message returns invalidProject failure',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(
            statusCode: 403,
            responseBody: '{"error": {"message": "Access denied"}}',
          );
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationFailure>(),
              reason: 'HTTP 403 should result in ValidationFailure');
          
          if (result is ValidationFailure) {
            expect(result.type, equals(ValidationFailureType.invalidProject),
                reason: 'HTTP 403 without API not enabled should be invalidProject type');
          }
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'HTTP 404 returns invalidProject failure',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(
            statusCode: 404,
            responseBody: '{"error": {"message": "Project not found"}}',
          );
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationFailure>(),
              reason: 'HTTP 404 should result in ValidationFailure');
          
          if (result is ValidationFailure) {
            expect(result.type, equals(ValidationFailureType.invalidProject),
                reason: 'HTTP 404 should be invalidProject type');
            expect(result.errorCode, equals('404'));
          }
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'HTTP 429 returns rateLimited failure',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(
            statusCode: 429,
            responseBody: '{"error": {"message": "Rate limit exceeded"}}',
          );
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationFailure>(),
              reason: 'HTTP 429 should result in ValidationFailure');
          
          if (result is ValidationFailure) {
            expect(result.type, equals(ValidationFailureType.rateLimited),
                reason: 'HTTP 429 should be rateLimited type');
            expect(result.errorCode, equals('429'));
          }
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'Network timeout returns networkError failure',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(shouldTimeout: true);
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationFailure>(),
              reason: 'Timeout should result in ValidationFailure');
          
          if (result is ValidationFailure) {
            expect(result.type, equals(ValidationFailureType.networkError),
                reason: 'Timeout should be networkError type');
          }
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'Socket exception returns networkError failure',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(shouldThrowSocketException: true);
          final validator = APIKeyValidatorImpl(httpClient: mockClient);

          final result = await validator.validateFunctionality(apiKey, projectId);
          
          expect(result, isA<ValidationFailure>(),
              reason: 'Socket exception should result in ValidationFailure');
          
          if (result is ValidationFailure) {
            expect(result.type, equals(ValidationFailureType.networkError),
                reason: 'Socket exception should be networkError type');
          }
          
          validator.dispose();
        },
      );
    });

    // =========================================================================
    // Complete Pipeline Properties (BYOKManager)
    // =========================================================================
    
    group('Complete Validation Pipeline', () {
      Glados2(any.validAPIKey, any.validProjectId).test(
        'Valid key with successful API call is stored',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(statusCode: 200);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          final result = await manager.storeAPIKey(apiKey, projectId);
          
          expect(result, isA<Success<void>>(),
              reason: 'Valid key should be stored successfully');
          expect(await manager.hasStoredKey(), isTrue,
              reason: 'Key should be present in storage');
          
          validator.dispose();
        },
      );

      Glados2(any.invalidAPIKey, any.validProjectId).test(
        'Invalid format key is rejected without API call (fail-fast)',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(statusCode: 200);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          final result = await manager.storeAPIKey(apiKey, projectId);
          
          expect(result, isA<Failure<void>>(),
              reason: 'Invalid format key should be rejected');
          expect(mockClient.callCount, equals(0),
              reason: 'No HTTP call should be made for invalid format (fail-fast)');
          expect(await manager.hasStoredKey(), isFalse,
              reason: 'Invalid key should not be stored');
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'Valid format but failed API call is rejected',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(statusCode: 401);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          final result = await manager.storeAPIKey(apiKey, projectId);
          
          expect(result, isA<Failure<void>>(),
              reason: 'Key with failed API validation should be rejected');
          expect(mockClient.callCount, equals(1),
              reason: 'HTTP call should be made for valid format key');
          expect(await manager.hasStoredKey(), isFalse,
              reason: 'Key with failed API validation should not be stored');
          
          validator.dispose();
        },
      );

      Glados3(any.validAPIKey, any.validProjectId, any.httpErrorCode).test(
        'Various HTTP error codes result in appropriate failures',
        (apiKey, projectId, errorCode) async {
          final mockClient = MockHttpClient(statusCode: errorCode);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          final result = await manager.storeAPIKey(apiKey, projectId);
          
          expect(result, isA<Failure<void>>(),
              reason: 'HTTP error $errorCode should result in failure');
          expect(await manager.hasStoredKey(), isFalse,
              reason: 'Key should not be stored on HTTP error');
          
          validator.dispose();
        },
      );
    });

    // =========================================================================
    // Storage Consistency Properties
    // =========================================================================
    
    group('Storage Consistency', () {
      Glados2(any.validAPIKey, any.validProjectId).test(
        'Stored key can be retrieved',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(statusCode: 200);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          await manager.storeAPIKey(apiKey, projectId);
          final retrieveResult = await manager.getAPIKey();
          
          expect(retrieveResult, isA<Success<APIKeyConfig>>(),
              reason: 'Stored key should be retrievable');
          
          final config = retrieveResult.valueOrNull;
          expect(config, isNotNull);
          expect(config!.apiKey, equals(apiKey.trim()),
              reason: 'Retrieved key should match stored key');
          expect(config.projectId, equals(projectId),
              reason: 'Retrieved project ID should match stored project ID');
          
          validator.dispose();
        },
      );

      Glados2(any.validAPIKey, any.validProjectId).test(
        'Deleted key cannot be retrieved',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(statusCode: 200);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          await manager.storeAPIKey(apiKey, projectId);
          await manager.deleteAPIKey();
          final retrieveResult = await manager.getAPIKey();
          
          expect(retrieveResult, isA<Failure<APIKeyConfig>>(),
              reason: 'Deleted key should not be retrievable');
          expect(await manager.hasStoredKey(), isFalse,
              reason: 'hasStoredKey should return false after deletion');
          
          validator.dispose();
        },
      );

      Glados3(any.validAPIKey, any.validAPIKey, any.validProjectId).test(
        'Updated key replaces old key',
        (oldKey, newKey, projectId) async {
          // Skip if keys are the same
          if (oldKey == newKey) return;
          
          final mockClient = MockHttpClient(statusCode: 200);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          await manager.storeAPIKey(oldKey, projectId);
          await manager.updateAPIKey(newKey, projectId);
          final retrieveResult = await manager.getAPIKey();
          
          expect(retrieveResult, isA<Success<APIKeyConfig>>(),
              reason: 'Updated key should be retrievable');
          
          final config = retrieveResult.valueOrNull;
          expect(config, isNotNull);
          expect(config!.apiKey, equals(newKey.trim()),
              reason: 'Retrieved key should be the new key');
          
          validator.dispose();
        },
      );
    });

    // =========================================================================
    // Idempotency Properties
    // =========================================================================
    
    group('Idempotency', () {
      Glados2(any.validAPIKey, any.validProjectId).test(
        'Multiple stores of same key are idempotent',
        (apiKey, projectId) async {
          final mockClient = MockHttpClient(statusCode: 200);
          final mockStorage = MockSecureStorage();
          final validator = APIKeyValidatorImpl(httpClient: mockClient);
          final manager = BYOKManagerImpl(
            secureStorage: mockStorage,
            apiKeyValidator: validator,
          );

          final result1 = await manager.storeAPIKey(apiKey, projectId);
          final result2 = await manager.storeAPIKey(apiKey, projectId);
          
          expect(result1, isA<Success<void>>());
          expect(result2, isA<Success<void>>());
          
          final retrieveResult = await manager.getAPIKey();
          expect(retrieveResult, isA<Success<APIKeyConfig>>());
          
          final config = retrieveResult.valueOrNull;
          expect(config, isNotNull);
          expect(config!.apiKey, equals(apiKey.trim()));
          
          validator.dispose();
        },
      );
    });
  });

  // ===========================================================================
  // Edge Case Tests
  // ===========================================================================
  
  group('Edge Cases', () {
    test('Empty API key fails format validation', () {
      final validator = APIKeyValidatorImpl();
      final result = validator.validateFormat('');
      
      expect(result, isA<ValidationFailure>());
      if (result is ValidationFailure) {
        expect(result.type, equals(ValidationFailureType.invalidFormat));
      }
      
      validator.dispose();
    });

    test('Whitespace-only API key fails format validation', () {
      final validator = APIKeyValidatorImpl();
      final result = validator.validateFormat('   ');
      
      expect(result, isA<ValidationFailure>());
      if (result is ValidationFailure) {
        expect(result.type, equals(ValidationFailureType.invalidFormat));
      }
      
      validator.dispose();
    });

    test('API key with leading/trailing whitespace is trimmed', () {
      final validator = APIKeyValidatorImpl();
      final validKey = 'AIza${'a' * 35}';
      final keyWithWhitespace = '  $validKey  ';
      
      final result = validator.validateFormat(keyWithWhitespace);
      expect(result, isA<ValidationSuccess>());
      
      validator.dispose();
    });

    test('Retrieving non-existent key returns NotFoundError', () async {
      final mockClient = MockHttpClient(statusCode: 200);
      final mockStorage = MockSecureStorage();
      final validator = APIKeyValidatorImpl(httpClient: mockClient);
      final manager = BYOKManagerImpl(
        secureStorage: mockStorage,
        apiKeyValidator: validator,
      );

      final result = await manager.getAPIKey();
      
      expect(result, isA<Failure<APIKeyConfig>>());
      
      validator.dispose();
    });

    test('Deleting non-existent key returns NotFoundError', () async {
      final mockClient = MockHttpClient(statusCode: 200);
      final mockStorage = MockSecureStorage();
      final validator = APIKeyValidatorImpl(httpClient: mockClient);
      final manager = BYOKManagerImpl(
        secureStorage: mockStorage,
        apiKeyValidator: validator,
      );

      final result = await manager.deleteAPIKey();
      
      expect(result, isA<Failure<void>>());
      
      validator.dispose();
    });

    test('HTTP 500 returns unknown failure type', () async {
      final mockClient = MockHttpClient(statusCode: 500);
      final validator = APIKeyValidatorImpl(httpClient: mockClient);
      final validKey = 'AIza${'a' * 35}';

      final result = await validator.validateFunctionality(validKey, 'test-project');
      
      expect(result, isA<ValidationFailure>());
      if (result is ValidationFailure) {
        expect(result.type, equals(ValidationFailureType.unknown));
      }
      
      validator.dispose();
    });

    test('Malformed JSON response still returns success for HTTP 200', () async {
      final mockClient = MockHttpClient(
        statusCode: 200,
        responseBody: 'not valid json',
      );
      final validator = APIKeyValidatorImpl(httpClient: mockClient);
      final validKey = 'AIza${'a' * 35}';

      final result = await validator.validateFunctionality(validKey, 'test-project');
      
      // Even if JSON parsing fails, HTTP 200 means the key is valid
      expect(result, isA<ValidationSuccess>());
      
      validator.dispose();
    });
  });
}
