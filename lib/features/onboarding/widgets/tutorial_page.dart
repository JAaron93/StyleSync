import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tutorial page explaining how to get a Gemini API key.
///
/// This page provides step-by-step instructions with links to:
/// - Google Cloud Console
/// - Vertex AI setup
///
/// It also explains the difference between Free and Paid tier quotas.
class TutorialPage extends StatelessWidget {
  /// Creates a [TutorialPage].
  ///
  /// [onNext] is called when the user taps the "Next" button.
  /// [onBack] is called when the user taps the back button.
  const TutorialPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  /// Callback invoked when the user taps "Next".
  final VoidCallback onNext;

  /// Callback invoked when the user taps the back button.
  final VoidCallback onBack;

  /// Google Cloud Console URL for creating a project.
  static const String _cloudConsoleUrl =
      'https://console.cloud.google.com/projectcreate';

  /// Vertex AI API enablement URL.
  static const String _vertexAiUrl =
      'https://console.cloud.google.com/apis/library/aiplatform.googleapis.com';

  /// API credentials URL.
  static const String _credentialsUrl =
      'https://console.cloud.google.com/apis/credentials';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Title
                Text(
                  'How to Get Your Gemini API Key',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'StyleSync uses Google\'s Gemini AI through Vertex AI. Follow these steps to set up your API key.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Important notice
                _NoticeCard(
                  icon: Icons.info_outline_rounded,
                  title: 'Important',
                  message:
                      'You need a Google Cloud project with the Vertex AI API enabled. This is different from Google AI Studio.',
                  colorScheme: colorScheme,
                  isWarning: false,
                ),
                const SizedBox(height: 24),
                // Step 1
                _TutorialStep(
                  stepNumber: 1,
                  title: 'Create a Google Cloud Project',
                  description:
                      'Go to the Google Cloud Console and create a new project (or select an existing one).',
                  linkText: 'Open Google Cloud Console',
                  onLinkTap: () => _launchUrl(_cloudConsoleUrl, context),
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 20),
                // Step 2
                _TutorialStep(
                  stepNumber: 2,
                  title: 'Enable Vertex AI API',
                  description:
                      'In your project, enable the Vertex AI API. This allows your project to use Gemini models.',
                  linkText: 'Enable Vertex AI API',
                  onLinkTap: () => _launchUrl(_vertexAiUrl, context),
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 20),
                // Step 3
                _TutorialStep(
                  stepNumber: 3,
                  title: 'Create an API Key',
                  description:
                      'Go to the Credentials page and create a new API key. Make sure to restrict it to the Vertex AI API for security.',
                  linkText: 'Create API Key',
                  onLinkTap: () => _launchUrl(_credentialsUrl, context),
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 24),
                // Quota information
                _QuotaInfoCard(colorScheme: colorScheme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Bottom navigation
        _BottomNavigation(
          onBack: onBack,
          onNext: onNext,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  /// Launches a URL in the default browser.
  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// A card displaying an important notice or warning.
class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.colorScheme,
    required this.isWarning,
  });

  final IconData icon;
  final String title;
  final String message;
  final ColorScheme colorScheme;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isWarning ? colorScheme.errorContainer : colorScheme.tertiaryContainer;
    final foregroundColor = isWarning
        ? colorScheme.onErrorContainer
        : colorScheme.onTertiaryContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: foregroundColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: foregroundColor.withValues(alpha: 0.9),
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

/// A single step in the tutorial with a number, title, description, and link.
class _TutorialStep extends StatelessWidget {
  const _TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.linkText,
    required this.onLinkTap,
    required this.colorScheme,
  });

  final int stepNumber;
  final String title;
  final String description;
  final String linkText;
  final VoidCallback onLinkTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Step content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              // Link button
              InkWell(
                onTap: onLinkTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        linkText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card explaining the difference between Free and Paid tier quotas.
class _QuotaInfoCard extends StatelessWidget {
  const _QuotaInfoCard({required this.colorScheme});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pricing & Quotas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _QuotaTier(
            title: 'Free Tier',
            description:
                'Limited requests per minute. Good for trying out the app.',
            icon: Icons.star_outline_rounded,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          _QuotaTier(
            title: 'Paid / Billing Enabled',
            description:
                'Higher quotas and priority access. Pay only for what you use.',
            icon: Icons.star_rounded,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          Text(
            'You can start with the free tier and upgrade later if needed.',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single quota tier row.
class _QuotaTier extends StatelessWidget {
  const _QuotaTier({
    required this.title,
    required this.description,
    required this.icon,
    required this.colorScheme,
  });

  final String title;
  final String description;
  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom navigation bar with back and next buttons.
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.onBack,
    required this.onNext,
    required this.colorScheme,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
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
            onPressed: onBack,
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
          // Next button
          FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Next'),
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
