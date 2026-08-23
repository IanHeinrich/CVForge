import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_file_snapshot.freezed.dart';

/// Metadata for the single `cvforge-vault.json` file `DriveApiClientService`
/// reads/writes in the user's hidden `appDataFolder` — never the file's
/// content itself (that's a plain `Map<String, dynamic>`, the same decoded
/// JSON shape `CvBackupBundle.fromJson` already consumes).
///
/// [version] is Drive's own monotonically-increasing revision counter
/// (returned as a string over the wire — Google's int64-as-string
/// convention — parsed to [int] here), not this app's `CvBackupBundle.
/// bundleVersion`. `DriveSyncService` compares it against the last value it
/// persisted locally to tell "nothing changed remotely since our last
/// sync" apart from "another device wrote since then" without downloading
/// the file just to check.
@freezed
abstract class DriveFileSnapshot with _$DriveFileSnapshot {
  const factory DriveFileSnapshot({
    required String fileId,
    required int version,
    required DateTime modifiedTime,
  }) = _DriveFileSnapshot;
}
