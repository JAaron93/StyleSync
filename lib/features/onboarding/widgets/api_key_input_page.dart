import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/byok/byok_manager.dart';
import '../../../core/byok/models/byok_error.dart';
import '../../../core/byok/models/validation_result.dart';

/// Page for entering and validating the Gemini API key.
///
/// This page provides text fields for the API key and Google Cloud Project ID,
/// validates the input, and stores the key using [BYOKManager].
class ApiKeyInputPage extends ConsumerStatefulWidget {
  /// Creates an [ApiKeyInputPage].
  ///
  /// [onComplete] is called when the API key is successfully validated and stored.
  /// [onBack] is called when the user taps the back button.
  const ApiKeyInputPage({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  /// Callback invoked when API key validation and storage succeeds.
  final VoidCallback onComplete;

  /// Callback invoked when the user taps the back button.
  final VoidCallback onBack;

  @override
  ConsumerState<ApiKeyInputPage> createState() => _ApiKeyInputPageState();
}

class _ApiKeyInputPageState extends ConsumerState<ApiKeyInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _apiKeyFocusNode = FocusNode();
  final _projectIdFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscureApiKey = true;
  String? _errorMessage;
  ValidationFailureType? _errorType;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _projectIdController.dispose();
    _apiKeyFocusNode.dispose();
    _projectIdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Enter Your API Key',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your Gemini API key and Google Cloud Project ID to enable AI features.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // API Key field
                  _buildApiKeyField(colorScheme),
                  const SizedBox(height: 24),
                  // Project ID field
                  _buildProjectIdField(colorScheme),
                  const SizedBox(height: 24),
                  // Error message
                  if (_errorMessage != null) ...[
                    _ErrorCard(
                      message: _errorMessage!,
                      errorType: _errorType,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Security notice
                  _SecurityNotice(colorScheme: colorScheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        // Bottom navigation
        _BottomNavigation(
          onBack: widget.onBack,
          onVerify: _handleVerifyAndContinue,
          isLoading: _isLoading,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  /// Builds the API key text field.
  Widget _buildApiKeyField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Key',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _apiKeyController,
          focusNode: _apiKeyFocusNode,
          obscureText: _obscureApiKey,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'AIza...',
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureApiKey
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              onPressed: () {
                setState(() {
                  _obscureApiKey = !_obscureApiKey;
                });
              },
              tooltip: _obscureApiKey ? 'Show API key' : 'Hide API key',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorMaxLines: 2,
          ),
          validator: _validateApiKeyFormat,
          onFieldSubmitted: (_) {
            _projectIdFocusNode.requestFocus();
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 4),
        Text(
          'Your API key starts with "AIza" and is 39 characters long.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Builds the Project ID text field.
  Widget _buildProjectIdField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Google Cloud Project ID',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _projectIdController,
          focusNode: _projectIdFocusNode,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'my-project-id',
            prefixIcon: const Icon(Icons.folder_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorMaxLines: 2,
          ),
          validator: _validateProjectId,
          onFieldSubmitted: (_) {
            _handleVerifyAndContinue();
          },
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 4),
        Text(
          'Found in your Google Cloud Console project settings.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Validates the API key format locally.
  String? _validateApiKeyFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your API key';
    }
    final trimmed = value.trim();
    if (!trimmed.startsWith('AIza')) {
      return 'API key must start with "AIza"';
    }
    if (trimmed.length != 39) {
      return 'API key must be exactly 39 characters';
    }
    return null;
  }

  /// Validates the Project ID format locally.
  String? _validateProjectId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Project ID';
    }
    final trimmed = value.trim();
    if (trimmed.length < 6 || trimmed.length > 30) {
      return 'Project ID must be 6-30 characters';
    }
    if (!RegExp(r'^[a-z][a-z0-9-]*[a-z0-9]$').hasMatch(trimmed)) {
      return 'Project ID must start with a letter, contain only lowercase letters, digits, and hyphens';
    }
    return null;
  }

  /// Handles the verify and continue button press.
  Future<void> _handleVerifyAndContinue() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
      _errorType = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final byokManager = ref.read(byokManagerProvider);
      final apiKey = _apiKeyController.text.trim();
      final projectId = _projectIdController.text.trim();

      // Store and validate the API key
      final result = await byokManager.storeAPIKey(apiKey, projectId);

      if (!mounted) return;

      if (result.isSuccess) {
        // Success - proceed to next step
        widget.onComplete();
      } else {
        // Handle failure
        final error = result.errorOrNull;
        setState(() {
          _errorMessage = error?.message ?? 'An unknown error occurred';
          if (error is ValidationError) {
            final validationResult = error.validationResult;
            if (validationResult is ValidationFailure) {
              _errorType = validationResult.type;
            }
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Card displaying validation errors with helpful context.
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.errorType,
    required this.colorScheme,
  });

  final String message;
  final ValidationFailureType? errorType;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIconForErrorType(errorType),
            color: colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitleForErrorType(errorType),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                if (_getHintForErrorType(errorType) != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _getHintForErrorType(errorType)!,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForErrorType(ValidationFailureType? type) {
    return switch (type) {
      ValidationFailureType.invalidFormat ||
      ValidationFailureType.malformedKey =>
        Icons.text_fields_rounded,
      ValidationFailureType.unauthorized => Icons.lock_rounded,
      ValidationFailureType.invalidProject => Icons.folder_off_rounded,
      ValidationFailureType.apiNotEnabled => Icons.api_rounded,
      ValidationFailureType.networkError => Icons.wifi_off_rounded,
      ValidationFailureType.rateLimited => Icons.speed_rounded,
      _ => Icons.error_outline_rounded,
    };
  }

  String _getTitleForErrorType(ValidationFailureType? type) {
    return switch (type) {
      ValidationFailureType.invalidFormat ||
      ValidationFailureType.malformedKey =>
        'Invalid API Key Format',
      ValidationFailureType.unauthorized => 'Unauthorized',
      ValidationFailureType.invalidProject => 'Invalid Project',
      ValidationFailureType.apiNotEnabled => 'API Not Enabled',
      ValidationFailureType.networkError => 'Network Error',
      ValidationFailureType.rateLimited => 'Rate Limited',
      _ => 'Validation Failed',
    };
  }

  String? _getHintForErrorType(ValidationFailureType? type) {
    return switch (type) {
      ValidationFailureType.unauthorized =>
        'Check that your API key is correct and hasn\'t been revoked.',
      ValidationFailureType.invalidProject =>
        'Verify your Project ID in the Google Cloud Console.',
      ValidationFailureType.apiNotEnabled =>
        'Go back to the tutorial and enable the Vertex AI API.',
      ValidationFailureType.networkError =>
        'Check your internet connection and try again.',
      ValidationFailureType.rateLimited =>
        'Wait a moment and try again.',
      _ => null,
    };
  }
}

/// Notice about API key security.
class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_rounded,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your API Key is Secure',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your API key is stored securely on your device using encrypted storage. It never leaves your device except to communicate directly with Google\'s servers.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom navigation bar with back and verify buttons.
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.onBack,
    required this.onVerify,
    required this.isLoading,
    required this.colorScheme,
  });

  final VoidCallback onBack;
  final VoidCallback onVerify;
  final bool isLoading;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          OutlinedButton.icon(
            onPressed: isLoading ? null : onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Spacer(),
          // Verify & Continue button
          FilledButton.icon(
            onPressed: isLoading ? null : onVerify,
            icon: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(isLoading ? 'Verifying...' : 'Verify & Continue'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
