import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'models/validation_result.dart';

/// Validates Vertex AI API keys for format and functionality.
///
/// This service provides two levels of validation:
/// 1. Format validation - checks the key structure without network calls
/// 2. Functional validation - verifies the key works with the Vertex AI API
abstract class APIKeyValidator {
  /// Validates the format of an API key.
  ///
  /// Checks:
  /// - Key starts with expected prefix (e.g., 'AIza')
  /// - Key has correct length (39 characters for Vertex AI)
  /// - Key contains only valid characters (alphanumeric, underscore, hyphen)
  ///
  /// Returns [ValidationSuccess] if format is valid.
  /// Returns [ValidationFailure] with [ValidationFailureType.invalidFormat]
  /// or [ValidationFailureType.malformedKey] if invalid.
  ValidationResult validateFormat(String apiKey);

  /// Validates the functionality of an API key by making a test API call.
  ///
  /// Makes a request to the Vertex AI models list endpoint:
  /// `GET https://{region}-aiplatform.googleapis.com/v1/projects/{projectId}/locations/{region}/models`
  ///
  /// Returns [ValidationSuccess] with available models metadata if successful.
  /// Returns [ValidationFailure] with specific error type if validation fails.
  ///
  /// **Important:** Call [dispose] when the validator is no longer needed
  /// to release underlying resources.
  Future<ValidationResult> validateFunctionality(
    String apiKey,
    String projectId, {
    String region = 'us-central1',
  });

  /// Releases resources held by this validator.
  ///
  /// Call this method when the validator is no longer needed to free
  /// any underlying resources (e.g., HTTP client connections).
  void dispose();
}

/// Default implementation of [APIKeyValidator].
///
/// Uses the `http` package for making API calls to validate key functionality.
class APIKeyValidatorImpl implements APIKeyValidator {
  /// The HTTP client used for API requests.
  ///
  /// Can be injected for testing purposes.
  final http.Client _httpClient;

  /// Whether this instance owns the HTTP client and should close it on dispose.
  ///
  /// When `true`, the client was created internally and will be closed in [dispose].
  /// When `false`, the client was injected externally and the caller is responsible
  /// for closing it.
  final bool _ownsHttpClient;

  /// The timeout duration for API requests.
  final Duration _timeout;

