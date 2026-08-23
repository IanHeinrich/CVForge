import 'package:cv_forge/ui/common/relative_time.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'drive_conflict_dialog_data.dart';
import 'drive_conflict_dialog_model.dart';

/// Shown when `DriveSyncService` finds this device has unsynced local
/// edits *and* Google Drive's own copy has moved on since this device
/// last synced — the one case sync can't resolve on its own. By the time
/// this dialog appears, a local safety backup has already been
/// downloaded (`DriveSyncService._raiseConflict`), so neither choice
/// below risks losing data permanently: the side not kept is always still
/// sitting in that download.
///
/// `request.data` carries [DriveConflictDialogData]. The response is a
/// `DialogResponse` of `bool`: `confirmed: false` means "decide later"
/// (the conflict stays unresolved — Drive sync simply pauses until the
/// user comes back); `confirmed: true` with `data: true` means "keep
/// this device"; `data: false` means "use Google Drive instead".
class DriveConflictDialog extends StackedView<DriveConflictDialogModel> {
  const DriveConflictDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  final DialogRequest request;
  final Function(DialogResponse) completer;

  DriveConflictDialogData get _data => request.data as DriveConflictDialogData;

  @override
  Widget builder(
    BuildContext context,
    DriveConflictDialogModel viewModel,
    Widget? child,
  ) {
    final data = _data;
    final localWhen = data.localUpdatedAt == null
        ? ''
        : ' — ${formatRelativeTime(data.localUpdatedAt!)}';
    final remoteWhen = data.remoteModifiedAt == null
        ? ''
        : ' — ${formatRelativeTime(data.remoteModifiedAt!)}';

    return AppDialogScaffold(
      title: 'This device and Google Drive have both changed',
      maxWidth: 480,
      cancelLabel: 'Decide later',
      confirmLabel: 'Keep this device',
      onCancel: () => completer(DialogResponse<bool>(confirmed: false)),
      onConfirm: () =>
          completer(DialogResponse<bool>(confirmed: true, data: true)),
      children: [
        const VGap.small(),
        Text(
          "You've made changes on this device since it last synced, and "
          "${data.accountEmail} has a newer version on Google Drive too — "
          "picking one replaces the other. Your current data on this "
          'device has already been downloaded as a backup, so nothing is '
          'lost either way.',
          style: context.appTypography.bodySmall,
        ),
        const VGap.medium(),
        _SideSummary(label: 'This device$localWhen'),
        const VGap.small(),
        _SideSummary(label: 'Google Drive$remoteWhen'),
        const VGap.medium(),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () =>
                completer(DialogResponse<bool>(confirmed: true, data: false)),
            child: const Text('Use Google Drive instead'),
          ),
        ),
      ],
    );
  }

  @override
  DriveConflictDialogModel viewModelBuilder(BuildContext context) =>
      DriveConflictDialogModel();
}

class _SideSummary extends StatelessWidget {
  const _SideSummary({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingCompact,
        vertical: context.appSpacing.paddingTight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(context.appRadius.small),
      ),
      child: Text(label, style: context.appTypography.bodySmall),
    );
  }
}
