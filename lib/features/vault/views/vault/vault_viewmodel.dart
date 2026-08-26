import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/features/studio/dialogs/template_gallery/template_gallery_dialog_data.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/vault_selection.dart';
import 'package:cv_forge/models/render/cv_composer.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_data.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/vault/dialogs/crop_photo/crop_photo_dialog_data.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_photo.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/language_item.dart';
import 'package:cv_forge/models/vault/profile_link.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/file_upload_service.dart';
import 'package:cv_forge/services/profile_photo_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// What the right-hand editor panel is currently showing, if anything.
/// `experience`/`project`/`education` are keyed by id (many possible
/// cards); `basics`/`skills`/`hobbies`/`documentDefaults` are singletons
/// (exactly one card each).
enum VaultEditorTarget {
  none,

  /// The only target that edits configuration rather than career content —
  /// what every new CV starts out as. It routes through this same panel
  /// mechanism deliberately: the Vault already has one way to open an
  /// editor, and a settings surface bolted on beside it would read as
  /// foreign.
  documentDefaults,
  basics,
  experience,
  project,
  education,
  skills,
  hobbies,
  languages,
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
  final _templateRegistry = locator<TemplateRegistryService>();
  final _localizationService = locator<LocalizationService>();
  final _dialogService = locator<DialogService>();
  final _fileUpload = locator<FileUploadService>();
  final _photoService = locator<ProfilePhotoService>();

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
  /// `DraftsListViewModel._query`. Narrows every content section, the three
  /// that are a single summary card rather than a list (Basics, Skills,
  /// Hobbies) included: a card that ignored the search would be the one
  /// part of the list still showing content the query did not find. Only
  /// the CV-defaults card is exempt, and it hides outright rather than
  /// filtering — it is configuration, not content.
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

  /// Skill categories narrowed to the query: a category survives on its own
  /// name (keeping all of its skills), or on containing a matching skill
  /// (keeping only the skills that matched). Same rule the Skills editor
  /// filters by — see `SkillsEditorPanel`, where it is stated.
  List<SkillCategory> get filteredSkillCategories {
    if (_query.isEmpty) return vault.skillCategories;
    final matched = <SkillCategory>[];
    for (final category in vault.skillCategories) {
      if (category.name.toLowerCase().contains(_query)) {
        matched.add(category);
        continue;
      }
      final skills = category.skills
          .where((s) => s.label.toLowerCase().contains(_query))
          .toList();
      if (skills.isNotEmpty) matched.add(category.copyWith(skills: skills));
    }
    return matched;
  }

  /// Matches a hobby's text — the only field a hobby has.
  List<HobbyItem> get filteredHobbies =>
      _filtered(vault.hobbies, (h) => [h.text]);

  /// Matches a language's name. The proficiency is deliberately not
  /// searched: "c1" would match a band the user cannot see spelled that
  /// way anywhere in this list.
  List<LanguageItem> get filteredLanguages =>
      _filtered(vault.languages, (l) => [l.name]);

  /// Whether "About you" still has anything to show under the current
  /// query. True whenever nothing is being searched for, so the card is
  /// only ever hidden by an active search that missed it.
  bool get basicsMatchQuery {
    if (_query.isEmpty) return true;
    final basics = vault.basics;
    return [
      basics.fullName,
      basics.headline,
      basics.email,
      basics.summary ?? '',
      basics.workAuthorization ?? '',
    ].any((field) => field.toLowerCase().contains(_query));
  }

  VaultEditorTarget _openTarget = VaultEditorTarget.none;
  String? _openId;

  VaultEditorTarget get openTarget => _openTarget;
  String? get openId => _openId;
  bool get isEditorOpen => _openTarget != VaultEditorTarget.none;

  void openDocumentDefaultsEditor() =>
      _open(VaultEditorTarget.documentDefaults);
  void openBasicsEditor() => _open(VaultEditorTarget.basics);
  void openSkillsEditor() => _open(VaultEditorTarget.skills);
  void openHobbiesEditor() => _open(VaultEditorTarget.hobbies);
  void openLanguagesEditor() => _open(VaultEditorTarget.languages);
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

