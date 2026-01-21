# WARP.md

This file provides guidance to software engineering agents when working with code in this repository.

## Project Overview
StyleSync is a Flutter application leveraging Firebase for backend services and Riverpod for state management. The project places a strong emphasis on security (cryptography, secure storage) and testing (property-based testing).

## Common Commands

### Setup & Dependencies
- **Install dependencies**: `flutter pub get`
- **Update dependencies**: `flutter pub upgrade`

### Development
- **Run App**: `flutter run`
- **Code Generation**: `dart run build_runner build --delete-conflicting-outputs`
  - Run this when modifying files that use code generation (e.g., Mockito mocks).
- **Format Code**: `dart format .`
- **Lint Code**: `flutter analyze`

### Testing
This project uses `flutter_test` for unit tests and `glados` for property-based testing.
- **Run All Tests**: `flutter test`
- **Run Specific Test**: `flutter test test/path/to/test.dart`
- **Update Mocks**: Run the code generation command.

## Architecture & Structure

### Core Components
- **`lib/core/`**: Contains foundational services and infrastructure code.
  - **`crypto/`**: Encryption and key derivation services.
  - **`storage/`**: Secure storage implementations (Hardware/Software backed).

### State Management
- Uses **Riverpod** (`flutter_riverpod`).
- Providers should be used to manage state and dependency injection.

### Testing Strategy
- **Unit Tests**: Located in `test/`. Use `mockito` for mocking dependencies.
- **Property-based Tests**: Uses `glados`. Look for files ending in `_properties_test.dart` or `_property_test.dart`.
  - When writing logic involving complex state transitions or cryptography, prefer adding property-based tests.

## Development Guidelines

### General
- **Imports**: Keep imports tidy and remove unused ones.
- **Readability**: Prefer readability over cleverness.
- **Documentation**: Update documentation when behavior or configuration changes.

### Platform Specifics
- **Consistency**: Ensure platform-specific configurations (Android/iOS) remain consistent after edits.
- **Android Build**: The project uses optimized Gradle settings (`android/gradle.properties`) for performance (parallel builds, caching, JVM args).

### Workflow
- **Code Reviews**: Inspect relevant files before editing. Explain changes and rationale.
- **Scope**: Keep changes focused and minimal. Avoid unrelated refactors.
