import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/cv_composer.dart';
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:pdf/pdf.dart';
import 'package:stacked/stacked.dart';

/// Owns Studio's selection UI. It reads [VaultService] for the master data
/// and [DraftService] for what's currently selected, then hands both to
/// [CvComposer] to produce the [resolvedCv] the preview renders — this is
/// the ViewModel `CvComposer` gets its test coverage through, per the
/// outside-in testing convention (a dedicated composer test would be a
/// unit test of a pure function, which the project's conventions avoid
/// unless asked for).
class StudioViewModel extends ReactiveViewModel {
  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _templateRegistry = locator<TemplateRegistryService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [
    _vaultService,
    _draftService,
  ];

  CvVault get _vault => _vaultService.vault;
  CvDraft get _draft => _draftService.draft;

  CvTemplate get template => _templateRegistry.byId(_draft.templateId);

  /// A4 today — [RegionProfile] is the seam a future Letter-format preset
  /// plugs into without touching this ViewModel.
  PdfPageFormat get pageFormat => PdfPageFormat.a4;

  ResolvedCv get resolvedCv =>
      CvComposer.compose(_vault, _draft, region: RegionProfile.uk);

  bool get hasContent => resolvedCv.sections.isNotEmpty;

  // --- section visibility ---

  bool get hasSummary =>
      (_draft.tailoredSummary ?? _vault.basics.summary)?.trim().isNotEmpty ??
      false;

  bool get hasReferences => (_vault.referencesNote ?? '').trim().isNotEmpty;

  /// Whether [type] has any underlying data at all — a section with
  /// nothing behind it gets no visibility toggle, since hiding/showing an
  /// empty section is meaningless.
  bool sectionHasData(CvSectionType type) => switch (type) {
    CvSectionType.summary => hasSummary,
    CvSectionType.skills => _allSkills.isNotEmpty,
    CvSectionType.experience => experiences.isNotEmpty,
    CvSectionType.projects => projects.isNotEmpty,
    CvSectionType.education => education.isNotEmpty,
    CvSectionType.hobbies => hobbies.isNotEmpty,
    CvSectionType.references => hasReferences,
  };

  bool isSectionHidden(CvSectionType type) =>
      _draft.hiddenSections.contains(type);

  Future<void> toggleSectionHidden(CvSectionType type) =>
      _draftService.setSectionHidden(type, hidden: !isSectionHidden(type));

  // --- experiences ---

  List<Experience> get experiences => _vault.experiences;

  bool isExperienceIncluded(String id) => _draft.experienceIds.contains(id);

  Future<void> toggleExperience(Experience experience) =>
      _draftService.setExperienceIncluded(
        experience.id,
        included: !isExperienceIncluded(experience.id),
        bulletIds: experience.bullets.map((b) => b.id).toList(),
      );

  List<Experience> get unselectedExperiences =>
      experiences.where((e) => !isExperienceIncluded(e.id)).toList();

  Future<void> addAllExperiences() async {
    for (final experience in unselectedExperiences) {
      await toggleExperience(experience);
    }
  }

  bool isExperienceBulletIncluded(String experienceId, String bulletId) =>
      (_draft.bulletIds[experienceId] ?? const []).contains(bulletId);

  /// Toggles one bullet within an already-included experience, keeping the
  /// remaining selection in the experience's own bullet order rather than
  /// the order bullets happened to be toggled in.
  Future<void> toggleExperienceBullet(Experience experience, CvBullet bullet) {
    final selected = {...(_draft.bulletIds[experience.id] ?? const [])};
    if (!selected.remove(bullet.id)) selected.add(bullet.id);
    return _draftService.setBulletsForExperience(
      experience.id,
      experience.bullets.map((b) => b.id).where(selected.contains).toList(),
    );
  }

  // --- projects ---

  List<Project> get projects => _vault.projects;

  bool isProjectIncluded(String id) => _draft.projectIds.contains(id);

  Future<void> toggleProject(Project project) =>
      _draftService.setProjectIncluded(
        project.id,
        included: !isProjectIncluded(project.id),
        bulletIds: project.bullets.map((b) => b.id).toList(),
      );

  List<Project> get unselectedProjects =>
      projects.where((p) => !isProjectIncluded(p.id)).toList();

  Future<void> addAllProjects() async {
    for (final project in unselectedProjects) {
      await toggleProject(project);
    }
  }

  bool isProjectBulletIncluded(String projectId, String bulletId) =>
      (_draft.projectBulletIds[projectId] ?? const []).contains(bulletId);

  /// Same shape as [toggleExperienceBullet], one entity type over.
  Future<void> toggleProjectBullet(Project project, CvBullet bullet) {
    final selected = {...(_draft.projectBulletIds[project.id] ?? const [])};
    if (!selected.remove(bullet.id)) selected.add(bullet.id);
    return _draftService.setBulletsForProject(
      project.id,
      project.bullets.map((b) => b.id).where(selected.contains).toList(),
    );
  }

  // --- skills ---

  List<SkillCategory> get skillCategories => _vault.skillCategories;

  List<Skill> get _allSkills => [
    for (final category in skillCategories) ...category.skills,
  ];

  bool isSkillIncluded(String id) => _draft.skillIds.contains(id);

  Future<void> toggleSkill(Skill skill) => _draftService.setSkillIncluded(
    skill.id,
    included: !isSkillIncluded(skill.id),
  );

  List<Skill> get unselectedSkills =>
      _allSkills.where((s) => !isSkillIncluded(s.id)).toList();

  Future<void> addAllSkills() async {
    for (final skill in unselectedSkills) {
      await toggleSkill(skill);
    }
  }

  // --- education ---

  List<Education> get education => _vault.education;

  bool isEducationIncluded(String id) => _draft.educationIds.contains(id);

  Future<void> toggleEducation(Education entry) => _draftService
      .setEducationIncluded(entry.id, included: !isEducationIncluded(entry.id));

  List<Education> get unselectedEducation =>
      education.where((e) => !isEducationIncluded(e.id)).toList();

  Future<void> addAllEducation() async {
    for (final entry in unselectedEducation) {
      await toggleEducation(entry);
    }
  }

  // --- hobbies ---

  List<HobbyItem> get hobbies => _vault.hobbies;

  bool isHobbyIncluded(String id) => _draft.hobbyIds.contains(id);

  Future<void> toggleHobby(HobbyItem hobby) => _draftService.setHobbyIncluded(
    hobby.id,
    included: !isHobbyIncluded(hobby.id),
  );

  List<HobbyItem> get unselectedHobbies =>
      hobbies.where((h) => !isHobbyIncluded(h.id)).toList();

  Future<void> addAllHobbies() async {
    for (final hobby in unselectedHobbies) {
      await toggleHobby(hobby);
    }
  }
}
