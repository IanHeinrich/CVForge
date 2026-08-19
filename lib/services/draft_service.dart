import 'dart:async';
import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/draft_index.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

/// Owns every saved CV draft — "The Studio" — and which one is currently
/// open. Each [CvDraft] is its own storage entry (`draft_<id>`); a small
/// [DraftIndex] entry tracks the full set of ids, their order, and
/// [activeDraftId] so opening/renaming/reordering drafts never requires
/// rewriting every other draft's JSON.
///
/// Deliberately has NO dependency on [VaultService] — it only ever stores
/// ids, never resolves them. That decoupling is what makes deleting a
/// Vault entry safe without touching every draft that might reference it
/// (dangling ids are handled by `CvComposer`, not here).
class DraftService with ListenableServiceMixin {
  DraftService() {
    listenToReactiveValues([_drafts, _activeDraftId, _persistError]);
  }

  final _localStorage = locator<LocalStorageService>();
  final _uuid = const Uuid();

  final ReactiveValue<List<CvDraft>> _drafts = ReactiveValue<List<CvDraft>>([]);

  /// Every saved draft, most recently updated first.
  List<CvDraft> get drafts =>
      [..._drafts.value]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  final ReactiveValue<String?> _activeDraftId = ReactiveValue<String?>(null);
  String? get activeDraftId => _activeDraftId.value;

  /// The currently-open draft. Falls back to an unpersisted empty draft if
  /// somehow nothing is active (e.g. every draft has been deleted) — call
  /// sites that need to distinguish "no drafts at all" from "a real draft"
  /// should check [drafts]/[activeDraftId] instead of this getter.
  CvDraft get draft {
    final id = _activeDraftId.value;
    if (id == null) return CvDraft.empty();
    return _drafts.value.firstWhere(
      (d) => d.id == id,
      orElse: () =>
          _drafts.value.isNotEmpty ? _drafts.value.first : CvDraft.empty(),
    );
  }

  /// Ids of drafts that have never had a manual selection made — i.e. a
  /// draft the user just created (or the very first draft a first-time
  /// user gets seeded with), so its consumer knows to default it to
  /// "everything in the Vault selected" rather than empty. Cleared by the
  /// first call to [selectAllFromVault] or any other mutation on that
  /// draft, whichever comes first, so it only ever fires once per draft.
  final Set<String> _freshDraftIds = {};
  bool get isFreshDraft =>
      _activeDraftId.value != null &&
      _freshDraftIds.contains(_activeDraftId.value);

  /// Set when the most recent write to [LocalStorageService] failed;
  /// cleared on the next successful one. Mirrors [VaultService.persistError].
  final ReactiveValue<Object?> _persistError = ReactiveValue<Object?>(null);
  Object? get persistError => _persistError.value;

  Future<void>? _readyFuture;
  Timer? _writeDebounce;

  /// See `VaultService._ready`'s doc comment for why the reset lives here
  /// (via `catchError`, deferred to a later microtask) rather than inside
  /// `_load` itself.
  Future<void> _ready() => _readyFuture ??= _load().catchError((
    Object error,
    StackTrace stackTrace,
  ) {
    _readyFuture = null;
    Error.throwWithStackTrace(error, stackTrace);
  });

  Future<void> load() => _ready();

  Future<void> _load() async {
    await _localStorage.ensureInitialized();

    final indexRaw = await _localStorage.read(
      StorageBoxes.drafts,
      StorageKeys.draftIndex,
    );
    if (indexRaw != null) {
      await _loadFromIndex(indexRaw);
      return;
    }

    // No index yet — a pre-multi-draft install may still have its one
    // draft under the old single-key scheme. Migrate it rather than
    // discarding it (see `StorageKeys.currentDraftId`'s doc comment).
    final legacyRaw = await _localStorage.read(
      StorageBoxes.drafts,
      StorageKeys.currentDraftId,
    );
    if (legacyRaw != null) {
      await _migrateLegacyDraft(legacyRaw);
      return;
    }

    // Truly first-ever load: seed one fresh draft so Studio/Drafts aren't
    // empty — matches the pre-multi-draft "first-time user starts with a
    // draft ready to populate" experience.
    await _seedFirstDraft();
  }

