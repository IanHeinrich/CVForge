import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/features/studio/dialogs/edit_draft/edit_draft_dialog_data.dart';
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
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:pdf/pdf.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// What the preview pane should show, distinguishing an empty Vault (no
/// source data at all) from a Vault with data that just isn't included in
/// this draft — the two look identical as an empty [ResolvedCv] but need
/// different copy and a different recovery action.
enum StudioPreviewState { vaultEmpty, nothingSelected, ready }

/// Owns Studio's selection UI. It reads [VaultService] for the master data
/// and [DraftService] for what's currently selected, then hands both to
/// [CvComposer] to produce the [resolvedCv] the preview renders — this is
/// the ViewModel `CvComposer` gets its test coverage through, per the
/// outside-in testing convention (a dedicated composer test would be a
/// unit test of a pure function, which the project's conventions avoid
/// unless asked for).
class StudioViewModel extends ReactiveViewModel implements Initialisable {
  StudioViewModel({this.requestedDraftId});

  /// The `?draftId=…` query param `StudioView` was opened with, if any —
  /// see its doc comment for why this is a query param rather than a path
  /// segment. `null` means "show whatever `DraftService` already has
  /// active", the pre-existing behaviour.
  final String? requestedDraftId;

  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _templateRegistry = locator<TemplateRegistryService>();
  final _pdfExportService = locator<PdfExportService>();
  final _routerService = locator<RouterService>();
  final _dialogService = locator<DialogService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [
    _vaultService,
    _draftService,
  ];

  /// Loads both services on this View's own account — see
  /// `VaultViewModel.initialise`'s doc comment for why. Keyed on
  /// [_loadBusyKey] rather than the model-level `isBusy`/`hasError` so a
  /// load in progress can't be confused with [isExporting]/
  /// [hasExportError], which reuse the model-level flags for the export
  /// action.
  static const _loadBusyKey = 'studio_load';

  @override
  void initialise() => runBusyFuture(_load(), busyObject: _loadBusyKey);

  Future<void> _load() async {
    await _vaultService.load();
    await _draftService.load();
    // No-ops for a null/unknown/already-active id (see `DraftService.
    // openDraft`'s doc comment) — a stale bookmark to a since-deleted
    // draft just falls back to whatever's active, the same "dangling ids
    // are normal" rule the rest of this app already follows.
    if (requestedDraftId != null) {
      await _draftService.openDraft(requestedDraftId!);
    }
    if (_draftService.isFreshDraft) await _selectAllFromVault();
  }

  /// A never-before-persisted draft (a first-time user's seeded draft, or
  /// one just created via "New CV") starts with everything in the Vault
  /// selected, rather than empty — once the user checks/unchecks anything,
  /// that becomes the real, persisted selection and this never runs again
  /// for that draft (see [DraftService.isFreshDraft]).
  Future<void> _selectAllFromVault() async {
    final vault = _vaultService.vault;
    await _draftService.selectAllFromVault(
      experienceIds: [for (final e in vault.experiences) e.id],
      bulletIds: {
        for (final e in vault.experiences)
          e.id: [for (final b in e.bullets) b.id],
      },
      projectIds: [for (final p in vault.projects) p.id],
      projectBulletIds: {
        for (final p in vault.projects) p.id: [for (final b in p.bullets) b.id],
      },
      skillIds: [
        for (final category in vault.skillCategories)
          for (final skill in category.skills) skill.id,
      ],
      educationIds: [for (final e in vault.education) e.id],
      hobbyIds: [for (final h in vault.hobbies) h.id],
    );
  }

  bool get isLoading => busy(_loadBusyKey);
  bool get hasLoadError => hasErrorForKey(_loadBusyKey);

  /// Mirrors `VaultViewModel.hasPersistError`/`retryPersist` for the draft
  /// side, so a failed selection write is surfaced rather than silently
  /// lost.
  bool get hasPersistError => _draftService.persistError != null;

  Future<void> retryPersist() => _draftService.flushPendingWrites();

  CvVault get _vault => _vaultService.vault;
  CvDraft get _draft => _draftService.draft;

  CvTemplate get template => _templateRegistry.byId(_draft.templateId);

  /// A4 today — [RegionProfile] is the seam a future Letter-format preset
  /// plugs into without touching this ViewModel.
  PdfPageFormat get pageFormat => PdfPageFormat.a4;

  ResolvedCv get resolvedCv =>
      CvComposer.compose(_vault, _draft, region: RegionProfile.uk);

  /// [CvVault.isEmpty] (no source data anywhere) is checked ahead of an
  /// empty [resolvedCv] (data exists but nothing is included) — the two
  /// states render the same "nothing to preview" outcome but need
  /// different copy and different recovery actions, see
  /// [StudioPreviewState].
  StudioPreviewState get previewState {
    if (_vault.isEmpty) return StudioPreviewState.vaultEmpty;
    if (resolvedCv.sections.isEmpty) return StudioPreviewState.nothingSelected;
    return StudioPreviewState.ready;
  }

