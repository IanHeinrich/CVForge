import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_sync_status.freezed.dart';

/// `DriveSyncService`'s reactive state — a sealed union (Dart 3 `switch`
/// over the cases, no `.when()`/`.map()`) so `DriveSettingsCard` and the
/// `AppChrome` status affordance can render every state without a
/// stringly-typed enum plus a scattered set of nullable fields.
///
/// [disconnected] and [connecting] carry no account, since none has been
/// granted yet. Every other state carries [accountEmail] — once Drive
/// sync has ever connected, the UI always has an account to show even
/// while offline or erroring, rather than losing it the moment something
/// goes wrong.
@freezed
sealed class DriveSyncStatus with _$DriveSyncStatus {
  /// Never connected — or the feature isn't configured at all (no
  /// `GOOGLE_OAUTH_CLIENT_ID` compiled in), which `DriveSyncService.
  /// isAvailable` distinguishes for the UI to decide whether to show the
  /// card at all.
  const factory DriveSyncStatus.disconnected() = DriveSyncDisconnected;

  /// The interactive [GoogleAuthService.connect] popup is in flight.
  const factory DriveSyncStatus.connecting() = DriveSyncConnecting;

  /// Connected, nothing pending. [lastSyncedAt] is null only in the
  /// instant between a fresh connect and the first successful sync.
  const factory DriveSyncStatus.idle({
    required String accountEmail,
    DateTime? lastSyncedAt,
  }) = DriveSyncIdle;

  /// A local edit landed and the debounce/max-wait timer is armed but
  /// hasn't fired yet.
  const factory DriveSyncStatus.pending({required String accountEmail}) =
      DriveSyncPending;

  /// A push or pull request is in flight.
  const factory DriveSyncStatus.syncing({required String accountEmail}) =
      DriveSyncSyncing;

  /// Drive had changed too, and both sides were just reconciled by
  /// `mergeBackupBundles`. Transient — it settles back to [idle] on a
  /// timer, and exists only so content arriving mid-session has some
  /// explanation attached rather than looking like a glitch.
  const factory DriveSyncStatus.merged({
    required String accountEmail,
    DateTime? lastSyncedAt,
  }) = DriveSyncMerged;

  /// Silent token renewal failed — the Google session or grant is gone.
  /// Local saves are unaffected; only Drive sync is paused until the user
  /// reconnects (a user gesture, so this can't happen automatically).
  const factory DriveSyncStatus.needsReauth({required String accountEmail}) =
      DriveSyncNeedsReauth;

  /// The last push/pull failed for a reason other than auth (network,
  /// an unexpected Drive response). [message] is short, user-facing copy
  /// — never the raw exception.
  const factory DriveSyncStatus.error({
    required String accountEmail,
    required String message,
  }) = DriveSyncErrorState;
}
