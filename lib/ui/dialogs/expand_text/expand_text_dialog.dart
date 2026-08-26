import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'expand_text_dialog_data.dart';
import 'expand_text_dialog_model.dart';

/// The same field, in a box with room to think in.
///
/// Studio's editor pane is roughly half a window wide with the preview
/// beside it, and a nested field row keeps only about 300px of that once
/// the nav column, indents and icon cluster are taken out. That is a slot
/// to write a sentence through, not a paragraph, and the summary and the
/// longer bullets are paragraphs.
///
/// Commits on confirm rather than on every keystroke, unlike the inline
/// fields: opening this is a deliberate detour, so cancelling out of it
/// should leave the field exactly as it was.
class ExpandTextDialog extends StackedView<ExpandTextDialogModel> {
  const ExpandTextDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  final DialogRequest request;
  final Function(DialogResponse) completer;

  ExpandTextDialogData get _initial =>
      (request.data as ExpandTextDialogData?) ??
      (label: '', text: '', markup: false);

  @override
  Widget builder(
    BuildContext context,
    ExpandTextDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: _initial.label.isEmpty
          ? context.l10n.commonExpandEditor
          : _initial.label,
      // Wider than the default confirmation width — the whole point is
      // the room, so a 420px dialog would defeat it.
      maxWidth: 720,
      confirmLabel: context.l10n.commonSave,
      onCancel: () => completer(DialogResponse<String>(confirmed: false)),
      onConfirm: () => completer(
        DialogResponse<String>(confirmed: true, data: viewModel.text),
      ),
      children: [
        AppTextField(
          initialValue: _initial.text,
          onChanged: viewModel.setText,
          markup: _initial.markup,
          minLines: 10,
          maxLines: 20,
          autofocus: true,
        ),
      ],
    );
  }

  @override
  ExpandTextDialogModel viewModelBuilder(BuildContext context) =>
      ExpandTextDialogModel(_initial.text);
}
