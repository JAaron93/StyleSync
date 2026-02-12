import 'package:flutter/material.dart';

/// Dialog widget for requesting face detection consent.
/// 
/// Explains that photos will be scanned for faces to protect privacy
/// and requests explicit user consent before proceeding.
class FaceDetectionConsentDialog extends StatelessWidget {
  final VoidCallback onConsentGranted;
  final VoidCallback onConsentRejected;

  const FaceDetectionConsentDialog({
    super.key,
    required this.onConsentGranted,
    required this.onConsentRejected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy Protection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To protect your privacy, we scan uploaded photos for faces.',
          ),
          const SizedBox(height: 16),
          const Text(
            'This analysis happens entirely on your device. '
            'No biometric data is extracted or stored.',
          ),
          const SizedBox(height: 16),
          const Text(
            'If a face is detected, we will ask for your consent before '
            'proceeding with storage.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onConsentRejected,
          child: const Text('Reject'),
        ),
        ElevatedButton(
          onPressed: onConsentGranted,
          child: const Text('Grant Consent'),
        ),
      ],
    );
  }
}
