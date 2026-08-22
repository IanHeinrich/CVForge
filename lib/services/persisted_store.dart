import 'dart:async';

import 'package:cv_forge/services/local_storage_service.dart';
import 'package:stacked/stacked.dart';

/// Shared plumbing behind every service that persists an aggregate to
/// [LocalStorageService] with a debounced write and a surfaced (never
/// swallowed) persistence failure. Mixed into `VaultService` and
/// `DraftService` — see either for the concrete shape; this file owns
/// only the mechanism common to both:
///
/// - An idempotent [ready] load, safe to call from every read/write
///   method — see [ready]'s own doc comment for exactly why its
///   failure-reset has to be wired the way it is.
/// - A short debounced write via [scheduleWrite], so rapid successive
///   edits (typing, toggling checkboxes) collapse into one storage write
///   instead of one per keystroke.
/// - [persistNow], which always writes whichever value [scheduleWrite]
///   was most recently called for, not necessarily whatever the mixing-in
///   service considers "current" by the time it runs — so flushing after
///   the service has moved on to something else mid-debounce can never
///   silently drop the pending write.
/// - [persistError], surfaced rather than swallowed on a write failure,
///   per this project's "never fire-and-forget a write of user data"
///   rule.
/// - [quarantine], for a payload that fails to parse on load: written
///   aside under a timestamped key rather than discarded, so one corrupt
///   entry never blocks the rest of what's in storage from loading.
mixin PersistedStoreMixin<T> {
  /// The mixing-in service's own [LocalStorageService] — typically just
  /// `locator<LocalStorageService>()` handed back through a getter, since
  /// a mixin can't declare its own constructor-injected fields.
  LocalStorageService get storage;

  final ReactiveValue<Object?> _persistError = ReactiveValue<Object?>(null);

  /// Set when the most recent write to [storage] failed; cleared on the
  /// next successful one.
  Object? get persistError => _persistError.value;

  /// A direct setter, for a mixing-in service that persists a *second*
  /// aggregate this mixin doesn't know about (e.g. `DraftService`'s
  /// `DraftIndex`) alongside the [T] this mixin manages, and needs to
  /// report that write's own success/failure through the same
  /// [persistError] its callers already watch.
  set persistError(Object? value) => _persistError.value = value;

  /// The underlying reactive value backing [persistError] — exposed (not
  /// just the unwrapped getter) so the mixing-in service's constructor can
  /// list it in `listenToReactiveValues` alongside its own reactive state.
  ReactiveValue<Object?> get persistErrorNotifier => _persistError;

  Future<void>? _readyFuture;
  Timer? _writeDebounce;
  T? _pendingWrite;

  /// The real (possibly slow, possibly failing) initial load: reads
  /// storage, migrates/quarantines as needed, and populates whatever
  /// reactive state the mixing-in service exposes.
  Future<void> loadFromStorage();

  /// Serializes and writes [value] under this store's own key(s).
  /// Exceptions should propagate — [persistNow]/the debounced write catch
  /// and surface them via [persistError]; this should not catch them
  /// itself.
  Future<void> writeToStorage(T value);

  /// [loadFromStorage] failing (storage genuinely unavailable) must not
  /// poison every subsequent call. The reset is chained via
  /// [Future.catchError] rather than written inside [loadFromStorage]'s
  /// own `catch` block, because [Future] callbacks always run in a later
  /// microtask — so this reset is guaranteed to fire after the `??=`
  /// below has assigned to [_readyFuture]. A reset inside
  /// [loadFromStorage] itself has no such guarantee: a call that throws
  /// synchronously (never true of real storage, but true of some test
  /// doubles) would run the reset before the `??=` assignment exists to
  /// clobber, so the reset fires first and is immediately overwritten.
  Future<void> ready() => _readyFuture ??= loadFromStorage().catchError((
    Object error,
    StackTrace stackTrace,
  ) {
    _readyFuture = null;
    Error.throwWithStackTrace(error, stackTrace);
  });

  /// Schedules [target] to be written after a short debounce, cancelling
  /// (and superseding, not stacking behind) any write already scheduled.
  void scheduleWrite(T target) {
    _writeDebounce?.cancel();
    _pendingWrite = target;
    _writeDebounce = Timer(const Duration(milliseconds: 300), () {
      _pendingWrite = null;
      unawaited(persistImmediately(target));
    });
  }

  /// Flushes whichever write [scheduleWrite] is currently debouncing,
  /// bypassing the timer. Writes whichever value [scheduleWrite] was most
  /// recently called for, not [fallback] — [fallback] only covers the case
  /// where nothing is actually pending, where writing it again costs
  /// nothing. This is what keeps a flush from writing the wrong thing once
  /// "current" has moved on (e.g. the active draft switching) while a
  /// write was still in flight.
  Future<void> persistNow(T fallback) async {
    _writeDebounce?.cancel();
    _writeDebounce = null;
    final target = _pendingWrite ?? fallback;
    _pendingWrite = null;
    await persistImmediately(target);
  }

  /// Writes [value] unconditionally — used for a direct, deliberate write
  /// (e.g. a newly created entity) that has nothing to do with whatever
  /// [scheduleWrite] might separately be debouncing for a *different*
  /// value, so it must not cancel that pending write or consult
  /// [_pendingWrite]. [persistNow] and the debounce timer both funnel
  /// through this for the try/catch + [persistError] bookkeeping, but
  /// call this directly only for a write that is itself the whole point
  /// of the call, not a flush of something else.
  Future<void> persistImmediately(T value) async {
    try {
      await writeToStorage(value);
      _persistError.value = null;
    } catch (e) {
      _persistError.value = e;
    }
  }

  /// Writes [raw] — a payload that failed to parse — aside under a
  /// timestamped key derived from [originalKey], so a corrupt entry is
  /// preserved for inspection rather than silently discarded, and never
  /// collides with a real key on a later write.
  Future<void> quarantine(String box, String originalKey, String raw) async {
    final key =
        '${originalKey}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
    await storage.write(box, key, raw);
  }
}

/// Throws a [FormatException] unless [json]'s `schemaVersion` is exactly
/// [expected] — an unknown version is treated the same as corruption
/// (quarantine + fall back) rather than risking a `fromJson` call silently
/// misinterpreting a future, differently-shaped payload. Shared by every
/// migrate-on-load path; [entity] only changes the exception's message
/// (e.g. "vault", "draft", "draft index").
void requireSchemaVersion(
  Map<String, dynamic> json,
  String entity, {
  int expected = 1,
}) {
  final version = json['schemaVersion'];
  if (version != expected) {
    throw FormatException('Unsupported $entity schemaVersion: $version');
  }
}
