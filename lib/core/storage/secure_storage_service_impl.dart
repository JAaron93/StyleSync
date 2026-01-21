import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:platform/platform.dart';
import 'secure_storage_service.dart';

class SecureStorageServiceImpl implements SecureStorageService {
  late FlutterSecureStorage _storage;
  SecureStorageBackend _backend = SecureStorageBackend.software;
  bool _initialized = false;
  final FlutterSecureStorage? _injectedStorage;
  final SecureStorageBackend? _injectedBackend;
  final Platform _platform;

  SecureStorageServiceImpl({
    FlutterSecureStorage? storage,
    SecureStorageBackend? backend,
    Platform? platform,
  })  : _injectedStorage = storage,
        _injectedBackend = backend,
        _platform = platform ?? const LocalPlatform() {
    if (_injectedStorage != null) {
      _storage = _injectedStorage!;
      _backend = _injectedBackend ?? SecureStorageBackend.software;
      _initialized = true;
    } else {
      _init();
    }
  }

  Future<void> _init() async {
    if (_initialized) return;

    try {
      if (_platform.isAndroid) {
        // v10.0.0+ uses AES-GCM by default which is hardware-backed (TEE/StrongBox).
        // StrongBox is automatically used if available and falls back to TEE internally.
        _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            keyCipherAlgorithm: KeyCipherAlgorithm.AES_GCM_NoPadding,
            storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
            enforceBiometrics: false,
            resetOnError: true,
          ),
        );
        _backend = SecureStorageBackend.hardwareBacked;
        debugPrint('SecureStorage: Using Android Keystore (hardware-backed)');
      } else if (_platform.isIOS) {
        _storage = const FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.unlocked_this_device,
          ),
        );
        _backend = SecureStorageBackend.hardwareBacked;
        debugPrint('SecureStorage: Using iOS Keychain (Secure Enclave)');
      } else {
        _storage = const FlutterSecureStorage();
        _backend = SecureStorageBackend.software;
        debugPrint('SecureStorage: Using software-backed storage');
      }
    } catch (e) {
      debugPrint('SecureStorage: Initialization failed, using software fallback: $e');
      _storage = const FlutterSecureStorage();
      _backend = SecureStorageBackend.software;
    }

    _initialized = true;
  }

  @override
  Future<void> write(String key, String value) async {
    await _init();
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    await _init();
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _init();
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _init();
    await _storage.deleteAll();
  }

  @override
  SecureStorageBackend get backend => _backend;

  @override
  bool get requiresBiometric => false; // Biometric requires additional config/auth step, will implement in task 2.3
}
