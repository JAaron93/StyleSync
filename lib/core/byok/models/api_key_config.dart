/// Configuration for a stored Vertex AI API key.
///
/// This model represents the complete configuration for a user's API key,
/// including metadata about when it was created and validated.
class APIKeyConfig {
  /// The Vertex AI API key.
  final String apiKey;

  /// The Google Cloud project ID for Vertex AI requests.
  final String projectId;

  /// Timestamp when the key was first stored.
  final DateTime createdAt;

  /// Timestamp of the last successful validation.
  final DateTime lastValidated;

  /// Whether cloud backup is enabled for this key.
  final bool cloudBackupEnabled;

  /// Idempotency key for deduplication of operations.
  final String idempotencyKey;

  /// Creates a new [APIKeyConfig] instance.
  const APIKeyConfig({
    required this.apiKey,
    required this.projectId,
    required this.createdAt,
    required this.lastValidated,
    required this.cloudBackupEnabled,
    required this.idempotencyKey,
  });

  /// Serializes this configuration to a JSON map.
  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'projectId': projectId,
        'createdAt': createdAt.toIso8601String(),
        'lastValidated': lastValidated.toIso8601String(),
        'cloudBackupEnabled': cloudBackupEnabled,
        'idempotencyKey': idempotencyKey,
      };

  /// Creates an [APIKeyConfig] from a JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  factory APIKeyConfig.fromJson(Map<String, dynamic> json) {
    try {
      return APIKeyConfig(
        apiKey: json['apiKey'] as String,
        projectId: json['projectId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastValidated: DateTime.parse(json['lastValidated'] as String),
        cloudBackupEnabled: json['cloudBackupEnabled'] as bool,
        idempotencyKey: json['idempotencyKey'] as String,
      );
    } catch (e, stackTrace) {
      throw FormatException('Invalid APIKeyConfig JSON: $e\n$stackTrace');
    }
  }

  /// Creates a copy of this configuration with the given fields replaced.
  APIKeyConfig copyWith({
    String? apiKey,
    String? projectId,
    DateTime? createdAt,
    DateTime? lastValidated,
    bool? cloudBackupEnabled,
    String? idempotencyKey,
  }) =>
      APIKeyConfig(
        apiKey: apiKey ?? this.apiKey,
        projectId: projectId ?? this.projectId,
        createdAt: createdAt ?? this.createdAt,
        lastValidated: lastValidated ?? this.lastValidated,
        cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APIKeyConfig &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey &&
          projectId == other.projectId &&
          createdAt == other.createdAt &&
          lastValidated == other.lastValidated &&
          cloudBackupEnabled == other.cloudBackupEnabled &&
          idempotencyKey == other.idempotencyKey;

  @override
  int get hashCode => Object.hash(
        apiKey,
        projectId,
        createdAt,
        lastValidated,
        cloudBackupEnabled,
        idempotencyKey,
      );

  @override
  String toString() => 'APIKeyConfig('
      'projectId: $projectId, '
      'createdAt: $createdAt, '
      'lastValidated: $lastValidated, '
      'cloudBackupEnabled: $cloudBackupEnabled, '
      'idempotencyKey: $idempotencyKey)';
}
