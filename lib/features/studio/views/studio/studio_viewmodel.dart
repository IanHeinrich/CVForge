import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/ui/common/l10n/document_language_labels.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/features/studio/dialogs/ai_assistant_run/ai_assistant_run_dialog_data.dart';
import 'package:cv_forge/features/studio/dialogs/edit_draft/edit_draft_dialog_data.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_data.dart';
import 'package:cv_forge/features/studio/dialogs/template_gallery/template_gallery_dialog_data.dart';
import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/vault_selection.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/models/draft/text_override_field.dart';
import 'package:cv_forge/models/render/cv_composer.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/language_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// What the preview pane should show, distinguishing an empty Vault (no
/// source data at all) from a Vault with data that just isn't included in
/// this draft — the two look identical as an empty [ResolvedCv] but need
/// different copy and a different recovery action.
enum StudioPreviewState { vaultEmpty, nothingSelected, ready }

/// Which overlay the preview pane draws over the rendered page, if any.
///
/// One tri-state rather than two independent flags, because the two
/// overlays are genuinely exclusive: `AtsXrayPainter` suppresses every
/// other layer while it is drawing the reading-order chain, so
/// "boxes *and* reading order" is not a state that can be rendered. A
/// pair of booleans could express it, and would then need a rule
/// somewhere keeping them from both being true.
enum StudioXrayMode {
  /// The ordinary rendered page, no overlay.
  off,

  /// Every extracted text run boxed, severity-coloured where a finding
  /// claimed it.
  boxes,

  /// The order a position-sorting extractor walks the page in.
  readingOrder,
}

/// Owns Studio's selection UI. It reads [VaultService] for the master data
/// and [DraftService] for what's currently selected, then hands both to
/// [CvComposer] to produce the [resolvedCv] the preview renders — this is
/// the ViewModel `CvComposer` gets its test coverage through, per the
/// outside-in testing convention.
class StudioViewModel extends ReactiveViewModel implements Initialisable {
  StudioViewModel({this.requestedDraftId});

  /// The `?draftId=…` query param `StudioView` was opened with — see its
  /// doc comment for why a query param rather than a path segment. `null`
  /// shows whatever `DraftService` already has active.
  final String? requestedDraftId;

  final _vaultService = locator<VaultService>();
  final _draftService = locator<DraftService>();
  final _settingsService = locator<SettingsService>();
  final _localizationService = locator<LocalizationService>();
  final _templateRegistry = locator<TemplateRegistryService>();
  final _pdfExportService = locator<PdfExportService>();
  final _routerService = locator<RouterService>();
  final _dialogService = locator<DialogService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [
    _vaultService,
    _draftService,
    // Added for [hasAiAssistantKey]: adding a key in Settings has to
    // re-enable "Tailor with AI" here without a reload.
    _settingsService,
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
    await _refreshAiAssistantUndoState();
    await _refreshCvTranslationUndoState();
  }

