import 'dart:async';
import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/example_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/experience_bullet.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

/// Owns "The Vault" — the master career store. Reactive via
/// [ListenableServiceMixin]: a ViewModel that resolves this service and
/// mixes in `ReactiveViewModelMixin` with this in its `reactiveServices`
/// rebuilds automatically whenever [vault] or [persistError] changes.
///
/// Every read-path method awaits [_ready] first — see [LocalStorageService]
/// for why that matters on a web app with real URLs.
class VaultService with ListenableServiceMixin {
  VaultService() {
    listenToReactiveValues([_vault, _persistError]);
  }

  final _localStorage = locator<LocalStorageService>();
  final _uuid = const Uuid();

  final ReactiveValue<CvVault> _vault = ReactiveValue<CvVault>(CvVault.empty());
  CvVault get vault => _vault.value;

  /// Set when the most recent write to [LocalStorageService] failed;
  /// cleared on the next successful one. ViewModels surface this instead
  /// of letting a failed save disappear silently.
  final ReactiveValue<Object?> _persistError = ReactiveValue<Object?>(null);
  Object? get persistError => _persistError.value;

  Future<void>? _readyFuture;
  Timer? _writeDebounce;

  Future<void> _ready() => _readyFuture ??= _load();

  /// Explicit load, normally called once from `StartupViewModel`. Safe to
  /// call multiple times or not at all — every mutator/read below awaits
  /// the same underlying future via [_ready].
  Future<void> load() => _ready();

