// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../features/studio/dialogs/ai_assistant_run/ai_assistant_run_dialog.dart';
import '../features/studio/dialogs/edit_draft/edit_draft_dialog.dart';
import '../features/studio/dialogs/region_gallery/region_gallery_dialog.dart';
import '../features/studio/dialogs/template_gallery/template_gallery_dialog.dart';
import '../features/vault/dialogs/confirm_delete/confirm_delete_dialog.dart';

enum DialogType {
  confirmDelete,
  editDraft,
  aiAssistantRun,
  templateGallery,
  regionGallery,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.confirmDelete: (context, request, completer) =>
        ConfirmDeleteDialog(request: request, completer: completer),
    DialogType.editDraft: (context, request, completer) =>
        EditDraftDialog(request: request, completer: completer),
    DialogType.aiAssistantRun: (context, request, completer) =>
        AiAssistantRunDialog(request: request, completer: completer),
    DialogType.templateGallery: (context, request, completer) =>
        TemplateGalleryDialog(request: request, completer: completer),
    DialogType.regionGallery: (context, request, completer) =>
        RegionGalleryDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
