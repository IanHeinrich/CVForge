import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/draft_index.dart';
import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/models/draft/text_override_field.dart';
import 'package:cv_forge/models/identified_list.dart';
import 'package:cv_forge/models/llm/ai_assistant_result.dart';
import 'package:cv_forge/models/llm/cv_translation_result.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
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
///
/// [DocumentDefaults] now lives on the Vault, and this service still does
/// not reach for it: [createDraft] and [resetSectionSettings] take it as a
/// parameter, supplied by callers that already hold both services. Same
/// move [selectAllFromVault] makes one method over, and for the same
/// reason — "has no dependency" is a promise the import graph keeps, where
/// "only reads the harmless parts" would be one a reviewer has to.
///
/// That also retired the last read of `SettingsService` here, so this
/// service now depends on neither store: it holds ids, its own drafts,
/// and nothing else anyone owns.
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
  CvDraft _emptyDraft({DocumentDefaults defaults = const DocumentDefaults()}) {
    final templateId = _templateRegistry.defaultTemplate.id;
    return CvDraft.empty(
      id: _uuid.v4(),
      name: locator<LocalizationService>().strings.draftDefaultName,
      templateId: templateId,
      region: defaults.region,
      documentLanguage: defaults.language,
    ).copyWith(
      sectionOrder: _seedSectionOrder(templateId, defaults),
      hiddenSections: _seedHiddenSections(defaults),
      hideHeadline: defaults.hideHeadline,
    );
  }

  /// The section order a brand-new draft using [templateId] should start
  /// with: the user's remembered default if they've saved one (see
  /// [DocumentDefaults.sectionOrder]), else that template's own suggested
  /// order (`CvTemplate.sectionOrder`).
  List<CvSectionType> _seedSectionOrder(
    String templateId,
    DocumentDefaults defaults,
  ) => defaults.sectionOrder ?? _templateRegistry.byId(templateId).sectionOrder;

  /// Same rationale as [_seedSectionOrder], one field over — the user's
  /// remembered default hidden-sections state, else nothing hidden.
  Set<CvSectionType> _seedHiddenSections(DocumentDefaults defaults) =>
      defaults.hiddenSections ?? const <CvSectionType>{};

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
      if (raw == null) continue;
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
    // Deliberately the constructor defaults rather than the Vault's.
    // This runs on a first-ever launch — when the Vault has never been
    // written either, so its defaults *are* these — or as recovery after
    // every stored draft failed to parse. Reaching for VaultService here
    // would buy nothing and would cost this service its independence from
    // it (see the class doc comment).
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
    DocumentDefaults defaults = const DocumentDefaults(),
  }) async {
    await ready();
    final id = _uuid.v4();
    // An explicit argument wins, then the user's saved default, then the
    // open draft's template. That last one is the pre-defaults behaviour
    // and stays as the fallback: with no default ever chosen, inheriting
    // from the draft in front of you beats resetting to the registry's
    // first entry.
    final resolvedTemplateId =
        templateId ?? defaults.templateId ?? draft.templateId;
    final created =
        CvDraft.empty(
          id: id,
          name: name,
          templateId: resolvedTemplateId,
          region: defaults.region,
          documentLanguage: defaults.language,
        ).copyWith(
          notes: notes,
          sectionOrder: _seedSectionOrder(resolvedTemplateId, defaults),
          hiddenSections: _seedHiddenSections(defaults),
          hideHeadline: defaults.hideHeadline,
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
      name: locator<LocalizationService>().strings.draftCopySuffix(source.name),
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
  ///
  /// Flushes any pending debounced write first, for the mirror of
  /// [replaceAll]'s reason: a write still sitting on its timer would
  /// otherwise fire *after* the storage entry is deleted below and
  /// recreate it, leaving a `draft_<id>` entry no index references.
  Future<void> deleteDraft(String id) async {
    await ready();
    if (!_drafts.value.any((d) => d.id == id)) return;
    await persistNow(draft);
    _drafts.value = _drafts.value.where((d) => d.id != id).toList();
    _freshDraftIds.remove(id);
    if (_activeDraftId.value == id) {
      _activeDraftId.value = _drafts.value.isEmpty
          ? null
          : _drafts.value.first.id;
    }
    await _localStorage.delete(StorageBoxes.drafts, StorageKeys.draftEntry(id));
    // Both undo snapshots, not just one — each pass keeps its own slot, so
    // a deleted draft would otherwise leave an orphaned row behind.
    await _localStorage.delete(
      StorageBoxes.drafts,
      StorageKeys.aiAssistantUndoFor(id),
    );
    await _localStorage.delete(
      StorageBoxes.drafts,
      StorageKeys.cvTranslationUndoFor(id),
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

    _freshDraftIds.clear();
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

  /// Changes what language *this* CV is written in, leaving the Vault's
  /// default — and every other draft — alone. The independence is the
  /// point: see [CvDraft.documentLanguage].
  Future<void> setDocumentLanguage(DocumentLanguage language) async {
    await ready();
    _setDraft((d) => d.copyWith(documentLanguage: language));
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
    required Map<String, List<String>> educationBulletIds,
    required List<String> hobbyIds,
    required List<String> languageIds,
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
        educationBulletIds: educationBulletIds,
        hobbyIds: hobbyIds,
        languageIds: languageIds,
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
  ///
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

  /// Same shape as [setExperienceIncluded], one entity type over.
  ///
  /// Excluding removes this entry's key from `educationBulletIds`, which
  /// for education means "all bullets" rather than "none" — harmless,
  /// since an entry that isn't in `educationIds` prints nothing at all,
  /// and re-including writes the key back explicitly. See
  /// `CvDraft.educationBulletIds`.
  Future<void> setEducationIncluded(
    String educationId, {
    required bool included,
    List<String> bulletIds = const [],
  }) => _setIncludedWithBullets(
    educationId,
    included: included,
    bulletIds: bulletIds,
    idsOf: (d) => d.educationIds,
    bulletIdsOf: (d) => d.educationBulletIds,
    copyWith: (d, ids, map) =>
        d.copyWith(educationIds: ids, educationBulletIds: map),
  );

  Future<void> setHobbyIncluded(String hobbyId, {required bool included}) =>
      _setIdIncluded(
        hobbyId,
        included: included,
        idsOf: (d) => d.hobbyIds,
        copyWith: (d, ids) => d.copyWith(hobbyIds: ids),
      );

  Future<void> setLanguageIncluded(
    String languageId, {
    required bool included,
  }) => _setIdIncluded(
    languageId,
    included: included,
    idsOf: (d) => d.languageIds,
    copyWith: (d, ids) => d.copyWith(languageIds: ids),
  );

  /// Shared by [setSkillIncluded], [setHobbyIncluded] and
  /// [setLanguageIncluded] — each just
  /// toggles [id] in a different one of [CvDraft]'s flat id lists. Also
  /// backs [_setIncludedWithBullets]'s id-list half via [_appliedIds].
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
  /// under [owner]. Shared by all four bullet-owning draft fields rather
  /// than a hand-written method per entity.
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
        BulletOwner.education => d.copyWith(
          educationBulletIds: {...d.educationBulletIds, ownerId: bulletIds},
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

  /// Resets the active draft's section order and hidden-sections state to
  /// [DocumentDefaults], by the same fallback rule as
  /// [_seedSectionOrder]/[_seedHiddenSections]. Both in one write, so they
  /// can't end up half-reset.
  Future<void> resetSectionSettings(DocumentDefaults defaults) async {
    await ready();
    _setDraft(
      (d) => d.copyWith(
        sectionOrder: _seedSectionOrder(d.templateId, defaults),
        hiddenSections: _seedHiddenSections(defaults),
      ),
    );
  }

  Future<void> setTargetJobDescription(String? jobDescription) async {
    await ready();
    _setDraft((d) => d.copyWith(targetJobDescription: jobDescription));
  }

  /// Applies an AI Assistant tailoring pass ([result]) as a single draft
  /// update and a single persisted write, not N calls through the
  /// individual setters above — each of those reads the draft fresh, so a
  /// batch of them applied in sequence would have every call but the last
  /// overwritten. Like [createDraft]/[updateDraftDetails], this is a
  /// deliberate, infrequent action rather than continuous typing, so it
  /// persists immediately instead of going through the debounce.
  ///
  /// Writes the pre-pass draft to a distinct storage key first (see
  /// [StorageKeys.aiAssistantUndoFor]) so [undoAiAssistantPass] can restore it —
  /// superseded by the next pass, never accumulated, and routed through
  /// the same [persistImmediately] bookkeeping as every other write in
  /// this class so a failed snapshot surfaces via [persistError] rather
  /// than throwing out of this method. A returned id/text null
  /// (`result.headline`/`result.summary`) means "the model chose not to
  /// touch this", so the existing override is left alone rather than
  /// cleared.
  Future<void> applyAiAssistantResult(AiAssistantResult result) async {
    await ready();
    final id = _activeDraftId.value;
    if (id == null) return;
    final current = _drafts.value.findById(id, (d) => d.id);
    if (current == null) return;

    await _writeUndoSnapshot(StorageKeys.aiAssistantUndoFor(id), current);

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
      educationBulletIds: result.educationBulletIds,
      hobbyIds: result.hobbyIds,
      languageIds: result.languageIds,
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
  /// recent [applyAiAssistantResult] call, and clears the snapshot — a second
  /// call without an intervening pass is a no-op. Returns whether a
  /// snapshot actually existed and was restored, so the caller knows
  /// whether anything happened.
  Future<bool> undoAiAssistantPass() =>
      _restoreUndoSnapshot(StorageKeys.aiAssistantUndoFor);

  /// Whether [draftId] has a pending AI Assistant undo snapshot — the Studio UI
  /// reads this to decide whether to show "Undo AI changes" at all. Not
  /// tracked as in-memory reactive state (unlike [isFreshDraft]): a
  /// snapshot's existence is storage state that must survive a reload, so
  /// it's checked directly rather than cached in a field that would just
  /// be wrong until the next write.
  Future<bool> hasAiAssistantUndoFor(String draftId) =>
      _hasUndoSnapshot(draftId, StorageKeys.aiAssistantUndoFor);

  /// Applies a finished translation pass to the active draft.
  ///
  /// Every map is **replaced**, not merged — unlike
  /// [applyAiAssistantResult]'s `bulletOverrides`. A second pass into a
  /// different language must not leave the first language's strings behind
  /// for whatever the model declined to answer this time.
  ///
  /// Replacing is safe because the response is complete: every key the
  /// request asked about is `required` in the schema, and a term that
  /// keeps its own name comes back unchanged rather than absent (see
  /// [buildCvTranslationResponseSchema]). So a map holds an entry for
  /// every field of that section, and a missing one means the pass did not
  /// cover that field at all — in which case the Vault's own text is the
  /// right thing to fall back to.
  Future<void> applyCvTranslationResult(
    CvTranslationResult result,
    DocumentLanguage language,
  ) async {
    await ready();
    final id = _activeDraftId.value;
    if (id == null) return;
    final current = _drafts.value.findById(id, (d) => d.id);
    if (current == null) return;

    // Only if there isn't one already, so the snapshot always holds the
    // last *untranslated* state. Overwriting it on a second pass would
    // make "Remove translation" restore a CV that is still translated —
    // which is exactly what it promises not to do. The AI Assistant's
    // snapshot is overwritten every pass on purpose: "Undo" there means
    // the last pass, where this means "back to untranslated".
    final key = StorageKeys.cvTranslationUndoFor(id);
    if (!await _hasUndoSnapshot(id, StorageKeys.cvTranslationUndoFor)) {
      await _writeUndoSnapshot(key, current);
    }

    final updated = current.copyWith(
      headlineOverride: result.headline ?? current.headlineOverride,
      tailoredSummary: result.summary ?? current.tailoredSummary,
      referencesOverride: result.referencesNote ?? current.referencesOverride,
      workAuthorizationOverride:
          result.workAuthorization ?? current.workAuthorizationOverride,
      roleOverrides: result.roles,
      projectTitleOverrides: result.projectTitles,
      skillCategoryNameOverrides: result.skillCategoryNames,
      skillLabelOverrides: result.skillLabels,
      educationQualificationOverrides: result.educationQualifications,
      educationGradeOverrides: result.educationGrades,
      educationDetailsOverrides: result.educationDetails,
      hobbyOverrides: result.hobbies,
      languageOverrides: result.languages,
      bulletOverrides: {...current.bulletOverrides, ...result.bullets},
      translatedTo: language,
      updatedAt: DateTime.now(),
    );
    _freshDraftIds.remove(id);
    _drafts.value = _sortedByRecency(
      _drafts.value.replaceById(id, updated, (d) => d.id),
    );
    await persistImmediately(updated);
  }

  /// Restores the active draft to how it was immediately before the most
  /// recent [applyCvTranslationResult], clearing [CvDraft.translatedTo]
  /// with it. Returns whether a snapshot existed.
  Future<bool> removeCvTranslation() =>
      _restoreUndoSnapshot(StorageKeys.cvTranslationUndoFor);

  /// Clears every per-draft text override, so each line reads exactly as
  /// the Vault has it.
  ///
  /// The unconditional way back. Because an override records no
  /// provenance — a hand edit, an AI rewrite and a translation are the
  /// same string in the same map, which is what keeps the layer simple —
  /// nothing can undo one kind selectively. This undoes all of them, and
  /// so always works, where "Undo AI changes" and "Remove translation"
  /// each depend on a snapshot that may not be there.
  ///
  /// Deliberately leaves **selection** alone: which entries, bullets and
  /// sections appear is a separate axis, reset by [resetSectionSettings].
  /// [CvDraft.translatedTo] clears with the text it described.
  Future<void> resetWordingToVault() async {
    await ready();
    final id = _activeDraftId.value;
    if (id == null) return;
    final current = _drafts.value.findById(id, (d) => d.id);
    if (current == null) return;

    // Every id-keyed map goes through `withoutTextOverrides`, derived from
    // `TextOverrideField.values`, so a newly added overridable field is
    // reset here without anyone remembering to come back and add it. Only
    // the four scalar overrides, which aren't in that enum, are named.
    final updated = current.withoutTextOverrides().copyWith(
      headlineOverride: null,
      tailoredSummary: null,
      referencesOverride: null,
      workAuthorizationOverride: null,
      translatedTo: null,
      updatedAt: DateTime.now(),
    );
    _drafts.value = _sortedByRecency(
      _drafts.value.replaceById(id, updated, (d) => d.id),
    );
    await persistImmediately(updated);

    // Both snapshots describe a world that no longer exists — offering
    // "Undo AI changes" after this would put the AI's wording back on a
    // draft the user just reset to the Vault.
    await _localStorage.delete(
      StorageBoxes.drafts,
      StorageKeys.aiAssistantUndoFor(id),
    );
    await _localStorage.delete(
      StorageBoxes.drafts,
      StorageKeys.cvTranslationUndoFor(id),
    );
  }

  /// Whether [draftId] still has a pre-translation snapshot, and so
  /// whether "Remove translation" has anything to restore. Read by Studio
  /// to decide whether to offer it at all — a translation can be applied
  /// while the snapshot write failed, and a button that silently does
  /// nothing is worse than no button.
  Future<bool> hasCvTranslationUndoFor(String draftId) =>
      _hasUndoSnapshot(draftId, StorageKeys.cvTranslationUndoFor);

  Future<void> _writeUndoSnapshot(String key, CvDraft current) => _persistAux(
    () => _localStorage.write(
      StorageBoxes.drafts,
      key,
      jsonEncode(current.toJson()),
    ),
  );

  /// Restores the active draft from the snapshot [keyFor] names and clears
  /// it — a second call without an intervening pass is a no-op. Returns
  /// whether a snapshot actually existed and was restored, so the caller
  /// knows whether anything happened.
  ///
  /// Shared by the AI Assistant and translation passes, which snapshot to
  /// two separate keys for the reason [StorageKeys.cvTranslationUndoFor]
  /// gives, but restore identically.
  Future<bool> _restoreUndoSnapshot(String Function(String) keyFor) async {
    await ready();
    final id = _activeDraftId.value;
    if (id == null) return false;
    final key = keyFor(id);
    final raw = await _localStorage.read(StorageBoxes.drafts, key);
    if (raw == null) return false;

    CvDraft restored;
    try {
      restored = CvDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      ).copyWith(updatedAt: DateTime.now());
    } catch (_) {
      await _localStorage.delete(StorageBoxes.drafts, key);
      return false;
    }

    _drafts.value = _sortedByRecency(
      _drafts.value.replaceById(id, restored, (d) => d.id),
    );
    await persistImmediately(restored);
    await _localStorage.delete(StorageBoxes.drafts, key);
    return true;
  }

  Future<bool> _hasUndoSnapshot(
    String draftId,
    String Function(String) keyFor,
  ) async {
    await ready();
    final raw = await _localStorage.read(StorageBoxes.drafts, keyFor(draftId));
    return raw != null;
  }

  Future<void> setTailoredSummary(String? summary) async {
    await ready();
    _setDraft((d) => d.copyWith(tailoredSummary: summary));
  }

  /// Sets or clears one id-keyed text override. A null [text] removes the
  /// entry, reverting that field to the Vault's own value.
  Future<void> setTextOverride(
    TextOverrideField field,
    String id,
    String? text,
  ) async {
    await ready();
    _setDraft((d) {
      final overrides = {...field.of(d)};
      if (text == null) {
        overrides.remove(id);
      } else {
        overrides[id] = text;
      }
      return field.applyTo(d, overrides);
    });
  }

  /// Drops [field] from what [entityId] prints on this draft, or puts it
  /// back.
  ///
  /// Deliberately **not** cleared by [resetWordingToVault]: that resets
  /// what the CV *says*, and whether a field appears at all is the same
  /// axis as which entries and bullets appear — see that method's own doc.
  Future<void> setFieldOmitted(
    DraftOmittableField field,
    String entityId, {
    required bool omitted,
  }) async {
    await ready();
    _setDraft((d) => field.applyTo(d, entityId, omitted: omitted));
  }

  Future<void> setHeadlineOverride(String? headline) async {
    await ready();
    _setDraft((d) => d.copyWith(headlineOverride: headline));
  }

  Future<void> setReferencesOverride(String? references) async {
    await ready();
    _setDraft((d) => d.copyWith(referencesOverride: references));
  }

  Future<void> setHeadlineHidden(bool hidden) async {
    await ready();
    _setDraft((d) => d.copyWith(hideHeadline: hidden));
  }

  /// Applies [update] to the active draft, stamps it, and schedules a
  /// debounced write — the shared path for every selection/tailoring
  /// setter above, all of which mutate the draft the user is currently
  /// looking at in Studio.
  void _setDraft(CvDraft Function(CvDraft current) update) {
    final id = _activeDraftId.value;
    if (id == null) return;
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
  /// AI Assistant undo snapshot, the [DraftIndex]) through the same
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
