import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// Settings' whole content in this PR: backup export/import. Follows
/// P1.7-G1's rule — `implements Initialisable`, loads via a keyed
/// `runBusyFuture` (mirroring `DraftsListViewModel`, not Vault's unkeyed
/// variant), renders `StorageUnavailableCard` on failure via
/// `AppChrome.gated`.
class SettingsViewModel extends ReactiveViewModel implements Initialisable {
  final _settingsService = locator<SettingsService>();
  final _backupService = locator<BackupService>();
  final _draftService = locator<DraftService>();
  final _dialogService = locator<DialogService>();

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
}
