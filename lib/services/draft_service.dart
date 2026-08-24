import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/draft_index.dart';
import 'package:cv_forge/models/identified_list.dart';
import 'package:cv_forge/models/llm/copilot_result.dart';
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/persisted_store.dart';
import 'package:cv_forge/services/settings_service.dart';
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
  final _settings = locator<SettingsService>();
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

  /// [drafts], most recently updated first, with [CvDraft.id] breaking
  /// ties. The tiebreak isn't cosmetic: `List.sort` isn't stable in Dart,
  /// so without a total order two drafts sharing an `updatedAt` can come
  /// back in either order between runs — which changes the bytes
  /// `BackupService.buildBundle` produces without any content changing, and
  /// Drive sync reads that as an edit to push.
  List<CvDraft> _sortedByRecency(List<CvDraft> drafts) =>
      [...drafts]..sort((a, b) {
        final byRecency = b.updatedAt.compareTo(a.updatedAt);
        return byRecency != 0 ? byRecency : a.id.compareTo(b.id);
      });

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
  CvDraft _emptyDraft({RegionProfile region = RegionProfile.uk}) {
    final templateId = _templateRegistry.defaultTemplate.id;
    return CvDraft.empty(
      id: _uuid.v4(),
      templateId: templateId,
      region: region,
    ).copyWith(
      sectionOrder: _seedSectionOrder(templateId),
      hiddenSections: _seedHiddenSections(),
    );
  }

  /// The section order a brand-new draft using [templateId] should start
  /// with: the user's remembered default if they've saved one (see
  /// `AppSettings.defaultSectionOrder`), else that template's own
  /// suggested order (`CvTemplate.sectionOrder`).
  List<CvSectionType> _seedSectionOrder(String templateId) =>
      _settings.settings.preferences.defaultSectionOrder ??
      _templateRegistry.byId(templateId).sectionOrder;

  /// Same seed-only rationale as [_seedSectionOrder], one field over — the
  /// user's remembered default hidden-sections state (see
  /// `AppSettings.defaultHiddenSections`), else nothing hidden.
  Set<CvSectionType> _seedHiddenSections() =>
      _settings.settings.preferences.defaultHiddenSections ??
      const <CvSectionType>{};

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
    await _settings.ready();
    final first = _emptyDraft(
      region: _settings.settings.preferences.defaultRegion,
    );
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

  /// Creates a new draft, makes it the active one, and marks it fresh (see
  /// [isFreshDraft]) so Studio defaults it to everything-selected. Returns
  /// the new draft's id.
  ///
  /// This and the other draft list management methods below
  /// (open/rename/duplicate/delete) are deliberate, infrequent user
  /// actions — a button press, a dialog confirm — rather than continuous
  /// typing, so unlike the selection/tailoring setters further down they
  /// persist immediately instead of going through the debounce.
  Future<String> createDraft({
    required String name,
    String notes = '',
    String? templateId,
  }) async {
    await ready();
    await _settings.ready();
    final id = _uuid.v4();
    final resolvedTemplateId = templateId ?? draft.templateId;
    final created =
        CvDraft.empty(
          id: id,
          name: name,
          templateId: resolvedTemplateId,
          region: _settings.settings.preferences.defaultRegion,
        ).copyWith(
          notes: notes,
          sectionOrder: _seedSectionOrder(resolvedTemplateId),
          hiddenSections: _seedHiddenSections(),
        );
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
    final current = _drafts.value.findById(id, (d) => d.id);
    if (current == null) return;
    final updated = current.copyWith(
      name: name,
      notes: notes,
      updatedAt: DateTime.now(),
    );
    _drafts.value = _sortedByRecency(
      _drafts.value.replaceById(id, updated, (d) => d.id),
    );
    await persistImmediately(updated);
  }

  /// Clones [id] as a new draft (new id, name suffixed) and makes the copy
  /// active — the fast path for starting the next application from an
  /// already-tailored CV. Returns the new draft's id, or [id] unchanged if
  /// no draft with that id exists.
  Future<String> duplicateDraft(String id) async {
    await ready();
    final source = _drafts.value.findById(id, (d) => d.id);
    if (source == null) return id;
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
    await _localStorage.delete(
      StorageBoxes.drafts,
      StorageKeys.copilotUndoFor(id),
    );
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

  Future<void> setTemplate(String templateId) async {
    await ready();
    _setDraft((d) => d.copyWith(templateId: templateId));
  }

  Future<void> setRegion(RegionProfile region) async {
    await ready();
    _setDraft((d) => d.copyWith(region: region));
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
    required List<String> publicationIds,
    required Map<String, List<String>> publicationBulletIds,
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
        publicationIds: publicationIds,
        publicationBulletIds: publicationBulletIds,
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

  /// Same shape as [setExperienceIncluded]/[setProjectIncluded], one
  /// entity type over — a [Publication] instead of a [Project].
  Future<void> setPublicationIncluded(
    String publicationId, {
    required bool included,
    List<String> bulletIds = const [],
  }) => _setIncludedWithBullets(
    publicationId,
    included: included,
    bulletIds: bulletIds,
    idsOf: (d) => d.publicationIds,
    bulletIdsOf: (d) => d.publicationBulletIds,
    copyWith: (d, ids, map) =>
        d.copyWith(publicationIds: ids, publicationBulletIds: map),
  );

  /// Shared by [setExperienceIncluded], [setProjectIncluded] and
  /// [setPublicationIncluded] — each toggles an entity's id in one list
  /// while keeping a parallel entityId->bulletIds map in sync via
  /// [_setIdIncluded]'s core, so the two can never drift apart.
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
      final ids = _appliedIds(idsOf(d), id, included: included);
      final map = {...bulletIdsOf(d)};
      if (included) {
        map[id] = bulletIds;
      } else {
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
  /// [CvDraft]'s flat id lists. Also backs [_setIncludedWithBullets]'s
  /// id-list half via [_appliedIds].
  Future<void> _setIdIncluded(
    String id, {
    required bool included,
    required List<String> Function(CvDraft draft) idsOf,
    required CvDraft Function(CvDraft draft, List<String> ids) copyWith,
  }) async {
    await ready();
    _setDraft(
      (d) => copyWith(d, _appliedIds(idsOf(d), id, included: included)),
    );
  }

  /// [ids] with [id] added (if absent) or removed, per [included] — the
  /// pure add-or-remove core shared by [_setIdIncluded] and
  /// [_setIncludedWithBullets].
  List<String> _appliedIds(
    List<String> ids,
    String id, {
    required bool included,
  }) {
    final result = [...ids];
    if (included) {
      if (!result.contains(id)) result.add(id);
    } else {
      result.remove(id);
    }
    return result;
  }

  /// Replaces the bullet selection for the entity [ownerId] refers to,
  /// under [owner]. Shared by every bullet-owning draft field
  /// (experience/project/publication — [CvDraft] has no education
  /// equivalent, see [BulletOwner]'s doc comment) rather than a
  /// hand-written method per entity.
  Future<void> setBulletIds(
    BulletOwner owner,
    String ownerId,
    List<String> bulletIds,
  ) async {
    await ready();
    _setDraft(
      (d) => switch (owner) {
        BulletOwner.experience => d.copyWith(
          bulletIds: {...d.bulletIds, ownerId: bulletIds},
        ),
        BulletOwner.project => d.copyWith(
          projectBulletIds: {...d.projectBulletIds, ownerId: bulletIds},
        ),
        BulletOwner.publication => d.copyWith(
          publicationBulletIds: {...d.publicationBulletIds, ownerId: bulletIds},
        ),
        BulletOwner.education => throw UnsupportedError(
          'CvDraft has no per-bullet selection for education entries.',
        ),
      },
    );
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

  Future<void> setSectionOrder(List<CvSectionType> order) async {
    await ready();
    _setDraft((d) => d.copyWith(sectionOrder: order));
  }

  /// Resets the active draft's section order AND hidden-sections state
  /// back to the user's default — their remembered default (see
  /// `AppSettings.defaultSectionOrder`/`AppSettings.defaultHiddenSections`)
  /// if they've saved one, else the active draft's own template's
  /// suggested order with nothing hidden. Same fallback rule as
  /// [_seedSectionOrder]/[_seedHiddenSections], just applied to an
  /// existing draft instead of a brand-new one, and both fields reset
  /// together in one write so they can't end up half-reset.
  Future<void> resetSectionSettings() async {
    await ready();
    await _settings.ready();
    _setDraft(
      (d) => d.copyWith(
        sectionOrder: _seedSectionOrder(d.templateId),
        hiddenSections: _seedHiddenSections(),
      ),
    );
  }

  Future<void> setTargetJobDescription(String? jobDescription) async {
    await ready();
    _setDraft((d) => d.copyWith(targetJobDescription: jobDescription));
  }

  /// Applies a Copilot tailoring pass ([result]) as a single draft update
  /// and a single persisted write — not N calls through the individual
  /// setters above, which produced a real "select all only selected one
  /// bullet" bug at ten times this scale when tried. Like
  /// [createDraft]/[updateDraftDetails], this is a deliberate, infrequent
  /// action rather than continuous typing, so it persists immediately
  /// instead of going through the debounce.
  ///
  /// Writes the pre-pass draft to a distinct storage key first (see
  /// [StorageKeys.copilotUndoFor]) so [undoCopilotPass] can restore it —
  /// superseded by the next pass, never accumulated, and routed through
  /// the same [persistImmediately] bookkeeping as every other write in
  /// this class so a failed snapshot surfaces via [persistError] rather
  /// than throwing out of this method. A returned id/text null
  /// (`result.headline`/`result.summary`) means "the model chose not to
  /// touch this", so the existing override is left alone rather than
  /// cleared.
  Future<void> applyCopilotResult(CopilotResult result) async {
    await ready();
    final id = _activeDraftId.value;
    if (id == null) return;
    final current = _drafts.value.findById(id, (d) => d.id);
    if (current == null) return;

    await _persistAux(
      () => _localStorage.write(
        StorageBoxes.drafts,
        StorageKeys.copilotUndoFor(id),
        jsonEncode(current.toJson()),
      ),
    );

    final updated = current.copyWith(
      headlineOverride: result.headline ?? current.headlineOverride,
      tailoredSummary: result.summary ?? current.tailoredSummary,
      experienceIds: result.experienceIds,
      bulletIds: result.bulletIds,
      projectIds: result.projectIds,
      projectBulletIds: result.projectBulletIds,
      bulletOverrides: {...current.bulletOverrides, ...result.bulletOverrides},
      skillIds: result.skillIds,
      educationIds: result.educationIds,
      hobbyIds: result.hobbyIds,
      publicationIds: result.publicationIds,
      publicationBulletIds: result.publicationBulletIds,
      hiddenSections: result.hiddenSections,
      updatedAt: DateTime.now(),
    );
    _freshDraftIds.remove(id);
    _drafts.value = _sortedByRecency(
      _drafts.value.replaceById(id, updated, (d) => d.id),
    );
    await persistImmediately(updated);
  }

  /// Restores the active draft to how it was immediately before the most
  /// recent [applyCopilotResult] call, and clears the snapshot — a second
  /// call without an intervening pass is a no-op. Returns whether a
  /// snapshot actually existed and was restored, so the caller knows
  /// whether anything happened.
  Future<bool> undoCopilotPass() async {
    await ready();
    final id = _activeDraftId.value;
    if (id == null) return false;
    final raw = await _localStorage.read(
      StorageBoxes.drafts,
      StorageKeys.copilotUndoFor(id),
    );
    if (raw == null) return false;

    CvDraft restored;
    try {
      restored = CvDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      ).copyWith(updatedAt: DateTime.now());
    } catch (_) {
      await _localStorage.delete(
        StorageBoxes.drafts,
        StorageKeys.copilotUndoFor(id),
      );
      return false;
    }

    _drafts.value = _sortedByRecency(
      _drafts.value.replaceById(id, restored, (d) => d.id),
    );
    await persistImmediately(restored);
    await _localStorage.delete(
      StorageBoxes.drafts,
      StorageKeys.copilotUndoFor(id),
    );
    return true;
  }

  /// Whether [draftId] has a pending Copilot undo snapshot — the Studio UI
  /// reads this to decide whether to show "Undo AI changes" at all. Not
  /// tracked as in-memory reactive state (unlike [isFreshDraft]): a
  /// snapshot's existence is storage state that must survive a reload, so
  /// it's checked directly rather than cached in a field that would just
  /// be wrong until the next write.
  Future<bool> hasCopilotUndoFor(String draftId) async {
    await ready();
    final raw = await _localStorage.read(
      StorageBoxes.drafts,
      StorageKeys.copilotUndoFor(draftId),
    );
    return raw != null;
  }

  Future<void> setTailoredSummary(String? summary) async {
    await ready();
    _setDraft((d) => d.copyWith(tailoredSummary: summary));
  }

  Future<void> setBulletOverride(String bulletId, String? text) async {
    await ready();
    _setDraft(
      (d) => d.copyWith(
        bulletOverrides: _appliedMapEntry(d.bulletOverrides, bulletId, text),
      ),
    );
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
    _setDraft(
      (d) => d.copyWith(
        educationDetailsOverrides: _appliedMapEntry(
          d.educationDetailsOverrides,
          educationId,
          text,
        ),
      ),
    );
  }

  /// [map] with [key] set to [value], or removed if [value] is null —
  /// shared by [setBulletOverride] and [setEducationDetailsOverride].
  Map<String, String> _appliedMapEntry(
    Map<String, String> map,
    String key,
    String? value,
  ) {
    final result = {...map};
    if (value == null) {
      result.remove(key);
    } else {
      result[key] = value;
    }
    return result;
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
    _drafts.value = _sortedByRecency(
      _drafts.value.replaceById(id, updated, (d) => d.id),
    );
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
    final index = DraftIndex(
      schemaVersion: 1,
      draftIds: [for (final d in _drafts.value) d.id],
      activeDraftId: _activeDraftId.value,
    );
    await _persistAux(
      () => _localStorage.write(
        StorageBoxes.drafts,
        StorageKeys.draftIndex,
        jsonEncode(index.toJson()),
      ),
    );
  }

  /// Writes something other than the [CvDraft] this mixin manages (a
  /// Copilot undo snapshot, the [DraftIndex]) through the same
  /// try/catch-and-surface-via-[persistError] bookkeeping
  /// [PersistedStoreMixin.persistImmediately] gives the primary write —
  /// so a failure here is never silently swallowed either.
  Future<void> _persistAux(Future<void> Function() write) async {
    try {
      await write();
      persistError = null;
    } catch (e) {
      persistError = e;
    }
  }
}
