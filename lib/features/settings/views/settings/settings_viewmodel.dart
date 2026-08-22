import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';
import 'package:cv_forge/services/llm_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// Settings' content: backup export/import (4.2) and Copilot connection
/// setup (4.4). Follows P1.7-G1's rule — `implements Initialisable`, loads
/// via a keyed `runBusyFuture` (mirroring `DraftsListViewModel`, not
/// Vault's unkeyed variant), renders `StorageUnavailableCard` on failure
/// via `AppChrome.gated`.
class SettingsViewModel extends ReactiveViewModel implements Initialisable {
  final _settingsService = locator<SettingsService>();
  final _backupService = locator<BackupService>();
  final _draftService = locator<DraftService>();
  final _vaultService = locator<VaultService>();
  final _dialogService = locator<DialogService>();
  final _llmService = locator<LlmService>();

  /// Not locator-registered — see `LlmService`'s own doc comment for why
  /// (stateless, deterministic, nothing else needs one injected).
  final _llmProviders = LlmProviderRegistry();

  @override
  List<ListenableServiceMixin> get listenableServices => [_settingsService];

  static const _loadBusyKey = 'settings_load';
  static const _exportBusyKey = 'settings_export';
  static const _importBusyKey = 'settings_import';

  @override
  void initialise() => runBusyFuture(_load(), busyObject: _loadBusyKey);

  // A real `async` wrapper, not `runBusyFuture(_settingsService.load())`
  // directly — see `VaultViewModel._load`'s doc comment for exactly why a
  // synchronously-throwing call needs this.
  Future<void> _load() async => _settingsService.load();

  bool get isLoading => busy(_loadBusyKey);
  bool get hasLoadError => hasErrorForKey(_loadBusyKey);

  bool get isExporting => busy(_exportBusyKey);
  bool get isImporting => busy(_importBusyKey);

  /// Short, per-failure copy for the most recent import attempt — mirrors
  /// `PdfExportStage`'s per-stage messaging (one generic message for every
  /// failure is a real defect, per P1.7-G7).
  String? get importErrorMessage {
    final error = this.error(_importBusyKey);
    if (error is! BackupException) return null;
    return switch (error.failure) {
      BackupFailure.malformed => "That file isn't a valid CVForge backup.",
      BackupFailure.unsupportedVersion =>
        'This backup was made by a newer version of CVForge.',
      BackupFailure.ioError => "Couldn't read that file. Try again.",
    };
  }

  Future<void> exportBackup() =>
      runBusyFuture(_export(), busyObject: _exportBusyKey);

  // Real `async` wrappers, not the service calls passed to [runBusyFuture]
  // directly — see `VaultViewModel._load`'s doc comment for why a call
  // that throws synchronously would otherwise bypass [runBusyFuture]'s
  // busy/error bookkeeping entirely.
  Future<void> _export() async {
    await _backupService.exportBackup();
    // Only reached on success — a thrown BackupException propagates out
    // of exportBackup above and this line never runs, so a failed export
    // never advances lastBackupAt (7.7 risk 2's "does not set on failure").
    await _settingsService.setLastBackupAt(DateTime.now());
  }

  Future<CvBackupBundle?> _pickImportFile() async =>
      _backupService.pickImportFile();
  Future<void> _applyImport(CvBackupBundle bundle) async =>
      _backupService.applyImport(bundle);

