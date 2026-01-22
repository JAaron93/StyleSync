/// Storage keys used by BYOKManager.
///
/// These constants define the keys used to store BYOK-related data
/// in secure storage.
abstract final class BYOKStorageKeys {
  /// Key for the API key configuration in secure storage.
  static const String apiKeyConfig = 'stylesync_api_key_config';

  /// Key for the cloud backup passphrase hash (for verification).
  static const String backupPassphraseHash = 'stylesync_backup_passphrase_hash';

  /// Key for the cloud backup enabled flag.
  static const String cloudBackupEnabled = 'stylesync_cloud_backup_enabled';
}
