import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'confirm_delete_dialog_model.dart';

/// A generic destructive-action confirmation, used by every "delete" flow
/// in the Vault. [DialogRequest.title]/[description] carry the specifics;
/// [DialogRequest.mainButtonTitle]/[secondaryButtonTitle] default to
/// "Delete"/"Cancel" if not supplied.
class ConfirmDeleteDialog extends StackedView<ConfirmDeleteDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ConfirmDeleteDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget builder(
    BuildContext context,
    ConfirmDeleteDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: request.title ?? 'Delete this?',
      destructive: true,
      cancelLabel: request.secondaryButtonTitle ?? 'Cancel',
      confirmLabel: request.mainButtonTitle ?? 'Delete',
      onCancel: () => completer(DialogResponse(confirmed: false)),
      onConfirm: () => completer(DialogResponse(confirmed: true)),
      children: [
        if (request.description != null) ...[
          const VGap.small(),
          Text(request.description!, style: context.appTypography.bodySmall),
        ],
      ],
    );
  }

  @override
  ConfirmDeleteDialogModel viewModelBuilder(BuildContext context) =>
      ConfirmDeleteDialogModel();
}
