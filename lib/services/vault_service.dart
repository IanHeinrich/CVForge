import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/identified_list.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/fixtures/example_vault.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/local_storage_service.dart';
import 'package:cv_forge/services/persisted_store.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

/// Owns "The Vault" — the master career store. Reactive via
/// [ListenableServiceMixin]: a ViewModel that resolves this service and
/// mixes in `ReactiveViewModelMixin` with this in its `reactiveServices`
/// rebuilds automatically whenever [vault] or [persistError] changes.
///
/// Every read-path method awaits [ready] first (from [PersistedStoreMixin])
/// — see [LocalStorageService] for why that matters on a web app with real
/// URLs.
class VaultService with ListenableServiceMixin, PersistedStoreMixin<CvVault> {
  VaultService() {
    listenToReactiveValues([_vault, persistErrorNotifier]);
  }

  final _localStorage = locator<LocalStorageService>();
  final _uuid = const Uuid();

  @override
  LocalStorageService get storage => _localStorage;

  final ReactiveValue<CvVault> _vault = ReactiveValue<CvVault>(CvVault.empty());
  CvVault get vault => _vault.value;

  /// Explicit load, normally called once from `StartupViewModel`. Safe to
  /// call multiple times or not at all — every mutator/read below awaits
  /// the same underlying future via [ready].
  Future<void> load() => ready();

