import 'dart:async';

import 'package:cv_forge/services/local_storage_service.dart';
import 'package:stacked/stacked.dart';

/// Shared plumbing behind every service that persists an aggregate to
/// [LocalStorageService] with a debounced write and a surfaced (never
/// swallowed) persistence failure. Mixed into `VaultService` and
/// `DraftService`; this file owns only the mechanism common to both.
///
/// [ready] is idempotent and safe to call from every read and write.
/// [scheduleWrite] collapses rapid edits into one storage write.
/// [persistNow] flushes whichever value [scheduleWrite] was most recently
/// called for, so a flush after the service has moved on can never drop
/// the pending write. [persistError] is surfaced per this project's "never
/// fire-and-forget a write of user data" rule, and [quarantine] sets a
/// corrupt payload aside so it can't block the rest of storage.
mixin PersistedStoreMixin<T> {
  /// The mixing-in service's own [LocalStorageService], through a getter
  /// because a mixin cannot declare constructor-injected fields.
  LocalStorageService get storage;

  final ReactiveValue<Object?> _persistError = ReactiveValue<Object?>(null);

  /// Set when the most recent write to [storage] failed; cleared on the
  /// next successful one.
  Object? get persistError => _persistError.value;

  /// For a service persisting a *second* aggregate this mixin doesn't know
  /// about (`DraftService`'s `DraftIndex`), reporting through the same
  /// [persistError] its callers already watch.
  set persistError(Object? value) => _persistError.value = value;

  /// The reactive value behind [persistError], exposed so the mixing-in
  /// service can list it in `listenToReactiveValues`.
  ReactiveValue<Object?> get persistErrorNotifier => _persistError;

  Future<void>? _readyFuture;
  Timer? _writeDebounce;
  T? _pendingWrite;

  /// The initial load: read storage, migrate or quarantine as needed, and
  /// populate the mixing-in service's reactive state.
  Future<void> loadFromStorage();

  /// Serializes and writes [value] under this store's own key(s).
  /// Exceptions should propagate — [persistNow]/the debounced write catch
  /// and surface them via [persistError]; this should not catch them
  /// itself.
  Future<void> writeToStorage(T value);

  /// A failed [loadFromStorage] must not poison every later call, so
  /// [_readyFuture] resets on failure.
  ///
  /// The reset is chained through [Future.catchError] rather than written
  /// in [loadFromStorage]'s own `catch`, because [Future] callbacks run in
  /// a later microtask and so are guaranteed to fire *after* the `??=`
  /// assigns. Inside [loadFromStorage] there is no such guarantee: a
  /// synchronous throw (some test doubles) resets before the assignment
  /// exists, and is immediately overwritten by it.
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

  /// Flushes the debounced write, bypassing the timer. Writes whichever
  /// value [scheduleWrite] last received, not [fallback] — [fallback] only
  /// covers "nothing pending", where rewriting it costs nothing. That is
  /// what keeps a flush from writing the wrong thing once "current" has
  /// moved on, e.g. the active draft switching mid-write.
  Future<void> persistNow(T fallback) async {
    _writeDebounce?.cancel();
    _writeDebounce = null;
    final target = _pendingWrite ?? fallback;
    _pendingWrite = null;
    await persistImmediately(target);
  }

  /// Writes [value] unconditionally, without cancelling or consulting a
  /// debounce that may be pending for a *different* value. [persistNow]
  /// and the debounce timer funnel through here for the try/catch and
  /// [persistError] bookkeeping — call it directly only for a write that
  /// is itself the point, never as a flush of something else.
  Future<void> persistImmediately(T value) async {
    try {
      await writeToStorage(value);
      _persistError.value = null;
    } catch (e) {
      _persistError.value = e;
    }
  }

  /// Sets a payload that failed to parse aside under a timestamped key, so
  /// it is preserved for inspection and can never collide with a real key.
  Future<void> quarantine(String box, String originalKey, String raw) async {
    final key =
        '${originalKey}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
    await storage.write(box, key, raw);
  }
}

/// Throws a [FormatException] unless [json]'s `schemaVersion` is exactly
/// [expected]. An unknown version is treated as corruption rather than
/// risking `fromJson` misreading a future, differently-shaped payload.
/// [entity] only changes the message.
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
