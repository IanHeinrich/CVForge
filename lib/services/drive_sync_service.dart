import 'dart:async';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/drive/drive_file_snapshot.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/drive_api_client_service.dart';
import 'package:cv_forge/services/google_auth_service.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';

/// Keeps the Vault + every Draft mirrored to the user's Google Drive
/// (hidden `appDataFolder`) so signing in on a second browser recovers
/// everything — see this feature's design doc for the full picture.
///
/// Local-first by design: Hive (via [VaultService]/[DraftService]) stays
/// the single source of truth the rest of the app reads from. This
/// service only ever pushes a snapshot of that state to Drive or pulls
/// one down and replaces it — the same whole-world `CvBackupBundle`
/// [BackupService.buildBundle]/`applyImport` already establish, reused
/// verbatim rather than a second serialization path. A failure here is
/// never fatal to a local save: it surfaces as [DriveSyncStatus.error]/
/// [DriveSyncStatus.needsReauth] and simply retries later.
///
/// Pure Dart — [GoogleAuthService] is the one dependency that needs
/// `dart:js_interop`, and only its abstract interface is imported here
/// (see that class's doc comment), so this service is registered normally
/// and fully VM-testable.
class DriveSyncService with ListenableServiceMixin {
  /// [idleDebounce]/[maxWait] are a test seam — production code always
  /// uses the defaults. Nothing else needs them injected, so this isn't a
  /// locator registration, just constructor defaults, the same pattern
  /// `LlmService({Dio? client})`/`DriveApiClientService({Dio? client})`
  /// use.
  DriveSyncService({
    this.idleDebounce = const Duration(seconds: 20),
    this.maxWait = const Duration(minutes: 2),
  }) {
    listenToReactiveValues([_status]);
  }

  final _auth = locator<GoogleAuthService>();
  final _api = locator<DriveApiClientService>();
  final _vault = locator<VaultService>();
  final _drafts = locator<DraftService>();
  final _backup = locator<BackupService>();
  final _localStorage = locator<LocalStorageService>();

  /// How long to wait after the *last* local edit before pushing — rapid
  /// successive edits (typing a bullet, reordering sections) collapse
  /// into one push, the same debounce shape `PersistedStoreMixin.
  /// scheduleWrite` already uses for the local Hive write, just longer:
  /// a Drive round trip is much more expensive than a local one, and
  /// nothing is lost by waiting — the local Hive write already happened
  /// on its own, much shorter, timer.
  final Duration idleDebounce;

  /// A ceiling on how long continuous editing can go without a push, so
  /// a long uninterrupted editing session still lands on Drive
  /// periodically rather than only once the user finally pauses.
  final Duration maxWait;

  final ReactiveValue<DriveSyncStatus> _status = ReactiveValue<DriveSyncStatus>(
    const DriveSyncStatus.disconnected(),
  );
  DriveSyncStatus get status => _status.value;

  /// Whether the feature should be shown in the UI at all — false when no
  /// `GOOGLE_OAUTH_CLIENT_ID` was compiled into this build.
  /// `DriveSettingsCard` hides itself entirely rather than show a
  /// "Connect" button that can only ever fail.
  bool get isAvailable => _auth.isConfigured;

  bool _listenersAttached = false;
  bool _dirty = false;
  bool _applyingRemote = false;
  Timer? _idleTimer;
  Timer? _maxWaitTimer;

  String? _fileId;
  String? _accountEmail;
  int? _lastSyncedVersion;
  DateTime? _lastSyncedAt;

  /// Drive's own `modifiedTime` as of the moment a
  /// [DriveSyncStatus.conflict] was raised — read by
  /// `SettingsViewModel.resolveDriveConflict` for `DriveConflictDialog`'s
  /// "Google Drive — N days ago" copy. Not persisted (a conflict is
  /// always resolved or abandoned within the same session it's raised
  /// in) and meaningless outside [DriveSyncStatus.conflict].
  DateTime? conflictRemoteModifiedAt;

  Future<void>? _startFuture;

  /// Resumes a previously-connected session — called once from
  /// `main.dart`, before `runApp`, so autosave is armed for the whole
  /// session regardless of which route the user lands on first (a
  /// refresh on e.g. `/studio` bypasses `StartupView` entirely, the same
  /// reason every other service self-initializes). Idempotent and safe
  /// to call more than once. A no-op — not an error — when the user has
  /// never connected, or this build has no client id configured.
  Future<void> start() => _startFuture ??= _start();

