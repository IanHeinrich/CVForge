// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../features/studio/dialogs/copilot_run/copilot_run_dialog.dart';
import '../features/studio/dialogs/edit_draft/edit_draft_dialog.dart';
import '../features/vault/dialogs/confirm_delete/confirm_delete_dialog.dart';

enum DialogType { confirmDelete, editDraft, copilotRun }

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.confirmDelete: (context, request, completer) =>
        ConfirmDeleteDialog(request: request, completer: completer),
    DialogType.editDraft: (context, request, completer) =>
        EditDraftDialog(request: request, completer: completer),
    DialogType.copilotRun: (context, request, completer) =>
        CopilotRunDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
