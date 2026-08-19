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

  /// The Phase 1 single-draft key. No longer written, but still read once
  /// on first load (see `DraftService._load`) to migrate a pre-multi-draft
  /// install's one saved draft into the indexed scheme below rather than
  /// discarding it.
  static const currentDraftId = 'current';

  /// The [DraftIndex] manifest — which draft ids exist and which is active.
  static const draftIndex = 'index';

  /// The per-draft storage key. Prefixed so it can never collide with
  /// [draftIndex] or a quarantined-payload key.
  static String draftEntry(String draftId) => 'draft_$draftId';
}