  @override
  Future<void> loadFromStorage() async {
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
      await quarantine(StorageBoxes.vault, StorageKeys.vaultProfile, raw);
      _vault.value = CvVault.empty();
    }
  }

  CvVault _migrate(Map<String, dynamic> json) {
    // schemaVersion 1 is the only version that exists today. A real v2
    // migration would add a case here that upgrades the map before
    // calling fromJson — see [requireSchemaVersion]'s doc comment for why
    // an unknown version is treated as corruption rather than risking
    // fromJson silently misinterpreting a differently-shaped payload.
    requireSchemaVersion(json, 'vault');
    return CvVault.fromJson(json);
  }

  Future<void> loadExampleVault() async {
    await ready();
    _setVault((_) => buildExampleVault());
  }

  /// Resets the Vault back to [CvVault.empty] — the same starting point as
  /// a first-ever launch, so the empty-state choice ("Load example CV" or
  /// build from scratch) is available again afterwards.
  Future<void> clearVault() async {
    await ready();
    _setVault((_) => CvVault.empty());
  }

  // --- basics ---

  Future<void> updateBasics(ContactBasics basics) async {
    await ready();
    _setVault((v) => v.copyWith(basics: basics));
  }

  Future<ProfileLink> addProfileLink({
    required String label,
    required String url,
  }) async {
    await ready();
    final link = ProfileLink(id: _uuid.v4(), label: label, url: url);
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(links: [...v.basics.links, link]),
      ),
    );
    return link;
  }

  Future<void> updateProfileLink(ProfileLink link) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(
          links: v.basics.links.replaceById(link.id, link, (l) => l.id),
        ),
      ),
    );
  }

  Future<void> deleteProfileLink(String id) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        basics: v.basics.copyWith(
          links: v.basics.links.removeById(id, (l) => l.id),
        ),
      ),
    );
  }

  Future<void> updateReferencesNote(String? note) async {
    await ready();
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
    await ready();
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
    await ready();
    _setVault(
      (v) => v.copyWith(
        experiences: v.experiences.replaceById(
          experience.id,
          experience,
          (e) => e.id,
        ),
      ),
    );
  }

  Future<void> deleteExperience(String experienceId) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        experiences: v.experiences.removeById(experienceId, (e) => e.id),
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
    await ready();
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

  Future<CvBullet> addBullet(
    String experienceId, {
    String? label,
    required String text,
  }) async {
    await ready();
    final bullet = CvBullet(id: _uuid.v4(), label: label, text: text);
    _updateExperience(
      experienceId,
      (e) => e.copyWith(bullets: [...e.bullets, bullet]),
    );
    return bullet;
  }

  Future<void> updateBullet(String experienceId, CvBullet bullet) async {
    await ready();
    _updateExperience(
      experienceId,
      (e) => e.copyWith(
        bullets: e.bullets.replaceById(bullet.id, bullet, (b) => b.id),
      ),
    );
  }

  Future<void> deleteBullet(String experienceId, String bulletId) async {
    await ready();
    _updateExperience(
      experienceId,
      (e) => e.copyWith(bullets: e.bullets.removeById(bulletId, (b) => b.id)),
    );
  }

  Future<void> reorderBullets(
    String experienceId,
    List<String> orderedBulletIds,
  ) async {
    await ready();
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

  // --- projects ---

  Future<Project> addProject({required String title, String? link}) async {
    await ready();
    final project = Project(id: _uuid.v4(), title: title, link: link);
    _setVault((v) => v.copyWith(projects: [...v.projects, project]));
    return project;
  }

  Future<void> updateProject(Project project) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        projects: v.projects.replaceById(project.id, project, (p) => p.id),
      ),
    );
  }

  Future<void> deleteProject(String projectId) async {
    await ready();
    _setVault(
      (v) =>
          v.copyWith(projects: v.projects.removeById(projectId, (p) => p.id)),
    );
  }

  // --- project bullets ---

  Future<CvBullet> addProjectBullet(
    String projectId, {
    String? label,
    required String text,
  }) async {
    await ready();
    final bullet = CvBullet(id: _uuid.v4(), label: label, text: text);
    _updateProject(
      projectId,
      (p) => p.copyWith(bullets: [...p.bullets, bullet]),
    );
    return bullet;
  }

  Future<void> updateProjectBullet(String projectId, CvBullet bullet) async {
    await ready();
    _updateProject(
      projectId,
      (p) => p.copyWith(
        bullets: p.bullets.replaceById(bullet.id, bullet, (b) => b.id),
      ),
    );
  }

  Future<void> deleteProjectBullet(String projectId, String bulletId) async {
    await ready();
    _updateProject(
      projectId,
      (p) => p.copyWith(bullets: p.bullets.removeById(bulletId, (b) => b.id)),
    );
  }

  Future<void> reorderProjectBullets(
    String projectId,
    List<String> orderedBulletIds,
  ) async {
    await ready();
    _updateProject(
      projectId,
      (p) => p.copyWith(
        bullets: [
          for (final id in orderedBulletIds)
            ...p.bullets.where((b) => b.id == id).take(1),
        ],
      ),
    );
  }

  /// Applies [update] to the single project matching [projectId]. Mirrors
  /// [_updateExperience] — same shape, one entity type over.
  void _updateProject(
    String projectId,
    Project Function(Project current) update,
  ) {
    _setVault(
      (v) => v.copyWith(
        projects: [
          for (final p in v.projects)
            if (p.id == projectId) update(p) else p,
        ],
      ),
    );
  }

  // --- skill categories & skills ---

  Future<SkillCategory> addSkillCategory(String name) async {
    await ready();
    final category = SkillCategory(id: _uuid.v4(), name: name);
    _setVault(
      (v) => v.copyWith(skillCategories: [...v.skillCategories, category]),
    );
    return category;
  }

  Future<void> updateSkillCategory(SkillCategory category) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: v.skillCategories.replaceById(
          category.id,
          category,
          (c) => c.id,
        ),
      ),
    );
  }

  Future<void> deleteSkillCategory(String categoryId) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        skillCategories: v.skillCategories.removeById(categoryId, (c) => c.id),
      ),
    );
  }

  Future<Skill> addSkill(String categoryId, String label) async {
    await ready();
    final skill = Skill(id: _uuid.v4(), label: label);
    _updateSkillCategory(
      categoryId,
      (c) => c.copyWith(skills: [...c.skills, skill]),
    );
    return skill;
  }

  Future<void> updateSkill(String categoryId, Skill skill) async {
    await ready();
    _updateSkillCategory(
      categoryId,
      (c) => c.copyWith(
        skills: c.skills.replaceById(skill.id, skill, (s) => s.id),
      ),
    );
  }

  Future<void> deleteSkill(String categoryId, String skillId) async {
    await ready();
    _updateSkillCategory(
      categoryId,
      (c) => c.copyWith(skills: c.skills.removeById(skillId, (s) => s.id)),
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
    await ready();
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
    await ready();
    _setVault(
      (v) => v.copyWith(
        education: v.education.replaceById(
          education.id,
          education,
          (e) => e.id,
        ),
      ),
    );
  }

  Future<void> deleteEducation(String educationId) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        education: v.education.removeById(educationId, (e) => e.id),
      ),
    );
  }

  // --- education bullets ---

  Future<CvBullet> addEducationBullet(
    String educationId, {
    String? label,
    required String text,
  }) async {
    await ready();
    final bullet = CvBullet(id: _uuid.v4(), label: label, text: text);
    _updateEducation(
      educationId,
      (e) => e.copyWith(bullets: [...e.bullets, bullet]),
    );
    return bullet;
  }

  Future<void> updateEducationBullet(
    String educationId,
    CvBullet bullet,
  ) async {
    await ready();
    _updateEducation(
      educationId,
      (e) => e.copyWith(
        bullets: e.bullets.replaceById(bullet.id, bullet, (b) => b.id),
      ),
    );
  }

  Future<void> deleteEducationBullet(
    String educationId,
    String bulletId,
  ) async {
    await ready();
    _updateEducation(
      educationId,
      (e) => e.copyWith(bullets: e.bullets.removeById(bulletId, (b) => b.id)),
    );
  }

  Future<void> reorderEducationBullets(
    String educationId,
    List<String> orderedBulletIds,
  ) async {
    await ready();
    _updateEducation(
      educationId,
      (e) => e.copyWith(
        bullets: [
          for (final id in orderedBulletIds)
            ...e.bullets.where((b) => b.id == id).take(1),
        ],
      ),
    );
  }

  /// Applies [update] to the single education entry matching [educationId].
  /// Mirrors [_updateExperience]/[_updateProject] — same shape, one entity
  /// type over.
  void _updateEducation(
    String educationId,
    Education Function(Education current) update,
  ) {
    _setVault(
      (v) => v.copyWith(
        education: [
          for (final e in v.education)
            if (e.id == educationId) update(e) else e,
        ],
      ),
    );
  }

  // --- hobbies ---

  Future<HobbyItem> addHobby(String text) async {
    await ready();
    final hobby = HobbyItem(id: _uuid.v4(), text: text);
    _setVault((v) => v.copyWith(hobbies: [...v.hobbies, hobby]));
    return hobby;
  }

  Future<void> updateHobby(HobbyItem hobby) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        hobbies: v.hobbies.replaceById(hobby.id, hobby, (h) => h.id),
      ),
    );
  }

  Future<void> deleteHobby(String hobbyId) async {
    await ready();
    _setVault(
      (v) => v.copyWith(hobbies: v.hobbies.removeById(hobbyId, (h) => h.id)),
    );
  }

  /// Wholesale-replaces the Vault — the one call site is `BackupService`'s
  /// import flow. Flushes (via [persistNow]) any write still sitting in
  /// the debounce timer *before* overwriting in-memory state, so a normal
  /// edit made just before import can't fire after import and silently
  /// clobber the freshly-restored data. [vault]'s own `updatedAt` is kept
  /// as-is — importing isn't itself an edit to the vault's content.
  Future<void> replaceAll(CvVault vault) async {
    await ready();
    await persistNow(_vault.value);
    _vault.value = vault;
    await persistImmediately(vault);
  }

  // --- publications ---

  Future<Publication> addPublication({
    required String title,
    String? citation,
    String? link,
  }) async {
    await ready();
    final publication = Publication(
      id: _uuid.v4(),
      title: title,
      citation: citation,
      link: link,
    );
    _setVault(
      (v) => v.copyWith(publications: [...v.publications, publication]),
    );
    return publication;
  }

  Future<void> updatePublication(Publication publication) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        publications: v.publications.replaceById(
          publication.id,
          publication,
          (p) => p.id,
        ),
      ),
    );
  }

  Future<void> deletePublication(String publicationId) async {
    await ready();
    _setVault(
      (v) => v.copyWith(
        publications: v.publications.removeById(publicationId, (p) => p.id),
      ),
    );
  }

  // --- publication bullets ---

  Future<CvBullet> addPublicationBullet(
    String publicationId, {
    String? label,
    required String text,
  }) async {
    await ready();
    final bullet = CvBullet(id: _uuid.v4(), label: label, text: text);
    _updatePublication(
      publicationId,
      (p) => p.copyWith(bullets: [...p.bullets, bullet]),
    );
    return bullet;
  }

  Future<void> updatePublicationBullet(
    String publicationId,
    CvBullet bullet,
  ) async {
    await ready();
    _updatePublication(
      publicationId,
      (p) => p.copyWith(
        bullets: p.bullets.replaceById(bullet.id, bullet, (b) => b.id),
      ),
    );
  }

  Future<void> deletePublicationBullet(
    String publicationId,
    String bulletId,
  ) async {
    await ready();
    _updatePublication(
      publicationId,
      (p) => p.copyWith(bullets: p.bullets.removeById(bulletId, (b) => b.id)),
    );
  }

  Future<void> reorderPublicationBullets(
    String publicationId,
    List<String> orderedBulletIds,
  ) async {
    await ready();
    _updatePublication(
      publicationId,
      (p) => p.copyWith(
        bullets: [
          for (final id in orderedBulletIds)
            ...p.bullets.where((b) => b.id == id).take(1),
        ],
      ),
    );
  }

  /// Applies [update] to the single publication matching [publicationId].
  /// Mirrors [_updateProject] — same shape, one entity type over.
  void _updatePublication(
    String publicationId,
    Publication Function(Publication current) update,
  ) {
    _setVault(
      (v) => v.copyWith(
        publications: [
          for (final p in v.publications)
            if (p.id == publicationId) update(p) else p,
        ],
      ),
    );
  }

  // --- persistence plumbing ---

  void _setVault(CvVault Function(CvVault current) update) {
    _vault.value = update(_vault.value).copyWith(updatedAt: DateTime.now());
    scheduleWrite(_vault.value);
  }

  /// Persists immediately, bypassing any pending debounce timer. Called
  /// from the app-lifecycle hook in `main.dart` when the tab is about to
  /// be hidden or closed (a debounce timer alone can't survive that), and
  /// from the Vault UI's "Retry" affordance after a [persistError] — both
  /// need the same "write right now" behaviour, so one method serves both.
  Future<void> flushPendingWrites() => persistNow(_vault.value);

  @override
  Future<void> writeToStorage(CvVault value) => _localStorage.write(
    StorageBoxes.vault,
    StorageKeys.vaultProfile,
    jsonEncode(value.toJson()),
  );
}
