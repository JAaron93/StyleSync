# Development Guidelines

## Code Style

### Dart Formatting
```bash
# Format all code
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

### Linting
```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

## Project Structure

### Organization
- **`lib/core/`**: Foundational services and infrastructure
- **`lib/features/`**: Feature implementations with UI
- **`test/`**: All test files mirror `lib/` structure

### File Naming
- **Dart files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/functions**: `camelCase`
- **Constants**: `lowerCamelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants

## Import Organization

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:riverpod/riverpod.dart';

// 4. Local imports
import 'package:stylesync/core/byok/byok_manager.dart';
```

## State Management

### Use Riverpod Providers
```dart
// Define provider
final myServiceProvider = Provider<MyService>((ref) {
  return MyServiceImpl();
});

// Use in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(myServiceProvider);
    return Text('Data: ${service.data}');
  }
}
```

### Provider Types
- **Provider**: Immutable, synchronous
- **FutureProvider**: Async initialization
- **StateNotifierProvider**: Mutable state
- **StreamProvider**: Reactive streams

## Error Handling

### Use Result Types
```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final Exception error;
  const Failure(this.error);
}
```

### Handle All Cases
```dart
final result = await service.operation();
switch (result) {
  case Success(value: final data):
    handleSuccess(data);
  case Failure(error: final error):
    handleError(error);
}
```

## Testing Guidelines

### Write Tests First
- Property tests for invariants
- Unit tests for individual methods
- Widget tests for UI components

### Mock Dependencies
```dart
@GenerateMocks([DependencyClass])
void main() {
  late MockDependencyClass mockDep;
  
  setUp(() {
    mockDep = MockDependencyClass();
  });
  
  test('description', () {
    when(mockDep.method()).thenReturn(value);
    // test code
  });
}
```

### Coverage
Run tests with coverage before submitting PR:
```bash
flutter test --coverage
```

## Documentation

### Code Comments
```dart
/// Brief description of what this does.
///
/// Detailed explanation if needed.
/// Can span multiple lines.
///
/// Parameters:
/// - [param1]: Description of param1
/// 
/// Returns: Description of return value
/// 
/// Throws: [Exception] when error occurs
ReturnType methodName(ParamType param1) {
  // implementation
}
```

### When to Comment
- **Public APIs**: Always document
- **Complex Logic**: Explain why, not what
- **Workarounds**: Explain temporary solutions
- **TODOs**: Track technical debt

## Security Guidelines

### Never Log Sensitive Data
```dart
// ❌ BAD
print('API Key: $apiKey');

// ✅ GOOD
print('API Key stored successfully');
```

### Clear Sensitive Data
```dart
// Clear after use
try {
  final result = await processKey(apiKey);
  return result;
} finally {
  apiKey = '';  // Clear sensitive data
}
```

### Use Secure Storage
```dart
// For API keys, tokens, passwords
await secureStorage.write(key: 'api_key', value: apiKey);

// For non-sensitive flags, preferences
await prefs.setBool('onboarding_complete', true);
```

## Performance Guidelines

### Minimize Rebuilds
- Use `const` constructors
- Split widgets appropriately
- Use `select` to watch specific values

### Async Operations
```dart
// Run heavy operations on isolates
Future<Result> compute(heavyFunction, data);

// Use FutureBuilder/AsyncValue for UI
ref.watch(futureProvider).when(
  data: (data) => DisplayWidget(data),
  loading: () => LoadingWidget(),
  error: (err, stack) => ErrorWidget(err),
);
```

## Code Review Checklist

- [ ] Code follows style guide
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No sensitive data logged
- [ ] Error handling comprehensive
- [ ] Performance considered
- [ ] Security best practices followed
- [ ] No breaking changes (or documented)

## Workflow

### Before Committing
1. Format code: `dart format .`
2. Run analyzer: `flutter analyze`
3. Run tests: `flutter test`
4. Check coverage: `flutter test --coverage`

### Commit Messages
```
feat: Add cloud backup service
fix: Resolve keychain access issue
docs: Update BYOK manager documentation
test: Add property tests for encryption
refactor: Extract validation logic
```

### Pull Requests
- Keep changes focused and minimal
- Link related issues
- Provide context in description
- Request reviews from relevant team members

## Common Patterns

### Dependency Injection
```dart
// Define interface
abstract class MyService {
  Future<void> operation();
}

// Implementation
class MyServiceImpl implements MyService {
  final Dependency _dep;
  
  MyServiceImpl({required Dependency dep}) : _dep = dep;
  
  @override
  Future<void> operation() async {
    // use _dep
  }
}

// Provider
final myServiceProvider = Provider<MyService>((ref) {
  final dep = ref.read(dependencyProvider);
  return MyServiceImpl(dep: dep);
});
```

### Platform Detection
```dart
import 'package:platform/platform.dart';

class ServiceImpl {
  final Platform _platform;
  
  ServiceImpl({Platform? platform})
      : _platform = platform ?? const LocalPlatform();
  
  void doSomething() {
    if (_platform.isAndroid) {
      // Android-specific
    } else if (_platform.isIOS) {
      // iOS-specific
    }
  }
}
```

## Related Documentation

- [Testing Strategy](../testing/strategy.md) - Testing guidelines
- [Architecture Overview](../architecture/overview.md) - System design
- [AGENTS.md](../../AGENTS.md) - Agent guidance