  DocumentDefaults get documentDefaults => vault.documentDefaults;

  Future<void> setDocumentLanguage(DocumentLanguage language) => _vaultService
      .setDocumentDefaults(documentDefaults.copyWith(language: language));

  /// Opens the same picker Studio's per-CV region button opens, in its
  /// `vaultDefault` context — one region surface with two entry points
  /// rather than two that can drift on wording or on which conventions
  /// they explain.
  ///
  /// Near-identical to `StudioViewModel.openRegionGallery` and left that
  /// way: they write to different services and pass different contexts, so
  /// factoring them together would need a home neither ViewModel owns.
  Future<void> openDefaultRegionPicker() async {
    final response = await _dialogService
        .showCustomDialog<RegionProfile, RegionGalleryDialogData>(
          variant: DialogType.regionGallery,
          data: RegionGalleryDialogData(
            currentRegion: documentDefaults.region,
            context: RegionGalleryContext.vaultDefault,
          ),
        );
    final selected = response?.data;
    if (response?.confirmed == true && selected != null) {
      await _vaultService.setDocumentDefaults(
        documentDefaults.copyWith(region: selected),
      );
    }
  }

  /// The template a new CV starts on. Falls back to the registry's own
  /// default when none has been chosen, so this getter always names a real
  /// template for the panel to show — `null` is a state the *stored* value
  /// has and the UI never does.
  CvTemplate get defaultTemplate => _templateRegistry.byId(
    documentDefaults.templateId ?? _templateRegistry.defaultTemplate.id,
  );

  /// Opens the same gallery Studio's per-CV template button opens, for the
  /// same reason [openDefaultRegionPicker] shares the region one.
  ///
  /// The thumbnails are rendered from the user's own Vault with everything
  /// selected, not from placeholder content — picking a template is a
  /// visual decision, and the whole value of the gallery is seeing your
  /// own CV in it. That composed draft is a throwaway and is never
  /// persisted; the Vault has no draft of its own, which is exactly why
  /// [VaultSelection] exists as a shared projection rather than as more
  /// inline code here.
  Future<void> openDefaultTemplatePicker() async {
    final region = documentDefaults.region;
    final previewDraft = VaultSelection.everythingIn(vault).applyTo(
      CvDraft.empty(
        id: 'vault-default-preview',
        templateId: defaultTemplate.id,
        region: region,
        documentLanguage: documentDefaults.language,
      ),
    );
    final response = await _dialogService
        .showCustomDialog<String, TemplateGalleryDialogData>(
          variant: DialogType.templateGallery,
          data: TemplateGalleryDialogData(
            currentTemplateId: defaultTemplate.id,
            cv: CvComposer.compose(
              vault,
              previewDraft,
              region: region,
              language: documentDefaults.language,
              sectionOrder: defaultSectionOrder,
            ),
            pageFormat: region.preset.page.toPdfPageFormat,
          ),
        );
    final selectedId = response?.data;
    if (response?.confirmed == true && selectedId != null) {
      await _vaultService.setDocumentDefaults(
        documentDefaults.copyWith(templateId: selectedId),
      );
    }
  }

  /// The order a new CV's sections start in — the saved default if there
  /// is one, else the default template's own suggestion. Always complete,
  /// so the panel lists every section rather than silently omitting one
  /// added since this was last saved.
  List<CvSectionType> get defaultSectionOrder => completeSectionOrder(
    documentDefaults.sectionOrder ?? defaultTemplate.sectionOrder,
  );

  bool isDefaultSectionHidden(CvSectionType type) =>
      documentDefaults.hiddenSections?.contains(type) ?? false;

  /// Whether a new CV starts with its headline shown — the same question
  /// Studio's pinned headline row asks per draft, one level up.
  ///
  /// Phrased as "include" rather than "hide" to match the checkbox it
  /// drives, and `StudioViewModel.includeHeadline` for the same reason.
  bool get includeDefaultHeadline => !documentDefaults.hideHeadline;