  /// A never-before-persisted draft (a first-time user's seeded draft, or
  /// one just created via "New CV") starts with everything in the Vault
  /// selected, rather than empty — once the user checks/unchecks anything,
  /// that becomes the real, persisted selection and this never runs again
  /// for that draft (see [DraftService.isFreshDraft]).
  Future<void> _selectAllFromVault() async {
    final selection = VaultSelection.everythingIn(_vaultService.vault);
    await _draftService.selectAllFromVault(
      experienceIds: selection.experienceIds,
      bulletIds: selection.bulletIds,
      projectIds: selection.projectIds,
      projectBulletIds: selection.projectBulletIds,
      skillIds: selection.skillIds,
      educationIds: selection.educationIds,
      educationBulletIds: selection.educationBulletIds,
      hobbyIds: selection.hobbyIds,
      languageIds: selection.languageIds,
      publicationIds: selection.publicationIds,
      publicationBulletIds: selection.publicationBulletIds,
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

  Future<void> setTemplate(String templateId) =>
      _draftService.setTemplate(templateId);

  /// Opens the template gallery and applies whatever was confirmed. A
  /// cancelled dialog returns `confirmed: false` and this is a no-op —
  /// [TemplateGalleryDialog] never calls back with `confirmed: true` and a
  /// null template id, so the null-check here is just satisfying the
  /// nullable [DialogResponse.data] type, not a real "confirmed but no
  /// selection" case.
  Future<void> openTemplateGallery() async {
    final response = await _dialogService
        .showCustomDialog<String, TemplateGalleryDialogData>(
          variant: DialogType.templateGallery,
          data: TemplateGalleryDialogData(
            currentTemplateId: template.id,
            cv: resolvedCv,
            pageFormat: pageFormat,
          ),
        );
    final selectedId = response?.data;
    if (response?.confirmed == true && selectedId != null) {
      await setTemplate(selectedId);
    }
  }

  RegionProfile get region => _draft.region;

  /// This CV's own language — the value that renders, not the Vault's
  /// default. See [CvDraft.documentLanguage] for why it is per-draft.
  DocumentLanguage get documentLanguage => _draft.documentLanguage;

  Future<void> setDocumentLanguage(DocumentLanguage language) =>
      _draftService.setDocumentLanguage(language);
  Future<void> setRegion(RegionProfile region) =>
      _draftService.setRegion(region);

  /// Opens the region picker and applies whatever was confirmed — same
  /// cancel/null-check shape as [openTemplateGallery], for the same
  /// reason.
  Future<void> openRegionGallery() async {
    final response = await _dialogService
        .showCustomDialog<RegionProfile, RegionGalleryDialogData>(
          variant: DialogType.regionGallery,
          data: RegionGalleryDialogData(
            currentRegion: region,
            context: RegionGalleryContext.draft,
          ),
        );
    final selected = response?.data;
    if (response?.confirmed == true && selected != null) {
      await setRegion(selected);
    }
  }

  PdfPageFormat get pageFormat => _draft.region.preset.page.toPdfPageFormat;

  /// Memoised on the identity of the Vault and Draft it was composed from.
  /// `StudioPreviewPane` reads this two to four times per build and
  /// rebuilds on every selection toggle, so recomposing per read walked the
  /// whole Vault and rebuilt the section tree for nothing.
  ///
  /// Identity, not equality: both services hand back the same instance
  /// until a write actually replaces it, so `identical` is the exact "has
  /// anything changed" signal, and a miss only costs the recompute that
  /// used to happen unconditionally. [CvDraft] supplies the region and
  /// section order too, so those need no key of their own.
  ResolvedCv get resolvedCv {
    final vault = _vault;
    final draft = _draft;
    final cached = _composed;
    if (cached != null &&
        identical(vault, _composedVault) &&
        identical(draft, _composedDraft)) {
      return cached;
    }
    final composed = CvComposer.compose(
      vault,
      draft,
      region: draft.region,
      language: draft.documentLanguage,
      sectionOrder: draft.effectiveSectionOrder,
    );
    _composedVault = vault;
    _composedDraft = draft;
    _composed = composed;
    return composed;
  }

  CvVault? _composedVault;
  CvDraft? _composedDraft;
  ResolvedCv? _composed;

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
      hobbies.length +
      languages.length +
      publications.length;

  /// Page count of the most recent successful render, or `null` before the
  /// first one. Set by `StudioPreviewPane`, which is the only place the
  /// rasterised page list exists — nothing else in this ViewModel can
  /// compute it without rasterising a second time.
  int? get pageCount => _pageCount;
  int? _pageCount;

  void setPageCount(int value) {
    if (_pageCount == value) return;
    _pageCount = value;
    notifyListeners();
  }

  /// Which ATS overlay the preview pane is drawing — what a text extractor
  /// pulls out of the CV, over the CV itself.
  ///
  /// A view mode rather than a separate analysis step, because the
  /// overlay's backdrop is rasterised by the same pass that produced its
  /// geometry (see `StudioXrayPane`). There is no "stale overlay" state to
  /// manage: boxes and page are always from one render.
  StudioXrayMode get xrayMode => _xrayMode;
  StudioXrayMode _xrayMode = StudioXrayMode.off;

  /// Whether any overlay is showing — what the preview pane branches on to
  /// decide which pane to build at all.
  bool get xrayEnabled => _xrayMode != StudioXrayMode.off;

  /// Whether that overlay is the reading-order chain, which is what
  /// `AtsXrayPainter.showFlowLines` takes.
  bool get xrayReadingOrder => _xrayMode == StudioXrayMode.readingOrder;

  /// Each mode's control is a toggle onto that mode, and pressing the mode
  /// already showing turns the overlay off. Both controls are permanently
  /// visible, so either is equally a way in — reading order is a peer of
  /// the boxes, not something nested behind them.
  void toggleXrayMode(StudioXrayMode mode) {
    assert(
      mode != StudioXrayMode.off,
      'Use closeXray to turn the overlay off.',
    );
    _xrayMode = _xrayMode == mode ? StudioXrayMode.off : mode;
    if (_xrayMode == StudioXrayMode.off) _xrayResult = null;
    notifyListeners();
  }

  /// The control group's label, stepping through every state in turn:
  /// off → boxes → reading order → off.
  ///
  /// It cannot mean "show both" — `AtsXrayPainter` draws the reading-order
  /// chain *instead of* every other layer, deliberately, because the boxes
  /// and the chain competing is what made the chain hard to follow. A
  /// cycle is what that constraint leaves: one control that reaches all
  /// three states, with the two icons as direct jumps into a mode for
  /// anyone who would rather not step.
  ///
  /// Declaration order *is* the cycle order, so a mode added to
  /// [StudioXrayMode] joins it by being declared in the right place
  /// rather than by editing here.
  void cycleXrayMode() {
    const values = StudioXrayMode.values;
    _xrayMode = values[(_xrayMode.index + 1) % values.length];
    if (_xrayMode == StudioXrayMode.off) _xrayResult = null;
    notifyListeners();
  }

  /// Back to the ordinary preview, whichever overlay was showing. Distinct
  /// from [cycleXrayMode] because the one caller — the X-Ray's own error
  /// state — needs "off" outright rather than the next state along.
  void closeXray() {
    if (_xrayMode == StudioXrayMode.off) return;
    _xrayMode = StudioXrayMode.off;
    _xrayResult = null;
    notifyListeners();
  }

  /// The findings from the most recent X-Ray pass, or null while one is
  /// still running (and whenever the overlay is off).
  ///
  /// Held here rather than inside `StudioXrayPane` because two sibling
  /// panes need it: the pane draws the boxes, and the editor column lists
  /// what they mean. Reported up by the pane that computes it — the same
  /// shape as [setPageCount], and for the same reason: it is derived from
  /// a render only that pane performs.
  AtsAnalysisResult? get xrayResult => _xrayResult;
  AtsAnalysisResult? _xrayResult;

  void setXrayResult(AtsAnalysisResult? value) {
    if (identical(_xrayResult, value)) return;
    _xrayResult = value;
    notifyListeners();
  }

  /// Why this CV has run longer than its region typically expects, or null
  /// when it hasn't — the badge branches on null rather than doing the
  /// comparison itself, keeping the judgement out of the View.
  ///
  /// Null while [pageCount] is still null: "we don't know yet" is not
  /// "you're fine", but it is not something to warn about either, and the
  /// badge isn't rendered in that state at all.
  ///
  /// Strictly *over* the typical maximum — a two-page CV in a two-page
  /// market is fine, not marginal. And the message offers the template as
  /// well as the content, because page count follows template density at
  /// least as much as it follows region; a warning that only says "cut
  /// something" is wrong about half the time.
  String? get pageCountWarning {
    final count = pageCount;
    if (count == null) return null;
    final preset = _draft.region.preset;
    if (count <= preset.typicalMaxPages) return null;
    final strings = _localizationService.strings;
    return strings.studioLengthWarning(
      _draft.region.displayName(strings),
      _draft.region.lengthNote(strings),
    );
  }

  /// Set when the chosen template prints a photograph into a market that
  /// doesn't want one — the one place `RegionPhotoStance` reaches beyond
  /// advice into something the app says unprompted.
  ///
  /// Advisory, never a block: plenty of legitimate reasons exist to send a
  /// photo CV anywhere, and the user picked this template deliberately.
  /// Only fires for `prohibited`/`discouraged`; `optional` is a genuine
  /// choice and warning about it would be noise.
  ///
  /// Nothing here checks whether the Vault actually holds a photo. The
  /// mismatch worth flagging is the *intent* — a template chosen to print
  /// one, aimed at a market that rejects them — and staying silent until
  /// the photo is uploaded would surface the warning at the moment it is
  /// least useful.
  String? get photoRegionWarning {
    if (!template.tags.contains(TemplateTag.photo)) return null;
    final strings = _localizationService.strings;
    return switch (region.preset.photo) {
      RegionPhotoStance.prohibited ||
      RegionPhotoStance.discouraged => strings.studioPhotoRegionWarning(
        region.preset.photo.name,
        region.displayName(strings),
      ),
      RegionPhotoStance.optional || RegionPhotoStance.expected => null,
    };
  }

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
          title: _localizationService.strings.studioEditDraftDetailsTitle(
            _draft.region.preset.documentNoun.name,
          ),
          data: EditDraftDialogData(name: _draft.name, notes: _draft.notes),
          mainButtonTitle: _localizationService.strings.commonSave,
          secondaryButtonTitle: _localizationService.strings.commonCancel,
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
    await addAllLanguages();
    await addAllPublications();
    for (final publication in publications) {
      await addAllPublicationBullets(publication);
    }
    for (final type in CvSectionType.values) {
      if (isSectionHidden(type)) await toggleSectionHidden(type);
    }
  }

  String get targetJobDescription => _draft.targetJobDescription ?? '';

  bool get hasTargetJobDescription => targetJobDescription.trim().isNotEmpty;

  Future<void> setTargetJobDescription(String value) => _draftService
      .setTargetJobDescription(_TextOverride.normalize(value, null));

  Future<void> clearTargetJobDescription() =>
      _draftService.setTargetJobDescription(null);

  /// Whether the AI Assistant has a key to run with. Gates "Tailor with AI"
  /// up front instead of letting the run dialog fail with
  /// `LlmFailure.noKey` — that check happened only after the user had
  /// written a job description and opened a modal, which is the most
  /// expensive possible moment to learn the feature was never set up.
  bool get hasAiAssistantKey =>
      _settingsService.apiKeyOriginFor(
        _settingsService.selectedAiAssistantProvider.id,
      ) !=
      ApiKeyOrigin.none;

  Future<void> goToAiAssistantSettings() =>
      _routerService.replaceWith(SettingsViewRoute());

  bool _hasAiAssistantUndo = false;
  bool get hasAiAssistantUndo => _hasAiAssistantUndo;

  Future<void> _refreshAiAssistantUndoState() async {
    _hasAiAssistantUndo = await _draftService.hasAiAssistantUndoFor(_draft.id);
    notifyListeners();
  }

  /// Opens [AiAssistantRunDialog], which drives the whole pass — confirm, run,
  /// apply, show rationale/keywordGaps — on its own; this just refreshes
  /// [hasAiAssistantUndo] afterwards, since a successful run inside the dialog
  /// already called [DraftService.applyAiAssistantResult] before returning.
  Future<void> tailorWithAi() async {
    await _dialogService.showCustomDialog(
      variant: DialogType.aiAssistantRun,
      data: AiAssistantRunDialogData(jobDescription: targetJobDescription),
    );
    await _refreshAiAssistantUndoState();
  }

  // Translation. Shares the AI Assistant's provider/key setup — hence
  // [hasAiAssistantKey] rather than a second key check — and nothing else.

  /// The language a translation run would produce, named on the card so
  /// the choice is visible where the action is, not only in the document
  /// bar where it was made.
  String get translationTargetLanguage =>
      _draft.documentLanguage.displayLabel(_localizationService.strings);

  /// The language this draft was last translated into, or null if never.
  String? get translatedLanguage =>
      _draft.translatedTo?.displayLabel(_localizationService.strings);

  /// Whether the applied translation is for a language this CV is no
  /// longer set to — the user changed the document language afterwards, so
  /// what prints is a translation into the wrong one.
  bool get isTranslationStale {
    final translated = _draft.translatedTo;
    return translated != null && translated != _draft.documentLanguage;
  }

  /// Opens [CvTranslationRunDialog], which drives the whole pass on its
  /// own — confirm, run, apply — exactly as [tailorWithAi] does.
  Future<void> translateCv() async {
    await _dialogService.showCustomDialog(variant: DialogType.cvTranslationRun);
    notifyListeners();
  }

  /// Whether a pre-translation snapshot exists to go back to.
  ///
  /// Gates the Remove affordance on the same thing that makes it work,
  /// rather than on [translatedLanguage] alone — otherwise the button can
  /// be offered when there is nothing to restore, and pressing it does
  /// nothing at all.
  bool _hasCvTranslationUndo = false;
  bool get hasCvTranslationUndo => _hasCvTranslationUndo;

  Future<void> _refreshCvTranslationUndoState() async {
    _hasCvTranslationUndo = await _draftService.hasCvTranslationUndoFor(
      _draft.id,
    );
    notifyListeners();
  }

  /// Restores the draft to its pre-translation state.
  ///
  /// Confirmed first because it is lossier than it looks: an override
  /// records no provenance, so anything hand-edited after the pass is
  /// indistinguishable from the translation and goes back with it.
  Future<void> removeTranslation() async {
    final strings = _localizationService.strings;
    final response = await _dialogService.showDialog(
      title: strings.studioTranslateRemove,
      description: strings.studioTranslateRemoveConfirm,
      buttonTitle: strings.commonRemove,
      cancelTitle: strings.commonCancel,
    );
    if (response?.confirmed != true) return;
    await _draftService.removeCvTranslation();
    await _refreshCvTranslationUndoState();
  }

  /// Whether this draft says anything the Vault does not, and so whether
  /// there is any wording to reset.
  ///
  /// The id-keyed half is derived from `TextOverrideField.values`, not
  /// listed here — a new overridable field must not be able to go missing
  /// from this check. Only the three scalar overrides, which have no id to
  /// key by and so aren't in that enum, are named individually.
  bool get hasWordingOverrides =>
      _draft.headlineOverride != null ||
      _draft.tailoredSummary != null ||
      _draft.referencesOverride != null ||
      _draft.hasAnyTextOverride;

  /// Discards every per-draft text edit — hand edits, AI rewrites and any
  /// translation alike — so each line reads as the Vault has it.
  ///
  /// The unconditional escape hatch, and the reason it is worth having
  /// even beside "Undo AI changes" and "Remove translation": those depend
  /// on a snapshot, and this only depends on the Vault, which is always
  /// there. Confirmed first because nothing can undo it.
  Future<void> resetWordingToVault() async {
    final strings = _localizationService.strings;
    if (!await _confirmReset(
      strings.studioResetWording,
      strings.studioResetWordingConfirm,
    )) {
      return;
    }
    await _draftService.resetWordingToVault();
    await _refreshAiAssistantUndoState();
    await _refreshCvTranslationUndoState();
  }

  Future<void> undoAiAssistantChanges() async {
    await _draftService.undoAiAssistantPass();
    await _refreshAiAssistantUndoState();
  }

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
    CvSectionType.languages => languages.isNotEmpty,
    CvSectionType.references => hasReferences,
    CvSectionType.publications => publications.isNotEmpty,
  };

