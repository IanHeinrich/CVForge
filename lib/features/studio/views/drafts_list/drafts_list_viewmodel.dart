import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/features/studio/dialogs/edit_draft/edit_draft_dialog_data.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// Studio's landing page: every saved CV, with create/open/rename/
/// duplicate/delete. Opening or creating a draft hands off to
/// [StudioViewRoute] to actually edit it.
class DraftsListViewModel extends ReactiveViewModel implements Initialisable {
  final _draftService = locator<DraftService>();
  final _templateRegistry = locator<TemplateRegistryService>();
  final _dialogService = locator<DialogService>();
  final _routerService = locator<RouterService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_draftService];

  static const _loadBusyKey = 'drafts_load';

  @override
  void initialise() =>
      runBusyFuture(_draftService.load(), busyObject: _loadBusyKey);

  bool get isLoading => busy(_loadBusyKey);
  bool get hasLoadError => hasErrorForKey(_loadBusyKey);

  bool get hasPersistError => _draftService.persistError != null;

  Future<void> retryPersist() => _draftService.flushPendingWrites();

  List<CvDraft> get drafts => _draftService.drafts;
  bool get isEmpty => drafts.isEmpty;

  String templateName(String templateId) =>
      _templateRegistry.byId(templateId).displayName;

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
