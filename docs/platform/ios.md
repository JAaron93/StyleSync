# iOS Implementation

## Configuration

### Deployment Target

**File**: [`ios/Runner.xcodeproj/project.pbxproj`](../../ios/Runner.xcodeproj/project.pbxproj)

- **Min Deployment Target**: iOS 14.0

### Podfile

**File**: [`ios/Podfile`](../../ios/Podfile)

```ruby
platform :ios, '14.0'
```

### Firebase Configuration

Add `GoogleService-Info.plist` to `ios/Runner/` directory.

## Platform-Specific Features

### Secure Storage
- **Keychain**: iOS secure credential storage
- **Secure Enclave**: Hardware-backed keys (iPhone 5s+)
- **Accessibility**: `unlocked_this_device` for maximum security
- **No iCloud Sync**: Prevents cloud backup of sensitive data

### Cryptography
- **Argon2id**: Native support
- **Hardware AES**: Uses Secure Enclave when available
- **CryptoKit**: iOS native crypto framework

## Build Commands

```bash
# Debug build
flutter build ios --debug --no-codesign

# Release build (requires Apple Developer account)
flutter build ios --release

# Run on simulator
flutter run -d iphone

# Run on device
flutter run -d <device-id>
```

## Xcode Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set development team
3. Configure signing certificates
4. Set bundle identifier

## Troubleshooting

### Common Issues
- **Pod install failures**: Run `pod install --repo-update` in `ios/` directory
- **Signing errors**: Configure Apple Developer account in Xcode
- **Simulator issues**: Reset simulator and clean build

## Related Documentation

- [Getting Started](../project/getting-started.md) - Setup guide
- [Secure Storage](../core-services/secure-storage-service.md) - Keychain details
