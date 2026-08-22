import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'copilot_run_dialog_data.dart';
import 'copilot_run_dialog_model.dart';

/// The Copilot tailoring pass' run dialog: confirm what's about to be sent
/// and to whom, run, then show the rationale and `keywordGaps` once
/// applied. See [CopilotRunPhase] for the state machine this renders.
class CopilotRunDialog extends StackedView<CopilotRunDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CopilotRunDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  String get _jobDescription =>
      (request.data as CopilotRunDialogData).jobDescription;

  @override
  Widget builder(
    BuildContext context,
    CopilotRunDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: 'Tailor with AI',
      maxWidth: 480,
      cancelLabel: viewModel.phase == CopilotRunPhase.result
          ? 'Close'
          : 'Cancel',
      confirmLabel: switch (viewModel.phase) {
        CopilotRunPhase.confirm => 'Run',
        CopilotRunPhase.running => 'Running…',
        CopilotRunPhase.result => 'Done',
        CopilotRunPhase.error => 'Try again',
      },
      // Blocked while running rather than left dismissible — closing
      // mid-flight would abandon a callback into a disposed ViewModel
      // once the request eventually completes.
      onCancel: viewModel.phase == CopilotRunPhase.running
          ? null
          : () => completer(DialogResponse(confirmed: false)),
      onConfirm: switch (viewModel.phase) {
        CopilotRunPhase.confirm || CopilotRunPhase.error => viewModel.run,
        CopilotRunPhase.running => null,
        CopilotRunPhase.result => () => completer(
          DialogResponse(confirmed: true),
        ),
      },
      children: [const VGap.medium(), ..._body(context, viewModel)],
    );
  }

  List<Widget> _body(BuildContext context, CopilotRunDialogModel viewModel) {
    switch (viewModel.phase) {
      case CopilotRunPhase.confirm:
        return [
          Text(
            'This sends the job description below and your CV content — '
            'not your name, email, phone, or links — to '
            '${viewModel.providerDisplayName}, using your own API key. '
            'There is no CVForge server in between. This can take up to '
            'a few minutes — the model reasons through your whole Vault '
            'before responding.',
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          Container(
            padding: EdgeInsets.all(context.appSpacing.paddingCompact),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
            ),
            child: SingleChildScrollView(
              child: Text(
                _jobDescription,
                style: const TextStyle(color: kcLightGrey),
              ),
            ),
          ),
        ];

      case CopilotRunPhase.running:
        return [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.appSpacing.paddingPage,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          Center(
            child: Text(
              'This can take up to a few minutes. Please keep this dialog '
              'open.',
              style: context.appTypography.bodySmall,
            ),
          ),
        ];

      case CopilotRunPhase.result:
        final result = viewModel.result!;
        return [
          Text('Rationale', style: context.appTypography.titleSmall),
          const VGap.tiny(),
          Text(result.rationale, style: context.appTypography.bodySmall),
          if (result.keywordGaps.isNotEmpty) ...[
            const VGap.small(),
            Text(
              "Not covered by your Vault",
              style: context.appTypography.titleSmall,
            ),
            const VGap.tiny(),
            for (final gap in result.keywordGaps)
              Text('• $gap', style: context.appTypography.bodySmall),
          ],
        ];

      case CopilotRunPhase.error:
        return [
          Text(
            viewModel.errorMessage ?? 'Something went wrong.',
            style: context.appTypography.bodySmall.copyWith(
              color: kcErrorColor,
            ),
          ),
        ];
    }
  }

  @override
  CopilotRunDialogModel viewModelBuilder(BuildContext context) =>
      CopilotRunDialogModel(jobDescription: _jobDescription);
}