  /// Total count of individual Vault items (not categories/groups) — used
  /// in the [StudioPreviewState.nothingSelected] message so it can say
  /// how much is sitting unselected, not just that something is.
  int get vaultItemCount =>
      experiences.length +
      projects.length +
      _allSkills.length +
      education.length +
      hobbies.length;

  Future<void> goToVault() => _routerService.replaceWith(VaultViewRoute());

  Future<void> goToDrafts() =>
      _routerService.replaceWith(DraftsListViewRoute());

  String get draftName => _draft.name;
  String get draftNotes => _draft.notes;

  /// Opens the same name/notes editor "New CV" uses, pre-filled with this
  /// draft's current values, so a CV can be renamed without leaving Studio
  /// for the drafts list.
  Future<void> editDraftDetails() async {
    final response = await _dialogService
        .showCustomDialog<EditDraftDialogData, EditDraftDialogData>(
          variant: DialogType.editDraft,
          title: 'Edit CV details',
          data: EditDraftDialogData(name: _draft.name, notes: _draft.notes),
          mainButtonTitle: 'Save',
          secondaryButtonTitle: 'Cancel',
        );
    final result = response?.data;
    if (response?.confirmed != true || result == null) return;
    await _draftService.updateDraftDetails(
      _draft.id,
      name: result.name,
      notes: result.notes,
    );
  }

  /// The recovery action for [StudioPreviewState.nothingSelected]: unhides
  /// every section and selects every Vault item — including every bullet
  /// of every included experience/project, not just the top-level entries
  /// — the same starting point a fresh draft gets from
  /// [_selectAllFromVault]. Runs sequentially rather than via
  /// `Future.wait` so each step reads the selection state left by the one
  /// before it, not a stale snapshot.
  Future<void> includeEverything() async {
    await addAllExperiences();
    for (final experience in experiences) {
      await addAllExperienceBullets(experience);
    }
    await addAllProjects();
    for (final project in projects) {
      await addAllProjectBullets(project);
    }
    await addAllSkills();
    await addAllEducation();
    await addAllHobbies();
    for (final type in CvSectionType.values) {
      if (isSectionHidden(type)) await toggleSectionHidden(type);
    }
  }

  // --- section visibility ---

  bool get hasSummary =>
      (_draft.tailoredSummary ?? _vault.basics.summary)?.trim().isNotEmpty ??
      false;

  bool get hasReferences =>
      (_draft.referencesOverride ?? _vault.referencesNote ?? '')
          .trim()
          .isNotEmpty;

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

  // --- text overrides ---
  //
  // Every override setter below shares one rule: empty input, or input
  // identical to the Vault's own value, collapses back to "no override"
  // (null) rather than persisting a draft value that's merely a copy of
  // the Vault's. Without this, opening an editor and blurring without
  // actually changing anything would silently disconnect that field from
  // future Vault edits — see `StudioFieldOverrideCard`'s doc comment for
  // the UI-level reasoning this backs.

  /// Shared by every override setter in this section.
  String? _normalizeOverride(String value, String? source) {
    final trimmed = value.trim();
    return trimmed.isEmpty || trimmed == (source ?? '').trim() ? null : value;
  }

  // --- headline override ---

  String get vaultHeadline => _vault.basics.headline;
  String get headlineText => _draft.headlineOverride ?? _vault.basics.headline;
  bool get hasHeadlineOverride => _draft.headlineOverride != null;

  Future<void> setHeadlineOverride(String value) => _draftService
      .setHeadlineOverride(_normalizeOverride(value, _vault.basics.headline));

  Future<void> revertHeadlineToVault() =>
      _draftService.setHeadlineOverride(null);

  // --- tailored summary ---

  String? get vaultSummary => _vault.basics.summary;

  /// What the editor box shows: the draft's override if it has one, else
  /// the Vault's text (which the box starts pre-filled with).
  String get summaryText =>
      _draft.tailoredSummary ?? _vault.basics.summary ?? '';

  bool get hasTailoredSummary => _draft.tailoredSummary != null;

  Future<void> setTailoredSummary(String value) => _draftService
      .setTailoredSummary(_normalizeOverride(value, _vault.basics.summary));

  Future<void> revertSummaryToVault() => _draftService.setTailoredSummary(null);

  // --- references override ---

  String? get vaultReferencesNote => _vault.referencesNote;
  String get referencesText =>
      _draft.referencesOverride ?? _vault.referencesNote ?? '';
  bool get hasReferencesOverride => _draft.referencesOverride != null;