  // Text overrides: every field below is "draft override, falling back to
  // the Vault's own value" — [_TextOverride] carries the shared behaviour
  // (blank or Vault-identical input collapses to "no override" rather
  // than persisting a value that's merely a copy of the Vault's — see its
  // doc comment for why) so each field here is just wiring, not its own
  // copy of that rule.

  String get vaultHeadline => _vault.basics.headline;
  late final _headlineOverride = _TextOverride(
    vaultValue: () => _vault.basics.headline,
    draftValue: () => _draft.headlineOverride,
    setOverride: _draftService.setHeadlineOverride,
  );
  String get headlineText => _headlineOverride.text;
  bool get hasHeadlineOverride => _headlineOverride.hasOverride;
  Future<void> setHeadlineOverride(String value) =>
      _headlineOverride.set(value);
  Future<void> revertHeadlineToVault() => _headlineOverride.revert();

  /// Whether the headline prints at all. Independent of the override
  /// above, which survives being hidden so toggling back restores the
  /// edit rather than discarding it.
  bool get includeHeadline => !_draft.hideHeadline;

  Future<void> toggleHeadline() =>
      _draftService.setHeadlineHidden(includeHeadline);

  String? get vaultSummary => _vault.basics.summary;
  late final _summaryOverride = _TextOverride(
    vaultValue: () => _vault.basics.summary,
    draftValue: () => _draft.tailoredSummary,
    setOverride: _draftService.setTailoredSummary,
  );
  String get summaryText => _summaryOverride.text;
  bool get hasTailoredSummary => _summaryOverride.hasOverride;
  Future<void> setTailoredSummary(String value) => _summaryOverride.set(value);
  Future<void> revertSummaryToVault() => _summaryOverride.revert();

