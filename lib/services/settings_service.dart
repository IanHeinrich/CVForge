import 'dart:convert';

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/settings/app_theme_mode.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/persisted_store.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/app/app.locator.dart';

/// Where a provider's API key currently lives, and therefore how long it
/// will last. The distinction is the whole point: [session] and
/// [remembered] behave identically until the tab reloads, at which point
/// one of them silently isn't there any more. Settings renders all three
/// states differently rather than letting a user discover the difference
/// from a failed run.
///
/// A bare enum beside the service that produces it, matching
/// `GoogleAuthFailure` in `google_auth_service.dart` and `DriveApiFailure`
/// in `drive_api_client_service.dart`.
enum ApiKeyOrigin {
  /// No key for this provider, in memory or on disk. The AI Assistant
  /// cannot run.
  none,

  /// In memory only — works now, gone on reload. No longer something a
  /// user can choose: [SettingsService.setApiKey] always tries to persist,
  /// so this means the write actually failed (storage unavailable), and
  /// the UI says so rather than implying the key is safely saved.
  session,

  /// Persisted to this device's storage and rehydrated at load. The normal
  /// outcome of a successful connection test.
  remembered,
}

/// Owns device-scoped [AppSettings] — same single-aggregate,
/// [PersistedStoreMixin] shape as `VaultService`, plus (from 4.4) a
/// per-provider AI Assistant API key kept deliberately off the [AppSettings]
/// model itself (see that model's doc comment for why).
class SettingsService
    with ListenableServiceMixin, PersistedStoreMixin<AppSettings> {
  SettingsService() {
    listenToReactiveValues([_settings, _apiKeyOrigins, persistErrorNotifier]);
  }

  /// Not locator-registered — see `LlmService`'s own doc comment for why
  /// (stateless, deterministic, nothing else needs one injected).
  final _providers = LlmProviderRegistry();

  final _localStorage = locator<LocalStorageService>();

  @override
  LocalStorageService get storage => _localStorage;

  final ReactiveValue<AppSettings> _settings = ReactiveValue<AppSettings>(
    AppSettings.empty(),
  );
  AppSettings get settings => _settings.value;

  /// Explicit load, called once from `SettingsViewModel.initialise`. Safe
  /// to call multiple times — every read/write path awaits the same
  /// underlying future via [ready].
  Future<void> load() => ready();

  /// Every portable-preference mutator routes through here so
  /// [CvPreferences.updatedAt] is stamped in exactly one place — it's the
  /// tie-break when two devices have both changed their settings, and a
  /// mutator that forgot to stamp it would silently always lose.
  void _setPreferences(CvPreferences Function(CvPreferences current) update) {
    _settings.value = _settings.value.copyWith(
      preferences: update(
        _settings.value.preferences,
      ).copyWith(updatedAt: DateTime.now()),
    );
    scheduleWrite(_settings.value);
  }

  Future<void> setAiAssistantProvider(String? providerId) async {
    await ready();
    _setPreferences((p) => p.copyWith(aiAssistantProviderId: providerId));
  }

  Future<void> setAiAssistantModel(String? modelId) async {
    await ready();
    _setPreferences((p) => p.copyWith(aiAssistantModelId: modelId));
  }

  /// Replaces the portable half wholesale — the apply path for a Drive
  /// sync or a backup import. Keeps the incoming [CvPreferences.updatedAt]
  /// rather than stamping now, for the same reason `VaultService.
  /// replaceAll` preserves the vault's: adopting someone else's state
  /// isn't an edit, and re-stamping would rig the next tie-break.
  Future<void> replacePreferences(CvPreferences preferences) async {
    await ready();
    await persistNow(_settings.value);
    _settings.value = _settings.value.copyWith(preferences: preferences);
    await persistImmediately(_settings.value);
  }

  Future<void> setLastBackupAt(DateTime value) async {
    await ready();
    _settings.value = _settings.value.copyWith(lastBackupAt: value);
    scheduleWrite(_settings.value);
  }

  /// Deliberately not routed through [_setPreferences]. The theme is
  /// device-scoped (see [AppSettings.themeMode]), and stamping
  /// [CvPreferences.updatedAt] for it would let a device that only changed
  /// its theme win an unrelated preferences tie-break and overwrite
  /// another device's region or section defaults.
  Future<void> setThemeMode(AppThemeMode mode) async {
    await ready();
    _settings.value = _settings.value.copyWith(themeMode: mode);
    scheduleWrite(_settings.value);
  }

  /// Only the default a *new* draft is created with (`DraftService.
  /// createDraft`'s own `_settings.settings.preferences.defaultRegion` read) — never
  /// touches any existing draft's own `CvDraft.region`, the same way
  /// changing [setDefaultSectionSettings] never rewrites a draft already
  /// created from the old default.
  Future<void> setDefaultRegion(RegionProfile region) async {
    await ready();
    _setPreferences((p) => p.copyWith(defaultRegion: region));
  }

  /// Sets the remembered default section order and hidden-sections state
  /// together, in one write rather than two separate calls — see
  /// `AppSettings.defaultSectionOrder`/`defaultHiddenSections` and
  /// `DraftService.createDraft`'s doc comment. The pair is always saved
  /// (and reset) together from the same Studio action, so there's no
  /// legitimate call site that would ever want to update just one.
  /// The app chrome's language. Null restores "follow the browser", which is
  /// the default — see [CvPreferences.localeTag] for why an explicit choice
  /// is the only thing that syncs.
  ///
  /// Never touches what the *document* is written in; that stays English.
  Future<void> setLocaleTag(String? tag) async {
    await ready();
    _setPreferences((p) => p.copyWith(localeTag: tag));
  }

  Future<void> setDefaultSectionSettings({
    required List<CvSectionType> order,
    required Set<CvSectionType> hiddenSections,
  }) async {
    await ready();
    _setPreferences(
      (p) => p.copyWith(
        defaultSectionOrder: order,
        defaultHiddenSections: hiddenSections,
      ),
    );
  }

  /// The key values themselves: in-memory only, deliberately **not**
  /// reactive, and never part of [AppSettings] (decision 13: a secret must
  /// not be reachable through any code path that serialises settings,
  /// including a backup export).
  ///
  /// Split from [_apiKeyOrigins] on purpose. Settings needs to rebuild when
  /// a key appears or disappears, but a secret has no business sitting in a
  /// `ReactiveValue` that broadcasts its contents to every listener — so
  /// the *set of provider ids and where their key lives* is reactive, and
  /// the keys are not.
  final Map<String, String> _sessionApiKeys = {};

  /// Which providers have a key and how durably — the reactive half of the
  /// pair above. Absent means [ApiKeyOrigin.none].
  final ReactiveValue<Map<String, ApiKeyOrigin>> _apiKeyOrigins =
      ReactiveValue<Map<String, ApiKeyOrigin>>(const {});

  /// Whether [providerId] has a usable key, and whether it survives a
  /// reload. Synchronous and safe to call from `build` — every key row is
  /// hydrated by [loadFromStorage], so this never needs to hit storage.
  ApiKeyOrigin apiKeyOriginFor(String providerId) =>
      _apiKeyOrigins.value[providerId] ?? ApiKeyOrigin.none;

  /// A display-safe fingerprint of the stored key — bullets plus its last
  /// four characters, the same affordance every API console uses. Enough to
  /// tell *which* key is loaded without putting the secret back on screen.
  /// Null when there's no key.
  String? maskedApiKeyFor(String providerId) {
    final key = _sessionApiKeys[providerId];
    if (key == null || key.isEmpty) return null;
    const bullets = '••••••••';
    return key.length <= 4
        ? bullets
        : '$bullets${key.substring(key.length - 4)}';
  }

  void _setApiKeyOrigin(String providerId, ApiKeyOrigin origin) {
    final next = Map<String, ApiKeyOrigin>.from(_apiKeyOrigins.value);
    if (origin == ApiKeyOrigin.none) {
      next.remove(providerId);
    } else {
      next[providerId] = origin;
    }
    _apiKeyOrigins.value = next;
  }

  /// Reads the in-memory key. Kept `Future`-returning because it awaits
  /// [ready]: a caller reaching this before the initial load (the AI
  /// Assistant run dialog on a deep-linked `/studio` refresh) would
  /// otherwise see an un-hydrated empty map and report "no key" for a key
  /// that is sitting in storage.
  Future<String?> apiKeyFor(String providerId) async {
    await ready();
    return _sessionApiKeys[providerId];
  }

  /// Saves [key] to this device, and keeps it in memory for this session
  /// regardless.
  ///
  /// Persisting is unconditional. It used to be gated on a "Remember on
  /// this device" checkbox that defaulted to *off*, which made the default
  /// experience "your key silently vanishes when you reload" — and singled
  /// the key out for an opt-in that the Vault and every CV, sitting in the
  /// same unencrypted IndexedDB, never asked for. The storage caveat is
  /// still stated in the UI; it just isn't a control any more.
  ///
  /// A failed write is not fatal: the key stays usable for this session and
  /// is reported as [ApiKeyOrigin.session] so the UI can say so. That case
  /// is real rather than defensive — `LocalStorageService` documents
  /// IndexedDB being genuinely unavailable under Firefox's strict privacy
  /// mode, and letting the exception escape here would surface as an
  /// unhandled error from the button that had just reported success.
  Future<void> setApiKey(String providerId, String key) async {
    await ready();
    _sessionApiKeys[providerId] = key;
    try {
      await _localStorage.write(
        StorageBoxes.settings,
        StorageKeys.apiKeyFor(providerId),
        key,
      );
      _setApiKeyOrigin(providerId, ApiKeyOrigin.remembered);
    } catch (_) {
      _setApiKeyOrigin(providerId, ApiKeyOrigin.session);
    }
  }

  /// Removes [providerId]'s key from memory and deletes its storage row
  /// immediately, not on the next write.
  Future<void> clearApiKey(String providerId) async {
    _sessionApiKeys.remove(providerId);
    await _localStorage.delete(
      StorageBoxes.settings,
      StorageKeys.apiKeyFor(providerId),
    );
    _setApiKeyOrigin(providerId, ApiKeyOrigin.none);
  }

  /// The provider the AI Assistant is currently set to use.
  ///
  /// Resolved here rather than in each ViewModel that needs it, because
  /// three of them did exactly this and a fourth was about to. Falls back
  /// to [LlmProviderRegistry.defaultProvider] when nothing is stored, or
  /// when a stored id no longer resolves (a provider removed between
  /// releases) — mirroring [LlmProviderRegistry.byId]'s own never-throw
  /// contract, since a settings read must never crash a build.
  LlmProvider get selectedAiAssistantProvider =>
      _providers.byId(settings.preferences.aiAssistantProviderId ?? '');

  /// The model within [selectedAiAssistantProvider], with the same
  /// never-throw fallback: the provider's first option when nothing is
  /// stored, or when a stored id no longer exists — a model retired
  /// between releases, or simply belonging to a different provider than
  /// the one now selected. The Settings dropdown *requires* this, since a
  /// value absent from its own item list throws at build time.
  LlmModelOption get selectedAiAssistantModel {
    final storedId = settings.preferences.aiAssistantModelId;
    final models = selectedAiAssistantProvider.models;
    return models.firstWhere(
      (m) => m.id == storedId,
      orElse: () => models.first,
    );
  }

  /// Stamped the first time a connection test succeeds anywhere — see
  /// [CvPreferences.aiAssistantConfiguredAt]. Deliberately write-once: it
  /// records that setup has happened, so re-testing an existing key
  /// shouldn't keep moving the date, and it survives removing a key.
  Future<void> markAiAssistantConfigured() async {
    await ready();
    if (settings.preferences.aiAssistantConfiguredAt != null) return;
    _setPreferences((p) => p.copyWith(aiAssistantConfiguredAt: DateTime.now()));
  }

  @override
  Future<void> loadFromStorage() async {
    await _localStorage.ensureInitialized();
    await _loadRememberedApiKeys();
    final raw = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.appSettings,
    );
    if (raw == null) {
      _settings.value = AppSettings.empty();
      return;
    }
    try {
      _settings.value = _migrate(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await quarantine(StorageBoxes.settings, StorageKeys.appSettings, raw);
      _settings.value = AppSettings.empty();
    }
  }

  /// Pulls every `api_key_*` row into memory up front, so
  /// [apiKeyOriginFor] can be a synchronous `build`-safe read. Enumerating
  /// rather than looping over known provider ids means a key belonging to
  /// a since-removed provider is still found — and so can still be cleared
  /// by [clearApiKey] — instead of being orphaned on disk forever.
  Future<void> _loadRememberedApiKeys() async {
    final keys = await _localStorage.keysWithPrefix(
      StorageBoxes.settings,
      StorageKeys.apiKeyPrefix,
    );
    final origins = <String, ApiKeyOrigin>{};
    for (final storageKey in keys) {
      final providerId = StorageKeys.providerIdFromApiKey(storageKey);
      if (providerId == null) continue;
      final value = await _localStorage.read(StorageBoxes.settings, storageKey);
      if (value == null || value.isEmpty) continue;
      _sessionApiKeys[providerId] = value;
      origins[providerId] = ApiKeyOrigin.remembered;
    }
    if (origins.isNotEmpty) _apiKeyOrigins.value = origins;
  }

  AppSettings _migrate(Map<String, dynamic> json) {
    requireSchemaVersion(json, 'settings');
    return AppSettings.fromJson(json);
  }

  @override
  Future<void> writeToStorage(AppSettings value) => _localStorage.write(
    StorageBoxes.settings,
    StorageKeys.appSettings,
    jsonEncode(value.toJson()),
  );
}
