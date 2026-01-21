# StyleSync

## Prerequisites

- **Flutter SDK**: `^3.10.7`
- **Dart SDK**: Compatible with the above Flutter version
- **Homebrew** (optional, for easy SDK installation on macOS)

## Getting Started

1. Install the Flutter SDK.
2. Run `flutter pub get` to install dependencies.
3. Use `flutter run` to launch the application.

## Development Environment

### Gradle Configuration
The project is configured with optimized Gradle settings in `android/gradle.properties`:
- `org.gradle.jvmargs`: Set to `-Xmx4G` to balance build performance and system resource usage.
- `org.gradle.parallel`: Enabled for faster builds on multi-core systems.
- `org.gradle.caching`: Enabled to reuse build artifacts across runs.
