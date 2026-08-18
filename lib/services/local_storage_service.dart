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

  Future<void> ensureInitialized() => _initFuture ??= _init();

  Future<void> _init() async {
    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox<String>(StorageBoxes.vault),
        Hive.openBox<String>(StorageBoxes.drafts),
        Hive.openBox<String>(StorageBoxes.settings),
      ]);
    } catch (_) {
      // Allow a subsequent call to retry (e.g. IndexedDB genuinely
      // unavailable in Firefox strict-privacy mode) rather than being
      // stuck forever on one failed cached Future.
      _initFuture = null;
      rethrow;
    }
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
