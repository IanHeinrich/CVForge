import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';

part 'cv_backup_bundle.freezed.dart';
part 'cv_backup_bundle.g.dart';

/// The full-backup envelope `BackupService` reads and writes — the whole
/// Vault plus every Draft, spanning machines and app versions. [vault] and
/// [drafts] (de)serialize via their own `CvVault.fromJson`/`CvDraft.fromJson`
/// automatically (`explicit_to_json: true` in `build.yaml`), so a malformed
/// nested draft throws straight out of [CvBackupBundle.fromJson] before any
/// storage write happens — the mechanism that makes import's
/// parse-everything-before-writing-anything rule hold without any bespoke
/// orchestration.
///
/// [bundleVersion] is independent of [CvVault.schemaVersion]/
/// [CvDraft.schemaVersion] and is checked strictly on import — unlike an
/// in-app schema version, a bundle genuinely crosses app versions, so an
/// unrecognised [bundleVersion] is rejected with an explicit "newer version
/// of CVForge" message rather than risking a silent misparse.
///
/// Carries [CvPreferences], never `AppSettings` — the portable slice of
/// settings by construction rather than by convention, so a device-scoped
/// field added to `AppSettings` later cannot start travelling by accident
/// and the API key (not a field on either type) can never reach a backup
/// file at all. See [CvPreferences] for what's excluded and why.
@freezed
abstract class CvBackupBundle with _$CvBackupBundle {
  const factory CvBackupBundle({
    required String app,
    required int bundleVersion,
    required DateTime exportedAt,
    required String appVersion,
    CvVault? vault,
    @Default(<CvDraft>[]) List<CvDraft> drafts,
    String? activeDraftId,

    /// Null only for a bundle written before preferences travelled at
    /// all — treated as "this side has nothing to say about preferences"
    /// by the merge, never as a request to clear them.
    CvPreferences? preferences,
  }) = _CvBackupBundle;

  factory CvBackupBundle.fromJson(Map<String, dynamic> json) =>
      _$CvBackupBundleFromJson(json);
}
