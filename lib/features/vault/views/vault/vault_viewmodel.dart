import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// What the right-hand editor panel is currently showing, if anything.
/// `experience`/`project`/`education` are keyed by id (many possible
/// cards); `basics`/`skills`/`hobbies` are singletons (exactly one card
/// each).
enum VaultEditorTarget {
  none,
  basics,
  experience,
  project,
  education,
  skills,
  hobbies,
  publication,
}

/// Most of this ViewModel's mutators are one-line forwards straight to
/// [VaultService] — deliberately, not an oversight: it keeps one stable,
/// mockable surface the View talks to (so a test only ever stubs
/// `VaultViewModel`'s own dependencies, never reaches past it to
/// `VaultService`), and it's the seam where a future mutator that needs
/// real ViewModel logic (validation, a confirmation dialog, panel-state
/// bookkeeping — see [deleteExperience]/[openExperienceEditor] for
/// examples that already do) can grow without moving the View onto a
/// different object. A future entity type's ViewModel should follow the
/// same shape: forward the plain mutators, add logic only where the View
/// genuinely needs it.
class VaultViewModel extends ReactiveViewModel implements Initialisable {
  final _vaultService = locator<VaultService>();
  final _dialogService = locator<DialogService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_vaultService];

  /// Loads [VaultService] on this View's own account rather than assuming
  /// `StartupView` already ran — refreshing (or deep-linking) straight to
  /// `/vault` skips `StartupView` entirely, and without this the Vault
  /// would render as empty even though real data is sitting in storage.
  /// Implementing [Initialisable] makes Stacked call this automatically
  /// when the ViewModel is created.
  @override
  void initialise() => runBusyFuture(_load());

  /// A real `async` wrapper, not `runBusyFuture(_vaultService.load())`
  /// directly — [runBusyFuture]'s argument is evaluated *before*
  /// `runBusyFuture` itself runs, so a call that throws synchronously
  /// (a mocked service in a test; see `PersistedStoreMixin.ready`'s doc
  /// comment for why production code shouldn't either, but can't be
  /// trusted to never regress) would throw straight out of [initialise]
  /// and never reach `runBusyFuture`'s error handling at all.
  Future<void> _load() async => _vaultService.load();

  bool get isLoading => isBusy;
  bool get hasLoadError => hasError;

  CvVault get vault => _vaultService.vault;

  bool get hasPersistError => _vaultService.persistError != null;

  Future<void> retryPersist() => _vaultService.flushPendingWrites();

  bool _emptyStateDismissed = false;
  bool get showEmptyState =>
      !isLoading && !_emptyStateDismissed && vault.isEmpty;

  void dismissEmptyState() {
    _emptyStateDismissed = true;
    rebuildUi();
  }

  Future<void> loadExampleVault() async {
    await _vaultService.loadExampleVault();
    _emptyStateDismissed = true;
    rebuildUi();
  }

  // --- editor panel open/close ---

  VaultEditorTarget _openTarget = VaultEditorTarget.none;
  String? _openId;

  VaultEditorTarget get openTarget => _openTarget;
  String? get openId => _openId;
  bool get isEditorOpen => _openTarget != VaultEditorTarget.none;

  void openBasicsEditor() => _open(VaultEditorTarget.basics);
  void openSkillsEditor() => _open(VaultEditorTarget.skills);
  void openHobbiesEditor() => _open(VaultEditorTarget.hobbies);
  void openExperienceEditor(String id) =>
      _open(VaultEditorTarget.experience, id);
  void openProjectEditor(String id) => _open(VaultEditorTarget.project, id);
  void openEducationEditor(String id) => _open(VaultEditorTarget.education, id);
  void openPublicationEditor(String id) =>
      _open(VaultEditorTarget.publication, id);

  void closeEditor() {
    _openTarget = VaultEditorTarget.none;
    _openId = null;
    rebuildUi();
  }

  void _open(VaultEditorTarget target, [String? id]) {
    _openTarget = target;
    _openId = id;
    rebuildUi();
  }

  // --- basics ---

  Future<void> updateBasics(ContactBasics basics) =>
      _vaultService.updateBasics(basics);

  Future<void> addProfileLink() =>
      _vaultService.addProfileLink(label: '', url: '');

  Future<void> updateProfileLink(ProfileLink link) =>
      _vaultService.updateProfileLink(link);

  Future<void> deleteProfileLink(String id) =>
      _vaultService.deleteProfileLink(id);

  Future<void> updateReferencesNote(String? note) =>
      _vaultService.updateReferencesNote(note);

  // --- experiences ---

  Future<void> addExperience() async {
    final now = DateTime.now();
    final created = await _vaultService.addExperience(
      role: '',
      company: '',
      location: '',
      start: YearMonth(year: now.year, month: now.month),
    );
    openExperienceEditor(created.id);
  }

  Future<void> updateExperience(Experience experience) =>
      _vaultService.updateExperience(experience);

  Future<void> groupExperience(String experienceId, String? withId) =>
      _vaultService.groupExperience(experienceId, withId);

  Future<void> deleteExperience(String id) async {
    final confirmed = await _confirmDelete(
      title: 'Delete this experience?',
      description:
          "This removes it and all of its bullets. This can't be undone.",
    );
    if (!confirmed) return;
    await _vaultService.deleteExperience(id);
    if (_openId == id) closeEditor();
  }

  // --- bullets ---

  Future<void> addBullet(String experienceId) =>
      _vaultService.addBullet(experienceId, text: '');

  Future<void> updateBullet(String experienceId, CvBullet bullet) =>
      _vaultService.updateBullet(experienceId, bullet);

  Future<void> deleteBullet(String experienceId, String bulletId) =>
      _vaultService.deleteBullet(experienceId, bulletId);

  Future<void> reorderBullets(String experienceId, List<String> orderedIds) =>
      _vaultService.reorderBullets(experienceId, orderedIds);

  // --- projects ---

  Future<void> addProject() async {
    final created = await _vaultService.addProject(title: '');
    openProjectEditor(created.id);
  }

  Future<void> updateProject(Project project) =>
      _vaultService.updateProject(project);

  Future<void> deleteProject(String id) async {
    final confirmed = await _confirmDelete(
      title: 'Delete this project?',
      description:
          "This removes it and all of its bullets. This can't be undone.",
    );
    if (!confirmed) return;
    await _vaultService.deleteProject(id);
    if (_openId == id) closeEditor();
  }

  Future<void> addProjectBullet(String projectId) =>
      _vaultService.addProjectBullet(projectId, text: '');

  Future<void> updateProjectBullet(String projectId, CvBullet bullet) =>
      _vaultService.updateProjectBullet(projectId, bullet);

  Future<void> deleteProjectBullet(String projectId, String bulletId) =>
      _vaultService.deleteProjectBullet(projectId, bulletId);

  Future<void> reorderProjectBullets(
    String projectId,
    List<String> orderedIds,
  ) => _vaultService.reorderProjectBullets(projectId, orderedIds);

  // --- skills ---

  Future<void> addSkillCategory(String name) =>
      _vaultService.addSkillCategory(name);

  Future<void> updateSkillCategory(SkillCategory category) =>
      _vaultService.updateSkillCategory(category);

  Future<void> deleteSkillCategory(String id) async {
    final confirmed = await _confirmDelete(
      title: 'Delete this category?',
      description: 'This removes it and all of its skills.',
    );
    if (confirmed) await _vaultService.deleteSkillCategory(id);
  }

  Future<void> addSkill(String categoryId, String label) =>
      _vaultService.addSkill(categoryId, label);

  Future<void> updateSkill(String categoryId, Skill skill) =>
      _vaultService.updateSkill(categoryId, skill);

  Future<void> deleteSkill(String categoryId, String skillId) =>
      _vaultService.deleteSkill(categoryId, skillId);

  // --- education ---

  Future<void> addEducation() async {
    final created = await _vaultService.addEducation(
      qualification: '',
      institution: '',
    );
    openEducationEditor(created.id);
  }

  Future<void> updateEducation(Education education) =>
      _vaultService.updateEducation(education);

  Future<void> deleteEducation(String id) async {
    final confirmed = await _confirmDelete(
      title: 'Delete this qualification?',
      description: "This can't be undone.",
    );
    if (!confirmed) return;
    await _vaultService.deleteEducation(id);
    if (_openId == id) closeEditor();
  }

  // --- hobbies ---

  Future<void> addHobby(String text) => _vaultService.addHobby(text);

  Future<void> updateHobby(HobbyItem hobby) => _vaultService.updateHobby(hobby);

  Future<void> deleteHobby(String id) => _vaultService.deleteHobby(id);

  // --- publications ---

  Future<void> addPublication() async {
    final created = await _vaultService.addPublication(title: '');
    openPublicationEditor(created.id);
  }

  Future<void> updatePublication(Publication publication) =>
      _vaultService.updatePublication(publication);

  Future<void> deletePublication(String id) async {
    final confirmed = await _confirmDelete(
      title: 'Delete this publication?',
      description: "This can't be undone.",
    );
    if (!confirmed) return;
    await _vaultService.deletePublication(id);
    if (_openId == id) closeEditor();
  }

  Future<bool> _confirmDelete({
    required String title,
    required String description,
  }) async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: title,
      description: description,
      mainButtonTitle: 'Delete',
      secondaryButtonTitle: 'Cancel',
    );
    return response?.confirmed ?? false;
  }
}
