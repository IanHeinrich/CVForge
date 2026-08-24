import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/brand_mark_loader/brand_mark_loader.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'ai_assistant_run_dialog_data.dart';
import 'ai_assistant_run_dialog_model.dart';

/// The AI Assistant tailoring pass' run dialog: confirm what's about to be sent
/// and to whom, run, then show the rationale and `keywordGaps` once
/// applied. See [AiAssistantRunPhase] for the state machine this renders.
class AiAssistantRunDialog extends StackedView<AiAssistantRunDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const AiAssistantRunDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  String get _jobDescription =>
      (request.data as AiAssistantRunDialogData).jobDescription;

  @override
  Widget builder(
    BuildContext context,
    AiAssistantRunDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: context.l10n.studioAiDialogTitle,
      maxWidth: 480,
      cancelLabel: viewModel.phase == AiAssistantRunPhase.result
          ? context.l10n.commonClose
          : context.l10n.commonCancel,
      confirmLabel: switch (viewModel.phase) {
        AiAssistantRunPhase.confirm => context.l10n.commonRun,
        AiAssistantRunPhase.running => context.l10n.commonRunning,
        AiAssistantRunPhase.result => context.l10n.commonDone,
        AiAssistantRunPhase.error => context.l10n.commonTryAgain,
      },
      // Blocked while running rather than left dismissible — closing
      // mid-flight would abandon a callback into a disposed ViewModel
      // once the request eventually completes.
      onCancel: viewModel.phase == AiAssistantRunPhase.running
          ? null
          : () => completer(DialogResponse(confirmed: false)),
      onConfirm: switch (viewModel.phase) {
        AiAssistantRunPhase.confirm ||
        AiAssistantRunPhase.error => viewModel.run,
        AiAssistantRunPhase.running => null,
        AiAssistantRunPhase.result => () => completer(
          DialogResponse(confirmed: true),
        ),
      },
      children: [const VGap.medium(), ..._body(context, viewModel)],
    );
  }

  List<Widget> _body(
    BuildContext context,
    AiAssistantRunDialogModel viewModel,
  ) {
    switch (viewModel.phase) {
      case AiAssistantRunPhase.confirm:
        return [
          Text(
            context.l10n.studioAiDialogPrivacy(viewModel.providerDisplayName),
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          Text(
            context.l10n.studioAiDialogRegionNote(viewModel.regionDisplayName),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ];

      case AiAssistantRunPhase.running:
        return [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.appSpacing.paddingPage,
            ),
            // The forging mark rather than a spinner: this wait runs to tens
            // of seconds, long enough that a spinner starts reading as a
            // stall. See BrandMarkLoader for where that line is drawn.
            child: Center(
              child: BrandMarkLoader(
                semanticsLabel: context.l10n.studioAiRunningTitle,
              ),
            ),
          ),
          Center(
            child: Text(
              context.l10n.studioAiRunningBody,
              style: context.appTypography.bodySmall,
            ),
          ),
        ];

      case AiAssistantRunPhase.result:
        final result = viewModel.result!;
        return [
          Text(
            context.l10n.studioAiRationale,
            style: context.appTypography.titleSmall,
          ),
          const VGap.tiny(),
          Text(result.rationale, style: context.appTypography.bodySmall),
          if (result.keywordGaps.isNotEmpty) ...[
            const VGap.small(),
            Text(
              context.l10n.studioAiKeywordGaps,
              style: context.appTypography.titleSmall,
            ),
            const VGap.tiny(),
            for (final gap in result.keywordGaps)
              Text(
                context.l10n.studioAiGapItem(gap),
                style: context.appTypography.bodySmall,
              ),
          ],
        ];

      case AiAssistantRunPhase.error:
        return [
          Text(
            viewModel.errorMessage ?? context.l10n.studioAiFailedTitle,
            style: context.appTypography.bodySmall.copyWith(
              color: kcErrorColor,
            ),
          ),
        ];
    }
  }

  @override
  AiAssistantRunDialogModel viewModelBuilder(BuildContext context) =>
      AiAssistantRunDialogModel(jobDescription: _jobDescription);
}
