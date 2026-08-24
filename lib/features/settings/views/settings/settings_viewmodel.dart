import 'dart:ui';

import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_data.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/settings/app_theme_mode.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/drive_sync_service.dart';
import 'package:cv_forge/services/google_auth_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';
import 'package:cv_forge/services/llm_service.dart';
import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// Settings' content: backup export/import and AI Assistant connection setup.
/// `implements Initialisable`, loads via a keyed `runBusyFuture`
/// (mirroring `DraftsListViewModel`, not Vault's unkeyed variant), renders
/// `StorageUnavailableCard` on failure via `AppChrome.gated`.
class SettingsViewModel extends ReactiveViewModel implements Initialisable {
  final _settingsService = locator<SettingsService>();
  final _backupService = locator<BackupService>();
  final _draftService = locator<DraftService>();
  final _vaultService = locator<VaultService>();
  final _dialogService = locator<DialogService>();
  final _llmService = locator<LlmService>();
  final _driveSyncService = locator<DriveSyncService>();
  final _localizationService = locator<LocalizationService>();

  /// Not locator-registered — see `LlmService`'s own doc comment for why
  /// (stateless, deterministic, nothing else needs one injected).
  final _llmProviders = LlmProviderRegistry();

  @override
  List<ListenableServiceMixin> get listenableServices => [
    _settingsService,
    _driveSyncService,
  ];

  static const _loadBusyKey = 'settings_load';
  static const _exportBusyKey = 'settings_export';
  static const _importBusyKey = 'settings_import';

  @override
  void initialise() => runBusyFuture(_load(), busyObject: _loadBusyKey);

  // See `VaultViewModel._load` for why these are real `async` wrappers
  // rather than the service call passed straight to [runBusyFuture].
  Future<void> _load() async => _settingsService.load();

  bool get isLoading => busy(_loadBusyKey);
  bool get hasLoadError => hasErrorForKey(_loadBusyKey);

  bool get isExporting => busy(_exportBusyKey);
  bool get isImporting => busy(_importBusyKey);

  /// Short, per-failure copy for the most recent import attempt — mirrors
  /// `PdfExportStage`'s per-stage messaging: one generic message for every
  /// failure is a real defect, not an acceptable fallback.
  String? get importErrorMessage {
    final error = this.error(_importBusyKey);
    if (error is! BackupException) return null;
    final strings = _localizationService.strings;
    return switch (error.failure) {
      BackupFailure.malformed => strings.settingsImportErrorMalformed,
      BackupFailure.unsupportedVersion =>
        strings.settingsImportErrorNewerVersion,
      BackupFailure.ioError => strings.settingsImportErrorIo,
    };
  }

  RegionProfile get defaultRegion =>
      _settingsService.settings.preferences.defaultRegion;

  /// Device-scoped, unlike [defaultRegion] — see [AppSettings.themeMode].
  AppThemeMode get themeMode => _settingsService.settings.themeMode;

  Future<void> setThemeMode(AppThemeMode mode) =>
      _settingsService.setThemeMode(mode);

  /// Opens the same picker Studio's per-CV region button opens, in its
  /// `appDefault` context — one region surface with two entry points
  /// rather than two that can drift on wording or on which conventions
  /// they explain. Settings used to carry its own chip row, which listed
  /// the regions without explaining any of them.
  ///
  /// Near-identical to [StudioViewModel.openRegionGallery] and left that
  /// way: they write to different services and pass different contexts, so
  /// factoring them together would need a home neither ViewModel owns.
  ///
  /// Only changes what a *new* CV is created with — see
  /// `SettingsService.setDefaultRegion`'s doc comment.
  Future<void> openDefaultRegionPicker() async {
    final response = await _dialogService
        .showCustomDialog<RegionProfile, RegionGalleryDialogData>(
          variant: DialogType.regionGallery,
          data: RegionGalleryDialogData(
            currentRegion: defaultRegion,
            context: RegionGalleryContext.appDefault,
          ),
        );
    final selected = response?.data;
    if (response?.confirmed == true && selected != null) {
      await _settingsService.setDefaultRegion(selected);
    }
  }

  Future<void> exportBackup() =>
      runBusyFuture(_export(), busyObject: _exportBusyKey);

  Future<void> _export() async {
    await _backupService.exportBackup();
    // Only reached on success — a thrown BackupException propagates out
    // of exportBackup above and this line never runs, so a failed export
    // never advances lastBackupAt.
    await _settingsService.setLastBackupAt(DateTime.now());
  }

  Future<CvBackupBundle?> _pickImportFile() async =>
      _backupService.pickImportFile();
  Future<void> _applyImport(CvBackupBundle bundle) async =>
      _backupService.applyImport(bundle);

