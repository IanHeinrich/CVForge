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
  /// [_init] itself. See `PersistedStoreMixin.ready`'s doc comment for exactly
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
  }

  /// Opens [boxName] if it isn't already — idempotent and cheap to call on
  /// every access, since Hive returns the cached instance once a box is
  /// open. Boxes are opened lazily, one at a time on first actual access,
  /// rather than all up front at boot: [StorageBoxes.settings] has no
  /// reader yet, and there's no reason its IndexedDB round-trip should sit
  /// on the critical path to first paint for a feature that doesn't exist.
  Future<Box<String>> _box(String boxName) async {
    await ensureInitialized();
    return Hive.isBoxOpen(boxName)
        ? Hive.box<String>(boxName)
        : Hive.openBox<String>(boxName);
  }

  Future<String?> read(String boxName, String key) async {
    final box = await _box(boxName);
    return box.get(key);
  }

  Future<void> write(String boxName, String key, String value) async {
    final box = await _box(boxName);
    await box.put(key, value);
  }

  Future<void> delete(String boxName, String key) async {
    final box = await _box(boxName);
    await box.delete(key);
  }

  /// Every key in [boxName] starting with [prefix]. The one read path that
  /// isn't "I already know the key I want": `SettingsService` needs to find
  /// the API key rows it has stored without being told which providers
  /// exist, since `StorageKeys.apiKeyFor` mints one key per provider id.
  /// Enumerating beats injecting `LlmProviderRegistry` down here — the row
  /// naming is already this file's contract, and a provider removed
  /// between releases still has its row found (and so can still be
  /// cleared) rather than becoming unreachable.
  Future<List<String>> keysWithPrefix(String boxName, String prefix) async {
    final box = await _box(boxName);
    return box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .toList(growable: false);
  }
}