  Future<void> toggleDefaultHeadline() => _vaultService.setDocumentDefaults(
    documentDefaults.copyWith(hideHeadline: !documentDefaults.hideHeadline),
  );

  /// Whether a new CV starts with its work-authorisation line shown — the
  /// same question Studio's pinned row asks per draft, one level up.
  ///
  /// Worth a default of its own rather than leaving it per-CV: the line is
  /// relevant to a minority of applications, so someone who keeps a
  /// sentence in the Vault mostly wants it off and turned on deliberately.
  bool get includeDefaultWorkAuthorization =>
      !documentDefaults.hideWorkAuthorization;

  Future<void> toggleDefaultWorkAuthorization() =>
      _vaultService.setDocumentDefaults(
        documentDefaults.copyWith(
          hideWorkAuthorization: !documentDefaults.hideWorkAuthorization,
        ),
      );

  /// Unlike Studio's list, which shows only the sections the open draft has
  /// data for, this one lists every section: a default is being set for
  /// CVs that do not exist yet, so "has data" has nothing to answer to.
  /// Both indices are therefore positions in the full list.
  Future<void> reorderDefaultSections(int oldIndex, int newIndex) async {
    final order = [...defaultSectionOrder];
    order.insert(newIndex, order.removeAt(oldIndex));
    await _vaultService.setDocumentDefaults(
      documentDefaults.copyWith(sectionOrder: order),
    );
  }

  Future<void> toggleDefaultSectionHidden(CvSectionType type) async {
    final hidden = {...?documentDefaults.hiddenSections};
    if (!hidden.remove(type)) hidden.add(type);
    await _vaultService.setDocumentDefaults(
      // The order is written alongside it even when untouched: until now it
      // may only have been implied by the template, and leaving it null
      // while hiding a section would let a later template change silently
      // reorder a list the user has already curated.
      documentDefaults.copyWith(
        hiddenSections: hidden,
        sectionOrder: defaultSectionOrder,
      ),
    );
  }

  Future<void> updateBasics(ContactBasics basics) =>
      _vaultService.updateBasics(basics);

  bool _photoBusy = false;

  /// True across the decode, which is long enough to notice on a photo
  /// straight off a phone camera.
  bool get photoBusy => _photoBusy;

  String? _photoError;

  /// Rendered inline by the photo control. A picked file that can't be
  /// decoded is an ordinary outcome the user has to be told about — the
  /// one thing it must never be is silently dropped.
  String? get photoError => _photoError;

  /// Pick, decode, crop, store. Any step the user backs out of leaves the
  /// existing photo (or its absence) exactly as it was.
  Future<void> pickPhoto() async {
    _photoError = null;
    _photoBusy = true;
    rebuildUi();
    try {
      final picked = await _fileUpload.pickImageFile();
      if (picked == null) return;

      final prepared = _photoService.prepareForCrop(picked);
      if (prepared == null) {
        _photoError = _localizationService.strings.vaultPhotoErrorUnreadable;
        return;
      }

      final response = await _dialogService
          .showCustomDialog<CvPhoto, CropPhotoDialogData>(
            variant: DialogType.cropPhoto,
            data: CropPhotoDialogData(preparedJpeg: prepared),
          );
      if (response?.confirmed != true) return;

      final photo = response?.data;
      if (photo == null) {
        _photoError = _localizationService.strings.vaultPhotoErrorPrepareFailed;
        return;
      }
      await updateBasics(vault.basics.copyWith(photo: photo));
    } finally {
      _photoBusy = false;
      rebuildUi();
    }
  }

  Future<void> removePhoto() async {
    _photoError = null;
    await updateBasics(vault.basics.copyWith(photo: null));
  }

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

  Future<void> addLanguage(String name) => _vaultService.addLanguage(name);

  Future<void> updateLanguage(LanguageItem language) =>
      _vaultService.updateLanguage(language);

  Future<void> deleteLanguage(String id) => _vaultService.deleteLanguage(id);

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
