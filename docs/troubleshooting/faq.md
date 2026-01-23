# Troubleshooting & FAQ

## Common Issues

### Setup & Installation

#### "No Android SDK found"
**Problem**: Flutter can't locate Android SDK

**Solution**:
1. Install Android Studio or Android SDK
2. Set `ANDROID_HOME` environment variable
3. Run `flutter doctor` to verify

#### "Pod install failed" (iOS)
**Problem**: CocoaPods dependency issues

**Solution**:
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

#### "Xcode build failed" (iOS)
**Problem**: iOS build errors

**Solution**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Set development team
3. Verify signing certificates
4. Clean build folder in Xcode

### Dependencies

#### "Version conflict" errors
**Problem**: Package version incompatibilities

**Solution**:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### "Missing generated files"
**Problem**: Mockito mocks not generated

**Solution**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Runtime Issues

#### "PlatformException: Secure storage unavailable"
**Problem**: Platform secure storage not accessible

**Possible Causes**:
- Device locked (iOS)
- Keystore unavailable (Android)
- Emulator limitations

**Solution**:
- Unlock device
- Test on real device
- Check platform logs for details

#### "Firebase not configured"
**Problem**: Missing Firebase configuration files

**Solution**:
- Android: Add `google-services.json` to `android/app/`
- iOS: Add `GoogleService-Info.plist` to `ios/Runner/`
- Run `flutterfire configure` to generate files

### Testing

#### "Tests fail with provider errors"
**Problem**: Riverpod providers not properly mocked

**Solution**:
```dart
testWidgets('test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myProvider.overrideWithValue(mockValue),
      ],
      child: MyApp(),
    ),
  );
});
```

#### "Property tests timeout"
**Problem**: Glados tests take too long

**Solution**:
- Reduce iteration count for complex tests
- Check for infinite loops
- Use lighter-weight generators

### Performance

#### "First build very slow"
**Problem**: Initial Gradle/CocoaPods setup

**Solution**:
- Normal on first build
- Subsequent builds much faster
- Enable build caching (already enabled in gradle.properties)

#### "App lags during key derivation"
**Problem**: Argon2id/PBKDF2 is CPU-intensive

**Solution**:
- This is expected (security vs performance trade-off)
- Operations run on isolates to avoid blocking UI
- Consider showing loading indicator

## FAQ

### General

**Q: What platforms are supported?**
A: Android 8.0+, iOS 14.0+, Web, macOS, Linux, Windows

**Q: Is my API key stored securely?**
A: Yes, using platform-native secure storage (Keychain on iOS, Keystore on Android) with hardware backing when available.

**Q: Are cloud backups encrypted?**
A: Yes, with AES-256-GCM client-side encryption before upload.

**Q: Can I use StyleSync without Firebase?**
A: No, Firebase is required for authentication and cloud backup.

### Security

**Q: What if I forget my backup passphrase?**
A: The backup becomes unrecoverable. You'll need to delete it and create a new one.

**Q: Can StyleSync developers see my API key?**
A: No, API keys are never transmitted to our servers and are encrypted client-side for backups.

**Q: Is Argon2id secure enough?**
A: Yes, Argon2id won the Password Hashing Competition and is recommended by security experts.

**Q: Why PBKDF2 on web instead of Argon2id?**
A: Argon2id is not available in browsers. PBKDF2 with 600,000 iterations provides adequate security.

### Development

**Q: How do I run tests?**
A: `flutter test` for all tests, or `flutter test path/to/test.dart` for specific tests.

**Q: How do I generate mocks?**
A: `dart run build_runner build --delete-conflicting-outputs`

**Q: What's the code coverage goal?**
A: 80% overall, 90%+ for core services, 95%+ for crypto.

**Q: How do I add a new dependency?**
A: Add to `pubspec.yaml` and run `flutter pub get`.

### Testing

**Q: Why use property-based testing?**
A: Property tests verify invariants across many inputs, catching edge cases that example-based tests miss.

**Q: What is Glados?**
A: Glados is a property-based testing library inspired by QuickCheck and Hypothesis.

**Q: How many property test iterations?**
A: Default is 100-200. Adjust based on test complexity and execution time.

## Getting Help

### Documentation
- Check this documentation site
- Review inline code comments
- See [AGENTS.md](../../AGENTS.md) for AI agent guidance

### Community
- File issues on GitHub
- Check existing issues for known problems
- Include logs and environment details in bug reports

### Debugging Tips
1. Enable verbose logging: `flutter run -v`
2. Check platform logs (Xcode Console, Android Logcat)
3. Use Flutter DevTools for debugging
4. Run with `--debug` to enable assertions

## Related Documentation

- [Getting Started](../project/getting-started.md) - Setup guide
- [Development Guidelines](../guidelines/development-guidelines.md) - Best practices
- [Testing Strategy](../testing/strategy.md) - Testing approach