  Future<void> _start() async {
    if (!isAvailable) return;
    await _localStorage.ensureInitialized();
    final enabled = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.driveEnabled,
    );
    if (enabled != 'true') return;
    final email = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.driveAccountEmail,
    );
    if (email == null) return;
    _accountEmail = email;
    _fileId = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.driveFileId,
    );
    final storedVersion = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedVersion,
    );
    _lastSyncedVersion = storedVersion == null
        ? null
        : int.tryParse(storedVersion);
    final storedSyncedAt = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedAt,
    );
    _lastSyncedAt = storedSyncedAt == null
        ? null
        : DateTime.tryParse(storedSyncedAt);
    _status.value = DriveSyncStatus.idle(
      accountEmail: email,
      lastSyncedAt: _lastSyncedAt,
    );
    _attachListeners();
    await _reconcile();
  }

  /// Interactive connect — must be called synchronously from a user
  /// gesture (a button's `onPressed`), since [GoogleAuthService.connect]
  /// shows Google's consent popup. Also the "Reconnect" action after
  /// [DriveSyncStatus.needsReauth]: re-requesting the same scope when a
  /// grant already exists is normally near-instant (no popup at all), so
  /// one method covers both first connect and recovering from a lapsed
  /// session. Propagates [GoogleAuthException]/[DriveApiException] for
  /// the caller's `runBusyFuture` to catch — see `VaultViewModel._load`'s
  /// doc comment for why every service call site here is written to
  /// throw rather than swallow.
  Future<void> connect() async {
    if (!isAvailable) return;
    _status.value = const DriveSyncStatus.connecting();
    final String token;
    try {
      token = await _auth.connect();
    } on GoogleAuthException {
      _status.value = const DriveSyncStatus.disconnected();
      rethrow;
    }
    final email = await _fetchEmailOrFallback(token);
    _accountEmail = email;
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveEnabled,
      'true',
    );
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveAccountEmail,
      email,
    );
    _attachListeners();
    await _reconcile();
  }

  Future<String> _fetchEmailOrFallback(String token) async {
    try {
      return await _api.fetchAccountEmail(token) ?? 'your Google account';
    } on DriveApiException {
      return 'your Google account';
    }
  }

  /// Disconnects Drive sync on this device only — revokes the token,
  /// forgets which file/version this device last synced, and stops
  /// watching for local edits. Never touches local data: the Vault and
  /// every Draft stay exactly as they are in Hive, and Drive's own copy
  /// (if any) is untouched too, so reconnecting later picks up wherever
  /// Drive was left.
  Future<void> disconnect() async {
    _cancelTimers();
    _detachListeners();
    await _auth.disconnect();
    await _localStorage.delete(StorageBoxes.settings, StorageKeys.driveEnabled);
    await _localStorage.delete(StorageBoxes.settings, StorageKeys.driveFileId);
    await _localStorage.delete(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedVersion,
    );
    await _localStorage.delete(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedAt,
    );
    await _localStorage.delete(
      StorageBoxes.settings,
      StorageKeys.driveAccountEmail,
    );
    _fileId = null;
    _accountEmail = null;
    _lastSyncedVersion = null;
    _lastSyncedAt = null;
    _dirty = false;
    _status.value = const DriveSyncStatus.disconnected();
  }

  /// The "Sync now" button — flushes any pending debounce immediately and
  /// also re-checks Drive even when nothing is dirty locally (a
  /// deliberate "pull in case another device wrote" check), unlike the
  /// idle/max-wait timers which only ever fire a push.
  Future<void> syncNow() async {
    if (_accountEmail == null) return;
    _cancelTimers();
    await _reconcile();
  }

  /// Flushes a pending debounced push immediately, bypassing its timer —
  /// called from `main.dart`'s `AppLifecycleState.hidden` handler
  /// alongside `VaultService.flushPendingWrites`/`DraftService.
  /// flushPendingWrites`, since a debounce timer alone can't survive the
  /// tab actually closing.
  Future<void> flushPendingWrites() => _flush();

  /// Resolves [DriveSyncStatus.conflict] per the user's choice in
  /// `DriveConflictDialog`. [keepLocal] pushes this device's data over
  /// Drive's; `false` discards this device's unsynced edits and pulls
  /// Drive's copy instead. Either way this is the only place a conflict
  /// is actually resolved — a fresh mismatch afterwards raises the
  /// conflict state again rather than silently reusing a stale choice.
  Future<void> resolveConflict({required bool keepLocal}) async {
    if (status is! DriveSyncConflict) return;
    final email = _accountEmail;
    final fileId = _fileId;
    if (email == null || fileId == null) return;
    final token = await _auth.silentAccessToken();
    if (token == null) {
      _status.value = DriveSyncStatus.needsReauth(accountEmail: email);
      return;
    }
    _status.value = DriveSyncStatus.syncing(accountEmail: email);
    try {
      if (keepLocal) {
        final updated = await _api.updateFile(
          token,
          fileId,
          _backup.buildBundle().toJson(),
        );
        _dirty = false;
        await _commitSync(email: email, fileId: fileId, snapshot: updated);
      } else {
        await _pullAndApply(token, fileId);
        final meta = await _api.fetchMetadata(token, fileId);
        _dirty = false;
        await _commitSync(email: email, fileId: fileId, snapshot: meta);
      }
    } on DriveApiException catch (e) {
      _handleApiError(e, email);
    }
  }

  void _attachListeners() {
    if (_listenersAttached) return;
    _vault.addListener(_onLocalChange);
    _drafts.addListener(_onLocalChange);
    _listenersAttached = true;
  }

  void _detachListeners() {
    if (!_listenersAttached) return;
    _vault.removeListener(_onLocalChange);
    _drafts.removeListener(_onLocalChange);
    _listenersAttached = false;
  }

  /// [VaultService]/[DraftService] notify on every change, including one
  /// this service caused itself by applying a remote pull — [_applyingRemote]
  /// is what stops that from being mistaken for a fresh local edit and
  /// immediately re-queuing a push of the very data that was just pulled.
  void _onLocalChange() {
    if (_applyingRemote) return;
    _dirty = true;
    final email = _accountEmail;
    if (email == null) return;
    // A conflict/reauth state means "waiting on the user", not "waiting
    // on the debounce" — don't paper over it with `pending`.
    if (status is! DriveSyncConflict && status is! DriveSyncNeedsReauth) {
      _status.value = DriveSyncStatus.pending(accountEmail: email);
    }
    _idleTimer?.cancel();
    _idleTimer = Timer(idleDebounce, _flush);
    _maxWaitTimer ??= Timer(maxWait, _flush);
  }

  void _cancelTimers() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _maxWaitTimer?.cancel();
    _maxWaitTimer = null;
  }

  Future<void> _flush() async {
    _cancelTimers();
    if (!_dirty) return;
    await _push();
  }

  /// Pushes the current local state to Drive — but only after confirming
  /// Drive's own `version` still matches what this device last saw.
  /// Every real edit funnels through here (the debounce/max-wait timers,
  /// and [resolveConflict]'s `keepLocal: true` branch both call this or
  /// its update logic directly), so this is the one place that check
  /// lives.
  Future<void> _push() async {
    final email = _accountEmail;
    if (email == null) return;
    final token = await _auth.silentAccessToken();
    if (token == null) {
      _status.value = DriveSyncStatus.needsReauth(accountEmail: email);
      return; // _dirty stays true — nothing was written.
    }
    final fileId = _fileId;
    if (fileId == null) {
      // No known file yet (shouldn't normally happen once connected —
      // connect()/`_reconcile()` both create or find one — but a clean
      // recovery either way).
      await _reconcile();
      return;
    }
    _status.value = DriveSyncStatus.syncing(accountEmail: email);
    try {
      final remote = await _api.fetchMetadata(token, fileId);
      if (_lastSyncedVersion != null && remote.version != _lastSyncedVersion) {
        // Another device wrote since our last sync — do not clobber it.
        await _raiseConflict(email, remote.modifiedTime);
        return;
      }
      final updated = await _api.updateFile(
        token,
        fileId,
        _backup.buildBundle().toJson(),
      );
      _dirty = false;
      await _commitSync(email: email, fileId: fileId, snapshot: updated);
    } on DriveApiException catch (e) {
      _handleApiError(e, email);
      // _dirty is deliberately left true — nothing was written, and the
      // next debounce/max-wait tick, or an explicit "Sync now"/reconnect,
      // will retry.
    }
  }

  /// Runs on every connect, app start (for a previously-connected
  /// device), and manual "Sync now" — finds or creates this feature's
  /// Drive file, then reconciles local vs. remote per this feature's
  /// design doc: unchanged → push if dirty; remote moved on + clean →
  /// apply remote silently; remote moved on + dirty → conflict, after a
  /// local safety backup.
  Future<void> _reconcile() async {
    final email = _accountEmail;
    if (email == null) return;
    final token = await _auth.silentAccessToken();
    if (token == null) {
      _status.value = DriveSyncStatus.needsReauth(accountEmail: email);
      return;
    }
    _status.value = DriveSyncStatus.syncing(accountEmail: email);
    try {
      var fileId = _fileId;
      if (fileId == null) {
        final existing = await _api.findFile(token);
        if (existing == null) {
          final created = await _api.createFile(
            token,
            _backup.buildBundle().toJson(),
          );
          _dirty = false;
          await _commitSync(
            email: email,
            fileId: created.fileId,
            snapshot: created,
          );
          return;
        }
        fileId = existing.fileId;
        _fileId = fileId;
      }

      final remote = await _api.fetchMetadata(token, fileId);
      if (_lastSyncedVersion != null && remote.version == _lastSyncedVersion) {
        _status.value = DriveSyncStatus.idle(
          accountEmail: email,
          lastSyncedAt: _lastSyncedAt,
        );
        if (_dirty) await _push();
        return;
      }

      if (!_dirty) {
        await _pullAndApply(token, fileId);
        await _commitSync(email: email, fileId: fileId, snapshot: remote);
        return;
      }

      await _raiseConflict(email, remote.modifiedTime);
    } on DriveApiException catch (e) {
      _handleApiError(e, email);
    } on FormatException {
      _status.value = DriveSyncStatus.error(
        accountEmail: email,
        message: "Drive's copy looked corrupted — left this device as is.",
      );
    }
  }

  Future<void> _pullAndApply(String token, String fileId) async {
    final content = await _api.downloadFile(token, fileId);
    final bundle = CvBackupBundle.fromJson(content);
    _applyingRemote = true;
    try {
      if (bundle.vault != null) await _vault.replaceAll(bundle.vault!);
      await _drafts.replaceAll(
        bundle.drafts,
        activeDraftId: bundle.activeDraftId,
      );
    } finally {
      _applyingRemote = false;
    }
  }

  /// A local edit landed *while* Drive's own copy had already moved on —
  /// the one case this feature can't resolve on its own. Downloads a
  /// local safety backup first (reusing the exact same
  /// `BackupService.exportBackup` a manual export uses) so the user's
  /// current data is on disk somewhere concrete before anything about it
  /// is even shown as being at risk, then raises the state
  /// `DriveConflictDialog` renders. [remoteModifiedAt] is cached in
  /// [conflictRemoteModifiedAt] purely for that dialog's "Google Drive —
  /// N days ago" copy; it plays no part in resolving the conflict itself.
  Future<void> _raiseConflict(String email, DateTime remoteModifiedAt) async {
    try {
      await _backup.exportBackup();
    } catch (_) {
      // Best-effort — still raise the conflict even if the safety
      // download itself failed. Silently clobbering one side instead
      // would be worse than a conflict prompt with one fewer safety net.
    }
    conflictRemoteModifiedAt = remoteModifiedAt;
    _status.value = DriveSyncStatus.conflict(accountEmail: email);
  }

  Future<void> _commitSync({
    required String email,
    required String fileId,
    required DriveFileSnapshot snapshot,
  }) async {
    final version = snapshot.version;
    final syncedAt = DateTime.now();
    _fileId = fileId;
    _lastSyncedVersion = version;
    _lastSyncedAt = syncedAt;
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveFileId,
      fileId,
    );
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedVersion,
      version.toString(),
    );
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedAt,
      syncedAt.toIso8601String(),
    );
    _status.value = DriveSyncStatus.idle(
      accountEmail: email,
      lastSyncedAt: syncedAt,
    );
  }

  void _handleApiError(DriveApiException e, String email) {
    if (e.failure == DriveApiFailure.notFound) {
      // The Drive-side file is gone (the user disconnected the app from
      // their Google Account settings, which deletes every appDataFolder
      // file — or deleted it some other way). Forget the cached
      // id/version so the next sync recreates it from scratch rather
      // than repeatedly hitting the same 404.
      _fileId = null;
      _lastSyncedVersion = null;
    }
    _status.value = switch (e.failure) {
      DriveApiFailure.needsReauth => DriveSyncStatus.needsReauth(
        accountEmail: email,
      ),
      DriveApiFailure.notFound => DriveSyncStatus.error(
        accountEmail: email,
        message:
            'Your CVForge file on Drive is gone — syncing again will '
            'recreate it.',
      ),
      DriveApiFailure.network => DriveSyncStatus.error(
        accountEmail: email,
        message: "Couldn't reach Google Drive — saved on this device.",
      ),
      DriveApiFailure.unknown => DriveSyncStatus.error(
        accountEmail: email,
        message:
            'Something went wrong syncing to Drive — saved on this '
            'device.',
      ),
    };
  }
}
