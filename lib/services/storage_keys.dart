/// Centralised box/key names for [LocalStorageService]. Kept in one place
/// so a future JSON export/import feature (Phase 2) reads from exactly the
/// same names services already write to.
abstract final class StorageBoxes {
  const StorageBoxes._();

  static const vault = 'cvforge_vault';
  static const drafts = 'cvforge_drafts';

  /// Backs `SettingsService`'s [AppSettings] row (see [StorageKeys.appSettings])
  /// — lazily opened like every other box.
  static const settings = 'cvforge_settings';
}

abstract final class StorageKeys {
  const StorageKeys._();

  /// The Vault is a single aggregate — one key.
  static const vaultProfile = 'profile';

  /// The Settings aggregate is also a single key — same "one JSON string
  /// under a named key" shape as [vaultProfile].
  static const appSettings = 'app_settings';

  /// The original single-draft key, from before multiple drafts existed.
  /// No longer written, but still read once on first load (see
  /// `DraftService.loadFromStorage`) to migrate a pre-multi-draft
  /// install's one saved draft into the indexed scheme below rather than
  /// discarding it.
  static const currentDraftId = 'current';

  /// The [DraftIndex] manifest — which draft ids exist and which is active.
  static const draftIndex = 'index';

  /// The per-draft storage key. Prefixed so it can never collide with
  /// [draftIndex] or a quarantined-payload key.
  static String draftEntry(String draftId) => 'draft_$draftId';

  /// A remembered Copilot API key's own row, one per provider — never a
  /// field on [AppSettings] (see that model's doc comment). Kept in the
  /// same [StorageBoxes.settings] box `SettingsService` already owns.
  static String apiKeyFor(String providerId) => 'api_key_$providerId';
}