  /// Creates a new [APIKeyValidatorImpl] instance.
  ///
  /// [httpClient] - Optional HTTP client for dependency injection (useful for testing).
  ///   If not provided, a new client will be created and owned by this instance.
  ///   If provided, the caller is responsible for closing it.
  /// [timeout] - Optional timeout duration for API requests (defaults to 10 seconds).
  APIKeyValidatorImpl({
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 10),
  })  : _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null,
        _timeout = timeout;

  /// Regular expression pattern for valid API key characters.
  ///
  /// Google API keys contain only alphanumeric characters, underscores, and hyphens.
  static final RegExp _validCharPattern = RegExp(r'^[A-Za-z0-9_-]+$');

  /// Expected prefix for Google API keys.
  static const String _expectedPrefix = 'AIza';

  /// Expected length for Google API keys.
  static const int _expectedLength = 39;

  @override
  ValidationResult validateFormat(String apiKey) {
    // Check for empty or whitespace-only input
    if (apiKey.trim().isEmpty) {
      return const ValidationFailure(
        type: ValidationFailureType.invalidFormat,
        message: 'API key cannot be empty',
      );
    }

    // Trim whitespace
    final trimmedKey = apiKey.trim();

    // Check prefix (Google API keys typically start with 'AIza')
    if (!trimmedKey.startsWith(_expectedPrefix)) {
      return const ValidationFailure(
        type: ValidationFailureType.invalidFormat,
        message: 'API key must start with "AIza"',
      );
    }

    // Check length (Google API keys are 39 characters)
    if (trimmedKey.length != _expectedLength) {
      return ValidationFailure(
        type: ValidationFailureType.malformedKey,
        message:
            'API key must be exactly $_expectedLength characters (got ${trimmedKey.length})',
      );
    }

    // Check for valid characters (alphanumeric, underscore, hyphen)
    if (!_validCharPattern.hasMatch(trimmedKey)) {
      return const ValidationFailure(
        type: ValidationFailureType.malformedKey,
        message: 'API key contains invalid characters',
      );
    }

    return const ValidationSuccess();
  }

  @override
  Future<ValidationResult> validateFunctionality(
    String apiKey,
    String projectId, {
    String region = 'us-central1',
  }) async {
    // Construct the Vertex AI models list endpoint URL
    final url = Uri.parse(
      'https://$region-aiplatform.googleapis.com/v1/'
      'projects/$projectId/locations/$region/models',
    );

    try {
      final response = await _httpClient
          .get(
            url,
            headers: {
              'x-goog-api-key': apiKey,
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      return _handleResponse(response, projectId);
    } on TimeoutException catch (e) {
      return ValidationFailure(
        type: ValidationFailureType.networkError,
        message: 'Request timed out. Please check your network connection.',
        originalError: e,
      );
    } on SocketException catch (e) {
      return ValidationFailure(
        type: ValidationFailureType.networkError,
        message: 'Network error. Please check your internet connection.',
        originalError: e,
      );
    } on http.ClientException catch (e) {
      return ValidationFailure(
        type: ValidationFailureType.networkError,
        message: 'Network error. Please check your internet connection.',
        originalError: e,
      );
    } catch (e) {
      return ValidationFailure(
        type: ValidationFailureType.unknown,
        message: 'An unexpected error occurred: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Handles the HTTP response and returns the appropriate [ValidationResult].
  ValidationResult _handleResponse(http.Response response, String projectId) {
    switch (response.statusCode) {
      case 200:
        // Success - parse available models
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          return ValidationSuccess(metadata: body);
        } catch (e) {
          // Even if parsing fails, the key is valid
          return const ValidationSuccess();
        }

      case 401:
        return const ValidationFailure(
          type: ValidationFailureType.unauthorized,
          message: 'API key is invalid or has been revoked',
          errorCode: '401',
        );

      case 403:
        // Check if it's a project access issue or API not enabled
        return _handle403Response(response, projectId);

      case 404:
        return ValidationFailure(
          type: ValidationFailureType.invalidProject,
          message: 'Project "$projectId" not found. '
              'Please verify the project ID.',
          errorCode: '404',
        );

      case 429:
        return const ValidationFailure(
          type: ValidationFailureType.rateLimited,
          message: 'Rate limit exceeded. Please try again later.',
          errorCode: '429',
        );

      default:
        return ValidationFailure(
          type: ValidationFailureType.unknown,
          message: 'Unexpected error (HTTP ${response.statusCode})',
          errorCode: response.statusCode.toString(),
        );
    }
  }

  /// Handles 403 responses to distinguish between API not enabled and access denied.
  ValidationFailure _handle403Response(
      http.Response response, String projectId) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMessage = body['error']?['message'] as String? ?? '';

      if (errorMessage.contains('API not enabled') ||
          errorMessage.contains('has not been used') ||
          errorMessage.contains('is disabled')) {
        return ValidationFailure(
          type: ValidationFailureType.apiNotEnabled,
          message: 'Vertex AI API is not enabled for project "$projectId". '
              'Please enable it in the Google Cloud Console.',
          errorCode: '403',
        );
      }
    } catch (_) {
      // If we can't parse the response, fall through to generic 403 handling
    }

    return ValidationFailure(
      type: ValidationFailureType.invalidProject,
      message: 'Access denied to project "$projectId". '
          'Please verify the project ID and API key permissions.',
      errorCode: '403',
    );
  }

  /// Closes the HTTP client if this instance owns it.
  ///
  /// Call this method when the validator is no longer needed to free resources.
  /// If an external HTTP client was injected via the constructor, it will not
  /// be closed (the caller is responsible for managing its lifecycle).
  @override
  void dispose() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}
