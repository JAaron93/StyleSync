import 'package:flutter/material.dart';

/// Dialog widget for requesting biometric consent for virtual try-on.
/// 
/// Explains how user photos will be processed and stored during try-on generation.
class BiometricConsentDialog extends StatefulWidget {
  final VoidCallback onConsentGranted;
  final VoidCallback onConsentRejected;

  const BiometricConsentDialog({
    super.key,
    required this.onConsentGranted,
    required this.onConsentRejected,
  });

  @override
  State<BiometricConsentDialog> createState() => _BiometricConsentDialogState();
}

class _BiometricConsentDialogState extends State<BiometricConsentDialog> {
  bool _decisionMade = false;

  void _handleConsentGranted() {
    _decisionMade = true;
    widget.onConsentGranted();
  }

  void _handleConsentRejected() {
    _decisionMade = true;
    widget.onConsentRejected();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_decisionMade) {
          _handleConsentRejected();
        }
      },
      child: AlertDialog(
        title: const Text('Virtual Try-On Consent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To generate virtual try-on images, we need to process your photo.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Processing happens on-device with direct client-to-AI communication.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Your input photo is ephemeral and deleted immediately after generation.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Generated try-on results are stored only if you explicitly save them.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _handleConsentRejected,
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: _handleConsentGranted,
            child: const Text('Grant Consent'),
          ),
        ],
      ),
    );
  }
}
