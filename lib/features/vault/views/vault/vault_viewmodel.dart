import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/experience_bullet.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// What the right-hand editor panel is currently showing, if anything.
/// `experience`/`education` are keyed by id (many possible cards);
/// `basics`/`skills`/`hobbies` are singletons (exactly one card each).
enum VaultEditorTarget { none, basics, experience, education, skills, hobbies }

class VaultViewModel extends ReactiveViewModel {
  final _vaultService = locator<VaultService>();
  final _dialogService = locator<DialogService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_vaultService];

  CvVault get vault => _vaultService.vault;

  bool _emptyStateDismissed = false;
  bool get showEmptyState => !_emptyStateDismissed && vault.isEmpty;

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
  void openEducationEditor(String id) => _open(VaultEditorTarget.education, id);

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

  Future<void> updateBullet(String experienceId, ExperienceBullet bullet) =>
      _vaultService.updateBullet(experienceId, bullet);

  Future<void> deleteBullet(String experienceId, String bulletId) =>
      _vaultService.deleteBullet(experienceId, bulletId);

  Future<void> reorderBullets(String experienceId, List<String> orderedIds) =>
      _vaultService.reorderBullets(experienceId, orderedIds);

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