  String? get vaultReferencesNote => _vault.referencesNote;
  late final _referencesOverride = _TextOverride(
    vaultValue: () => _vault.referencesNote,
    draftValue: () => _draft.referencesOverride,
    setOverride: _draftService.setReferencesOverride,
  );
  String get referencesText => _referencesOverride.text;
  bool get hasReferencesOverride => _referencesOverride.hasOverride;
  Future<void> setReferencesOverride(String value) =>
      _referencesOverride.set(value);
  Future<void> revertReferencesToVault() => _referencesOverride.revert();

  bool isSectionHidden(CvSectionType type) =>
      _draft.hiddenSections.contains(type);

  /// Hiding the section currently open in the editor pane clears the
  /// selection rather than leaving the editor showing a section the nav
  /// no longer lists — [openSection] only ever points at something
  /// [sectionHasData] and visible.
  Future<void> toggleSectionHidden(CvSectionType type) async {
    final hiding = !isSectionHidden(type);
    await _draftService.setSectionHidden(type, hidden: hiding);
    if (hiding && _openSection == type) selectSection(null);
  }

  /// Which section's items the editor pane is showing. Null on open —
  /// deliberately, so the first thing seen is the section list rather
  /// than an arbitrary section's contents. Not persisted: which section
  /// was last being edited isn't part of the document, and restoring it
  /// on load would fight that same "start at the list" decision.
  CvSectionType? get openSection => _openSection;
  CvSectionType? _openSection;

  void selectSection(CvSectionType? type) {
    if (_openSection == type && !_headlineOpen) return;
    _openSection = type;
    _headlineOpen = false;
    notifyListeners();
  }

  /// Whether the editor pane is showing the headline rather than a
  /// section.
  ///
  /// The headline is not a [CvSectionType] and must not become one — it
  /// prints in the name block, has no heading of its own and cannot be
  /// reordered, so a ninth case would appear in the reorderable list as a
  /// draggable row that changes nothing. It still needs its own row and
  /// its own editor, so "what the pane is showing" is a section *or* the
  /// headline, and this is the second half of that.
  bool get isHeadlineOpen => _headlineOpen;
  bool _headlineOpen = false;

  void selectHeadline() {
    if (_headlineOpen) return;
    _headlineOpen = true;
    _openSection = null;
    notifyListeners();
  }

  /// Whether there is a headline to show a row for at all — the same
  /// "nothing behind it, so no toggle" rule [sectionHasData] applies to
  /// every section.
  bool get hasHeadline =>
      (_draft.headlineOverride ?? _vault.basics.headline).trim().isNotEmpty;

  /// This draft's full section order (all [CvSectionType] cases, whether
  /// [sectionHasData] or not) — the "Sections" picker filters this down to
  /// the ones with data for display and dragging, per [reorderSections]'s
  /// doc comment.
  List<CvSectionType> get sectionOrder => _draft.effectiveSectionOrder;

  /// [oldIndex]/[newIndex] are positions within the *visible*
  /// ([sectionHasData]) subsequence, matching what the "Sections" list
  /// actually shows and drags — a no-data section has no meaningful
  /// position, so each reorder simply appends every no-data section,
  /// unchanged, after the reordered visible ones. `CvComposer` already
  /// skips a no-data section regardless of where it sits in the order, so
  /// nothing is lost; if such a section later gains data it reappears at
  /// the end of the visible list rather than at its old slot.
  Future<void> reorderSections(int oldIndex, int newIndex) async {
    final visible = sectionOrder.where(sectionHasData).toList();
    final invisible = sectionOrder.where((t) => !sectionHasData(t)).toList();
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    await _draftService.setSectionOrder([...visible, ...invisible]);
  }