  Future<void> _loadFromIndex(String indexRaw) async {
    DraftIndex index;
    try {
      index = _migrateIndex(jsonDecode(indexRaw) as Map<String, dynamic>);
    } catch (_) {
      await _quarantine(StorageKeys.draftIndex, indexRaw);
      index = DraftIndex.empty();
    }

    final loaded = <CvDraft>[];
    for (final id in index.draftIds) {
      final raw = await _localStorage.read(
        StorageBoxes.drafts,
        StorageKeys.draftEntry(id),
      );
      if (raw == null) continue; // dangling index entry — drop silently.
      try {
        loaded.add(_migrateDraft(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        await _quarantine(StorageKeys.draftEntry(id), raw);
      }
    }

    if (loaded.isEmpty) {
      await _seedFirstDraft();
      return;
    }

    _drafts.value = loaded;
    final requestedActive = index.activeDraftId;
    final activeStillExists = loaded.any((d) => d.id == requestedActive);
    _activeDraftId.value = activeStillExists
        ? requestedActive
        : loaded.first.id;

    // Repair the persisted index if it referenced dangling/missing ids or
    // a stale active id, so the drift doesn't get re-derived on every load.
    final repaired =
        !activeStillExists || index.draftIds.length != loaded.length;
    if (repaired) await _persistIndex();
  }

  Future<void> _migrateLegacyDraft(String raw) async {
    CvDraft draft;
    try {
      draft = _migrateDraft(jsonDecode(raw) as Map<String, dynamic>);
      // The legacy scheme always used this literal id; give it a real one
      // now that ids are meaningful (they key per-draft storage entries).
      if (draft.id == StorageKeys.currentDraftId) {
        draft = draft.copyWith(id: _uuid.v4());
      }
    } catch (_) {
      await _quarantine(StorageKeys.currentDraftId, raw);
      draft = CvDraft.empty(id: _uuid.v4());
      _freshDraftIds.add(draft.id);
    }

    _drafts.value = [draft];
    _activeDraftId.value = draft.id;
    await _persistDraft(draft);
    await _persistIndex();
    // The old key is left in place, dead but harmless — no destructive
    // delete needed once its data has a home in the new scheme.
  }

  Future<void> _seedFirstDraft() async {
    final first = CvDraft.empty(id: _uuid.v4());
    _drafts.value = [first];
    _activeDraftId.value = first.id;
    _freshDraftIds.add(first.id);
    await _persistDraft(first);
    await _persistIndex();
  }

  CvDraft _migrateDraft(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version != 1) {
      throw FormatException('Unsupported draft schemaVersion: $version');
    }
    return CvDraft.fromJson(json);
  }

  DraftIndex _migrateIndex(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version != 1) {
      throw FormatException('Unsupported draft index schemaVersion: $version');
    }
    return DraftIndex.fromJson(json);
  }

  Future<void> _quarantine(String originalKey, String raw) async {
    final key =
        '${originalKey}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
    await _localStorage.write(StorageBoxes.drafts, key, raw);
  }

  // --- draft list management (create/open/rename/duplicate/delete) ---
  //
  // These are deliberate, infrequent user actions (a button press, a
  // dialog confirm) rather than continuous typing, so unlike the
  // selection/tailoring setters below they persist immediately instead of
  // going through the debounce.

  /// Creates a new draft, makes it the active one, and marks it fresh (see
  /// [isFreshDraft]) so Studio defaults it to everything-selected. Returns
  /// the new draft's id.
  Future<String> createDraft({
    required String name,
    String notes = '',
    String? templateId,
  }) async {
    await _ready();
    final id = _uuid.v4();
    final created = CvDraft.empty(
      id: id,
      name: name,
      templateId: templateId ?? draft.templateId,
    ).copyWith(notes: notes);
    _drafts.value = [..._drafts.value, created];
    _activeDraftId.value = id;
    _freshDraftIds.add(id);
    await _persistDraft(created);
    await _persistIndex();
    return id;
  }

  /// Switches which draft [draft] resolves to. No-ops for an unknown id.
  Future<void> openDraft(String id) async {
    await _ready();
    if (_activeDraftId.value == id) return;
    if (!_drafts.value.any((d) => d.id == id)) return;
    _activeDraftId.value = id;
    await _persistIndex();
  }

  /// Updates a draft's name/notes without touching its selections. No-ops
  /// for an unknown id.
  Future<void> updateDraftDetails(
    String id, {
    required String name,
    required String notes,
  }) async {
    await _ready();
    final index = _drafts.value.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final updated = _drafts.value[index].copyWith(
      name: name,
      notes: notes,
      updatedAt: DateTime.now(),
    );
    _drafts.value = [
      for (final d in _drafts.value)
        if (d.id == id) updated else d,
    ];
    await _persistDraft(updated);
  }

  /// Clones [id] as a new draft (new id, name suffixed) and makes the copy
  /// active — the fast path for starting the next application from an
  /// already-tailored CV. Returns the new draft's id, or [id] unchanged if
  /// no draft with that id exists.
  Future<String> duplicateDraft(String id) async {
    await _ready();
    final index = _drafts.value.indexWhere((d) => d.id == id);
    if (index == -1) return id;
    final source = _drafts.value[index];
    final newId = _uuid.v4();
    final copy = source.copyWith(
      id: newId,
      name: '${source.name} (copy)',
      updatedAt: DateTime.now(),
    );
    _drafts.value = [..._drafts.value, copy];
    _activeDraftId.value = newId;
    await _persistDraft(copy);
    await _persistIndex();
    return newId;
  }

