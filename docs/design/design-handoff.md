# StyleSync Design Handoff Documentation

## Overview

This document provides all necessary information for developers to implement the StyleSync UI (Task 23). It consolidates design decisions, specifications, and guidelines from the prototyping phase.

**Target Audience**: Developers implementing Task 23 (UI screens and navigation)  
**Prerequisites**: Familiarity with Flutter, Riverpod, and Firebase  
**Related Tasks**: Task 23 (Implement UI screens and navigation)

---

## Design Assets

### Prototype
- **Tool**: Figma
- **Link**: [https://www.figma.com/proto/StyleSync-Prototype-v1](https://www.figma.com/proto/StyleSync-Prototype-v1)
- **Version**: 1.0 - 2026-02-11

### Wireframes
- **Location**: `docs/design/wireframes.md`
- **Format**: ASCII art wireframes with annotations
- **Screens**: 45+ unique screens and states

### Component Library
- **Location**: To be created in Figma/Adobe XD
- **Components**: Buttons, cards, modals, navigation, inputs, feedback elements

---

## Screen Inventory

### Required Screens (Priority Order)

#### Phase 1: Core Flows (MVP)
1. **Onboarding** (3 screens)
   - Welcome Screen
   - API Key Tutorial Screen
   - API Key Input Screen

2. **Age Verification** (3 screens)
   - Age Gate Screen
   - Access Denied Screen
   - Verification Success Screen

3. **Digital Closet** (5 screens)
   - Closet Main Screen
   - Upload Options Modal
   - Item Detail Screen
   - Face Detection Consent Dialog
   - Upload Processing Screen

4. **Virtual Try-On** (4 screens)
   - Try-On Main Screen
   - Biometric Consent Dialog
   - Generation Progress Screen
   - Try-On Result Screen

5. **Settings** (3 screens)
   - Settings Main Screen
   - API Key Management Screen
   - Usage History Screen

#### Phase 2: Extended Features
6. **Rate Limit** (3 screens)
   - Warning Banner Component
   - Rate Limit Modal
   - Rate Limit Info Modal

7. **Outfit Canvas** (4 screens)
   - Outfit Canvas Screen
   - Save Outfit Dialog
   - Outfit Gallery Screen
   - AI Suggestions Screen

8. **Cloud Backup** (2 screens)
   - Cloud Backup Settings Screen
   - Passphrase Setup Dialog

#### Phase 3: Edge Cases & States
9. **Empty States** (3 screens)
   - Empty Closet
   - Empty Outfits
   - Empty Usage History

10. **Error States** (4 screens)
    - Network Error Modal
    - API Error Modal
    - Storage Quota Modal
    - Generic Error Modal

11. **Loading States** (3 screens)
    - Generic Loading Screen
    - Skeleton Screens
    - Progress Indicators

---

## Navigation Structure

### Bottom Navigation (Main Tabs)

```dart
enum MainTab {
  closet,
  tryOn,
  outfits,
}

// Implementation with go_router
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/closet',
          builder: (context, state) => ClosetScreen(),
        ),
        GoRoute(
          path: '/try-on',
          builder: (context, state) => TryOnScreen(),
        ),
        GoRoute(
          path: '/outfits',
          builder: (context, state) => OutfitGalleryScreen(),
        ),
      ],
    ),
  ],
);
```

### Route Definitions

```dart
// Onboarding routes
'/onboarding/welcome'
'/onboarding/tutorial'
'/onboarding/api-key-input'

// Age verification routes
'/age-gate'
'/age-gate/denied'
'/age-gate/verification'

// Main app routes
'/closet'
'/closet/:itemId'
'/try-on'
'/try-on/result/:resultId'
'/outfits'
'/outfits/:outfitId'
'/outfits/create'

// Settings routes
'/settings'
'/settings/api-key'
'/settings/cloud-backup'
'/settings/usage-history'
'/settings/consents'

// Modal routes (overlay)
'/modal/face-detection-consent'
'/modal/biometric-consent'
'/modal/rate-limit'
'/modal/upload-options'
```

### Deep Linking

Support deep links for:
- Direct to item: `stylesync://closet/item/{itemId}`
- Direct to try-on: `stylesync://try-on?itemId={itemId}`
- Direct to outfit: `stylesync://outfits/{outfitId}`

---

## Design System

### Colors

```dart
class AppColors {
  // Primary colors
  static const primary = Color(0xFF6200EE);
  static const primaryVariant = Color(0xFF3700B3);
  static const secondary = Color(0xFF03DAC6);
  
  // Neutral colors
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F5);
  static const error = Color(0xFFB00020);
  
  // Text colors
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF757575);
  static const textDisabled = Color(0xFFBDBDBD);
  
  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
}
```

**Note**: Final colors to be determined by visual designer. These are placeholders.

### Typography

```dart
class AppTextStyles {
  // Headlines
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.25,
  );
  
  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.33,
  );
  
  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body text
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.43,
  );
  
  // Captions
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.33,
  );
  
  // Buttons
  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
```

### Spacing

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

### Border Radius

```dart
class AppBorderRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const circular = 9999.0; // Fully rounded
}
```

### Elevation

```dart
class AppElevation {
  static const none = 0.0;
  static const sm = 2.0;
  static const md = 4.0;
  static const lg = 8.0;
  static const xl = 16.0;
}
```

---

## Component Specifications

### Buttons

#### Primary Button
```dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          minimumSize: Size(0, 48),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(text, style: AppTextStyles.button),
      ),
    );
  }
}
```

#### Secondary Button
```dart
// Similar to PrimaryButton but with outlined style
style: OutlinedButton.styleFrom(
  foregroundColor: AppColors.primary,
  side: BorderSide(color: AppColors.primary),
  // ... rest similar to primary
)
```

### Cards

#### Clothing Item Card
```dart
class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onTap;
  final bool isSelected;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                child: CachedNetworkImage(
                  imageUrl: item.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerPlaceholder(),
                  errorWidget: (context, url, error) => ErrorPlaceholder(),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            // Category label
            Text(
              item.tags.category.toString().split('.').last,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Modals

#### Bottom Sheet Modal
```dart
void showBottomSheetModal(
  BuildContext context, {
  required Widget child,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: child,
    ),
  );
}
```

#### Full Screen Modal
```dart
/// Presents a full-screen modal using go_router.
///
/// NOTE: go_router is preferred over Navigator.of(context).push for consistency 
/// with the project's declarative routing architecture, ensuring that modal 
/// states are correctly managed in the navigation stack and support deep linking.
void showFullScreenModal(
  BuildContext context, {
  required String routePath,
}) {
  // Use go_router to navigate to the modal route
  context.push(routePath);
}