  /// Resets this draft's order and hidden-sections state back to the
  /// user's saved default (or, if they've never saved one, the active
  /// template's own suggested order with nothing hidden).
  ///
  /// The defaults are passed in rather than read by `DraftService`, which
  /// stays decoupled from the Vault — see its class doc comment.
  /// Both reset controls ask first. Neither can be undone — the wording
  /// reset discards edits no snapshot holds, and the section reset
  /// discards an arrangement that was never stored anywhere else — and
  /// they sit next to each other, so one asking and the other not would
  /// read as the silent one being the safe one.
  Future<bool> _confirmReset(String title, String description) async {
    final strings = _localizationService.strings;
    final response = await _dialogService.showDialog(
      title: title,
      description: description,
      buttonTitle: strings.commonReset,
      cancelTitle: strings.commonCancel,
    );
    return response?.confirmed == true;
  }

  Future<void> resetSectionSettings() async {
    final strings = _localizationService.strings;
    if (!await _confirmReset(
      strings.studioSectionsResetDefault,
      strings.studioSectionsResetDefaultConfirm,
    )) {
      return;
    }
    await _draftService.resetSectionSettings(
      _vaultService.vault.documentDefaults,
    );
  }

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

  List<Experience> get selectedExperiences => _experienceSelection.selected;

  Future<void> removeAllExperiences() => _experienceSelection.removeAll();

  late final _experienceBullets = _BulletSelection(
    selectedIdsFor: (id) => _draft.bulletIds[id] ?? const [],
    setBulletIds: (id, ids) =>
        _draftService.setBulletIds(BulletOwner.experience, id, ids),
  );

  bool isExperienceBulletIncluded(String experienceId, String bulletId) =>
      _experienceBullets.isIncluded(experienceId, bulletId);

  Future<void> toggleExperienceBullet(Experience experience, CvBullet bullet) =>
      _experienceBullets.toggle(experience.id, experience.bullets, bullet.id);

  Future<void> addAllExperienceBullets(Experience experience) =>
      _experienceBullets.addAll(experience.id, experience.bullets);

  Future<void> removeAllExperienceBullets(Experience experience) =>
      _experienceBullets.removeAll(experience.id, experience.bullets);

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

  List<Project> get selectedProjects => _projectSelection.selected;

  Future<void> removeAllProjects() => _projectSelection.removeAll();

  late final _projectBullets = _BulletSelection(
    selectedIdsFor: (id) => _draft.projectBulletIds[id] ?? const [],
    setBulletIds: (id, ids) =>
        _draftService.setBulletIds(BulletOwner.project, id, ids),
  );

  bool isProjectBulletIncluded(String projectId, String bulletId) =>
      _projectBullets.isIncluded(projectId, bulletId);

  Future<void> toggleProjectBullet(Project project, CvBullet bullet) =>
      _projectBullets.toggle(project.id, project.bullets, bullet.id);

  Future<void> addAllProjectBullets(Project project) =>
      _projectBullets.addAll(project.id, project.bullets);

  Future<void> removeAllProjectBullets(Project project) =>
      _projectBullets.removeAll(project.id, project.bullets);

  // Every id-keyed override quartet below is the same four operations
  // over a different [TextOverrideField] and Vault fallback. Blank input,
  // or input identical to the Vault's own value, collapses back to "no
  // override" — see [_TextOverride], which applies the same rule to the
  // three scalar fields.
  //
  // Bullet ids are globally unique (see `Skill.linkedBulletIds`), so a
  // bullet override needs only the bullet, never its owning entity.

  String _overrideText(
    TextOverrideField field,
    String id,
    String? vaultValue,
  ) => field.of(_draft)[id] ?? vaultValue ?? '';

  bool _hasOverride(TextOverrideField field, String id) =>
      field.of(_draft).containsKey(id);

  Future<void> _setOverride(
    TextOverrideField field,
    String id,
    String value,
    String? vaultValue,
  ) => _draftService.setTextOverride(
    field,
    id,
    _TextOverride.normalize(value, vaultValue),
  );

  Future<void> _revertOverride(TextOverrideField field, String id) =>
      _draftService.setTextOverride(field, id, null);

  String bulletText(CvBullet bullet) =>
      _overrideText(TextOverrideField.bullet, bullet.id, bullet.text);

  bool hasBulletOverride(String bulletId) =>
      _hasOverride(TextOverrideField.bullet, bulletId);

  Future<void> setBulletOverride(CvBullet bullet, String value) =>
      _setOverride(TextOverrideField.bullet, bullet.id, value, bullet.text);

  Future<void> revertBulletOverride(String bulletId) =>
      _revertOverride(TextOverrideField.bullet, bulletId);

  // The entity-title overrides below are the same wiring as [bulletText],
  // one per field that prints. They exist so a draft can shorten a job
  // title or drop a market's untranslatable jargon for one application
  // without editing the Vault, which would change every other draft.

  String roleText(Experience entry) =>
      _overrideText(TextOverrideField.role, entry.id, entry.role);

  bool hasRoleOverride(String experienceId) =>
      _hasOverride(TextOverrideField.role, experienceId);

  Future<void> setRoleOverride(Experience entry, String value) =>
      _setOverride(TextOverrideField.role, entry.id, value, entry.role);

  Future<void> revertRoleOverride(String experienceId) =>
      _revertOverride(TextOverrideField.role, experienceId);

  String projectTitleText(Project entry) =>
      _overrideText(TextOverrideField.projectTitle, entry.id, entry.title);

  bool hasProjectTitleOverride(String projectId) =>
      _hasOverride(TextOverrideField.projectTitle, projectId);

  Future<void> setProjectTitleOverride(Project entry, String value) =>
      _setOverride(
        TextOverrideField.projectTitle,
        entry.id,
        value,
        entry.title,
      );

  Future<void> revertProjectTitleOverride(String projectId) =>
      _revertOverride(TextOverrideField.projectTitle, projectId);

  /// Whether [entityId] drops [field] on this draft — the third state a
  /// printed field can be in, alongside Vault-sourced and overridden.
  /// Generic rather than a pair of wrappers per field: unlike a text
  /// override there is no per-field effective value to resolve, so there
  /// would be nothing for the wrappers to do.
  bool isFieldOmitted(DraftOmittableField field, String entityId) =>
      field.isOmittedFor(_draft, entityId);