  /// Deletes a draft. If it was active, another draft (arbitrarily, the
  /// first remaining) becomes active, or [activeDraftId] becomes null if
  /// none are left.
  Future<void> deleteDraft(String id) async {
    await _ready();
    if (!_drafts.value.any((d) => d.id == id)) return;
    _drafts.value = _drafts.value.where((d) => d.id != id).toList();
    _freshDraftIds.remove(id);
    if (_activeDraftId.value == id) {
      _activeDraftId.value = _drafts.value.isEmpty
          ? null
          : _drafts.value.first.id;
    }
    await _localStorage.delete(StorageBoxes.drafts, StorageKeys.draftEntry(id));
    await _persistIndex();
  }

  // --- active-draft selection/tailoring (Studio) ---

  Future<void> setTemplate(String templateId) async {
    await _ready();
    _setDraft((d) => d.copyWith(templateId: templateId));
  }

  /// Populates a never-before-persisted draft with everything the caller
  /// hands it — meant to be called once, right after opening it, with the
  /// caller's full Vault content, so a fresh draft starts fully populated
  /// instead of empty. No-ops if [isFreshDraft] is already false, so a
  /// caller doesn't need to re-check it right before calling.
  ///
  /// Still takes plain ids/maps rather than Vault types — this service
  /// stays decoupled from `VaultService` (see the class doc comment); the
  /// caller (which already depends on both services) resolves the Vault
  /// into these shapes.
  Future<void> selectAllFromVault({
    required List<String> experienceIds,
    required Map<String, List<String>> bulletIds,
    required List<String> projectIds,
    required Map<String, List<String>> projectBulletIds,
    required List<String> skillIds,
    required List<String> educationIds,
    required List<String> hobbyIds,
  }) async {
    await _ready();
    if (!isFreshDraft) return;
    _setDraft(
      (d) => d.copyWith(
        experienceIds: experienceIds,
        bulletIds: bulletIds,
        projectIds: projectIds,
        projectBulletIds: projectBulletIds,
        skillIds: skillIds,
        educationIds: educationIds,
        hobbyIds: hobbyIds,
      ),
    );
  }

  /// Includes/excludes an experience. When including, [bulletIds] should
  /// be the full ordered set of bullet ids to show for it (typically "all
  /// of them", resolved by the caller from `VaultService` — this service
  /// never looks a Vault entity up itself). Bundled into one call so the
  /// experience-id list and its bullet selection can't go out of sync.
  Future<void> setExperienceIncluded(
    String experienceId, {
    required bool included,
    List<String> bulletIds = const [],
  }) => _setIncludedWithBullets(
    experienceId,
    included: included,
    bulletIds: bulletIds,
    idsOf: (d) => d.experienceIds,
    bulletIdsOf: (d) => d.bulletIds,
    copyWith: (d, ids, map) => d.copyWith(experienceIds: ids, bulletIds: map),
  );

  Future<void> setBulletsForExperience(
    String experienceId,
    List<String> bulletIds,
  ) async {
    await _ready();
    _setDraft(
      (d) => d.copyWith(bulletIds: {...d.bulletIds, experienceId: bulletIds}),
    );
  }

  /// Same shape as [setExperienceIncluded], one entity type over — a
  /// [Project] instead of an [Experience].
  Future<void> setProjectIncluded(
    String projectId, {
    required bool included,
    List<String> bulletIds = const [],
  }) => _setIncludedWithBullets(
    projectId,
    included: included,
    bulletIds: bulletIds,
    idsOf: (d) => d.projectIds,
    bulletIdsOf: (d) => d.projectBulletIds,
    copyWith: (d, ids, map) =>
        d.copyWith(projectIds: ids, projectBulletIds: map),
  );

  Future<void> setBulletsForProject(
    String projectId,
    List<String> bulletIds,
  ) async {
    await _ready();
    _setDraft(
      (d) => d.copyWith(
        projectBulletIds: {...d.projectBulletIds, projectId: bulletIds},
      ),
    );
  }

