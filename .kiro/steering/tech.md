# Technology Stack

## Framework & Language
- **Flutter**: `^3.10.7`
- **Dart**: `^3.10.7`
- **Build System**: Flutter CLI, Gradle (Android), Xcode (iOS)

## Core Dependencies
- **State Management**: Riverpod (`flutter_riverpod: ^2.6.1`)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Cryptography**: `cryptography: ^2.9.0`, `argon2: ^1.0.1`
- **Secure Storage**: `flutter_secure_storage: ^10.0.0`
- **HTTP**: `http: ^1.2.2`

## Testing Stack
- **Unit Testing**: `flutter_test` (built-in)
- **Property-Based Testing**: `glados: ^1.1.7`
- **Mocking**: `mockito: ^5.6.3`
- **Code Generation**: `build_runner: ^2.10.5`

## Common Commands

### Setup
```bash
flutter pub get                    # Install dependencies
flutter pub upgrade                # Update dependencies
```

### Development
```bash
flutter run                        # Run app (debug mode)
flutter run --release              # Run app (release mode)
dart format .                      # Format code
flutter analyze                    # Lint/analyze code
```

### Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```
Run this after modifying files with code generation annotations (e.g., Mockito mocks).

### Testing
```bash
flutter test                       # Run all tests
flutter test test/path/to/test.dart  # Run specific test
flutter test --coverage            # Generate coverage report
```

## Platform-Specific Notes

### Android
- Gradle configuration optimized in `android/gradle.properties`
- JVM args: `-Xmx4G` for balanced performance
- Parallel builds and caching enabled

### iOS
- Xcode project in `ios/` directory
- Uses CocoaPods for dependency management
