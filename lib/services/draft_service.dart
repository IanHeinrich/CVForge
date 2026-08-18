import 'dart:async';
import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';

/// Owns the current tailoring/selection state — "The Studio" draft.
///
/// Deliberately has NO dependency on [VaultService] — it only ever stores
/// ids, never resolves them. That decoupling is what makes deleting a
/// Vault entry safe without touching every draft that might reference it
/// (dangling ids are handled by `CvComposer`, not here).
class DraftService with ListenableServiceMixin {
  DraftService() {
    listenToReactiveValues([_draft, _persistError]);
  }

  final _localStorage = locator<LocalStorageService>();

  final ReactiveValue<CvDraft> _draft = ReactiveValue<CvDraft>(CvDraft.empty());
  CvDraft get draft => _draft.value;

  /// Set when the most recent write to [LocalStorageService] failed;
  /// cleared on the next successful one. Mirrors [VaultService.persistError].
  final ReactiveValue<Object?> _persistError = ReactiveValue<Object?>(null);
  Object? get persistError => _persistError.value;

  Future<void>? _readyFuture;
  Timer? _writeDebounce;

  Future<void> _ready() => _readyFuture ??= _load();

  Future<void> load() => _ready();

  Future<void> _load() async {
    await _localStorage.ensureInitialized();
    final raw = await _localStorage.read(
      StorageBoxes.drafts,
      StorageKeys.currentDraftId,
    );
    if (raw == null) {
      _draft.value = CvDraft.empty();
      return;
    }
    try {
      _draft.value = _migrate(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _quarantine(raw);
      _draft.value = CvDraft.empty();
    }
  }

  CvDraft _migrate(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version != 1) {
      throw FormatException('Unsupported draft schemaVersion: $version');
    }
    return CvDraft.fromJson(json);
  }

  Future<void> _quarantine(String raw) async {
    final key =
        '${StorageKeys.currentDraftId}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
    await _localStorage.write(StorageBoxes.drafts, key, raw);
  }

  Future<void> setTemplate(String templateId) async {
    await _ready();
    _setDraft((d) => d.copyWith(templateId: templateId));
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

  void _setDraft(CvDraft Function(CvDraft current) update) {
    _draft.value = update(_draft.value).copyWith(updatedAt: DateTime.now());
    _scheduleWrite();
  }

  void _scheduleWrite() {
    _writeDebounce?.cancel();
    _writeDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_persist());
    });
  }

  /// Persists immediately, bypassing any pending debounce timer. See
  /// [VaultService.flushPendingWrites] for the two production call sites.
  Future<void> flushPendingWrites() async {
    _writeDebounce?.cancel();
    _writeDebounce = null;
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final json = jsonEncode(_draft.value.toJson());
      await _localStorage.write(
        StorageBoxes.drafts,
        StorageKeys.currentDraftId,
        json,
      );
      _persistError.value = null;
    } catch (e) {
      _persistError.value = e;
    }
  }
}
