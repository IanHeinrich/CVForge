import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/backup/cv_backup_merge.dart';
import 'package:cv_forge/models/drive/drive_file_snapshot.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/drive_api_client_service.dart';
import 'package:cv_forge/services/google_auth_service.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';

/// Keeps the Vault + every Draft mirrored to the user's Google Drive
/// (hidden `appDataFolder`) so signing in on a second browser recovers
/// everything — see this feature's design doc for the full picture.
///
/// Local-first by design: Hive (via [VaultService]/[DraftService]) stays
/// the single source of truth the rest of the app reads from. This service
/// only ever pushes a snapshot of that state to Drive, pulls one down, or
/// reconciles the two — always through the same whole-world
/// `CvBackupBundle` [BackupService.buildBundle] already produces for the
/// JSON export, reused verbatim rather than a second serialization path. A
/// failure here is never fatal to a local save: it surfaces as
/// [DriveSyncStatus.error]/[DriveSyncStatus.needsReauth] and retries later.
///
/// **Divergence merges, it doesn't prompt.** When Drive has moved on and
/// this device has its own unsynced edits, [mergeBackupBundles] reconciles
/// them against [_baseJson] — the last bundle both sides agreed on. Drive
/// offers no `If-Match` precondition on `files.update`, so a write can
/// still land between this device reading and writing; merging makes that
/// self-healing rather than destructive, since the losing device still
/// holds its edit locally and its own ancestor still predates our write.
///
/// Pure Dart — [GoogleAuthService] is the one dependency that needs
/// `dart:js_interop`, and only its abstract interface is imported here
/// (see that class's doc comment), so this service is registered normally
/// and fully VM-testable.
class DriveSyncService with ListenableServiceMixin {
  /// [idleDebounce]/[maxWait]/[mergedNoticeDuration] are a test seam —
  /// production code always uses the defaults. Nothing else needs them
  /// injected, so this isn't a locator registration, just constructor
  /// defaults, the same pattern `LlmService({Dio? client})`/
  /// `DriveApiClientService({Dio? client})` use.
  DriveSyncService({
    this.idleDebounce = const Duration(seconds: 4),
    this.maxWait = const Duration(seconds: 30),
    this.mergedNoticeDuration = const Duration(seconds: 6),
  }) {
    listenToReactiveValues([_status]);
  }

  final _auth = locator<GoogleAuthService>();
  final _localizationService = locator<LocalizationService>();
  final _api = locator<DriveApiClientService>();
  final _vault = locator<VaultService>();
  final _drafts = locator<DraftService>();
  final _backup = locator<BackupService>();
  final _settings = locator<SettingsService>();
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

  /// How long [DriveSyncStatus.merged] stays up before settling back to
  /// [DriveSyncStatus.idle].
  final Duration mergedNoticeDuration;

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
  bool _applyingRemote = false;
  bool _awaitingGesture = false;
  Timer? _idleTimer;
  Timer? _maxWaitTimer;
  Timer? _mergedNoticeTimer;

  String? _fileId;
  String? _accountEmail;
  int? _lastSyncedVersion;
  DateTime? _lastSyncedAt;

  /// The last bundle this device and Drive agreed on — the common ancestor
  /// [mergeBackupBundles] needs, and the baseline [_isDirty] compares
  /// against. Persisted under [StorageKeys.driveSyncBase], so unlike the
  /// in-memory signature this replaced it survives a page reload — which
  /// is what stopped the first sync after every reload misreading itself
  /// as a conflict.
  ///
  /// **Invariant: this is always the exact JSON that is on Drive right
  /// now** — either the payload just uploaded or the one just downloaded,
  /// never a post-apply local rebuild. Local rebuilds differ (applying
  /// prunes blanks and re-sorts drafts), and an ancestor that describes
  /// something neither side holds turns the next merge's diffs into
  /// phantom adds and deletes. [_mergeApplyAndPush] is ordered the way it
  /// is specifically to keep this true.
  Map<String, dynamic>? _baseJson;
  String? _baseSignature;

  Future<void>? _startFuture;

