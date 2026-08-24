/// Centralised box/key names for [LocalStorageService], so every reader
/// and writer of a row agrees on its name.
abstract final class StorageBoxes {
  const StorageBoxes._();

  static const vault = 'cvforge_vault';
  static const drafts = 'cvforge_drafts';

  static const settings = 'cvforge_settings';
}

abstract final class StorageKeys {
  const StorageKeys._();

  /// The Vault and Settings are each a single aggregate under one key.
  static const vaultProfile = 'profile';
  static const appSettings = 'app_settings';

  /// The original single-draft key. No longer written, but still read
  /// once on first load to migrate an old install into the scheme below.
  static const currentDraftId = 'current';

  /// The [DraftIndex] manifest — which draft ids exist and which is active.
  static const draftIndex = 'index';

  /// The per-draft storage key. Prefixed so it can never collide with
  /// [draftIndex] or a quarantined-payload key.
  static String draftEntry(String draftId) => 'draft_$draftId';

  /// A remembered AI Assistant API key's own row, one per provider —
  /// never a field on [AppSettings] (see that model's doc comment).
  static String apiKeyFor(String providerId) => '$apiKeyPrefix$providerId';

  /// [apiKeyFor]'s prefix on its own, so `SettingsService` can find every
  /// remembered key at load without being told which providers exist.
  static const apiKeyPrefix = 'api_key_';

  /// The inverse of [apiKeyFor], or null if [key] isn't one — here so the
  /// encoding lives in one place.
  static String? providerIdFromApiKey(String key) =>
      key.startsWith(apiKeyPrefix) && key.length > apiKeyPrefix.length
      ? key.substring(apiKeyPrefix.length)
      : null;

  /// The pre-pass [CvDraft] snapshot an AI Assistant tailoring pass writes
  /// before applying its result. A distinct prefix from [draftEntry], not
  /// a suffix, so a scan of `draft_*` keys never sees it.
  static String aiAssistantUndoFor(String draftId) =>
      'ai_assistant_undo_$draftId';

  /// The same for a translation pass, in a **separate** slot: each pass
  /// restores to the state before itself, so sharing one key would have
  /// "Undo AI changes" silently undo a translation.
  static String cvTranslationUndoFor(String draftId) =>
      'cv_translation_undo_$draftId';

  /// `DriveSyncService`'s own bookkeeping — device-scoped preferences, so
  /// they sit alongside [appSettings]. Never the access token, which is
  /// in-memory only, and never reachable through [AppSettings] or
  /// [CvBackupBundle].
  static const driveEnabled = 'drive_enabled';
  static const driveFileId = 'drive_file_id';
  static const driveLastSyncedVersion = 'drive_last_synced_version';
  static const driveLastSyncedAt = 'drive_last_synced_at';
  static const driveAccountEmail = 'drive_account_email';

  /// The last bundle this device and Drive agreed on — the common ancestor
  /// `mergeBackupBundles` needs to tell "the other device added this" from
  /// "this device deleted it".
  ///
  /// Unlike its neighbours this is a whole serialized bundle, tens of KB,
  /// in a non-lazy box, so it loads at boot. Affordable against a Vault of
  /// the same order on the same path — but it is the row to move to its
  /// own lazy box if the bundle grows past that.
  static const driveSyncBase = 'drive_sync_base';
}
