import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'storage_keys.dart';

/// The only file in this project that imports `hive_ce`. Everything else
/// persists via plain `read`/`write` of JSON strings against a named box —
/// no Hive TypeAdapters, no typeId/field-index landmines, and it makes a
/// future "export the whole Vault as JSON" feature a single [read] call.
///
/// [ensureInitialized] is idempotent (returns a cached [Future]) and safe
/// to call from multiple services concurrently — this matters because this
/// is a web app with real URLs, and refreshing on e.g. `/studio` bypasses
/// `StartupView` entirely, so every service must be able to self-initialize
/// on first read rather than assuming some other code already did it.
class LocalStorageService {
  Future<void>? _initFuture;

  /// A failed init (e.g. IndexedDB genuinely unavailable in Firefox
  /// strict-privacy mode) must not poison every subsequent call — the
  /// reset lives here, chained via [Future.catchError], not inside
  /// [_init] itself. See `VaultService._ready`'s doc comment for exactly
  /// why: a reset written inside [_init]'s own `catch` block would run
  /// (and be silently clobbered by this `??=` assignment) before this
  /// assignment ever executes, if the very first awaited call ever throws
  /// synchronously.
  Future<void> ensureInitialized() =>
      _initFuture ??= _init().catchError((Object error, StackTrace stackTrace) {
        _initFuture = null;
        Error.throwWithStackTrace(error, stackTrace);
      });

  Future<void> _init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(StorageBoxes.vault),
      Hive.openBox<String>(StorageBoxes.drafts),
      Hive.openBox<String>(StorageBoxes.settings),
    ]);
  }

  Future<String?> read(String boxName, String key) async {
    await ensureInitialized();
    return Hive.box<String>(boxName).get(key);
  }

  Future<void> write(String boxName, String key, String value) async {
    await ensureInitialized();
    await Hive.box<String>(boxName).put(key, value);
  }

  Future<void> delete(String boxName, String key) async {
    await ensureInitialized();
    await Hive.box<String>(boxName).delete(key);
  }

  Future<List<String>> keys(String boxName) async {
    await ensureInitialized();
    return Hive.box<String>(boxName).keys.cast<String>().toList();
  }
}