  Future<void> toggleFieldOmitted(DraftOmittableField field, String entityId) =>
      _draftService.setFieldOmitted(
        field,
        entityId,
        omitted: !isFieldOmitted(field, entityId),
      );

  String publicationTitleText(Publication entry) =>
      _overrideText(TextOverrideField.publicationTitle, entry.id, entry.title);

  bool hasPublicationTitleOverride(String publicationId) =>
      _hasOverride(TextOverrideField.publicationTitle, publicationId);

  Future<void> setPublicationTitleOverride(Publication entry, String value) =>
      _setOverride(
        TextOverrideField.publicationTitle,
        entry.id,
        value,
        entry.title,
      );

  Future<void> revertPublicationTitleOverride(String publicationId) =>
      _revertOverride(TextOverrideField.publicationTitle, publicationId);

  String publicationCitationText(Publication entry) => _overrideText(
    TextOverrideField.publicationCitation,
    entry.id,
    entry.citation ?? '',
  );

  bool hasPublicationCitationOverride(String publicationId) =>
      _hasOverride(TextOverrideField.publicationCitation, publicationId);

  Future<void> setPublicationCitationOverride(
    Publication entry,
    String value,
  ) => _setOverride(
    TextOverrideField.publicationCitation,
    entry.id,
    value,
    entry.citation ?? '',
  );

  Future<void> revertPublicationCitationOverride(String publicationId) =>
      _revertOverride(TextOverrideField.publicationCitation, publicationId);

  String experienceLocationText(Experience entry) => _overrideText(
    TextOverrideField.experienceLocation,
    entry.id,
    entry.location,
  );

  bool hasExperienceLocationOverride(String experienceId) =>
      _hasOverride(TextOverrideField.experienceLocation, experienceId);

  Future<void> setExperienceLocationOverride(Experience entry, String value) =>
      _setOverride(
        TextOverrideField.experienceLocation,
        entry.id,
        value,
        entry.location,
      );

  Future<void> revertExperienceLocationOverride(String experienceId) =>
      _revertOverride(TextOverrideField.experienceLocation, experienceId);

  String educationLocationText(Education entry) => _overrideText(
    TextOverrideField.educationLocation,
    entry.id,
    entry.location ?? '',
  );

  bool hasEducationLocationOverride(String educationId) =>
      _hasOverride(TextOverrideField.educationLocation, educationId);

  Future<void> setEducationLocationOverride(Education entry, String value) =>
      _setOverride(
        TextOverrideField.educationLocation,
        entry.id,
        value,
        entry.location ?? '',
      );

  Future<void> revertEducationLocationOverride(String educationId) =>
      _revertOverride(TextOverrideField.educationLocation, educationId);

  String skillLabelText(Skill entry) =>
      _overrideText(TextOverrideField.skillLabel, entry.id, entry.label);

  bool hasSkillLabelOverride(String skillId) =>
      _hasOverride(TextOverrideField.skillLabel, skillId);

  Future<void> setSkillLabelOverride(Skill entry, String value) =>
      _setOverride(TextOverrideField.skillLabel, entry.id, value, entry.label);

  Future<void> revertSkillLabelOverride(String skillId) =>
      _revertOverride(TextOverrideField.skillLabel, skillId);

  String skillCategoryNameText(SkillCategory entry) =>
      _overrideText(TextOverrideField.skillCategoryName, entry.id, entry.name);

  bool hasSkillCategoryNameOverride(String categoryId) =>
      _hasOverride(TextOverrideField.skillCategoryName, categoryId);

  Future<void> setSkillCategoryNameOverride(
    SkillCategory entry,
    String value,
  ) => _setOverride(
    TextOverrideField.skillCategoryName,
    entry.id,
    value,
    entry.name,
  );

  Future<void> revertSkillCategoryNameOverride(String categoryId) =>
      _revertOverride(TextOverrideField.skillCategoryName, categoryId);

  String hobbyText(HobbyItem entry) =>
      _overrideText(TextOverrideField.hobby, entry.id, entry.text);

  bool hasHobbyOverride(String hobbyId) =>
      _hasOverride(TextOverrideField.hobby, hobbyId);

  Future<void> setHobbyOverride(HobbyItem entry, String value) =>
      _setOverride(TextOverrideField.hobby, entry.id, value, entry.text);

  Future<void> revertHobbyOverride(String hobbyId) =>
      _revertOverride(TextOverrideField.hobby, hobbyId);

  String languageName(LanguageItem entry) =>
      _overrideText(TextOverrideField.language, entry.id, entry.name);

  bool hasLanguageOverride(String languageId) =>
      _hasOverride(TextOverrideField.language, languageId);

  Future<void> setLanguageOverride(LanguageItem entry, String value) =>
      _setOverride(TextOverrideField.language, entry.id, value, entry.name);

  Future<void> revertLanguageOverride(String languageId) =>
      _revertOverride(TextOverrideField.language, languageId);

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

  /// Same shape as [_Selection.addAll], restricted to one category.
  Future<void> addAllSkillsInCategory(SkillCategory category) async {
    for (final skill in category.skills) {
      if (!isSkillIncluded(skill.id)) await toggleSkill(skill);
    }
  }

  /// Inverse of [addAllSkillsInCategory].
  Future<void> removeAllSkillsInCategory(SkillCategory category) async {
    for (final skill in category.skills) {
      if (isSkillIncluded(skill.id)) await toggleSkill(skill);
    }
  }

  /// Bullet ids currently included in this draft, across all four
  /// bullet-owning collections — restricted to entries that are themselves
  /// included, since an excluded entry's bullet map entry doesn't mean the
  /// bullets are shown. Backs [unselectedEvidencedSkills],
  /// [selectEvidencedSkills], and [evidenceCountFor].
  Set<String> get _includedBulletIds => {
    for (final id in _draft.experienceIds) ...?_draft.bulletIds[id],
    for (final id in _draft.projectIds) ...?_draft.projectBulletIds[id],
    for (final id in _draft.publicationIds) ...?_draft.publicationBulletIds[id],
    for (final entry in _vault.education)
      if (_draft.educationIds.contains(entry.id))
        ..._educationBulletSelection(entry),
  };