  Future<void> setReferencesOverride(String value) => _draftService
      .setReferencesOverride(_normalizeOverride(value, _vault.referencesNote));

  Future<void> revertReferencesToVault() =>
      _draftService.setReferencesOverride(null);

  bool isSectionHidden(CvSectionType type) =>
      _draft.hiddenSections.contains(type);

  Future<void> toggleSectionHidden(CvSectionType type) =>
      _draftService.setSectionHidden(type, hidden: !isSectionHidden(type));

  // --- experiences ---

  late final _experienceSelection = _Selection<Experience>(
    items: () => _vault.experiences,
    idOf: (e) => e.id,
    selectedIds: () => _draft.experienceIds,
    setIncluded: (e, {required included}) =>
        _draftService.setExperienceIncluded(
          e.id,
          included: included,
          bulletIds: e.bullets.map((b) => b.id).toList(),
        ),
  );

  List<Experience> get experiences => _vault.experiences;

  bool isExperienceIncluded(String id) => _experienceSelection.isIncluded(id);

  Future<void> toggleExperience(Experience experience) =>
      _experienceSelection.toggle(experience);

  List<Experience> get unselectedExperiences => _experienceSelection.unselected;

  Future<void> addAllExperiences() => _experienceSelection.addAll();

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

  /// Selects every bullet of [experience] not already included. Must
  /// `await` each [toggleExperienceBullet] before starting the next —
  /// each call reads `_draft.bulletIds` fresh to compute its own updated
  /// list, so firing them all without awaiting would have every call read
  /// the same pre-toggle draft and only the last write survive.
  Future<void> addAllExperienceBullets(Experience experience) async {
    for (final bullet in experience.bullets) {
      if (!isExperienceBulletIncluded(experience.id, bullet.id)) {
        await toggleExperienceBullet(experience, bullet);
      }
    }
  }

  // --- projects ---

  late final _projectSelection = _Selection<Project>(
    items: () => _vault.projects,
    idOf: (p) => p.id,
    selectedIds: () => _draft.projectIds,
    setIncluded: (p, {required included}) => _draftService.setProjectIncluded(
      p.id,
      included: included,
      bulletIds: p.bullets.map((b) => b.id).toList(),
    ),
  );

  List<Project> get projects => _vault.projects;

  bool isProjectIncluded(String id) => _projectSelection.isIncluded(id);

  Future<void> toggleProject(Project project) =>
      _projectSelection.toggle(project);

  List<Project> get unselectedProjects => _projectSelection.unselected;

  Future<void> addAllProjects() => _projectSelection.addAll();

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

  /// Same shape as [addAllExperienceBullets], one entity type over.
  Future<void> addAllProjectBullets(Project project) async {
    for (final bullet in project.bullets) {
      if (!isProjectBulletIncluded(project.id, bullet.id)) {
        await toggleProjectBullet(project, bullet);
      }
    }
  }

  // --- bullet text overrides ---
  //
  // Shared by experience and project bullets alike — bullet ids are
  // globally unique (see `Skill.linkedBulletIds`'s doc comment), so an
  // override lookup needs only the bullet, never which entity it belongs
  // to.

  String bulletText(CvBullet bullet) =>
      _draft.bulletOverrides[bullet.id] ?? bullet.text;

  bool hasBulletOverride(String bulletId) =>
      _draft.bulletOverrides.containsKey(bulletId);

  Future<void> setBulletOverride(CvBullet bullet, String value) => _draftService
      .setBulletOverride(bullet.id, _normalizeOverride(value, bullet.text));

  Future<void> revertBulletOverride(String bulletId) =>
      _draftService.setBulletOverride(bulletId, null);

  // --- skills ---

  late final _skillSelection = _Selection<Skill>(
    items: () => _allSkills,
    idOf: (s) => s.id,
    selectedIds: () => _draft.skillIds,
    setIncluded: (s, {required included}) =>
        _draftService.setSkillIncluded(s.id, included: included),
  );

  List<SkillCategory> get skillCategories => _vault.skillCategories;

  List<Skill> get _allSkills => [
    for (final category in skillCategories) ...category.skills,
  ];

  bool isSkillIncluded(String id) => _skillSelection.isIncluded(id);

  Future<void> toggleSkill(Skill skill) => _skillSelection.toggle(skill);

  List<Skill> get unselectedSkills => _skillSelection.unselected;

  Future<void> addAllSkills() => _skillSelection.addAll();

  // --- education ---

  late final _educationSelection = _Selection<Education>(
    items: () => _vault.education,
    idOf: (e) => e.id,
    selectedIds: () => _draft.educationIds,
    setIncluded: (e, {required included}) =>
        _draftService.setEducationIncluded(e.id, included: included),
  );

  List<Education> get education => _vault.education;

