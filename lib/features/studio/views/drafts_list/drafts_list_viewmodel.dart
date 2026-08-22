import 'dart:typed_data';

import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/features/studio/dialogs/edit_draft/edit_draft_dialog_data.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/render/cv_composer.dart';
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/template_thumbnail_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// Studio's landing page: every saved CV, with create/open/rename/
/// duplicate/delete. Opening or creating a draft hands off to
/// [StudioViewRoute] to actually edit it.
class DraftsListViewModel extends ReactiveViewModel implements Initialisable {
  final _draftService = locator<DraftService>();
  final _vaultService = locator<VaultService>();
  final _templateRegistry = locator<TemplateRegistryService>();
  final _thumbnailService = locator<TemplateThumbnailService>();
  final _dialogService = locator<DialogService>();
  final _routerService = locator<RouterService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [
    _draftService,
    _vaultService,
  ];

  static const _loadBusyKey = 'drafts_load';

  @override
  void initialise() => runBusyFuture(_load(), busyObject: _loadBusyKey);

  /// A real `async` wrapper, not `runBusyFuture(_vaultService.load())`
  /// directly — see `StudioViewModel._load`'s doc comment for why: the
  /// Vault is needed here too now, for each card's thumbnail.
  Future<void> _load() async {
    await _vaultService.load();
    await _draftService.load();
  }

  bool get isLoading => busy(_loadBusyKey);
  bool get hasLoadError => hasErrorForKey(_loadBusyKey);

  bool get hasPersistError => _draftService.persistError != null;

  Future<void> retryPersist() => _draftService.flushPendingWrites();

  List<CvDraft> get drafts => _draftService.drafts;
  bool get isEmpty => drafts.isEmpty;

  String templateName(String templateId) =>
      _templateRegistry.byId(templateId).displayName;

  /// This draft's own [ResolvedCv] — the same join [StudioViewModel.
  /// resolvedCv] performs, computed per-draft here since the drafts list
  /// shows every draft at once rather than one active one.
  ResolvedCv _resolvedCv(CvDraft draft) => CvComposer.compose(
    _vaultService.vault,
    draft,
    region: draft.region,
    sectionOrder: draft.effectiveSectionOrder,
  );

  PdfPageFormat pageFormat(CvDraft draft) =>
      draft.region.preset.page.toPdfPageFormat;

  /// Width ÷ height of [draft]'s own page format, so its card's thumbnail
  /// slot matches a US Letter draft's proportions as readily as an A4
  /// one — see `TemplateGalleryDialogModel.pageAspectRatio`'s identical
  /// rationale.
  double pageAspectRatio(CvDraft draft) {
    final format = pageFormat(draft);
    return format.width / format.height;
  }

  /// Cached per draft id, keyed additionally on the [ResolvedCv]/template
  /// it was rendered from so a card's `FutureBuilder` doesn't re-request a
  /// render on every list rebuild, and a stale render (this draft's
  /// content or template changed since) is evicted rather than shown —
  /// same shape as `TemplateGalleryDialogModel._thumbnailFutures`, one
  /// level up: keyed per draft rather than per template, since this grid
  /// shows many drafts rather than one draft's many templates.
  final _thumbnailCache = <String, ({ResolvedCv cv, String templateId})>{};
  final _thumbnailFutures = <String, Future<Uint8List>>{};

  Future<Uint8List> thumbnailFor(CvDraft draft) {
    final cv = _resolvedCv(draft);
    final cached = _thumbnailCache[draft.id];
    if (cached != null &&
        cached.cv == cv &&
        cached.templateId == draft.templateId) {
      return _thumbnailFutures[draft.id]!;
    }
    _thumbnailCache[draft.id] = (cv: cv, templateId: draft.templateId);
    final future = _thumbnailService.thumbnail(
      cv: cv,
      templateId: draft.templateId,
      format: pageFormat(draft),
    );
    _thumbnailFutures[draft.id] = future;
    return future;
  }

  Future<void> createDraft() async {
    final result = await _editDraftDialog(
      title: 'New CV',
      initial: const EditDraftDialogData(name: '', notes: ''),
      mainButtonTitle: 'Create',
    );
    if (result == null) return;
    final id = await _draftService.createDraft(
      name: result.name,
      notes: result.notes,
      templateId: _templateRegistry.defaultTemplate.id,
    );
    await _routerService.replaceWith(StudioViewRoute(draftId: id));
  }

  Future<void> openDraft(String id) async {
    await _draftService.openDraft(id);
    await _routerService.replaceWith(StudioViewRoute(draftId: id));
  }

  Future<void> editDraft(CvDraft draft) async {
    final result = await _editDraftDialog(
      title: 'Edit CV details',
      initial: EditDraftDialogData(name: draft.name, notes: draft.notes),
      mainButtonTitle: 'Save',
    );
    if (result == null) return;
    await _draftService.updateDraftDetails(
      draft.id,
      name: result.name,
      notes: result.notes,
    );
  }

  Future<void> duplicateDraft(CvDraft draft) async {
    final id = await _draftService.duplicateDraft(draft.id);
    await _routerService.replaceWith(StudioViewRoute(draftId: id));
  }

  Future<void> deleteDraft(CvDraft draft) async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirmDelete,
      title: 'Delete "${draft.name}"?',
      description: "This can't be undone.",
      mainButtonTitle: 'Delete',
      secondaryButtonTitle: 'Cancel',
    );
    if (response?.confirmed != true) return;
    await _draftService.deleteDraft(draft.id);
  }

  Future<EditDraftDialogData?> _editDraftDialog({
    required String title,
    required EditDraftDialogData initial,
    required String mainButtonTitle,
  }) async {
    final response = await _dialogService
        .showCustomDialog<EditDraftDialogData, EditDraftDialogData>(
          variant: DialogType.editDraft,
          title: title,
          data: initial,
          mainButtonTitle: mainButtonTitle,
          secondaryButtonTitle: 'Cancel',
        );
    if (response?.confirmed != true) return null;
    return response?.data;
  }
}
