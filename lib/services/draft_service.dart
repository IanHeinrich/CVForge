import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/draft_index.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/persisted_store.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/template_registry_service.dart';
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
class DraftService with ListenableServiceMixin, PersistedStoreMixin<CvDraft> {
  DraftService() {
    listenToReactiveValues([_drafts, _activeDraftId, persistErrorNotifier]);
  }

  final _localStorage = locator<LocalStorageService>();
  final _templateRegistry = locator<TemplateRegistryService>();
  final _uuid = const Uuid();

  @override
  LocalStorageService get storage => _localStorage;

  final ReactiveValue<List<CvDraft>> _drafts = ReactiveValue<List<CvDraft>>([]);

  /// Every saved draft, most recently updated first. Kept sorted at every
  /// write (see [_sortedByRecency] and its call sites) rather than
  /// resorting on every read here — this getter is read from build
  /// methods, so it shouldn't do the sorting work, or hand back a
  /// different list identity, on every single call.
  List<CvDraft> get drafts => _drafts.value;

  /// [drafts], most recently updated first.
  List<CvDraft> _sortedByRecency(List<CvDraft> drafts) =>
      [...drafts]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  final ReactiveValue<String?> _activeDraftId = ReactiveValue<String?>(null);
  String? get activeDraftId => _activeDraftId.value;

  /// The currently-open draft. Falls back to an unpersisted empty draft if
  /// somehow nothing is active (e.g. every draft has been deleted) — call
  /// sites that need to distinguish "no drafts at all" from "a real draft"
  /// should check [drafts]/[activeDraftId] instead of this getter.
  CvDraft get draft {
    final id = _activeDraftId.value;
    if (id == null) return _emptyDraft();
    return _drafts.value.firstWhere(
      (d) => d.id == id,
      orElse: () =>
          _drafts.value.isNotEmpty ? _drafts.value.first : _emptyDraft(),
    );
  }

  /// An unpersisted placeholder draft for when nothing is active yet (e.g.
  /// every draft has been deleted) — always stamped with a real, currently
  /// registered template id rather than a stale literal, so
  /// `TemplateRegistryService.byId`'s unknown-id fallback is never the only
  /// thing standing between this draft and a phantom template.
  CvDraft _emptyDraft() => CvDraft.empty(
    id: _uuid.v4(),
    templateId: _templateRegistry.defaultTemplate.id,
  );

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

  Future<void> load() => ready();

