import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/draft/cv_draft.dart';
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
/// Deliberately has no `AppSettings` field at all — not stripped from the
/// bundle, absent from it. Settings are device-scoped and a backup is
/// career data; leaving settings out means the Copilot API key can never
/// reach a backup file by construction.
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
  }) = _CvBackupBundle;

  factory CvBackupBundle.fromJson(Map<String, dynamic> json) =>
      _$CvBackupBundleFromJson(json);
}
