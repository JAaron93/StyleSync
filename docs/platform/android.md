# Android Implementation

## Configuration

### Min SDK

**File**: [`android/app/build.gradle.kts`](../../android/app/build.gradle.kts)

```kotlin
minSdk = 24  // Android 8.0+
```

### Gradle Configuration

**File**: [`android/gradle.properties`](../../android/gradle.properties)

Optimized settings for performance:

```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G
org.gradle.parallel=true
org.gradle.caching=true
```

### Firebase Configuration

Add `google-services.json` to `android/app/` directory.

## Platform-Specific Features

### Secure Storage
- **Android Keystore**: System-wide credential storage
- **StrongBox**: Hardware security module (Android 9+, Pixel 3+)
- **TEE (Trusted Execution Environment)**: Hardware-backed keys
- **AES-GCM**: Authenticated encryption for data

### Backend Priority
1. StrongBox (dedicated HSM)
2. Hardware-backed TEE
3. Software fallback

### Cryptography
- **Argon2id**: Native support
- **Hardware AES**: AES-NI acceleration when available

## Build Commands

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release

# Run on device/emulator
flutter run
```

## Signing (Release)

Create `android/key.properties`:

```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=<key-alias>
storeFile=<path-to-keystore>
```

## Troubleshooting

### Common Issues
- **No Android SDK**: Install Android Studio or SDK tools
- **Gradle build failures**: Run `./gradlew clean` in `android/` directory
- **Keystore errors**: Verify key.properties configuration

### Performance
- **First build slow**: Gradle downloads dependencies
- **Incremental builds**: Fast due to caching

## Related Documentation

- [Getting Started](../project/getting-started.md) - Setup guide
- [Secure Storage](../core-services/secure-storage-service.md) - Keystore details