// Example usage within a Page/Screen:
// showFullScreenModal(context, routePath: '/modal/upload-options');

// In GoRouter configuration, these routes should be defined using 
// a MaterialPage with fullscreenDialog: true in their PageBuilder.
// Example route definition:
// GoRoute(
//   path: '/modal/upload-options',
//   pageBuilder: (context, state) => MaterialPage(
//     fullscreenDialog: true,
//     child: Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => context.pop(), // Uses go_router to pop
//         ),
//       ),
//       body: const UploadOptionsModal(),
//     ),
//   ),
// ),
```

### Loading States

#### Shimmer Placeholder
```dart
class ShimmerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}
```

#### App Progress Indicator
```dart
class AppProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: AppColors.surface,
      valueColor: AlwaysStoppedAnimation(AppColors.primary),
    );
  }
}
```

---

## Animations & Transitions

### Screen Transitions

```dart
// Slide transition (custom for go_router)
GoRoute(
  path: '/next-screen',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: NextScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      
      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
),
```

### Micro-interactions

```dart
// Button press animation
AnimatedScale(
  scale: isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 100),
  child: button,
);

// Fade in animation
FadeTransition(
  opacity: animation,
  child: child,
);
```

---

## Accessibility

### Requirements

1. **Touch Targets**: Minimum 44x44pt
2. **Color Contrast**: 4.5:1 for text, 3:1 for UI components
3. **Screen Reader**: All interactive elements must have semantic labels
4. **Focus Indicators**: Visible focus states for keyboard navigation

### Implementation

```dart
// Semantic labels
Semantics(
  label: 'Upload clothing item',
  button: true,
  child: IconButton(
    icon: Icon(Icons.add),
    onPressed: onUpload,
  ),
);

// Minimum touch target
SizedBox(
  width: 44,
  height: 44,
  child: IconButton(
    icon: Icon(Icons.settings),
    onPressed: onSettings,
  ),
);
```

---

## Platform-Specific Considerations

### iOS
- Use Cupertino widgets where appropriate
- Follow Human Interface Guidelines
- Support iOS-specific gestures (swipe back)
- Use iOS-style navigation bar

### Android
- Use Material Design 3 components
- Follow Material Design Guidelines
- Support Android back button
- Use Material-style app bar

### Adaptive Widgets

```dart
// Platform-adaptive button
Widget adaptiveButton({
  required String text,
  required VoidCallback onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      child: Text(text),
    );
  }
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(text),
  );
}
```

---

## State Management Integration

### Screen State Pattern

```dart
class ClosetScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(clothingItemsProvider);
    final filter = ref.watch(clothingFilterProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('My Closet')),
      body: itemsAsync.when(
        data: (items) => _buildItemGrid(items, filter),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadOptions(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## Testing Requirements

### Widget Tests

Each screen must have widget tests covering:
1. Initial render
2. Loading states
3. Error states
4. User interactions
5. Navigation

Example:
```dart
testWidgets('ClosetScreen displays items', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clothingItemsProvider.overrideWithValue(
          AsyncValue.data(mockClothingItems),
        ),
      ],
      child: MaterialApp(home: ClosetScreen()),
    ),
  );
  
  expect(find.byType(ClothingItemCard), findsWidgets);
});
```

---

## Performance Guidelines

### Image Loading
- Use `CachedNetworkImage` for all network images
- Implement progressive loading (thumbnail → full)
- Set appropriate cache duration

### List Performance
- Use `ListView.builder` for long lists
- Implement lazy loading for pagination
- Use `AutomaticKeepAliveClientMixin` for tab views

### Memory Management
- Dispose controllers in `dispose()`
- Cancel streams and subscriptions
- Clear image cache when appropriate

---

## Checklist for Implementation

### Before Starting
- [ ] Review all wireframes
- [ ] Review prototype
- [ ] Review API contracts
- [ ] Set up design system constants
- [ ] Create reusable component library

### During Implementation
- [ ] Follow wireframe layouts
- [ ] Implement all states (loading, error, empty)
- [ ] Add proper error handling
- [ ] Implement accessibility features
- [ ] Write widget tests
- [ ] Test on both iOS and Android

### Before Completion
- [ ] All screens match wireframes
- [ ] All navigation flows work
- [ ] All modals and dialogs implemented
- [ ] Loading and error states tested
- [ ] Accessibility audit passed
- [ ] Widget tests passing
- [ ] Performance profiling done

---

## Questions & Support

For questions about design decisions or clarifications:
1. Review wireframes and prototype first
2. Check API contracts for data structures
3. Consult with design team if still unclear

**Design Team Contact**: Kiro (Lead Product Designer) - design-team@stylesync.io (Slack: @kiro-design)

---

**Document Version**: 1.0  
**Last Updated**: 2026-02-10  
**Next Review**: After Task 23 completion

