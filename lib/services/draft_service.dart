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
    listenToReactiveValues([_draft]);
  }

  final _localStorage = locator<LocalStorageService>();

  final ReactiveValue<CvDraft> _draft = ReactiveValue<CvDraft>(CvDraft.empty());
  CvDraft get draft => _draft.value;

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
  }) async {
    await _ready();
    _setDraft((d) {
      final ids = [...d.experienceIds];
      final map = {...d.bulletIds};
      if (included) {
        if (!ids.contains(experienceId)) ids.add(experienceId);
        map[experienceId] = bulletIds;
      } else {
        ids.remove(experienceId);
        map.remove(experienceId);
      }
      return d.copyWith(experienceIds: ids, bulletIds: map);
    });
  }

  Future<void> setBulletsForExperience(
    String experienceId,
    List<String> bulletIds,
  ) async {
    await _ready();
    _setDraft(
      (d) => d.copyWith(bulletIds: {...d.bulletIds, experienceId: bulletIds}),
    );
  }

  Future<void> setSkillIncluded(
    String skillId, {
    required bool included,
  }) async {
    await _ready();
    _setDraft((d) {
      final ids = [...d.skillIds];
      if (included) {
        ids.add(skillId);
      } else {
        ids.remove(skillId);
      }
      return d.copyWith(skillIds: ids.toSet().toList());
    });
  }

  Future<void> setEducationIncluded(
    String educationId, {
    required bool included,
  }) async {
    await _ready();
    _setDraft((d) {
      final ids = [...d.educationIds];
      if (included) {
        ids.add(educationId);
      } else {
        ids.remove(educationId);
      }
      return d.copyWith(educationIds: ids.toSet().toList());
    });
  }

  Future<void> setHobbyIncluded(
    String hobbyId, {
    required bool included,
  }) async {
    await _ready();
    _setDraft((d) {
      final ids = [...d.hobbyIds];
      if (included) {
        ids.add(hobbyId);
      } else {
        ids.remove(hobbyId);
      }
      return d.copyWith(hobbyIds: ids.toSet().toList());
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

  Future<void> flushPendingWrites() async {
    if (_writeDebounce == null) return;
    _writeDebounce!.cancel();
    _writeDebounce = null;
    await _persist();
  }

  Future<void> _persist() async {
    final json = jsonEncode(_draft.value.toJson());
    await _localStorage.write(
      StorageBoxes.drafts,
      StorageKeys.currentDraftId,
      json,
    );
  }
}
