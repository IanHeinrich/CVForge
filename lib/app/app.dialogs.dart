// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../features/vault/dialogs/confirm_delete/confirm_delete_dialog.dart';

enum DialogType { confirmDelete }

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.confirmDelete: (context, request, completer) =>
        ConfirmDeleteDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
