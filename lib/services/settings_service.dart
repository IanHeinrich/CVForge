import 'dart:convert';

import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/persisted_store.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/app/app.locator.dart';

/// Owns device-scoped [AppSettings] — same single-aggregate,
/// [PersistedStoreMixin] shape as `VaultService`. No mutators yet (see
/// [AppSettings]'s own doc comment for why) — [load] and [settings] are
/// this PR's whole surface.
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