  /// Skills [selectEvidencedSkills] would add — i.e. not yet selected, and
  /// linked to at least one bullet currently included in this draft. A
  /// separate getter from the action itself so the "Select N evidenced
  /// skills" button can show the count before it fires.
  List<Skill> get unselectedEvidencedSkills {
    final included = _includedBulletIds;
    return _allSkills
        .where(
          (s) =>
              !isSkillIncluded(s.id) &&
              s.linkedBulletIds.any(included.contains),
        )
        .toList();
  }

  /// Selects every skill linked to a bullet already included in this
  /// draft — the CV's own evidence deciding which skills to claim, rather
  /// than a manual pass through every category. Adds only: a skill already
  /// selected (whether or not it's linked to anything) is never touched,
  /// so this can never undo a manual selection.
  Future<void> selectEvidencedSkills() async {
    for (final skill in unselectedEvidencedSkills) {
      await toggleSkill(skill);
    }
  }

  /// Whether any skill in the whole Vault has ever been linked to a
  /// bullet — distinguishes "nothing has been linked yet" from "everything
  /// evidenced is already selected" so the evidenced-skills button in
  /// `StudioSkillSelector` can explain a zero count correctly instead of
  /// just going quietly disabled.
  bool get hasAnyLinkedSkills =>
      _allSkills.any((s) => s.linkedBulletIds.isNotEmpty);

  /// How many of [skill]'s linked bullets are included in this draft right
  /// now — backs a per-chip "proven by N included bullets" tooltip in
  /// `StudioSkillSelector`. Zero for a skill with no links at all, same as
  /// one whose links exist but none are currently included.
  int evidenceCountFor(Skill skill) =>
      skill.linkedBulletIds.where(_includedBulletIds.contains).length;

  late final _educationSelection = _Selection<Education>(
    items: () => _vault.education,
    idOf: (e) => e.id,
    selectedIds: () => _draft.educationIds,
    setIncluded: (e, {required included}) => _draftService.setEducationIncluded(
      e.id,
      included: included,
      bulletIds: e.bullets.map((b) => b.id).toList(),
    ),
  );

  List<Education> get education => _vault.education;

  bool isEducationIncluded(String id) => _educationSelection.isIncluded(id);

  Future<void> toggleEducation(Education entry) =>
      _educationSelection.toggle(entry);

  List<Education> get unselectedEducation => _educationSelection.unselected;

  Future<void> addAllEducation() => _educationSelection.addAll();

  List<Education> get selectedEducation => _educationSelection.selected;

  Future<void> removeAllEducation() => _educationSelection.removeAll();

  /// [entry]'s included bullet ids, through the absent-means-all rule
  /// that only education carries — see `CvDraft.educationBulletIds`. The
  /// one place this ViewModel resolves it, so the rest of the class can
  /// treat education like every other bullet owner.
  List<String> _educationBulletSelection(Education entry) =>
      _draft.educationBulletSelection(entry.id, [
        for (final b in entry.bullets) b.id,
      ]);

  late final _educationBullets = _BulletSelection(
    selectedIdsFor: (id) {
      final entry = _vault.education.where((e) => e.id == id).firstOrNull;
      return entry == null ? const [] : _educationBulletSelection(entry);
    },
    setBulletIds: (id, ids) =>
        _draftService.setBulletIds(BulletOwner.education, id, ids),
  );

  bool isEducationBulletIncluded(String educationId, String bulletId) =>
      _educationBullets.isIncluded(educationId, bulletId);

  Future<void> toggleEducationBullet(Education entry, CvBullet bullet) =>
      _educationBullets.toggle(entry.id, entry.bullets, bullet.id);

  Future<void> addAllEducationBullets(Education entry) =>
      _educationBullets.addAll(entry.id, entry.bullets);

  Future<void> removeAllEducationBullets(Education entry) =>
      _educationBullets.removeAll(entry.id, entry.bullets);

  /// Same shape as [bulletText]. [Education.institution] and `year` have
  /// no counterpart here deliberately — see [CvDraft]'s override-layer
  /// doc for which fields stay Vault-sourced and why.
  String educationDetailsText(Education entry) => _overrideText(
    TextOverrideField.educationDetails,
    entry.id,
    entry.details,
  );

  bool hasEducationDetailsOverride(String educationId) =>
      _hasOverride(TextOverrideField.educationDetails, educationId);

  Future<void> setEducationDetailsOverride(Education entry, String value) =>
      _setOverride(
        TextOverrideField.educationDetails,
        entry.id,
        value,
        entry.details,
      );

  Future<void> revertEducationDetailsOverride(String educationId) =>
      _revertOverride(TextOverrideField.educationDetails, educationId);

  String educationQualificationText(Education entry) => _overrideText(
    TextOverrideField.educationQualification,
    entry.id,
    entry.qualification,
  );

  bool hasEducationQualificationOverride(String educationId) =>
      _hasOverride(TextOverrideField.educationQualification, educationId);

  Future<void> setEducationQualificationOverride(
    Education entry,
    String value,
  ) => _setOverride(
    TextOverrideField.educationQualification,
    entry.id,
    value,
    entry.qualification,
  );

  Future<void> revertEducationQualificationOverride(String educationId) =>
      _revertOverride(TextOverrideField.educationQualification, educationId);

  String educationGradeText(Education entry) =>
      _overrideText(TextOverrideField.educationGrade, entry.id, entry.grade);

  bool hasEducationGradeOverride(String educationId) =>
      _hasOverride(TextOverrideField.educationGrade, educationId);

  Future<void> setEducationGradeOverride(Education entry, String value) =>
      _setOverride(
        TextOverrideField.educationGrade,
        entry.id,
        value,
        entry.grade,
      );

  Future<void> revertEducationGradeOverride(String educationId) =>
      _revertOverride(TextOverrideField.educationGrade, educationId);

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

  List<HobbyItem> get selectedHobbies => _hobbySelection.selected;

  Future<void> removeAllHobbies() => _hobbySelection.removeAll();

  late final _languageSelection = _Selection<LanguageItem>(
    items: () => _vault.languages,
    idOf: (l) => l.id,
    selectedIds: () => _draft.languageIds,
    setIncluded: (l, {required included}) =>
        _draftService.setLanguageIncluded(l.id, included: included),
  );

  List<LanguageItem> get languages => _vault.languages;

