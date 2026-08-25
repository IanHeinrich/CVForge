import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/identified_list.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/fixtures/example_vault.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/vault_pruning.dart';
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

  /// Replaces the Vault's *content* with the worked example, keeping
  /// [CvVault.documentDefaults].
  ///
  /// The defaults are configuration, not content, so loading a sample CV
  /// is no more a reason to forget which region and language the user
  /// works in than it is a reason to forget their password. This is the
  /// same trap `CvVaultEmptiness.isEmpty`'s doc records for photos, one
  /// step further along: a photo could be fixed by counting it as content,
  /// and the defaults cannot, because they are never absent. So they have
  /// to be carried across by hand here and in [clearVault].
  Future<void> loadExampleVault() async {
    await ready();
    _setVault(
      (v) => buildExampleVault().copyWith(documentDefaults: v.documentDefaults),
    );
  }

  /// Resets the Vault back to [CvVault.empty] — the same starting point as
  /// a first-ever launch, so the empty-state choice ("Load example CV" or
  /// build from scratch) is available again afterwards.
  ///
  /// Keeps [CvVault.documentDefaults] for the reason [loadExampleVault]
  /// gives. "Clear my career history" is not "forget that I write my CVs
  /// in Dutch".
  Future<void> clearVault() async {
    await ready();
    _setVault(
      (v) => CvVault.empty().copyWith(documentDefaults: v.documentDefaults),
    );
  }

  /// The one write path for what new CVs start out as.
  ///
  /// Unlike every other mutator here this changes configuration rather
  /// than content, which has one consequence worth naming: [_setVault]
  /// stamps `CvVault.updatedAt`, and Drive's three-way merge uses that
  /// timestamp to settle *contested content* too. So changing a language
  /// here makes this device win any bullet both devices edited since they
  /// last agreed. That is acceptable — it is a real edit by a real person,
  /// at a real moment — but it is a consequence rather than an accident,
  /// and `cv_backup_merge_test` pins it.
  Future<void> setDocumentDefaults(DocumentDefaults defaults) async {
    await ready();
    _setVault((v) => v.copyWith(documentDefaults: defaults));
  }

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
  /// company, sequential roles) — or, when [withExperienceId] is null,
  /// removes [experienceId] from whatever group it is in. Reuses the
  /// target's existing companyGroupId if it already has one, so grouping
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

  void _updateExperience(
    String experienceId,
    Experience Function(Experience current) update,
  ) => _setVault(
    (v) => v.copyWith(
      experiences: v.experiences.updateById(experienceId, update, (e) => e.id),
    ),
  );

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

  void _updateProject(
    String projectId,
    Project Function(Project current) update,
  ) => _setVault(
    (v) => v.copyWith(
      projects: v.projects.updateById(projectId, update, (p) => p.id),
    ),
  );

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

  void _updateSkillCategory(
    String categoryId,
    SkillCategory Function(SkillCategory current) update,
  ) => _setVault(
    (v) => v.copyWith(
      skillCategories: v.skillCategories.updateById(
        categoryId,
        update,
        (c) => c.id,
      ),
    ),
  );

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

  void _updateEducation(
    String educationId,
    Education Function(Education current) update,
  ) => _setVault(
    (v) => v.copyWith(
      education: v.education.updateById(educationId, update, (e) => e.id),
    ),
  );

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

  void _updatePublication(
    String publicationId,
    Publication Function(Publication current) update,
  ) => _setVault(
    (v) => v.copyWith(
      publications: v.publications.updateById(
        publicationId,
        update,
        (p) => p.id,
      ),
    ),
  );

  /// One API shared by every bullet-owning entity (experience, project,
  /// education, publication) rather than a hand-written quartet per
  /// entity — [owner] plus [_updateBulletsOf] resolves "which list, and
  /// how to write it back" without four copies of the same add/update/
  /// delete/reorder bodies.
  Future<CvBullet> addBullet(
    BulletOwner owner,
    String ownerId, {
    required String text,
  }) async {
    await ready();
    final bullet = CvBullet(id: _uuid.v4(), text: text);
    _updateBulletsOf(owner, ownerId, (bullets) => [...bullets, bullet]);
    return bullet;
  }

  Future<void> updateBullet(
    BulletOwner owner,
    String ownerId,
    CvBullet bullet,
  ) async {
    await ready();
    _updateBulletsOf(
      owner,
      ownerId,
      (bullets) => bullets.replaceById(bullet.id, bullet, (b) => b.id),
    );
  }

  Future<void> deleteBullet(
    BulletOwner owner,
    String ownerId,
    String bulletId,
  ) async {
    await ready();
    _updateBulletsOf(
      owner,
      ownerId,
      (bullets) => bullets.removeById(bulletId, (b) => b.id),
    );
  }

  Future<void> reorderBullets(
    BulletOwner owner,
    String ownerId,
    List<String> orderedBulletIds,
  ) async {
    await ready();
    _updateBulletsOf(
      owner,
      ownerId,
      (bullets) => bullets.reorderByIds(orderedBulletIds, (b) => b.id),
    );
  }

  /// Resolves [owner] to the entity holding [ownerId] and rewrites its
  /// bullets field via [update] — the one place that knows each owner's
  /// concrete type, so every public bullet method above stays a single
  /// call regardless of which entity it is operating on.
  void _updateBulletsOf(
    BulletOwner owner,
    String ownerId,
    List<CvBullet> Function(List<CvBullet> current) update,
  ) {
    switch (owner) {
      case BulletOwner.experience:
        _updateExperience(
          ownerId,
          (e) => e.copyWith(bullets: update(e.bullets)),
        );
      case BulletOwner.project:
        _updateProject(ownerId, (p) => p.copyWith(bullets: update(p.bullets)));
      case BulletOwner.education:
        _updateEducation(
          ownerId,
          (e) => e.copyWith(bullets: update(e.bullets)),
        );
      case BulletOwner.publication:
        _updatePublication(
          ownerId,
          (p) => p.copyWith(bullets: update(p.bullets)),
        );
    }
  }

  void _setVault(CvVault Function(CvVault current) update) {
    _vault.value = update(_vault.value).copyWith(updatedAt: DateTime.now());
    scheduleWrite(_vault.value);
  }

  /// Wholesale-replaces the Vault — the one call site is BackupService's
  /// import flow. Flushes (via [persistNow]) any write still sitting in
  /// the debounce timer before overwriting in-memory state, so a normal
  /// edit made just before import can not fire after import and silently
  /// clobber the freshly-restored data. vault's own updatedAt is kept
  /// as-is — importing is not itself an edit to the vault's content.
  Future<void> replaceAll(CvVault vault) async {
    await ready();
    await persistNow(_vault.value);
    _vault.value = vault;
    await persistImmediately(vault);
  }

  /// Persists immediately, bypassing any pending debounce timer. Called
  /// from the app-lifecycle hook in main.dart when the tab is about to
  /// be hidden or closed (a debounce timer alone can not survive that), and
  /// from the Vault UI's Retry affordance after a [persistError] — both
  /// need the same "write right now" behaviour, so one method serves both.
  Future<void> flushPendingWrites() => persistNow(_vault.value);

  /// Every persistence path — the debounced write, an explicit flush, and
  /// [replaceAll]'s import — funnels through here, which is why the
  /// blank-entry prune lives at this one point rather than in each caller.
  /// See [CvVaultPruning.withoutBlankEntries] for what counts as blank and
  /// why it is enforced on write instead of on create.
  @override
  Future<void> writeToStorage(CvVault value) => _localStorage.write(
    StorageBoxes.vault,
    StorageKeys.vaultProfile,
    jsonEncode(value.withoutBlankEntries().toJson()),
  );
}
