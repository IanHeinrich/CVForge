// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../features/studio/dialogs/ai_assistant_run/ai_assistant_run_dialog.dart';
import '../features/studio/dialogs/cv_translation_run/cv_translation_run_dialog.dart';
import '../features/studio/dialogs/edit_draft/edit_draft_dialog.dart';
import '../features/studio/dialogs/region_gallery/region_gallery_dialog.dart';
import '../features/studio/dialogs/template_gallery/template_gallery_dialog.dart';
import '../features/vault/dialogs/confirm_delete/confirm_delete_dialog.dart';
import '../features/vault/dialogs/crop_photo/crop_photo_dialog.dart';
import '../ui/dialogs/expand_text/expand_text_dialog.dart';

enum DialogType {
  confirmDelete,
  editDraft,
  aiAssistantRun,
  templateGallery,
  regionGallery,
  cropPhoto,
  cvTranslationRun,
  expandText,
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
    DialogType.cropPhoto: (context, request, completer) =>
        CropPhotoDialog(request: request, completer: completer),
    DialogType.cvTranslationRun: (context, request, completer) =>
        CvTranslationRunDialog(request: request, completer: completer),
    DialogType.expandText: (context, request, completer) =>
        ExpandTextDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