  bool isEducationIncluded(String id) => _educationSelection.isIncluded(id);

  Future<void> toggleEducation(Education entry) =>
      _educationSelection.toggle(entry);

  List<Education> get unselectedEducation => _educationSelection.unselected;

  Future<void> addAllEducation() => _educationSelection.addAll();

  /// Same shape as [bulletText] — only [Education.details] is prose, so
  /// that's the only field an override map exists for.
  String educationDetailsText(Education entry) =>
      _draft.educationDetailsOverrides[entry.id] ?? entry.details ?? '';

  bool hasEducationDetailsOverride(String educationId) =>
      _draft.educationDetailsOverrides.containsKey(educationId);

  Future<void> setEducationDetailsOverride(Education entry, String value) =>
      _draftService.setEducationDetailsOverride(
        entry.id,
        _normalizeOverride(value, entry.details),
      );

  Future<void> revertEducationDetailsOverride(String educationId) =>
      _draftService.setEducationDetailsOverride(educationId, null);

  // --- hobbies ---

  late final _hobbySelection = _Selection<HobbyItem>(
    items: () => _vault.hobbies,
    idOf: (h) => h.id,
    selectedIds: () => _draft.hobbyIds,
    setIncluded: (h, {required included}) =>
        _draftService.setHobbyIncluded(h.id, included: included),
  );

  List<HobbyItem> get hobbies => _vault.hobbies;

  bool isHobbyIncluded(String id) => _hobbySelection.isIncluded(id);

  Future<void> toggleHobby(HobbyItem hobby) => _hobbySelection.toggle(hobby);

  List<HobbyItem> get unselectedHobbies => _hobbySelection.unselected;

  Future<void> addAllHobbies() => _hobbySelection.addAll();

  // --- export ---

  bool get isExporting => isBusy;
  bool get hasExportError => hasError;
  Object? get exportError => modelError;

  /// Recovery copy for [hasExportError], one per [PdfExportStage] — falls
  /// back to a generic message for anything that isn't a
  /// [PdfExportException] (there shouldn't be one, but a raw exception
  /// leaking past `PdfExportService` shouldn't crash this getter).
  String get exportErrorMessage {
    final error = exportError;
    if (error is! PdfExportException) {
      return "Couldn't export the PDF — try again.";
    }
    return switch (error.stage) {
      PdfExportStage.fonts =>
        "Couldn't load the fonts needed to export — check your "
            'connection and try again.',
      PdfExportStage.render =>
        "Couldn't generate the PDF — try again, and if it keeps "
            'failing, check your CV for unusual characters or formatting.',
      PdfExportStage.save =>
        "Couldn't save the file — check your browser's download "
            'settings and try again.',
    };
  }

  /// Fires straight off the calling `onPressed` with fonts already warmed
  /// by `StartupViewModel` — web export needs a real user gesture, and the
  /// longer the async gap after the click, the stricter Safari gets about
  /// still honouring it.
  Future<void> exportPdf() => runBusyFuture(
    _pdfExportService.export(
      cv: resolvedCv,
      templateId: template.id,
      fullName: _vault.basics.fullName,
      draftName: _draft.name,
      format: pageFormat,
    ),
  );
}

/// Backs every `isXIncluded`/`toggleX`/`unselectedX`/`addAllX` quartet
/// above — experiences, projects, skills, education, and hobbies are all
/// "a flat list of ids, toggled by id against [DraftService]" with only
/// the Vault collection and the setter differing, so one generic class
/// replaces five near-identical copies.
///
/// [items] and [selectedIds] are closures re-evaluated on every call, not
/// values captured once — the ViewModel's own `_vault`/`_draft` getters
/// change out from under a `late final _xSelection` field across its
/// lifetime, and this is what lets one `_Selection` instance stay correct
/// for that instance's whole lifetime rather than only reflecting
/// whatever was true when it was first constructed.
class _Selection<T> {
  _Selection({
    required this.items,
    required this.idOf,
    required this.selectedIds,
    required this.setIncluded,
  });

  final List<T> Function() items;
  final String Function(T item) idOf;
  final List<String> Function() selectedIds;
  final Future<void> Function(T item, {required bool included}) setIncluded;

  bool isIncluded(String id) => selectedIds().contains(id);

  Future<void> toggle(T item) =>
      setIncluded(item, included: !isIncluded(idOf(item)));

  List<T> get unselected =>
      items().where((item) => !isIncluded(idOf(item))).toList();

  /// Includes every currently-unselected item, one at a time — each
  /// [toggle] must be awaited before the next starts, since [isIncluded]
  /// reads [selectedIds] fresh on every call and a synchronous loop would
  /// have every toggle see the same pre-toggle selection.
  Future<void> addAll() async {
    for (final item in unselected) {
      await toggle(item);
    }
  }
}