  /// Null means never backed up — [BackupSettingsCard] shows that state
  /// plainly rather than defaulting to silence (7.7's "the real problem").
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

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: 'Replace your data?',
      description:
          'This will replace your Vault and all ${_draftService.drafts.length} '
          'CVs with ${bundle.drafts.length} CVs from this file. Your current '
          'data downloads as a backup first.',
      mainButtonTitle: 'Replace',
      secondaryButtonTitle: 'Cancel',
    );
    if (response?.confirmed != true) return;

    await runBusyFuture(_applyImport(bundle), busyObject: _importBusyKey);
  }

  // --- Copilot connection (4.4) -------------------------------------

  static const _testConnectionBusyKey = 'settings_test_copilot_connection';

  /// Every registered provider, for the provider selector. Only shown by
  /// the UI once there's more than one to choose between — see
  /// [showCopilotProviderSelector].
  List<LlmProvider> get copilotProviders => _llmProviders.available;

  bool get showCopilotProviderSelector => _llmProviders.available.length > 1;

  /// Falls back to [LlmProviderRegistry.defaultProvider] when nothing is
  /// stored, or a stored id no longer resolves (a provider removed between
  /// releases) — mirrors [LlmProviderRegistry.byId]'s own never-throw
  /// contract, since a settings read must never crash a build.
  LlmProvider get selectedCopilotProvider =>
      _llmProviders.byId(_settingsService.settings.copilotProviderId ?? '');

  /// Switches the active provider and resets the stored model to that
  /// provider's first option — a model id from the *previous* provider
  /// would otherwise sit in `AppSettings.copilotModelId` pointing at
  /// nothing meaningful for the new one. [selectedCopilotModel]'s own
  /// fallback would paper over a stale id at read time regardless, but
  /// leaving `copilotModelId` actually correct is worth the extra write.
  Future<void> selectCopilotProvider(String providerId) async {
    await _settingsService.setCopilotProvider(providerId);
    await _settingsService.setCopilotModel(
      _llmProviders.byId(providerId).models.first.id,
    );
    clearConnectionTestResult();
  }

  List<LlmModelOption> get copilotModels => selectedCopilotProvider.models;

  String get selectedCopilotModelId => selectedCopilotModel.id;

  /// Falls back to the provider's first model when nothing is stored, or
  /// when a stored id no longer exists (a model retired between releases,
  /// or simply belonging to a different provider than the one currently
  /// selected) — the dropdown must always have a value present in its own
  /// item list or it throws at build time.
  LlmModelOption get selectedCopilotModel {
    final storedId = _settingsService.settings.copilotModelId;
    final models = selectedCopilotProvider.models;
    return models.firstWhere(
      (m) => m.id == storedId,
      orElse: () => models.first,
    );
  }

  Future<void> selectCopilotModel(String modelId) async {
    await _settingsService.setCopilotModel(modelId);
    clearConnectionTestResult();
  }

  bool get rememberApiKey => _settingsService.settings.rememberApiKey;

  /// Turning the toggle off deletes the stored key immediately (decision
  /// 8) rather than waiting for the next write. Only the *current*
  /// provider's key — switching providers and clearing this toggle for
  /// one does not touch a key already remembered for the other.
  Future<void> setRememberApiKey(bool value) async {
    await _settingsService.setRememberApiKey(value);
    if (!value) {
      await _settingsService.clearApiKey(selectedCopilotProvider.id);
    }
  }

  bool get isTestingConnection => busy(_testConnectionBusyKey);

  bool _connectionTestSucceeded = false;
  bool get connectionTestSucceeded => _connectionTestSucceeded;

  /// Called whenever something the last connection test result no longer
  /// describes changes — the provider, the model, or the key field itself
  /// (see `CopilotSettingsCard`'s api key `onChanged`). Without this, a
  /// stale "Connected." (or stale error) from a previous key/provider
  /// stays shown indefinitely, which is 7.7 issue 6.
  void clearConnectionTestResult() {
    if (!_connectionTestSucceeded && !hasErrorForKey(_testConnectionBusyKey)) {
      return;
    }
    _connectionTestSucceeded = false;
    setErrorForObject(_testConnectionBusyKey, null);
    rebuildUi();
  }

  /// Mirrors `importErrorMessage`'s per-failure-case copy (P1.7-G7: one
  /// generic message for every failure is a real defect). Interpolates
  /// the selected provider's name rather than hardcoding one, now that
  /// there's more than one.
  String? get connectionTestErrorMessage {
    final error = this.error(_testConnectionBusyKey);
    if (error is! LlmException) return null;
    final providerName = selectedCopilotProvider.displayName;
    return switch (error.failure) {
      LlmFailure.noKey => 'Enter an API key first.',
      LlmFailure.unauthorized =>
        'That key was rejected — check it and try again.',
      LlmFailure.rateLimited =>
        'Your API account is rate limited — try again in a moment.',
      LlmFailure.overloaded =>
        "$providerName's API is temporarily unavailable — try again "
            'shortly.',
      LlmFailure.network =>
        "Couldn't reach $providerName — check your connection.",
      LlmFailure.timeout => 'The request timed out — try again.',
      LlmFailure.refusal => 'The connection check was refused.',
      LlmFailure.invalidRequest =>
        "$providerName rejected the request. That's a bug in CVForge, not "
            'your key.',
      LlmFailure.malformedResponse => 'Got an unexpected response — try again.',
    };
  }

  /// Rendered next to the model dropdown so a BYOK user sees what a run
  /// costs before starting one — the reason the rate table exists at all
  /// (an unrendered price can be wrong indefinitely without anyone
  /// noticing).
  String priceLabelFor(LlmModelOption model) =>
      '\$${model.inputPricePerMTok.toStringAsFixed(2)} in / '
      '\$${model.outputPricePerMTok.toStringAsFixed(2)} out per M tokens';

  // A real `async` wrapper, not `_llmService.testConnection(...)` returned
  // directly — see `VaultViewModel._load`'s doc comment for exactly why a
  // synchronously-throwing call needs this: `runBusyFuture` can only catch
  // a failure inside the `Future` it's given, not one thrown while that
  // argument is still being evaluated.
  Future<void> _testConnection(String apiKey) async =>
      _llmService.testConnection(selectedCopilotProvider.id, apiKey);

  /// Only stores [apiKey] (in memory always, on disk if
  /// [rememberApiKey] is on — see `SettingsService.setApiKey`) once the
  /// connection actually validates it, so a rejected key never lingers.
  Future<void> testCopilotConnection(String apiKey) async {
    _connectionTestSucceeded = false;
    await runBusyFuture(
      _testConnection(apiKey),
      busyObject: _testConnectionBusyKey,
    );
    if (!hasErrorForKey(_testConnectionBusyKey)) {
      _connectionTestSucceeded = true;
      await _settingsService.setApiKey(selectedCopilotProvider.id, apiKey);
    }
    rebuildUi();
  }
}