  bool isLanguageIncluded(String id) => _languageSelection.isIncluded(id);

  Future<void> toggleLanguage(LanguageItem language) =>
      _languageSelection.toggle(language);

  List<LanguageItem> get unselectedLanguages => _languageSelection.unselected;

  Future<void> addAllLanguages() => _languageSelection.addAll();

  List<LanguageItem> get selectedLanguages => _languageSelection.selected;

  Future<void> removeAllLanguages() => _languageSelection.removeAll();

  late final _publicationSelection = _Selection<Publication>(
    items: () => _vault.publications,
    idOf: (p) => p.id,
    selectedIds: () => _draft.publicationIds,
    setIncluded: (p, {required included}) =>
        _draftService.setPublicationIncluded(
          p.id,
          included: included,
          bulletIds: p.bullets.map((b) => b.id).toList(),
        ),
  );

  List<Publication> get publications => _vault.publications;

  bool isPublicationIncluded(String id) => _publicationSelection.isIncluded(id);

  Future<void> togglePublication(Publication publication) =>
      _publicationSelection.toggle(publication);

  List<Publication> get unselectedPublications =>
      _publicationSelection.unselected;

  Future<void> addAllPublications() => _publicationSelection.addAll();

  List<Publication> get selectedPublications => _publicationSelection.selected;

  Future<void> removeAllPublications() => _publicationSelection.removeAll();

  late final _publicationBullets = _BulletSelection(
    selectedIdsFor: (id) => _draft.publicationBulletIds[id] ?? const [],
    setBulletIds: (id, ids) =>
        _draftService.setBulletIds(BulletOwner.publication, id, ids),
  );

  bool isPublicationBulletIncluded(String publicationId, String bulletId) =>
      _publicationBullets.isIncluded(publicationId, bulletId);

  Future<void> togglePublicationBullet(
    Publication publication,
    CvBullet bullet,
  ) => _publicationBullets.toggle(
    publication.id,
    publication.bullets,
    bullet.id,
  );

  Future<void> addAllPublicationBullets(Publication publication) =>
      _publicationBullets.addAll(publication.id, publication.bullets);

  Future<void> removeAllPublicationBullets(Publication publication) =>
      _publicationBullets.removeAll(publication.id, publication.bullets);

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
      return _localizationService.strings.studioExportErrorGeneric;
    }
    return switch (error.stage) {
      PdfExportStage.fonts =>
        _localizationService.strings.studioExportErrorFonts,
      PdfExportStage.render =>
        _localizationService.strings.studioExportErrorRender,
      PdfExportStage.save => _localizationService.strings.studioExportErrorSave,
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
/// the Vault collection and the setter differing.
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

  List<T> get selected =>
      items().where((item) => isIncluded(idOf(item))).toList();

  /// Includes every currently-unselected item, one at a time — each
  /// [toggle] must be awaited before the next starts, since [isIncluded]
  /// reads [selectedIds] fresh on every call and a synchronous loop would
  /// have every toggle see the same pre-toggle selection.
  Future<void> addAll() async {
    for (final item in unselected) {
      await toggle(item);
    }
  }

  Future<void> removeAll() async {
    for (final item in selected) {
      await toggle(item);
    }
  }
}

/// Backs the isXBulletIncluded/toggleXBullet/addAllXBullets/
/// removeAllXBullets quartet for experience, project and publication
/// bullets — the same "selected ids keyed by owner, toggled through
/// `DraftService.setBulletIds`, preserving the owner's own bullet order"
/// shape three times over, differing only in which of `CvDraft`'s three
/// bullet-id maps backs it. [selectedIdsFor] is re-evaluated on every
/// call for the same reason [_Selection.selectedIds] is.
class _BulletSelection {
  _BulletSelection({required this.selectedIdsFor, required this.setBulletIds});

  final List<String> Function(String ownerId) selectedIdsFor;
  final Future<void> Function(String ownerId, List<String> bulletIds)
  setBulletIds;

  bool isIncluded(String ownerId, String bulletId) =>
      selectedIdsFor(ownerId).contains(bulletId);

  /// Toggles [bulletId] within [ownerId]'s selection, writing back
  /// [allBullets] filtered to the (post-toggle) selected set — preserving
  /// the owner's own bullet order rather than the order bullets happened
  /// to be toggled in.
  Future<void> toggle(
    String ownerId,
    List<CvBullet> allBullets,
    String bulletId,
  ) {
    final selected = {...selectedIdsFor(ownerId)};
    if (!selected.remove(bulletId)) selected.add(bulletId);
    return setBulletIds(
      ownerId,
      allBullets.map((b) => b.id).where(selected.contains).toList(),
    );
  }

  /// Selects every bullet of [allBullets] not already included, awaiting
  /// each toggle for the reason [_Selection.addAll] gives.
  Future<void> addAll(String ownerId, List<CvBullet> allBullets) async {
    for (final bullet in allBullets) {
      if (!isIncluded(ownerId, bullet.id)) {
        await toggle(ownerId, allBullets, bullet.id);
      }
    }
  }

  Future<void> removeAll(String ownerId, List<CvBullet> allBullets) async {
    for (final bullet in allBullets) {
      if (isIncluded(ownerId, bullet.id)) {
        await toggle(ownerId, allBullets, bullet.id);
      }
    }
  }
}

/// One of the three scalar draft overrides — headline, tailored summary,
/// references note — falling back to the Vault's own value.
///
/// Blank input, or input identical to the Vault's, collapses back to "no
/// override" (`null`); otherwise opening an editor and blurring without
/// changing anything would silently disconnect the field from future
/// Vault edits. [normalize] is the id-keyed fields' rule too.
class _TextOverride {
  _TextOverride({
    required this.vaultValue,
    required this.draftValue,
    required this.setOverride,
  });

  final String? Function() vaultValue;
  final String? Function() draftValue;
  final Future<void> Function(String? value) setOverride;

  bool get hasOverride => draftValue() != null;
  String get text => draftValue() ?? vaultValue() ?? '';

  Future<void> set(String value) => setOverride(normalize(value, vaultValue()));

  Future<void> revert() => setOverride(null);

  static String? normalize(String value, String? source) {
    final trimmed = value.trim();
    return trimmed.isEmpty || trimmed == (source ?? '').trim() ? null : value;
  }
}
