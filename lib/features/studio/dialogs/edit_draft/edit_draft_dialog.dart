import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'edit_draft_dialog_data.dart';
import 'edit_draft_dialog_model.dart';

/// Name + notes editor shared by "New CV" (blank [request.data]) and
/// "Edit CV details" (populated from the draft being edited).
class EditDraftDialog extends StackedView<EditDraftDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const EditDraftDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  EditDraftDialogData get _initial =>
      (request.data as EditDraftDialogData?) ??
      const EditDraftDialogData(name: '', notes: '');

  @override
  Widget builder(
    BuildContext context,
    EditDraftDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: request.title ?? 'CV details',
      maxWidth: 420,
      cancelLabel: request.secondaryButtonTitle ?? 'Cancel',
      confirmLabel: request.mainButtonTitle ?? 'Save',
      onCancel: () =>
          completer(DialogResponse<EditDraftDialogData>(confirmed: false)),
      onConfirm: () {
        final result = viewModel.submit();
        if (result == null) return;
        completer(
          DialogResponse<EditDraftDialogData>(confirmed: true, data: result),
        );
      },
      children: [
        const VGap.medium(),
        TextField(
          controller: viewModel.nameController,
          autofocus: true,
          onChanged: viewModel.onNameChanged,
          style: const TextStyle(color: kcWhite),
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. "Acme — Backend Engineer"',
            errorText: viewModel.showNameError ? 'Give this CV a name' : null,
          ),
        ),
        const VGap.small(),
        TextField(
          controller: viewModel.notesController,
          minLines: 2,
          maxLines: 5,
          style: const TextStyle(color: kcWhite),
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'What this CV is for, or anything to remember',
          ),
        ),
      ],
    );
  }

  @override
  EditDraftDialogModel viewModelBuilder(BuildContext context) =>
      EditDraftDialogModel(initial: _initial);
}