  Future<void> _load() async {
    await _localStorage.ensureInitialized();
    final raw = await _localStorage.read(
      StorageBoxes.vault,
      StorageKeys.vaultProfile,
    );
    if (raw == null) {
      _vault.value = CvVault.empty();
      return;
    }
    try {
      _vault.value = _migrate(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _quarantine(raw);
      _vault.value = CvVault.empty();
    }
  }

  CvVault _migrate(Map<String, dynamic> json) {
    // schemaVersion 1 is the only version that exists today. An unknown
    // version is treated the same as corruption (quarantine + fall back)
    // rather than risking CvVault.fromJson silently misinterpreting a
    // future, differently-shaped payload. A real v2 migration would add a
    // case here that upgrades the map before calling fromJson.
    final version = json['schemaVersion'];
    if (version != 1) {
      throw FormatException('Unsupported vault schemaVersion: $version');
    }
    return CvVault.fromJson(json);
  }

  Future<void> _quarantine(String raw) async {
    final key =
        '${StorageKeys.vaultProfile}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
    await _localStorage.write(StorageBoxes.vault, key, raw);
  }

  Future<void> loadExampleVault() async {
    await _ready();
    _setVault((_) => buildExampleVault());
  }

  // --- basics ---

  Future<void> updateBasics(ContactBasics basics) async {
    await _ready();
    _setVault((v) => v.copyWith(basics: basics));
  }

  Future<ProfileLink> addProfileLink({
    required String label,
    required String url,
  }) async {
    await _ready();
    final link = ProfileLink(id: _uuid.v4(), label: label, url: url);
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(links: [...v.basics.links, link]),
      ),
    );
    return link;
  }

  Future<void> updateProfileLink(ProfileLink link) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(
          links: _replaceById(v.basics.links, link.id, link, (l) => l.id),
        ),
      ),
    );
  }

  Future<void> deleteProfileLink(String id) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(
          links: _removeById(v.basics.links, id, (l) => l.id),
        ),
      ),
    );
  }

  Future<void> updateReferencesNote(String? note) async {
    await _ready();
    _setVault((v) => v.copyWith(referencesNote: note));
  }

  // --- experiences ---

  Future<Experience> addExperience({
    required String role,
    required String company,
    required String location,
    required YearMonth start,
    YearMonth? end,
    bool isCurrent = false,
  }) async {
    await _ready();
    final experience = Experience(
      id: _uuid.v4(),
      role: role,
      company: company,
      location: location,
      start: start,
      end: end,
      isCurrent: isCurrent,
    );
    _setVault((v) => v.copyWith(experiences: [...v.experiences, experience]));
    return experience;
  }

  Future<void> updateExperience(Experience experience) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        experiences: _replaceById(
          v.experiences,
          experience.id,
          experience,
          (e) => e.id,
        ),
      ),
    );
  }

  Future<void> deleteExperience(String experienceId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        experiences: _removeById(v.experiences, experienceId, (e) => e.id),
      ),
    );
  }

  /// Groups [experienceId] with [withExperienceId] as a promotion (same
  /// company, sequential roles) — or, when [withExperienceId] is `null`,
  /// removes [experienceId] from whatever group it's in. Reuses the
  /// target's existing `companyGroupId` if it already has one, so grouping
  /// a third role with an existing pair joins the same group rather than
  /// creating a new one.
  Future<void> groupExperience(
    String experienceId,
    String? withExperienceId,
  ) async {
    await _ready();
    if (withExperienceId == null) {
      _updateExperience(experienceId, (e) => e.copyWith(companyGroupId: null));
      return;
    }
    final target = vault.experiences.firstWhere(
      (e) => e.id == withExperienceId,
    );
    final groupId = target.companyGroupId ?? _uuid.v4();
    if (target.companyGroupId == null) {
      _updateExperience(
        withExperienceId,
        (e) => e.copyWith(companyGroupId: groupId),
      );
    }
    _updateExperience(experienceId, (e) => e.copyWith(companyGroupId: groupId));
  }

  // --- bullets ---

  Future<ExperienceBullet> addBullet(
    String experienceId, {
    String? label,
    required String text,
  }) async {
    await _ready();
    final bullet = ExperienceBullet(id: _uuid.v4(), label: label, text: text);
    _updateExperience(
      experienceId,
      (e) => e.copyWith(bullets: [...e.bullets, bullet]),
    );
    return bullet;
  }

  Future<void> updateBullet(
    String experienceId,
    ExperienceBullet bullet,
  ) async {
    await _ready();
    _updateExperience(
      experienceId,
      (e) => e.copyWith(
        bullets: _replaceById(e.bullets, bullet.id, bullet, (b) => b.id),
      ),
    );
  }

  Future<void> deleteBullet(String experienceId, String bulletId) async {
    await _ready();
    _updateExperience(
      experienceId,
      (e) => e.copyWith(bullets: _removeById(e.bullets, bulletId, (b) => b.id)),
    );
  }

  Future<void> reorderBullets(
    String experienceId,
    List<String> orderedBulletIds,
  ) async {
    await _ready();
    _updateExperience(
      experienceId,
      (e) => e.copyWith(
        bullets: [
          for (final id in orderedBulletIds)
            ...e.bullets.where((b) => b.id == id).take(1),
        ],
      ),
    );
  }

  /// Applies [update] to the single experience matching [experienceId],
  /// leaving every other experience untouched. Shared by every bullet
  /// mutator above, since they all reach through the same experience to
  /// touch its nested bullet list.
  void _updateExperience(
    String experienceId,
    Experience Function(Experience current) update,
  ) {
    _setVault(
      (v) => v.copyWith(
        experiences: [
          for (final e in v.experiences)
            if (e.id == experienceId) update(e) else e,
        ],
      ),
    );
  }

  // --- skill categories & skills ---

  Future<SkillCategory> addSkillCategory(String name) async {
    await _ready();
    final category = SkillCategory(id: _uuid.v4(), name: name);
    _setVault(
      (v) => v.copyWith(skillCategories: [...v.skillCategories, category]),
    );
    return category;
  }

  Future<void> updateSkillCategory(SkillCategory category) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: _replaceById(
          v.skillCategories,
          category.id,
          category,
          (c) => c.id,
        ),
      ),
    );
  }

  Future<void> deleteSkillCategory(String categoryId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: _removeById(
          v.skillCategories,
          categoryId,
          (c) => c.id,
        ),
      ),
    );
  }

  Future<Skill> addSkill(String categoryId, String label) async {
    await _ready();
    final skill = Skill(id: _uuid.v4(), label: label);
    _updateSkillCategory(
      categoryId,
      (c) => c.copyWith(skills: [...c.skills, skill]),
    );
    return skill;
  }

  Future<void> updateSkill(String categoryId, Skill skill) async {
    await _ready();
    _updateSkillCategory(
      categoryId,
      (c) => c.copyWith(
        skills: _replaceById(c.skills, skill.id, skill, (s) => s.id),
      ),
    );
  }

  Future<void> deleteSkill(String categoryId, String skillId) async {
    await _ready();
    _updateSkillCategory(
      categoryId,
      (c) => c.copyWith(skills: _removeById(c.skills, skillId, (s) => s.id)),
    );
  }

  /// Applies [update] to the single skill category matching [categoryId].
  /// Shared by every skill mutator, mirroring [_updateExperience] one
  /// nesting level down.
  void _updateSkillCategory(
    String categoryId,
    SkillCategory Function(SkillCategory current) update,
  ) {
    _setVault(
      (v) => v.copyWith(
        skillCategories: [
          for (final c in v.skillCategories)
            if (c.id == categoryId) update(c) else c,
        ],
      ),
    );
  }

  // --- education ---

  Future<Education> addEducation({
    required String qualification,
    required String institution,
    String? location,
    int? year,
    String? grade,
    String? details,
  }) async {
    await _ready();
    final education = Education(
      id: _uuid.v4(),
      qualification: qualification,
      institution: institution,
      location: location,
      year: year,
      grade: grade,
      details: details,
    );
    _setVault((v) => v.copyWith(education: [...v.education, education]));
    return education;
  }

  Future<void> updateEducation(Education education) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        education: _replaceById(
          v.education,
          education.id,
          education,
          (e) => e.id,
        ),
      ),
    );
  }

  Future<void> deleteEducation(String educationId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        education: _removeById(v.education, educationId, (e) => e.id),
      ),
    );
  }

  // --- hobbies ---

  Future<HobbyItem> addHobby(String text) async {
    await _ready();
    final hobby = HobbyItem(id: _uuid.v4(), text: text);
    _setVault((v) => v.copyWith(hobbies: [...v.hobbies, hobby]));
    return hobby;
  }

  Future<void> updateHobby(HobbyItem hobby) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(
        hobbies: _replaceById(v.hobbies, hobby.id, hobby, (h) => h.id),
      ),
    );
  }

  Future<void> deleteHobby(String hobbyId) async {
    await _ready();
    _setVault(
      (v) => v.copyWith(hobbies: _removeById(v.hobbies, hobbyId, (h) => h.id)),
    );
  }

  // --- persistence plumbing ---

  void _setVault(CvVault Function(CvVault current) update) {
    _vault.value = update(_vault.value).copyWith(updatedAt: DateTime.now());
    _scheduleWrite();
  }

  /// Replaces the item whose [idOf] matches [id] with [replacement],
  /// leaving every other item and the list order untouched.
  List<T> _replaceById<T>(
    List<T> items,
    String id,
    T replacement,
    String Function(T item) idOf,
  ) => [
    for (final item in items)
      if (idOf(item) == id) replacement else item,
  ];

  /// Drops the item whose [idOf] matches [id].
  List<T> _removeById<T>(
    List<T> items,
    String id,
    String Function(T item) idOf,
  ) => items.where((item) => idOf(item) != id).toList();

  void _scheduleWrite() {
    _writeDebounce?.cancel();
    _writeDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_persist());
    });
  }

  /// Persists immediately, bypassing any pending debounce timer. Called
  /// from the app-lifecycle hook in `main.dart` when the tab is about to
  /// be hidden or closed (a debounce timer alone can't survive that), and
  /// from the Vault UI's "Retry" affordance after a [persistError] — both
  /// need the same "write right now" behaviour, so one method serves both.
  Future<void> flushPendingWrites() async {
    _writeDebounce?.cancel();
    _writeDebounce = null;
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final json = jsonEncode(_vault.value.toJson());
      await _localStorage.write(
        StorageBoxes.vault,
        StorageKeys.vaultProfile,
        json,
      );
      _persistError.value = null;
    } catch (e) {
      _persistError.value = e;
    }
  }
}
