# Getting Started

This guide will help you set up the StyleSync development environment and run the application.

## Prerequisites

### Required Software
- **Flutter SDK**: `^3.10.7` or later
- **Dart SDK**: Bundled with Flutter
- **Git**: For version control

### Platform-Specific Requirements

#### Android Development
- **Android Studio** or **Android SDK**
- **Android SDK Platform-Tools**
- **Android SDK Build-Tools**
- **Min SDK**: 24 (Android 8.0+)

#### iOS Development (macOS only)
- **Xcode**: Version 14.0 or later
- **CocoaPods**: Dependency manager for iOS
- **Min deployment target**: iOS 14.0

#### Optional Tools
- **Homebrew** (macOS): For easy SDK installation
- **VS Code** or **Android Studio**: Recommended IDEs

## Installation

### 1. Install Flutter SDK

#### Using Homebrew (macOS)
```bash
brew install --cask flutter
```

#### Manual Installation
1. Download Flutter SDK from [flutter.dev](https://flutter.dev)
2. Extract to desired location
3. Add Flutter to your PATH

Verify installation:
```bash
flutter --version
flutter doctor
```

### 2. Clone the Repository

```bash
git clone <repository-url>
cd StyleSync
```

### 3. Install Dependencies

```bash
flutter pub get
```

This will install all required packages including:
- Firebase services (core, auth, storage, firestore)
- Flutter Secure Storage
- Riverpod for state management
- Cryptography packages (Argon2, cryptography)
- Testing frameworks (mockito, glados)

### 4. Firebase Configuration

StyleSync requires Firebase for authentication and cloud backup features.

#### Option 1: Using FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

#### Option 2: Manual Configuration
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app and download `google-services.json` to `android/app/`
3. Add iOS app and download `GoogleService-Info.plist` to `ios/Runner/`

#### Firebase Security Rules
Deploy the required security rules for Firebase Storage:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Primary backup path
    match /users/{userId}/api_key_backup.json {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId && request.resource.size > 0;
    }
    
    // Temporary file path for passphrase rotation
    match /backups/{userId}/api_key_backup.tmp {
      allow read, write: if request.auth != null && request.auth.uid == userId && request.resource.size > 0;
    }
  }
}
```

## Running the Application

### Development Mode

Run on connected device or emulator:
```bash
flutter run
```

Run on specific device:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Hot Reload
While the app is running, press:
- `r` for hot reload
- `R` for hot restart
- `q` to quit

## Common Commands

### Code Generation
Run this after modifying files that use code generation (e.g., Mockito mocks):
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Code Quality

#### Format Code
```bash
dart format .
```

#### Analyze Code
```bash
flutter analyze
```

### Testing

#### Run All Tests
```bash
flutter test
```

#### Run Specific Test File
```bash
flutter test test/path/to/test_file.dart
```

#### Run Tests with Coverage
```bash
flutter test --coverage
```

### Building

#### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

#### iOS
```bash
# Debug build
flutter build ios --debug --no-codesign

# Release build (requires code signing)
flutter build ios --release
```

## Development Environment Setup

### Gradle Configuration (Android)
The project uses optimized Gradle settings in `android/gradle.properties`:
- **JVM Args**: `-Xmx4G` for balanced performance
- **Parallel Builds**: Enabled for faster builds on multi-core systems
- **Build Caching**: Enabled to reuse artifacts across runs

### IDE Configuration

#### VS Code
Recommended extensions:
- Flutter
- Dart
- Dart Data Class Generator

#### Android Studio
- Flutter plugin
- Dart plugin

## Troubleshooting

### Common Issues

#### "No Android SDK found"
- Install Android Studio or Android SDK
- Set `ANDROID_HOME` environment variable
- Run `flutter doctor` to verify setup

#### iOS Build Errors
- Run `pod install` in the `ios/` directory
- Open `ios/Runner.xcworkspace` in Xcode and verify settings
- Ensure Xcode command line tools are installed

#### Dependency Conflicts
```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get
```

#### Code Generation Issues
```bash
# Force rebuild generated files
dart run build_runner build --delete-conflicting-outputs
```

### Getting Help
- Check [Troubleshooting & FAQ](../troubleshooting/faq.md) for more solutions
- Review Flutter documentation at [flutter.dev](https://flutter.dev)
- Check Firebase documentation at [firebase.google.com](https://firebase.google.com)

## Next Steps

After setting up your environment:

1. **Understand the Architecture**: Read [Architecture Overview](../architecture/overview.md)
2. **Review Development Guidelines**: See [Development Guidelines](../guidelines/development-guidelines.md)
3. **Explore Core Services**: Start with [Core Services](../core-services/byok-manager.md)
4. **Run Tests**: Verify your setup with `flutter test`

## Additional Resources

- [Project Overview](./overview.md) - High-level introduction
- [Testing Strategy](../testing/strategy.md) - Testing approach and tools
- [Security Overview](../security/overview.md) - Security implementation details
