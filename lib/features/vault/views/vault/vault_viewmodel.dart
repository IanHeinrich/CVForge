import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
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
/// mockable surface the View talks to, and it's the seam where a future
/// mutator that needs real ViewModel logic (validation, a confirmation
/// dialog, panel-state bookkeeping — see [deleteExperience]/
/// [openExperienceEditor] for examples that already do) can grow without
/// moving the View onto a different object.
class VaultViewModel extends ReactiveViewModel implements Initialisable {
  VaultViewModel({bool cameFromInvalidUrl = false})
    : _invalidUrlNoticePending = cameFromInvalidUrl;

  final _vaultService = locator<VaultService>();
  final _localizationService = locator<LocalizationService>();
  final _dialogService = locator<DialogService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_vaultService];

  /// Set once, from `VaultView`'s `invalidUrl` query param — see that
  /// class's doc comment. `consumeInvalidUrlNotice` flips it off
  /// immediately rather than via `rebuildUi()`/`notifyListeners()`: the
  /// View calls it from inside `builder()`, and notifying listeners
  /// mid-build would trigger a rebuild while one is already in progress.
  /// A plain field mutation is safe there and still leaves every build
  /// after the first — including the ones `AppChrome.gated`'s loading
  /// state causes before the Vault finishes loading — returning `false`.
  bool _invalidUrlNoticePending;

  bool consumeInvalidUrlNotice() {
    if (!_invalidUrlNoticePending) return false;
    _invalidUrlNoticePending = false;
    return true;
  }

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

  /// Presentation state, not persisted — same call as
  /// `DraftsListViewModel._query`. Only narrows `VaultCardList`'s
  /// multi-entry sections (work history, projects, education,
  /// publications) — Basics/Skills/Hobbies are single summary cards, not
  /// lists, so there's nothing there to filter.
  String _query = '';
  bool get isSearching => _query.isNotEmpty;

  void setQuery(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed == _query) return;
    _query = trimmed;
    rebuildUi();
  }

  List<T> _filtered<T>(List<T> items, List<String> Function(T) fieldsOf) {
    if (_query.isEmpty) return items;
    return items.where((item) {
      return fieldsOf(item).any((f) => f.toLowerCase().contains(_query));
    }).toList();
  }

  /// Matches role or company — the same two fields `VaultCardList` shows
  /// as an experience card's title/subtitle.
  List<Experience> get filteredExperiences =>
      _filtered(vault.experiences, (e) => [e.role, e.company]);

  /// Matches title or link, mirroring a project card's title/subtitle.
  List<Project> get filteredProjects =>
      _filtered(vault.projects, (p) => [p.title, p.link ?? '']);

  /// Matches qualification or institution, mirroring an education card's
  /// title/subtitle.
  List<Education> get filteredEducation =>
      _filtered(vault.education, (e) => [e.qualification, e.institution]);

  /// Matches title or citation, mirroring a publication card's
  /// title/subtitle.
  List<Publication> get filteredPublications =>
      _filtered(vault.publications, (p) => [p.title, p.citation ?? '']);

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

  // Year field validation: a rejected year edit must show an error, not
  // silently discard the keystroke while the field goes on showing a
  // value the model never received. The error lives here rather than on
  // the (stateless) editor panels, per CLAUDE.md's "logic in the
  // ViewModel" rule; keyed by entity id since several entries' panels can
  // exist across a session even though only one is open at a time.

  static const _minYear = 1900;
  static const _maxYear = 2100;

  final Map<String, String> _experienceStartYearErrors = {};
  final Map<String, String> _experienceEndYearErrors = {};
  final Map<String, String> _educationYearErrors = {};

  String? experienceStartYearError(String experienceId) =>
      _experienceStartYearErrors[experienceId];
  String? experienceEndYearError(String experienceId) =>
      _experienceEndYearErrors[experienceId];
  String? educationYearError(String educationId) =>
      _educationYearErrors[educationId];

  /// Null means valid. [allowEmpty] lets Education's optional year treat
  /// a blank field as valid too — a start/end year is never optional, so
  /// callers for those leave it at the default.
  String? _yearError(String raw, {bool allowEmpty = false}) {
    final trimmed = raw.trim();
    final strings = _localizationService.strings;
    if (trimmed.isEmpty) {
      return allowEmpty ? null : strings.vaultYearRequired;
    }
    final year = int.tryParse(trimmed);
    if (year == null) return strings.vaultYearInvalid;
    if (year < _minYear || year > _maxYear) {
      return _localizationService.strings.vaultYearOutOfRange(
        _minYear,
        _maxYear,
      );
    }
    return null;
  }

  Future<void> updateExperienceStartYear(
    Experience experience,
    String raw,
  ) async {
    final error = _yearError(raw);
    if (error != null) {
      _experienceStartYearErrors[experience.id] = error;
      rebuildUi();
      return;
    }
    _experienceStartYearErrors.remove(experience.id);
    await updateExperience(
      experience.copyWith(
        start: experience.start.copyWith(year: int.parse(raw.trim())),
      ),
    );
  }

  Future<void> updateExperienceEndYear(
    Experience experience,
    String raw,
  ) async {
    final error = _yearError(raw);
    if (error != null) {
      _experienceEndYearErrors[experience.id] = error;
      rebuildUi();
      return;
    }
    _experienceEndYearErrors.remove(experience.id);
    // An entry with no end date yet seeds the year from *now*, not from
    // start — adopting start's year here produces a plausible-looking but
    // silently wrong end date the moment only the month gets set
    // afterwards.
    final end =
        experience.end ??
        YearMonth(year: DateTime.now().year, month: experience.start.month);
    await updateExperience(
      experience.copyWith(end: end.copyWith(year: int.parse(raw.trim()))),
    );
  }

  Future<void> updateEducationYear(Education education, String raw) async {
    final error = _yearError(raw, allowEmpty: true);
    if (error != null) {
      _educationYearErrors[education.id] = error;
      rebuildUi();
      return;
    }
    _educationYearErrors.remove(education.id);
    final trimmed = raw.trim();
    await updateEducation(
      education.copyWith(year: trimmed.isEmpty ? null : int.parse(trimmed)),
    );
  }

  Future<void> deleteExperience(String id) => _confirmDeleteThen(
    title: _localizationService.strings.vaultDeleteExperienceTitle,
    description: _localizationService.strings.vaultDeleteWithBulletsBody,
    delete: () => _vaultService.deleteExperience(id),
    closeIfOpenId: id,
  );

  /// One set of pass-throughs for every bullet-owning entity, carrying
  /// [owner] straight through to the matching [VaultService] method — see
  /// that class's bullet API for why the owner is a parameter rather than
  /// four methods per action.
  Future<void> addBullet(BulletOwner owner, String ownerId) =>
      _vaultService.addBullet(owner, ownerId, text: '');

  Future<void> updateBullet(
    BulletOwner owner,
    String ownerId,
    CvBullet bullet,
  ) => _vaultService.updateBullet(owner, ownerId, bullet);

  Future<void> deleteBullet(
    BulletOwner owner,
    String ownerId,
    String bulletId,
  ) => _vaultService.deleteBullet(owner, ownerId, bulletId);

  Future<void> reorderBullets(
    BulletOwner owner,
    String ownerId,
    List<String> orderedIds,
  ) => _vaultService.reorderBullets(owner, ownerId, orderedIds);

  Future<void> addProject() async {
    final created = await _vaultService.addProject(title: '');
    openProjectEditor(created.id);
  }

  Future<void> updateProject(Project project) =>
      _vaultService.updateProject(project);

  Future<void> deleteProject(String id) => _confirmDeleteThen(
    title: _localizationService.strings.vaultDeleteProjectTitle,
    description: _localizationService.strings.vaultDeleteWithBulletsBody,
    delete: () => _vaultService.deleteProject(id),
    closeIfOpenId: id,
  );

  /// Returns the created [SkillCategory] (not just `void`) so a caller
  /// that needs its id right away — `BulletListEditor`'s "+ New category"
  /// option when adding a skill that doesn't exist yet — can add a skill
  /// under it in the same action, same reasoning as [addSkill]'s own doc
  /// comment.
  Future<SkillCategory> addSkillCategory(String name) =>
      _vaultService.addSkillCategory(name);

  Future<void> updateSkillCategory(SkillCategory category) =>
      _vaultService.updateSkillCategory(category);

  Future<void> deleteSkillCategory(String id) async {
    final confirmed = await _confirmDelete(
      title: _localizationService.strings.vaultDeleteCategoryTitle,
      description: _localizationService.strings.vaultDeleteCategoryBody,
    );
    if (confirmed) await _vaultService.deleteSkillCategory(id);
  }

  /// Returns the created [Skill] (not just `void`) so a caller that needs
  /// its id right away — `BulletListEditor`'s quick "add a skill that
  /// doesn't exist yet" flow — can link it to a bullet in the same
  /// action, rather than requiring a trip back to the Skills panel.
  Future<Skill> addSkill(String categoryId, String label) =>
      _vaultService.addSkill(categoryId, label);

  Future<void> updateSkill(String categoryId, Skill skill) =>
      _vaultService.updateSkill(categoryId, skill);

  Future<void> deleteSkill(String categoryId, String skillId) =>
      _vaultService.deleteSkill(categoryId, skillId);

  Future<void> addEducation() async {
    final created = await _vaultService.addEducation(
      qualification: '',
      institution: '',
    );
    openEducationEditor(created.id);
  }

  Future<void> updateEducation(Education education) =>
      _vaultService.updateEducation(education);

  Future<void> deleteEducation(String id) => _confirmDeleteThen(
    title: _localizationService.strings.vaultDeleteQualificationTitle,
    description: _localizationService.strings.vaultDeleteUndoneBody,
    delete: () => _vaultService.deleteEducation(id),
    closeIfOpenId: id,
  );

  Future<void> addHobby(String text) => _vaultService.addHobby(text);

  Future<void> updateHobby(HobbyItem hobby) => _vaultService.updateHobby(hobby);

  Future<void> deleteHobby(String id) => _vaultService.deleteHobby(id);

  Future<void> addPublication() async {
    final created = await _vaultService.addPublication(title: '');
    openPublicationEditor(created.id);
  }

  Future<void> updatePublication(Publication publication) =>
      _vaultService.updatePublication(publication);

  Future<void> deletePublication(String id) => _confirmDeleteThen(
    title: _localizationService.strings.vaultDeletePublicationTitle,
    description: _localizationService.strings.vaultDeleteWithBulletsBody,
    delete: () => _vaultService.deletePublication(id),
    closeIfOpenId: id,
  );

  /// Shared by every entity-level delete action above: confirm, delete,
  /// and close the editor panel if it was showing the just-deleted entity
  /// — one method instead of four identical bodies differing only in
  /// copy and which service call to make.
  Future<void> _confirmDeleteThen({
    required String title,
    required String description,
    required Future<void> Function() delete,
    String? closeIfOpenId,
  }) async {
    final confirmed = await _confirmDelete(
      title: title,
      description: description,
    );
    if (!confirmed) return;
    await delete();
    if (closeIfOpenId != null && _openId == closeIfOpenId) closeEditor();
  }

  Future<bool> _confirmDelete({
    required String title,
    required String description,
    String? confirmLabel,
  }) async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: title,
      description: description,
      mainButtonTitle:
          confirmLabel ?? _localizationService.strings.commonDelete,
      secondaryButtonTitle: _localizationService.strings.commonCancel,
    );
    return response?.confirmed ?? false;
  }
}