  /// Null means never backed up — [BackupSettingsCard] shows that state
  /// plainly rather than defaulting to silence.
  DateTime? get lastBackupAt => _settingsService.settings.lastBackupAt;

  /// True once the Vault or any Draft has been touched since
  /// [lastBackupAt] — computed from `CvVault.updatedAt`/`CvDraft.updatedAt`
  /// rather than a separate persisted dirty flag, since those timestamps
  /// already exist and a reactive comparison can't drift from them the
  /// way a flag maintained on every write path could. Meaningless (and
  /// not read) when [lastBackupAt] is null — "Never backed up" already
  /// says everything that state needs to say.
  bool get hasChangesSinceBackup {
    final last = lastBackupAt;
    if (last == null) return false;
    if (_vaultService.vault.updatedAt.isAfter(last)) return true;
    return _draftService.drafts.any((d) => d.updatedAt.isAfter(last));
  }

  Future<void> importBackup() async {
    final bundle = await runBusyFuture<CvBackupBundle?>(
      _pickImportFile(),
      busyObject: _importBusyKey,
    );
    if (bundle == null) return; // cancelled, or pickImportFile's own error —
    // surfaced separately via importErrorMessage.

    final strings = _localizationService.strings;
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: strings.settingsImportConfirmTitle,
      description: strings.settingsImportConfirmBody(
        defaultRegion.preset.documentNoun.name,
        _draftService.drafts.length,
        bundle.drafts.length,
      ),
      mainButtonTitle: strings.commonReplace,
      secondaryButtonTitle: strings.commonCancel,
    );
    if (response?.confirmed != true) return;

