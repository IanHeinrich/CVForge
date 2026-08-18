import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: kcDarkGreyColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title ?? 'Delete this?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kcWhite,
              ),
            ),
            if (request.description != null) ...[
              verticalSpaceSmall,
              Text(
                request.description!,
                style: const TextStyle(fontSize: 14, color: kcLightGrey),
              ),
            ],
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => completer(DialogResponse(confirmed: false)),
                  child: Text(request.secondaryButtonTitle ?? 'Cancel'),
                ),
                horizontalSpaceSmall,
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  onPressed: () => completer(DialogResponse(confirmed: true)),
                  child: Text(request.mainButtonTitle ?? 'Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  ConfirmDeleteDialogModel viewModelBuilder(BuildContext context) =>
      ConfirmDeleteDialogModel();
}
