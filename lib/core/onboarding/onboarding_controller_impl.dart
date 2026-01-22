import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_controller.dart';

/// Storage key used to persist the onboarding completion state.
const String _kOnboardingCompleteKey = 'onboarding_complete';

/// Implementation of [OnboardingController] using SharedPreferences.
///
/// This implementation persists the onboarding completion state to
/// SharedPreferences, ensuring the state survives app restarts.
/// All operations are thread-safe through the use of a Completer-based
/// lock mechanism.
class OnboardingControllerImpl implements OnboardingController {
  /// Creates an [OnboardingControllerImpl] instance.
  ///
  /// Optionally accepts a [SharedPreferences] instance for testing.
  /// If not provided, the instance will be obtained lazily on first use.
  OnboardingControllerImpl({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  SharedPreferences? _sharedPreferences;

  /// Completer used to ensure thread-safe initialization of SharedPreferences.
  Completer<SharedPreferences>? _initCompleter;

  /// Gets the SharedPreferences instance, initializing it if necessary.
  ///
  /// This method ensures thread-safe lazy initialization by using a
  /// Completer to prevent multiple simultaneous initialization attempts.
  Future<SharedPreferences> _getPrefs() async {
    if (_sharedPreferences != null) {
      return _sharedPreferences!;
    }

    // Use a completer to ensure only one initialization happens
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<SharedPreferences>();

    try {
      final prefs = await SharedPreferences.getInstance();
      _sharedPreferences = prefs;
      _initCompleter!.complete(prefs);
      return prefs;
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_kOnboardingCompleteKey) ?? false;
  }

  @override
  Future<void> markOnboardingComplete() async {
    final prefs = await _getPrefs();
    final success = await prefs.setBool(_kOnboardingCompleteKey, true);
    if (!success) {
      throw StateError('Failed to persist onboarding completion state');
    }
  }

  @override
  Future<void> resetOnboarding() async {
    final prefs = await _getPrefs();
    // remove() returns false if key doesn't exist, which is fine for reset
    await prefs.remove(_kOnboardingCompleteKey);
  }
}