  /// Shared by [setExperienceIncluded] and [setProjectIncluded] — both
  /// toggle an entity's id in one list while keeping a parallel
  /// entityId->bulletIds map in sync, so the two can never drift apart.
  Future<void> _setIncludedWithBullets(
    String id, {
    required bool included,
    required List<String> bulletIds,
    required List<String> Function(CvDraft draft) idsOf,
    required Map<String, List<String>> Function(CvDraft draft) bulletIdsOf,
    required CvDraft Function(
      CvDraft draft,
      List<String> ids,
      Map<String, List<String>> bulletIds,
    )
    copyWith,
  }) async {
    await _ready();
    _setDraft((d) {
      final ids = [...idsOf(d)];
      final map = {...bulletIdsOf(d)};
      if (included) {
        if (!ids.contains(id)) ids.add(id);
        map[id] = bulletIds;
      } else {
        ids.remove(id);
        map.remove(id);
      }
      return copyWith(d, ids, map);
    });
  }

  Future<void> setSkillIncluded(String skillId, {required bool included}) =>
      _setIdIncluded(
        skillId,
        included: included,
        idsOf: (d) => d.skillIds,
        copyWith: (d, ids) => d.copyWith(skillIds: ids),
      );

  Future<void> setEducationIncluded(
    String educationId, {
    required bool included,
  }) => _setIdIncluded(
    educationId,
    included: included,
    idsOf: (d) => d.educationIds,
    copyWith: (d, ids) => d.copyWith(educationIds: ids),
  );

  Future<void> setHobbyIncluded(String hobbyId, {required bool included}) =>
      _setIdIncluded(
        hobbyId,
        included: included,
        idsOf: (d) => d.hobbyIds,
        copyWith: (d, ids) => d.copyWith(hobbyIds: ids),
      );

  /// Shared by [setSkillIncluded], [setEducationIncluded], and
  /// [setHobbyIncluded] — each just toggles [id] in a different one of
  /// [CvDraft]'s flat id lists.
  Future<void> _setIdIncluded(
    String id, {
    required bool included,
    required List<String> Function(CvDraft draft) idsOf,
    required CvDraft Function(CvDraft draft, List<String> ids) copyWith,
  }) async {
    await _ready();
    _setDraft((d) {
      final ids = [...idsOf(d)];
      if (included) {
        ids.add(id);
      } else {
        ids.remove(id);
      }
      return copyWith(d, ids.toSet().toList());
    });
  }

  Future<void> setSectionHidden(
    CvSectionType type, {
    required bool hidden,
  }) async {
    await _ready();
    _setDraft((d) {
      final hiddenSections = {...d.hiddenSections};
      if (hidden) {
        hiddenSections.add(type);
      } else {
        hiddenSections.remove(type);
      }
      return d.copyWith(hiddenSections: hiddenSections);
    });
  }

  Future<void> setTailoredSummary(String? summary) async {
    await _ready();
    _setDraft((d) => d.copyWith(tailoredSummary: summary));
  }

  Future<void> setBulletOverride(String bulletId, String? text) async {
    await _ready();
    _setDraft((d) {
      final overrides = {...d.bulletOverrides};
      if (text == null) {
        overrides.remove(bulletId);
      } else {
        overrides[bulletId] = text;
      }
      return d.copyWith(bulletOverrides: overrides);
    });
  }

  /// Applies [update] to the active draft, stamps it, and schedules a
  /// debounced write — the shared path for every selection/tailoring
  /// setter above, all of which mutate the draft the user is currently
  /// looking at in Studio.
  void _setDraft(CvDraft Function(CvDraft current) update) {
    final id = _activeDraftId.value;
    if (id == null) return; // No draft loaded yet — defensive no-op.
    _freshDraftIds.remove(id);
    final updated = update(draft).copyWith(updatedAt: DateTime.now());
    _drafts.value = [
      for (final d in _drafts.value)
        if (d.id == id) updated else d,
    ];
    _scheduleWrite(updated);
  }

  void _scheduleWrite(CvDraft target) {
    _writeDebounce?.cancel();
    _writeDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_persistDraft(target));
    });
  }

  /// Persists immediately, bypassing any pending debounce timer. See
  /// [VaultService.flushPendingWrites] for the two production call sites.
  Future<void> flushPendingWrites() async {
    _writeDebounce?.cancel();
    _writeDebounce = null;
    await _persistDraft(draft);
  }

  Future<void> _persistDraft(CvDraft target) async {
    try {
      final json = jsonEncode(target.toJson());
      await _localStorage.write(
        StorageBoxes.drafts,
        StorageKeys.draftEntry(target.id),
        json,
      );
      _persistError.value = null;
    } catch (e) {
      _persistError.value = e;
    }
  }

  Future<void> _persistIndex() async {
    try {
      final index = DraftIndex(
        schemaVersion: 1,
        draftIds: [for (final d in _drafts.value) d.id],
        activeDraftId: _activeDraftId.value,
      );
      await _localStorage.write(
        StorageBoxes.drafts,
        StorageKeys.draftIndex,
        jsonEncode(index.toJson()),
      );
      _persistError.value = null;
    } catch (e) {
      _persistError.value = e;
    }
  }
}
