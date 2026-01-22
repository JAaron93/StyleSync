import '../../crypto/kdf_metadata.dart';

/// Encrypted backup blob structure for cloud storage.
///
/// This model represents the encrypted API key backup stored in Firebase Storage.
/// It contains all the information needed to decrypt the backup, including
/// KDF parameters and the encrypted data itself.
class CloudBackupBlob {
  /// Schema version for forward compatibility.
  ///
  /// Increment this when making breaking changes to the blob format.
  final int version;

  /// KDF metadata (algorithm, salt, parameters).
  ///
  /// Contains all the parameters needed to derive the decryption key
  /// from the user's passphrase.
  final KdfMetadata kdfMetadata;

  /// Base64-encoded encrypted data (nonce + ciphertext + MAC).
  ///
  /// The encrypted payload containing the serialized [APIKeyConfig].
  final String encryptedData;

  /// Timestamp when the backup was created.
  final DateTime createdAt;

  /// Timestamp when the backup was last updated.
  final DateTime updatedAt;

  /// Creates a new [CloudBackupBlob] instance.
  const CloudBackupBlob({
    required this.version,
    required this.kdfMetadata,
    required this.encryptedData,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The current schema version.
  ///
  /// Used when creating new backups to ensure they use the latest format.
  static const int currentVersion = 1;

  /// Serializes this blob to a JSON map.
  ///
  /// The resulting map can be stored as JSON in Firebase Storage.
  Map<String, dynamic> toJson() => {
        'version': version,
        'kdf': kdfMetadata.toJson(),
        'encrypted_data': encryptedData,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Creates a [CloudBackupBlob] from a JSON map.
  ///
  /// Throws [FormatException] if:
  /// - The JSON is malformed or missing required fields
  /// - The version is newer than [currentVersion] (unsupported)
  /// - The KDF metadata is invalid
  factory CloudBackupBlob.fromJson(Map<String, dynamic> json) {
    // Validate required keys
    for (final key in ['version', 'kdf', 'encrypted_data', 'created_at', 'updated_at']) {
      if (!json.containsKey(key)) {
        throw FormatException('Missing required key: $key');
      }
    }

    // Validate version
    final version = json['version'];
    if (version is! int) {
      throw const FormatException('version must be an integer');
    }
    if (version > currentVersion) {
      throw FormatException(
        'Backup version $version is not supported. '
        'Please update the app to restore this backup.',
      );
    }
    if (version < 1) {
      throw FormatException('Invalid backup version: $version');
    }

    // Parse KDF metadata
    final kdfJson = json['kdf'];
    if (kdfJson is! Map<String, dynamic>) {
      throw const FormatException('kdf must be a JSON object');
    }
    final kdfMetadata = KdfMetadata.fromJson(kdfJson);

    // Validate encrypted data
    final encryptedData = json['encrypted_data'];
    if (encryptedData is! String || encryptedData.isEmpty) {
      throw const FormatException('encrypted_data must be a non-empty string');
    }

    // Parse timestamps
    DateTime parseTimestamp(String key) {
      final value = json[key];
      if (value is! String) {
        throw FormatException('$key must be a string');
      }
      try {
        return DateTime.parse(value);
      } catch (e) {
        throw FormatException('Invalid timestamp for $key: $value');
      }
    }

    return CloudBackupBlob(
      version: version,
      kdfMetadata: kdfMetadata,
      encryptedData: encryptedData,
      createdAt: parseTimestamp('created_at'),
      updatedAt: parseTimestamp('updated_at'),
    );
  }

  /// Creates a copy of this blob with the given fields replaced.
  CloudBackupBlob copyWith({
    int? version,
    KdfMetadata? kdfMetadata,
    String? encryptedData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CloudBackupBlob(
        version: version ?? this.version,
        kdfMetadata: kdfMetadata ?? this.kdfMetadata,
        encryptedData: encryptedData ?? this.encryptedData,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudBackupBlob &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          kdfMetadata == other.kdfMetadata &&
          encryptedData == other.encryptedData &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      Object.hash(version, kdfMetadata, encryptedData, createdAt, updatedAt);

  @override
  String toString() => 'CloudBackupBlob('
      'version: $version, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