    await runBusyFuture(_applyImport(bundle), busyObject: _importBusyKey);
  }

  /// Wipes every Vault entry after confirmation. Lives here rather than
  /// on `VaultViewModel` — it belongs beside Backup, where "export
  /// first, then restore replaces everything" is already the established
  /// framing, not as the first interactive element on the Vault screen
  /// above the user's own name. Reaching `/vault` afterwards constructs a
  /// fresh `VaultViewModel`, which already starts at the empty state on
  /// its own, so nothing here needs to reset Vault-side UI state the way
  /// the old in-place `clearVault` did.
  Future<void> clearVault() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: _localizationService.strings.settingsClearVaultConfirmTitle,
      description: _localizationService.strings.settingsClearVaultConfirmBody,
      mainButtonTitle: _localizationService.strings.commonClear,
      secondaryButtonTitle: _localizationService.strings.commonCancel,
    );
    if (response?.confirmed != true) return;
    await _vaultService.clearVault();
    // _vaultService isn't in listenableServices (only settings needs live
    // reactivity here) — without this, the freshly-emptied vault's
    // updatedAt wouldn't show up in hasChangesSinceBackup until something
    // else happened to trigger a rebuild.
    rebuildUi();
  }

  static const _testConnectionBusyKey = 'settings_test_ai_assistant_connection';

  /// Every registered provider, for the provider selector. Only shown by
  /// the UI once there's more than one to choose between — see
  /// [showAiAssistantProviderSelector].
  List<LlmProvider> get aiAssistantProviders => _llmProviders.available;

  bool get showAiAssistantProviderSelector =>
      _llmProviders.available.length > 1;

  /// Resolved by `SettingsService` — see
  /// [SettingsService.selectedAiAssistantProvider] for the never-throw
  /// fallback rules, stated there once rather than in each ViewModel that
  /// needs them.
  LlmProvider get selectedAiAssistantProvider =>
      _settingsService.selectedAiAssistantProvider;

  /// Switches the active provider and resets the stored model to that
  /// provider's first option — a model id from the *previous* provider
  /// would otherwise sit in `CvPreferences.aiAssistantModelId` pointing at
  /// nothing meaningful for the new one. [selectedAiAssistantModel]'s own
  /// fallback would paper over a stale id at read time regardless, but
  /// leaving `aiAssistantModelId` actually correct is worth the extra write.
  Future<void> selectAiAssistantProvider(String providerId) async {
    await _settingsService.setAiAssistantProvider(providerId);
    await _settingsService.setAiAssistantModel(
      _llmProviders.byId(providerId).models.first.id,
    );
    clearConnectionTestResult();
  }

  List<LlmModelOption> get aiAssistantModels =>
      selectedAiAssistantProvider.models;

  String get selectedAiAssistantModelId => selectedAiAssistantModel.id;

  /// Resolved by `SettingsService` — see
  /// [SettingsService.selectedAiAssistantModel] for the stale-id fallback.
  LlmModelOption get selectedAiAssistantModel =>
      _settingsService.selectedAiAssistantModel;

  Future<void> selectAiAssistantModel(String modelId) async {
    await _settingsService.setAiAssistantModel(modelId);
    clearConnectionTestResult();
  }

  /// Whether the selected provider has a key, and how long it survives —
  /// the state the card's whole two-mode layout keys off.
  ApiKeyOrigin get apiKeyOrigin =>
      _settingsService.apiKeyOriginFor(selectedAiAssistantProvider.id);

  bool get hasApiKey => apiKeyOrigin != ApiKeyOrigin.none;

  /// Bullets plus the key's last four characters, for the configured
  /// state — see [SettingsService.maskedApiKeyFor].
  String? get maskedApiKey =>
      _settingsService.maskedApiKeyFor(selectedAiAssistantProvider.id);

  /// True when this user has set the AI Assistant up before — on another
  /// device, or on this one before clearing site data — but this browser
  /// has no key for the selected provider.
  ///
  /// `CvPreferences.aiAssistantConfiguredAt` syncs; the key deliberately
  /// does not (a secret has no business in `CvBackupBundle`, which is also
  /// the file a backup export downloads). So the second device knows setup
  /// happened and can say so, instead of showing a blank field that looks
  /// identical to never having started.
  bool get wasConfiguredElsewhere =>
      !hasApiKey &&
      _settingsService.settings.preferences.aiAssistantConfiguredAt != null;

  /// Confirmed first: neither provider lets a key be read back after
  /// creation, so removing one here means generating a new one in their
  /// console — not an undo-able click. Same `confirmDelete` dialog as
  /// [clearVault] and [disconnectDrive].
  Future<void> removeApiKey() async {
    final providerName = selectedAiAssistantProvider.displayName;
    final strings = _localizationService.strings;
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: strings.settingsAiRemoveKeyConfirmTitle(providerName),
      description: strings.settingsAiRemoveKeyConfirmBody(providerName),
      mainButtonTitle: strings.commonRemove,
      secondaryButtonTitle: strings.commonCancel,
    );
    if (response?.confirmed != true) return;
    await _settingsService.clearApiKey(selectedAiAssistantProvider.id);
    clearConnectionTestResult();
  }

  bool get isTestingConnection => busy(_testConnectionBusyKey);

  bool _connectionTestSucceeded = false;
  bool get connectionTestSucceeded => _connectionTestSucceeded;

  /// Called whenever something the last connection test result no longer
  /// describes changes — the provider, the model, or the key field itself
  /// (see `AiAssistantSettingsCard`'s api key `onChanged`). Without this, a
  /// stale "Connected." (or stale error) from a previous key/provider
  /// stays shown indefinitely.
  void clearConnectionTestResult() {
    if (!_connectionTestSucceeded && !hasErrorForKey(_testConnectionBusyKey)) {
      return;
    }
    _connectionTestSucceeded = false;
    setErrorForObject(_testConnectionBusyKey, null);
    rebuildUi();
  }

  /// Mirrors `importErrorMessage`'s per-failure-case copy — one generic
  /// message for every failure is a real defect, not an acceptable
  /// fallback. Interpolates the selected provider's name rather than
  /// hardcoding one, now that there's more than one.
  String? get connectionTestErrorMessage {
    final error = this.error(_testConnectionBusyKey);
    if (error is! LlmException) return null;
    final providerName = selectedAiAssistantProvider.displayName;
    final strings = _localizationService.strings;
    return switch (error.failure) {
      LlmFailure.noKey => strings.settingsAiErrorNoKey,
      LlmFailure.unauthorized => strings.settingsAiErrorUnauthorized,
      LlmFailure.rateLimited => strings.settingsAiErrorRateLimited,
      LlmFailure.overloaded => strings.settingsAiErrorOverloaded(providerName),
      LlmFailure.network => strings.settingsAiErrorNetwork(providerName),
      LlmFailure.timeout => strings.settingsAiErrorTimeout,
      LlmFailure.refusal => strings.settingsAiErrorRefusal,
      LlmFailure.invalidRequest => strings.settingsAiErrorInvalidRequest(
        providerName,
      ),
      LlmFailure.malformedResponse => strings.settingsAiErrorMalformedResponse,
    };
  }

  /// Rendered next to the model dropdown so a BYOK user sees what a run
  /// costs before starting one — the reason the rate table exists at all
  /// (an unrendered price can be wrong indefinitely without anyone
  /// noticing).
  String priceLabelFor(LlmModelOption model) => _localizationService.strings
      .settingsAiPriceRate(model.inputPricePerMTok, model.outputPricePerMTok);

  Future<void> _testConnection(String apiKey) async =>
      _llmService.testConnection(selectedAiAssistantProvider.id, apiKey);

  /// Tests [typedKey] when the user has entered one, and the already-stored
  /// key otherwise.
  ///
  /// The fallback is the point: in the configured state there is no text
  /// field to read, so passing the (empty) field's contents made "Test
  /// connection" fail with `LlmFailure.noKey` for users whose key was
  /// present and working.
  ///
  /// A typed key is only stored — see `SettingsService.setApiKey` — once
  /// the connection actually validates it, so a rejected key never lingers
  /// or overwrites a good one.
  Future<void> testAiAssistantConnection([String? typedKey]) async {
    _connectionTestSucceeded = false;
    final providerId = selectedAiAssistantProvider.id;
    final typed = typedKey?.trim() ?? '';
    final apiKey = typed.isNotEmpty
        ? typed
        : await _settingsService.apiKeyFor(providerId) ?? '';

    await runBusyFuture(
      _testConnection(apiKey),
      busyObject: _testConnectionBusyKey,
    );
    if (!hasErrorForKey(_testConnectionBusyKey)) {
      _connectionTestSucceeded = true;
      if (typed.isNotEmpty) {
        await _settingsService.setApiKey(providerId, typed);
      }
      await _settingsService.markAiAssistantConfigured();
    }
    rebuildUi();
  }

  static const _driveConnectBusyKey = 'drive_connect';
  static const _driveSyncBusyKey = 'drive_sync';

  /// False hides `DriveSettingsCard` entirely — no `GOOGLE_OAUTH_CLIENT_ID`
  /// was compiled into this build, so a "Connect" button here could only
  /// ever fail.
  bool get isDriveAvailable => _driveSyncService.isAvailable;

  DriveSyncStatus get driveSyncStatus => _driveSyncService.status;

  bool get isDriveConnecting => busy(_driveConnectBusyKey);
  bool get isDriveSyncingNow => busy(_driveSyncBusyKey);

  /// Mirrors `importErrorMessage`/`connectionTestErrorMessage`'s
  /// per-failure-case copy — one generic message for every failure is a
  /// real defect, not an acceptable fallback.
  String? get driveConnectErrorMessage {
    final error = this.error(_driveConnectBusyKey);
    if (error is! GoogleAuthException) return null;
    final strings = _localizationService.strings;
    return switch (error.failure) {
      GoogleAuthFailure.notConfigured =>
        strings.settingsDriveErrorNotConfigured,
      GoogleAuthFailure.scriptLoadFailed =>
        strings.settingsDriveErrorScriptLoad,
      GoogleAuthFailure.cancelledOrBlocked =>
        strings.settingsDriveErrorCancelled,
      GoogleAuthFailure.unknown => strings.settingsDriveErrorUnknown,
    };
  }

  Future<void> connectDrive() =>
      runBusyFuture(_connectDrive(), busyObject: _driveConnectBusyKey);

  Future<void> _connectDrive() async => _driveSyncService.connect();

  Future<void> syncDriveNow() =>
      runBusyFuture(_syncDriveNow(), busyObject: _driveSyncBusyKey);

  Future<void> _syncDriveNow() async => _driveSyncService.syncNow();

  /// Stops syncing on this device only — see `DriveSyncService.disconnect`'s
  /// doc comment for why local data is never touched by this. Confirmed
  /// first since it's easy to mistake for "delete my data on Drive",
  /// which it explicitly is not.
  Future<void> disconnectDrive() async {
    final strings = _localizationService.strings;
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: strings.settingsDriveDisconnectConfirmTitle,
      description: strings.settingsDriveDisconnectConfirmBody,
      mainButtonTitle: strings.commonDisconnect,
      secondaryButtonTitle: strings.commonCancel,
    );
    if (response?.confirmed != true) return;
    await _driveSyncService.disconnect();
  }

  /// The language picker only earns its place once there is more than one
  /// language to pick, so `SettingsView` hides the card until then. Reading
  /// the list off the generated `supportedLocales` means adding a language
  /// stays a one-file change — a new `.arb` and nothing else.
  List<Locale> get availableLocales => LocalizationService.supportedLocales;

  bool get showLanguageSelector => availableLocales.length > 1;

  /// Null means "follow the browser" — the default, and the only value that
  /// does not sync between devices.
  String? get selectedLocaleTag =>
      _localizationService.selectedLocale?.toLanguageTag();

  /// Each language named in its own language, read from that locale's own
  /// ARB rather than a map here, so a new language brings its own name with
  /// it.
  String localeDisplayName(Locale locale) =>
      lookupAppLocalizations(locale).localeDisplayName;

  Future<void> setLocaleTag(String? tag) =>
      _localizationService.setLocale(tag == null ? null : Locale(tag));
}
