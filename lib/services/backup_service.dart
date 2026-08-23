import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/file_download_service.dart';
import 'package:cv_forge/services/file_upload_service.dart';
import 'package:cv_forge/services/vault_service.dart';

/// Which part of a backup/restore failed — lets the UI show different
/// recovery copy per failure mode, the same [PdfExportStage] precedent
/// `PdfExportService` already established.
enum BackupFailure { malformed, unsupportedVersion, ioError }

/// Wraps whatever [BackupService.pickImportFile]/[applyImport] threw,
/// tagged with [failure] so callers can classify it without inspecting the
/// underlying exception.
class BackupException implements Exception {
  const BackupException(this.failure, this.cause);

  final BackupFailure failure;
  final Object? cause;

  @override
  String toString() => 'BackupException(failure: $failure, cause: $cause)';
}

/// Orchestrates the full-backup export/import: the whole Vault plus every
/// Draft, one JSON file. Import is always replace-the-world (never merge —
/// see [CvBackupBundle]'s doc comment) and always auto-exports the current
/// state first, before anything is overwritten.
class BackupService {
  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _fileDownload = locator<FileDownloadService>();
  final _fileUpload = locator<FileUploadService>();

  /// The bundle envelope's own version — independent of [CvVault]/[CvDraft]'s
  /// `schemaVersion`, and checked strictly, since a bundle genuinely
  /// crosses app versions rather than just in-app storage upgrades.
  static const bundleVersion = 1;

  /// Provenance only, never branched on — a small hardcoded literal rather
  /// than a `package_info_plus` dependency, since nothing reads this back.
  /// Keep it in sync with `pubspec.yaml`'s `version:` at each bump.
  static const _appVersion = '2.9.0';

  CvBackupBundle _buildBundle() => CvBackupBundle(
    app: 'cv-forge',
    bundleVersion: bundleVersion,
    exportedAt: DateTime.now(),
    appVersion: _appVersion,
    vault: _vaultService.vault,
    drafts: _draftService.drafts,
    activeDraftId: _draftService.activeDraftId,
  );

  /// Downloads the whole Vault + every Draft as one JSON file.
  Future<void> exportBackup() async {
    final bundle = _buildBundle();
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(bundle.toJson())));
    try {
      await _fileDownload.saveFile(
        nameWithoutExtension: 'cvforge_backup_${_dateStamp(DateTime.now())}',
        bytes: bytes,
        extension: 'json',
        mimeType: MimeType.json,
      );
    } catch (e) {
      throw BackupException(BackupFailure.ioError, e);
    }
  }

  /// Opens the platform file picker, reads and validates the chosen file,
  /// and returns the parsed bundle — or `null` if the user cancelled.
  /// Every inner model is round-tripped through `fromJson` here, before
  /// [applyImport] ever runs, so a bundle that fails to parse can never
  /// leave storage partially written.
  Future<CvBackupBundle?> pickImportFile() async {
    final Uint8List? bytes;
    try {
      bytes = await _fileUpload.pickJsonFile();
    } catch (e) {
      throw BackupException(BackupFailure.ioError, e);
    }
    if (bytes == null) return null;

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (e) {
      throw BackupException(BackupFailure.malformed, e);
    }

    final version = json['bundleVersion'];
    if (version is! int) {
      throw const BackupException(
        BackupFailure.malformed,
        'missing bundleVersion',
      );
    }
    if (version > bundleVersion) {
      throw BackupException(BackupFailure.unsupportedVersion, version);
    }

    try {
      return CvBackupBundle.fromJson(json);
    } catch (e) {
      throw BackupException(BackupFailure.malformed, e);
    }
  }

  /// Replaces the entire Vault and every Draft with [bundle]'s contents.
  /// Auto-exports the current state first (handed to the user as a
  /// download) so the one destructive operation in the app always leaves
  /// an escape hatch, per this project's "no silent data loss" rule.
  Future<void> applyImport(CvBackupBundle bundle) async {
    await exportBackup();
    if (bundle.vault != null) {
      await _vaultService.replaceAll(bundle.vault!);
    }
    await _draftService.replaceAll(
      bundle.drafts,
      activeDraftId: bundle.activeDraftId,
    );
  }

  String _dateStamp(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