  /// Chains successive [_push]/[_reconcile] entry points so at most one
  /// sync operation is ever actually talking to Drive at a time. Without
  /// this, two independent triggers (say the idle timer and a stale
  /// max-wait timer, or a manual "Sync now" landing mid-push) could both
  /// read `_lastSyncedVersion`, both call `updateFile`, and finish out of
  /// order — the slower one's `_commitSync` then overwrites the faster
  /// one's already-correct bookkeeping with a stale value. The next
  /// check would then see Drive's real (newer) `version` disagree with
  /// that clobbered `_lastSyncedVersion` and misread *this device's own*
  /// second write as another device's.
  ///
  /// Only wraps the true external entry points ([_flush], [syncNow],
  /// [connect]/[_start]'s call to [_reconcile]) — [_push]'s own fallback
  /// call to [_reconcile], [_reconcile]'s own call to [_push], and
  /// [_push]'s call to [_mergeApplyAndPush] call the raw method directly.
  /// All happen within an already-held lock (nothing else can interleave
  /// on Dart's single-threaded event loop until the current `await` chain
  /// yields back to one of the real entry points above), so re-acquiring
  /// there would deadlock instead of protecting anything.
  Future<void>? _syncLock;

  Future<void> _runExclusive(Future<void> Function() action) async {
    final previous = _syncLock;
    final unlock = Completer<void>();
    _syncLock = unlock.future;
    if (previous != null) await previous;
    try {
      await action();
    } finally {
      unlock.complete();
    }
  }

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
    await _loadBase();
    // Honest as it stands: [lastSyncedAt] really is when this device last
    // synced, and nothing is in flight to contradict it. The reconcile
    // below deliberately waits for a user gesture rather than running now
    // — see [_resumeOnGesture].
    _status.value = DriveSyncStatus.idle(
      accountEmail: email,
      lastSyncedAt: _lastSyncedAt,
    );
    _attachListeners();
    await _auth.warmUp();
    unawaited(_resumeOnGesture());
  }

  /// Waits for the user's next interaction, then syncs.
  ///
  /// A fresh page load holds no access token — they're in-memory only, by
  /// the same rule that keeps the AI Assistant key out of storage — and GIS
  /// cannot mint a replacement without a live user gesture: it renews via
  /// a popup, and the browser refuses to open one at load, reporting
  /// `popup_failed_to_open`. Syncing immediately on start therefore fails
  /// every single time and strands the session on "Reconnect" until the
  /// user visits Settings, despite the grant being perfectly valid.
  ///
  /// Waiting costs nothing in practice — the first click or keypress
  /// arrives within seconds and the whole thing is invisible — and it
  /// keeps the failure honest: reaching [DriveSyncStatus.needsReauth] now
  /// means the grant is genuinely gone, not merely unusable this instant.
  Future<void> _resumeOnGesture() async {
    if (_awaitingGesture) return;
    _awaitingGesture = true;
    try {
      final token = await _auth.tokenOnNextUserGesture();
      if (token == null) {
        final email = _accountEmail;
        if (email != null) {
          _status.value = DriveSyncStatus.needsReauth(accountEmail: email);
        }
        return;
      }
      await _runExclusive(_reconcile);
    } finally {
      _awaitingGesture = false;
    }
  }

  Future<void> _loadBase() async {
    final stored = await _localStorage.read(
      StorageBoxes.settings,
      StorageKeys.driveSyncBase,
    );
    if (stored == null) return;
    try {
      final decoded = jsonDecode(stored);
      if (decoded is Map<String, dynamic>) _setBase(decoded);
    } on FormatException {
      // A corrupt ancestor is no worse than none — the no-ancestor path
      // unions rather than dropping anything, and the next successful
      // sync rewrites it.
    }
  }

  void _setBase(Map<String, dynamic> json) {
    _baseJson = json;
    _baseSignature = _contentSignature(json);
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
    await _runExclusive(_reconcile);
  }

  Future<String> _fetchEmailOrFallback(String token) async {
    try {
      return await _api.fetchAccountEmail(token) ??
          _localizationService.strings.driveSyncAccountFallback;
    } on DriveApiException {
      return _localizationService.strings.driveSyncAccountFallback;
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
    _mergedNoticeTimer?.cancel();
    _mergedNoticeTimer = null;
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
    await _localStorage.delete(
      StorageBoxes.settings,
      StorageKeys.driveSyncBase,
    );
    _fileId = null;
    _accountEmail = null;
    _lastSyncedVersion = null;
    _lastSyncedAt = null;
    _baseJson = null;
    _baseSignature = null;
    _status.value = const DriveSyncStatus.disconnected();
  }

  /// The "Sync now" button — flushes any pending debounce immediately and
  /// also re-checks Drive even when nothing is dirty locally (a
  /// deliberate "pull in case another device wrote" check), unlike the
  /// idle/max-wait timers which only ever fire a push.
  Future<void> syncNow() async {
    if (_accountEmail == null) return;
    _cancelTimers();
    await _runExclusive(_reconcile);
  }

  /// Flushes a pending debounced push immediately, bypassing its timer —
  /// called from `main.dart`'s `AppLifecycleState.hidden` handler
  /// alongside `VaultService.flushPendingWrites`/`DraftService.
  /// flushPendingWrites`, since a debounce timer alone can't survive the
  /// tab actually closing.
  Future<void> flushPendingWrites() => _flush();

  void _attachListeners() {
    if (_listenersAttached) return;
    _vault.addListener(_onLocalChange);
    _drafts.addListener(_onLocalChange);
    // Settings too, since CvPreferences rides in the bundle — without
    // this, changing your default region would sit unsynced until an
    // unrelated Vault edit happened to push it.
    _settings.addListener(_onLocalChange);
    _listenersAttached = true;
  }

  void _detachListeners() {
    if (!_listenersAttached) return;
    _vault.removeListener(_onLocalChange);
    _drafts.removeListener(_onLocalChange);
    _settings.removeListener(_onLocalChange);
    _listenersAttached = false;
  }

  /// Whether local content differs from what Drive currently holds —
  /// answered by comparing the bundle this device would push against
  /// [_baseSignature], not by watching timestamps.
  ///
  /// Timestamps were the previous signal and were wrong in both
  /// directions. They said "dirty" for a no-op edit (typing a character
  /// then deleting it still bumps `updatedAt`), which is why the push path
  /// needed a *second*, content-based check to avoid pointless writes. And
  /// they said "clean" whenever this device had never synced — so a fresh
  /// connect on a browser that already held a Vault took [_reconcile]'s
  /// silent-adopt branch and replaced that Vault with Drive's, losing it.
  /// No ancestor now answers "assume divergent", which routes to the merge
  /// and keeps both sides.
  ///
  /// Costs a `buildBundle()` + encode per call rather than three date
  /// comparisons. Only [_flush] and [_reconcile] call it — a handful of
  /// times a minute, never on a UI path.
  bool get _isDirty {
    final base = _baseSignature;
    if (base == null) return true;
    return _contentSignature(_backup.buildBundle().toJson()) != base;
  }

  /// Arms the debounce/max-wait timers on every local change —
  /// [_isDirty] (not this callback) is what actually decides whether
  /// there's anything to push once they fire, so this only needs to
  /// schedule the check, never track whether one is warranted.
  void _onLocalChange() {
    if (_applyingRemote) return;
    final email = _accountEmail;
    if (email == null) return;
    // A reauth state means "waiting on the user", not "waiting on the
    // debounce" — don't paper over it with `pending`.
    if (status is! DriveSyncNeedsReauth) {
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
    // status and _isDirty are both re-checked *inside* _runExclusive, not
    // just here — by the time any earlier in-flight sync finishes and
    // this actually gets to run, that earlier operation may already have
    // changed either.
    await _runExclusive(() async {
      // Reauth means "waiting on the user": automatic retries would just
      // re-fail on every subsequent edit (each one re-arms these timers).
      // Only a manual "Sync now" or reconnecting should attempt again.
      if (status is DriveSyncNeedsReauth) return;
      if (!_isDirty) return;
      await _push();
    });
  }

  /// Pushes the current local state to Drive, reconciling first if Drive
  /// holds content this device hasn't seen. Every real edit funnels
  /// through here (both timers and [_reconcile]'s dirty branch), so this
  /// is the one place that check lives.
  Future<void> _push() async {
    final email = _accountEmail;
    if (email == null) return;
    final token = await _auth.silentAccessToken();
    if (token == null) {
      // Mid-session expiry (tokens last an hour) lands here, and a
      // debounce timer is never a user gesture — so wait for one rather
      // than declaring the session dead. Nothing was written; _isDirty
      // still reads true, so the retry picks the edit up.
      unawaited(_resumeOnGesture());
      return;
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
      // An unknown version is as untrustworthy as a mismatched one: it
      // means this device has no idea what Drive holds, so writing
      // straight over it would clobber whatever is there. _isDirty
      // reaching this path with no ancestor is exactly that case.
      if (_lastSyncedVersion == null || remote.version != _lastSyncedVersion) {
        // Drive's counter moved — but Google documents `version` as
        // reflecting every server-side change, "even those not visible to
        // the user", so it can move without the content changing. Compare
        // what Drive actually holds before treating this as divergence.
        final remoteJson = await _api.downloadFile(token, fileId);
        if (_contentSignature(remoteJson) != _baseSignature) {
          await _mergeApplyAndPush(token, fileId, email, remoteJson, remote);
          return;
        }
      }
      final bundleJson = _backup.buildBundle().toJson();
      if (_contentSignature(bundleJson) == _baseSignature) {
        // Dirty enough to get here but identical to what's already on
        // Drive — nothing to write, just re-record the bookkeeping.
        await _commitSync(
          email: email,
          fileId: fileId,
          snapshot: remote,
          base: bundleJson,
        );
        return;
      }
      final updated = await _api.updateFile(token, fileId, bundleJson);
      await _commitSync(
        email: email,
        fileId: fileId,
        snapshot: updated,
        base: bundleJson,
      );
    } on DriveApiException catch (e) {
      await _handleApiError(e, email);
      // Nothing was written — _isDirty still reads true off the unchanged
      // local content, so the next debounce/max-wait tick, or an explicit
      // "Sync now"/reconnect, will retry on its own.
    } on FormatException {
      _status.value = DriveSyncStatus.error(
        accountEmail: email,
        message: _localizationService.strings.driveSyncErrorCorrupted,
      );
    }
  }

  /// Reconciles Drive's content with this device's and lands the result on
  /// both. The ordering here is load-bearing.
  ///
  /// Applying *before* pushing, and pushing a rebuild rather than the
  /// merge output, is what keeps [_baseJson]'s invariant true: applying
  /// prunes blank entries and re-sorts drafts, so a post-apply
  /// `buildBundle()` is not byte-identical to what [mergeBackupBundles]
  /// returned. Uploading the rebuild means the ancestor describes exactly
  /// what both sides hold. It also fails better — if the upload dies after
  /// a successful apply, local has the merged content, Drive and the
  /// ancestor are untouched, and the retry re-merges to the same result
  /// and pushes once. The reverse order can leave the user staring at
  /// stale data while Drive has already moved on.
  Future<void> _mergeApplyAndPush(
    String token,
    String fileId,
    String email,
    Map<String, dynamic> remoteJson,
    DriveFileSnapshot remoteMeta,
  ) async {
    final local = _backup.buildBundle();
    final remote = CvBackupBundle.fromJson(remoteJson);

    // The only divergence a merge genuinely can't settle: the other
    // device is running a build whose data shape this one doesn't know.
    // "Keep this device's copy" would be actively wrong advice there —
    // it would push older-schema content over newer — so this asks the
    // user to update rather than offering a side to discard.
    if (remote.bundleVersion > BackupService.bundleVersion ||
        !bundlesAreMergeable(local, remote)) {
      _status.value = DriveSyncStatus.error(
        accountEmail: email,
        message: _localizationService.strings.driveSyncErrorNewerVersion,
      );
      return;
    }

    final base = _baseJson == null
        ? _emptyAncestor()
        : CvBackupBundle.fromJson(_baseJson!);
    final merged = mergeBackupBundles(base: base, local: local, remote: remote);

    if (_contentSignature(merged.toJson()) == _contentSignature(remoteJson)) {
      // This device was purely behind — Drive already holds everything
      // the merge produced, so adopt it without a pointless write back.
      await _applyBundle(merged);
      await _commitSync(
        email: email,
        fileId: fileId,
        snapshot: remoteMeta,
        base: remoteJson,
      );
      return;
    }

    await _applyBundle(merged);
    final pushJson = _backup.buildBundle().toJson();
    final updated = await _api.updateFile(token, fileId, pushJson);
    await _commitSync(
      email: email,
      fileId: fileId,
      snapshot: updated,
      base: pushJson,
      merged: true,
    );
  }

  /// The ancestor to merge against when this device has never recorded
  /// one — a brand-new device, or an existing user's first sync after
  /// [StorageKeys.driveSyncBase] was introduced. Empty means every id on
  /// both sides reads as an addition, so the merge unions and drops
  /// nothing: with no ancestor there is no evidence that any absence *is*
  /// a deletion. The cost is that a delete made before this point can
  /// come back once; the alternative is discarding a side outright.
  CvBackupBundle _emptyAncestor() => CvBackupBundle(
    app: 'cv-forge',
    bundleVersion: BackupService.bundleVersion,
    exportedAt: DateTime.fromMillisecondsSinceEpoch(0),
    appVersion: '',
  );

  /// Replaces local state with [bundle], suppressing the change
  /// notifications it causes — otherwise applying Drive's own content
  /// would look like a local edit and immediately re-arm a push.
  Future<void> _applyBundle(CvBackupBundle bundle) async {
    _applyingRemote = true;
    try {
      if (bundle.vault != null) await _vault.replaceAll(bundle.vault!);
      await _drafts.replaceAll(
        bundle.drafts,
        activeDraftId: bundle.activeDraftId,
      );
      if (bundle.preferences != null) {
        await _settings.replacePreferences(bundle.preferences!);
      }
    } finally {
      _applyingRemote = false;
    }
  }

  /// Runs on every connect, app start (for a previously-connected
  /// device), and manual "Sync now" — finds or creates this feature's
  /// Drive file, then reconciles: version unchanged → push if dirty;
  /// remote moved on + local clean → adopt remote; remote moved on +
  /// local dirty → delegate to [_push], which merges.
  Future<void> _reconcile() async {
    final email = _accountEmail;
    if (email == null) return;
    final token = await _auth.silentAccessToken();
    if (token == null) {
      unawaited(_resumeOnGesture());
      return;
    }
    _status.value = DriveSyncStatus.syncing(accountEmail: email);
    try {
      var fileId = _fileId;
      if (fileId == null) {
        final existing = await _api.findFile(token);
        if (existing == null) {
          final bundleJson = _backup.buildBundle().toJson();
          final created = await _api.createFile(token, bundleJson);
          await _commitSync(
            email: email,
            fileId: created.fileId,
            snapshot: created,
            base: bundleJson,
          );
          return;
        }
        fileId = existing.fileId;
        _fileId = fileId;
      }

      final remote = await _api.fetchMetadata(token, fileId);
      final isDirty = _isDirty;
      if (_lastSyncedVersion != null && remote.version == _lastSyncedVersion) {
        _status.value = DriveSyncStatus.idle(
          accountEmail: email,
          lastSyncedAt: _lastSyncedAt,
        );
        if (isDirty) await _push();
        return;
      }

      if (!isDirty) {
        // Drive moved on and local is byte-identical to the ancestor, so
        // there is nothing here a merge could add — adopt Drive's copy
        // directly and skip the round trip. Safe in a way it wasn't when
        // dirtiness came from timestamps: "not dirty" now genuinely means
        // "this device holds exactly what Drive last gave it".
        await _pullAndApply(token, fileId, email, remote);
        return;
      }

      await _push();
    } on DriveApiException catch (e) {
      await _handleApiError(e, email);
    } on FormatException {
      _status.value = DriveSyncStatus.error(
        accountEmail: email,
        message: _localizationService.strings.driveSyncErrorCorrupted,
      );
    }
  }

  Future<void> _pullAndApply(
    String token,
    String fileId,
    String email,
    DriveFileSnapshot snapshot,
  ) async {
    final content = await _api.downloadFile(token, fileId);
    await _applyBundle(CvBackupBundle.fromJson(content));
    await _commitSync(
      email: email,
      fileId: fileId,
      snapshot: snapshot,
      // The downloaded content, not a post-apply rebuild — see _baseJson.
      base: content,
    );
  }

  /// A stable content fingerprint for [bundleJson], used both to decide
  /// whether anything needs writing and to compare Drive's copy against
  /// the ancestor.
  ///
  /// Drops `exportedAt` and `appVersion`: both change without any career
  /// data changing — the first on literally every build of a bundle, the
  /// second on every app release — so leaving either in would make every
  /// device rewrite the file for nothing. Map keys are sorted recursively
  /// so the fingerprint survives a regenerated `toJson()` reordering
  /// fields; list order is preserved, since that one *is* content. Hashing
  /// rather than keeping the JSON means the persisted ancestor's
  /// signature costs 64 characters instead of the whole bundle.
  ///
  /// Copies rather than mutating [bundleJson] in place — callers go on to
  /// use the same map (`CvBackupBundle.fromJson` needs `exportedAt` back).
  String _contentSignature(Map<String, dynamic> bundleJson) {
    final withoutVolatile = Map<String, dynamic>.from(bundleJson)
      ..remove('exportedAt')
      ..remove('appVersion');
    final canonical = jsonEncode(_canonicalize(withoutVolatile));
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  Object? _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      return {for (final key in keys) key: _canonicalize(value[key])};
    }
    if (value is List) return [for (final item in value) _canonicalize(item)];
    return value;
  }

  Future<void> _commitSync({
    required String email,
    required String fileId,
    required DriveFileSnapshot snapshot,
    required Map<String, dynamic> base,
    bool merged = false,
  }) async {
    final syncedAt = DateTime.now();
    _fileId = fileId;
    _lastSyncedVersion = snapshot.version;
    _lastSyncedAt = syncedAt;
    _setBase(base);
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveFileId,
      fileId,
    );
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedVersion,
      snapshot.version.toString(),
    );
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveLastSyncedAt,
      syncedAt.toIso8601String(),
    );
    await _localStorage.write(
      StorageBoxes.settings,
      StorageKeys.driveSyncBase,
      jsonEncode(base),
    );
    if (merged) {
      _showMergedNotice(email, syncedAt);
      return;
    }
    _status.value = DriveSyncStatus.idle(
      accountEmail: email,
      lastSyncedAt: syncedAt,
    );
  }

  /// Content arriving mid-session with no explanation reads as a glitch,
  /// so a merge says so briefly before the indicator settles back to idle.
  void _showMergedNotice(String email, DateTime syncedAt) {
    _status.value = DriveSyncStatus.merged(
      accountEmail: email,
      lastSyncedAt: syncedAt,
    );
    _mergedNoticeTimer?.cancel();
    _mergedNoticeTimer = Timer(mergedNoticeDuration, () {
      // Anything newer than the notice wins — a pending edit or a fresh
      // error must not be overwritten just because this timer came due.
      if (status is! DriveSyncMerged) return;
      _status.value = DriveSyncStatus.idle(
        accountEmail: email,
        lastSyncedAt: syncedAt,
      );
    });
  }

  Future<void> _handleApiError(DriveApiException e, String email) async {
    if (e.failure == DriveApiFailure.notFound) {
      // The Drive-side file is gone (the user disconnected the app from
      // their Google Account settings, which deletes every appDataFolder
      // file — or deleted it some other way). Forget everything that
      // described it, persisted rows included, so the next sync recreates
      // it from scratch rather than repeatedly hitting the same 404 or
      // merging against an ancestor for a file that no longer exists.
      _fileId = null;
      _lastSyncedVersion = null;
      _baseJson = null;
      _baseSignature = null;
      await _localStorage.delete(
        StorageBoxes.settings,
        StorageKeys.driveFileId,
      );
      await _localStorage.delete(
        StorageBoxes.settings,
        StorageKeys.driveLastSyncedVersion,
      );
      await _localStorage.delete(
        StorageBoxes.settings,
        StorageKeys.driveSyncBase,
      );
    }
    _status.value = switch (e.failure) {
      DriveApiFailure.needsReauth => DriveSyncStatus.needsReauth(
        accountEmail: email,
      ),
      DriveApiFailure.notFound => DriveSyncStatus.error(
        accountEmail: email,
        message: _localizationService.strings.driveSyncErrorFileGone,
      ),
      DriveApiFailure.network => DriveSyncStatus.error(
        accountEmail: email,
        message: _localizationService.strings.driveSyncErrorNetwork,
      ),
      DriveApiFailure.unknown => DriveSyncStatus.error(
        accountEmail: email,
        message: _localizationService.strings.driveSyncErrorUnknown,
      ),
    };
  }
}