  @override
  Future<void> loadFromStorage() async {
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
      await quarantine(StorageBoxes.drafts, StorageKeys.draftIndex, indexRaw);
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
        await quarantine(StorageBoxes.drafts, StorageKeys.draftEntry(id), raw);
      }
    }

    if (loaded.isEmpty) {
      await _seedFirstDraft();
      return;
    }

    _drafts.value = _sortedByRecency(loaded);
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
      await quarantine(StorageBoxes.drafts, StorageKeys.currentDraftId, raw);
      draft = _emptyDraft();
      _freshDraftIds.add(draft.id);
    }

    _drafts.value = [draft];
    _activeDraftId.value = draft.id;
    await persistImmediately(draft);
    await _persistIndex();
    // The old key is left in place, dead but harmless — no destructive
    // delete needed once its data has a home in the new scheme.
  }

  Future<void> _seedFirstDraft() async {
    final first = _emptyDraft();
    _drafts.value = [first];
    _activeDraftId.value = first.id;
    _freshDraftIds.add(first.id);
    await persistImmediately(first);
    await _persistIndex();
  }

  CvDraft _migrateDraft(Map<String, dynamic> json) {
    requireSchemaVersion(json, 'draft');
    return CvDraft.fromJson(json);
  }

  DraftIndex _migrateIndex(Map<String, dynamic> json) {
    requireSchemaVersion(json, 'draft index');
    return DraftIndex.fromJson(json);
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
    await ready();
    final id = _uuid.v4();
    final created = CvDraft.empty(
      id: id,
      name: name,
      templateId: templateId ?? draft.templateId,
    ).copyWith(notes: notes);
    _drafts.value = _sortedByRecency([..._drafts.value, created]);
    _activeDraftId.value = id;
    _freshDraftIds.add(id);
    await persistImmediately(created);
    await _persistIndex();
    return id;
  }

  /// Switches which draft [draft] resolves to. No-ops for an unknown id.
  Future<void> openDraft(String id) async {
    await ready();
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
    await ready();
    final index = _drafts.value.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final updated = _drafts.value[index].copyWith(
      name: name,
      notes: notes,
      updatedAt: DateTime.now(),
    );
    _drafts.value = _sortedByRecency([
      for (final d in _drafts.value)
        if (d.id == id) updated else d,
    ]);
    await persistImmediately(updated);
  }

  /// Clones [id] as a new draft (new id, name suffixed) and makes the copy
  /// active — the fast path for starting the next application from an
  /// already-tailored CV. Returns the new draft's id, or [id] unchanged if
  /// no draft with that id exists.
  Future<String> duplicateDraft(String id) async {
    await ready();
    final index = _drafts.value.indexWhere((d) => d.id == id);
    if (index == -1) return id;
    final source = _drafts.value[index];
    final newId = _uuid.v4();
    final copy = source.copyWith(
      id: newId,
      name: '${source.name} (copy)',
      updatedAt: DateTime.now(),
    );
    _drafts.value = _sortedByRecency([..._drafts.value, copy]);
    _activeDraftId.value = newId;
    await persistImmediately(copy);
    await _persistIndex();
    return newId;
  }

  /// Deletes a draft. If it was active, another draft (arbitrarily, the
  /// first remaining) becomes active, or [activeDraftId] becomes null if
  /// none are left.
  Future<void> deleteDraft(String id) async {
    await ready();
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

  /// Wholesale-replaces every draft — the one call site is `BackupService`'s
  /// import flow. Flushes (via [persistNow]) any write still sitting in the
  /// debounce timer *before* overwriting in-memory state, for the same
  /// stale-write-clobbers-the-import reason as [VaultService.replaceAll].
  ///
  /// Deletes the storage entry for every draft id that existed before the
  /// replacement but isn't in [drafts] — what makes "replace the world"
  /// actually true at the storage layer, not just in the in-memory index;
  /// otherwise an orphaned `draft_<id>` entry survives forever, unreferenced
  /// but never cleaned up.
  Future<void> replaceAll(
    List<CvDraft> drafts, {
    required String? activeDraftId,
  }) async {
    await ready();
    await persistNow(draft);

    final oldIds = _drafts.value.map((d) => d.id).toSet();
    final newIds = drafts.map((d) => d.id).toSet();
    for (final id in oldIds.difference(newIds)) {
      await _localStorage.delete(
        StorageBoxes.drafts,
        StorageKeys.draftEntry(id),
      );
    }

    _freshDraftIds.clear(); // imported drafts are never "fresh"
    _drafts.value = _sortedByRecency(drafts);
    _activeDraftId.value = drafts.any((d) => d.id == activeDraftId)
        ? activeDraftId
        : (drafts.isNotEmpty ? drafts.first.id : null);

    for (final d in drafts) {
      await persistImmediately(d);
    }
    await _persistIndex();
  }

  // --- active-draft selection/tailoring (Studio) ---

  Future<void> setTemplate(String templateId) async {
    await ready();
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
    await ready();
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
    await ready();
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
    await ready();
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
    await ready();
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
    await ready();
    _setDraft((d) {
      final ids = [...idsOf(d)];
      if (included) {
        if (!ids.contains(id)) ids.add(id);
      } else {
        ids.remove(id);
      }
      return copyWith(d, ids);
    });
  }

  Future<void> setSectionHidden(
    CvSectionType type, {
    required bool hidden,
  }) async {
    await ready();
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
    await ready();
    _setDraft((d) => d.copyWith(tailoredSummary: summary));
  }

  Future<void> setBulletOverride(String bulletId, String? text) async {
    await ready();
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

  Future<void> setHeadlineOverride(String? headline) async {
    await ready();
    _setDraft((d) => d.copyWith(headlineOverride: headline));
  }

  Future<void> setReferencesOverride(String? references) async {
    await ready();
    _setDraft((d) => d.copyWith(referencesOverride: references));
  }

  /// Same shape as [setBulletOverride], one entity type over — only
  /// [Education.details] is prose-overridable.
  Future<void> setEducationDetailsOverride(
    String educationId,
    String? text,
  ) async {
    await ready();
    _setDraft((d) {
      final overrides = {...d.educationDetailsOverrides};
      if (text == null) {
        overrides.remove(educationId);
      } else {
        overrides[educationId] = text;
      }
      return d.copyWith(educationDetailsOverrides: overrides);
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
    _drafts.value = _sortedByRecency([
      for (final d in _drafts.value)
        if (d.id == id) updated else d,
    ]);
    scheduleWrite(updated);
  }

  /// Persists immediately, bypassing any pending debounce timer. See
  /// [VaultService.flushPendingWrites] for the two production call sites.
  Future<void> flushPendingWrites() => persistNow(draft);

  @override
  Future<void> writeToStorage(CvDraft value) => _localStorage.write(
    StorageBoxes.drafts,
    StorageKeys.draftEntry(value.id),
    jsonEncode(value.toJson()),
  );

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
      persistError = null;
    } catch (e) {
      persistError = e;
    }
  }
}
