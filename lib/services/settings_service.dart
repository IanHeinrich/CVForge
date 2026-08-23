import 'dart:convert';

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/persisted_store.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/app/app.locator.dart';

/// Owns device-scoped [AppSettings] — same single-aggregate,
/// [PersistedStoreMixin] shape as `VaultService`, plus (from 4.4) a
/// per-provider Copilot API key kept deliberately off the [AppSettings]
/// model itself (see that model's doc comment for why).
class SettingsService
    with ListenableServiceMixin, PersistedStoreMixin<AppSettings> {
  SettingsService() {
    listenToReactiveValues([_settings, persistErrorNotifier]);
  }

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

  Future<void> setCopilotProvider(String? providerId) async {
    await ready();
    _settings.value = _settings.value.copyWith(copilotProviderId: providerId);
    scheduleWrite(_settings.value);
  }

  Future<void> setCopilotModel(String? modelId) async {
    await ready();
    _settings.value = _settings.value.copyWith(copilotModelId: modelId);
    scheduleWrite(_settings.value);
  }

  Future<void> setLastBackupAt(DateTime value) async {
    await ready();
    _settings.value = _settings.value.copyWith(lastBackupAt: value);
    scheduleWrite(_settings.value);
  }

  Future<void> setRememberApiKey(bool value) async {
    await ready();
    _settings.value = _settings.value.copyWith(rememberApiKey: value);
    scheduleWrite(_settings.value);
  }

  /// Sets the remembered default section order and hidden-sections state
  /// together, in one write rather than two separate calls — see
  /// `AppSettings.defaultSectionOrder`/`defaultHiddenSections` and
  /// `DraftService.createDraft`'s doc comment. The pair is always saved
  /// (and reset) together from the same Studio action, so there's no
  /// legitimate call site that would ever want to update just one.
  Future<void> setDefaultSectionSettings({
    required List<CvSectionType> order,
    required Set<CvSectionType> hiddenSections,
  }) async {
    await ready();
    _settings.value = _settings.value.copyWith(
      defaultSectionOrder: order,
      defaultHiddenSections: hiddenSections,
    );
    scheduleWrite(_settings.value);
  }

  /// In-memory only — never reactive, since a key changing never needs to
  /// trigger a rebuild by itself, and never part of [AppSettings] (decision
  /// 13: a secret must not be reachable through any code path that
  /// serialises settings, including a future backup export).
  final Map<String, String> _sessionApiKeys = {};

  /// Reads the in-memory key first; for a remembered key that hasn't been
  /// loaded into memory yet this session (e.g. right after startup), falls
  /// back to [StorageKeys.apiKeyFor] and caches the result.
  Future<String?> apiKeyFor(String providerId) async {
    final cached = _sessionApiKeys[providerId];
    if (cached != null) return cached;
    final stored = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.apiKeyFor(providerId),
    );
    if (stored != null) _sessionApiKeys[providerId] = stored;
    return stored;
  }

  /// Always kept in memory for the rest of this session; additionally
  /// persisted only when [AppSettings.rememberApiKey] is on — see that
  /// field's doc comment. Awaits [ready] first because that flag is read
  /// from loaded settings: without it, a call landing before the initial
  /// load sees a default-empty `rememberApiKey: false` and silently
  /// declines to persist a key the user did ask to remember.
  Future<void> setApiKey(String providerId, String key) async {
    await ready();
    _sessionApiKeys[providerId] = key;
    if (settings.rememberApiKey) {
      await _localStorage.write(
        StorageBoxes.settings,
        StorageKeys.apiKeyFor(providerId),
        key,
      );
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
  }

  @override
  Future<void> loadFromStorage() async {
    await _localStorage.ensureInitialized();
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
