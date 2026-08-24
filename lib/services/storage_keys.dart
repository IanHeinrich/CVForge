/// Centralised box/key names for [LocalStorageService]. Kept in one place
/// so a future JSON export/import feature reads from exactly the same
/// names services already write to.
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

  /// A remembered AI Assistant API key's own row, one per provider — never a
  /// field on [AppSettings] (see that model's doc comment). Kept in the
  /// same [StorageBoxes.settings] box `SettingsService` already owns.
  static String apiKeyFor(String providerId) => '$apiKeyPrefix$providerId';

  /// [apiKeyFor]'s prefix on its own, so `SettingsService` can find every
  /// remembered key at load via `LocalStorageService.keysWithPrefix`
  /// without being told which providers exist. Kept beside the builder it
  /// belongs to — the two must never drift.
  static const apiKeyPrefix = 'api_key_';

  /// The provider id encoded in an [apiKeyFor] row, or null if [key] isn't
  /// one. The inverse of [apiKeyFor], defined here so the encoding is
  /// described in exactly one place.
  static String? providerIdFromApiKey(String key) =>
      key.startsWith(apiKeyPrefix) && key.length > apiKeyPrefix.length
      ? key.substring(apiKeyPrefix.length)
      : null;

  /// The pre-pass [CvDraft] snapshot an AI Assistant tailoring pass writes
  /// before applying its result — a distinct prefix from [draftEntry], not
  /// a suffix on it, so nothing that enumerates drafts by scanning
  /// `draft_*` keys ever sees it. Kept in [StorageBoxes.drafts] alongside
  /// the draft it belongs to; superseded by the next pass, cleared when
  /// the draft is deleted.
  static String aiAssistantUndoFor(String draftId) =>
      'ai_assistant_undo_$draftId';

  /// `DriveSyncService`'s own bookkeeping rows — kept in
  /// [StorageBoxes.settings] alongside [appSettings] rather than a new
  /// box, since they're device-scoped preferences in exactly the same
  /// sense. Never the access token itself (that's in-memory only, the
  /// same rule `apiKeyFor`'s doc comment already establishes for the
  /// AI Assistant key) and never reachable through [AppSettings] or
  /// [CvBackupBundle], for the same "no secret-adjacent state in a
  /// serialized model" reasoning.
  static const driveEnabled = 'drive_enabled';
  static const driveFileId = 'drive_file_id';
  static const driveLastSyncedVersion = 'drive_last_synced_version';
  static const driveLastSyncedAt = 'drive_last_synced_at';
  static const driveAccountEmail = 'drive_account_email';

  /// The last bundle this device and Drive agreed on — the common ancestor
  /// `mergeBackupBundles` needs to tell "the other device added this" from
  /// "this device deleted it". Unlike its neighbours this is a whole
  /// serialized bundle, not a scalar: tens of KB, and [StorageBoxes.settings]
  /// is a non-lazy box, so it loads at boot alongside `app_settings`. That's
  /// affordable against a Vault of the same order already loading on the
  /// same path — but it's the row to move to its own lazy box if the bundle
  /// ever grows past that.
  static const driveSyncBase = 'drive_sync_base';
}
