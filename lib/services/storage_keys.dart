/// Centralised box/key names for [LocalStorageService]. Kept in one place
/// so a future JSON export/import feature (Phase 2) reads from exactly the
/// same names services already write to.
abstract final class StorageBoxes {
  const StorageBoxes._();

  static const vault = 'cvforge_vault';
  static const drafts = 'cvforge_drafts';

  /// Opened now, unused until Phase 2 (BYOK API keys, region preference).
  static const settings = 'cvforge_settings';
}

abstract final class StorageKeys {
  const StorageKeys._();

  /// The Vault is a single aggregate — one key.
  static const vaultProfile = 'profile';

  /// Phase 1 only ever has one draft; multi-draft support (Phase 2) just
  /// means using real draft ids as keys instead of always this constant.
  static const currentDraftId = 'current';
}
