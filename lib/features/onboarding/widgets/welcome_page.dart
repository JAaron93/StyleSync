import 'package:flutter/material.dart';

/// Welcome page displayed as the first step of onboarding.
///
/// This page introduces the app's core features and provides
/// a "Get Started" button to proceed to the next step.
class WelcomePage extends StatelessWidget {
  /// Creates a [WelcomePage].
  ///
  /// [onGetStarted] is called when the user taps the "Get Started" button.
  const WelcomePage({
    super.key,
    required this.onGetStarted,
  });

  /// Callback invoked when the user taps "Get Started".
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          // App icon/logo placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.checkroom_rounded,
              size: 64,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 32),
          // Welcome title
          Text(
            'Welcome to StyleSync',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            'Your AI-powered personal stylist',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          // Feature cards
          _FeatureCard(
            icon: Icons.photo_library_rounded,
            title: 'Digital Wardrobe',
            description:
                'Organize your entire wardrobe digitally. Take photos of your clothes and let AI categorize them automatically.',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            icon: Icons.person_pin_rounded,
            title: 'Virtual Try-On',
            description:
                'See how outfits look on you before wearing them. Mix and match pieces from your wardrobe virtually.',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            icon: Icons.lightbulb_rounded,
            title: 'Outfit Brainstorming',
            description:
                'Get AI-powered outfit suggestions based on the occasion, weather, and your personal style preferences.',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 48),
          // Get Started button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onGetStarted,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// A card widget displaying a feature with an icon, title, and description.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorScheme,
  });

  final IconData icon;
  final String title;
  final String description;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSecondaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
