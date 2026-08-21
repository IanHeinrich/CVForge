import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';
import 'package:cv_forge/services/llm_service.dart';
import 'package:cv_forge/services/settings_service.dart';
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
  Future<void> _export() async => _backupService.exportBackup();
  Future<CvBackupBundle?> _pickImportFile() async =>
      _backupService.pickImportFile();
  Future<void> _applyImport(CvBackupBundle bundle) async =>
      _backupService.applyImport(bundle);

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

  /// With one provider registered, the model dropdown is this card's whole
  /// surface — a provider selector only earns its place once there is more
  /// than one to choose between.
  List<LlmModelOption> get copilotModels =>
      _llmProviders.defaultProvider.models;

  String get selectedCopilotModelId => selectedCopilotModel.id;

  /// Falls back to the provider's first model when nothing is stored, or
  /// when a stored id no longer exists (a model retired between releases)
  /// — the dropdown must always have a value present in its own item list
  /// or it throws at build time.
  LlmModelOption get selectedCopilotModel {
    final storedId = _settingsService.settings.copilotModelId;
    final models = _llmProviders.defaultProvider.models;
    return models.firstWhere(
      (m) => m.id == storedId,
      orElse: () => models.first,
    );
  }

  Future<void> selectCopilotModel(String modelId) async {
    await _settingsService.setCopilotProvider(_llmProviders.defaultProvider.id);
    await _settingsService.setCopilotModel(modelId);
  }

  bool get rememberApiKey => _settingsService.settings.rememberApiKey;

  /// Turning the toggle off deletes the stored key immediately (decision
  /// 8) rather than waiting for the next write.
  Future<void> setRememberApiKey(bool value) async {
    await _settingsService.setRememberApiKey(value);
    if (!value) {
      await _settingsService.clearApiKey(_llmProviders.defaultProvider.id);
    }
  }

  bool get isTestingConnection => busy(_testConnectionBusyKey);

  bool _connectionTestSucceeded = false;
  bool get connectionTestSucceeded => _connectionTestSucceeded;

  /// Mirrors `importErrorMessage`'s per-failure-case copy (P1.7-G7: one
  /// generic message for every failure is a real defect).
  String? get connectionTestErrorMessage {
    final error = this.error(_testConnectionBusyKey);
    if (error is! LlmException) return null;
    return switch (error.failure) {
      LlmFailure.noKey => 'Enter an API key first.',
      LlmFailure.unauthorized =>
        'That key was rejected — check it and try again.',
      LlmFailure.rateLimited =>
        'Your API account is rate limited — try again in a moment.',
      LlmFailure.overloaded =>
        "Anthropic's API is temporarily unavailable — try again shortly.",
      LlmFailure.network => "Couldn't reach Anthropic — check your connection.",
      LlmFailure.timeout => 'The request timed out — try again.',
      LlmFailure.refusal => 'The connection check was refused.',
      LlmFailure.invalidRequest =>
        "Anthropic rejected the request. That's a bug in CVForge, not your "
            'key.',
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
      _llmService.testConnection(_llmProviders.defaultProvider.id, apiKey);

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
      await _settingsService.setApiKey(
        _llmProviders.defaultProvider.id,
        apiKey,
      );
    }
    rebuildUi();
  }
}
