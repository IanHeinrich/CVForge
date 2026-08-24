import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/brand_mark_loader/brand_mark_loader.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'cv_translation_run_dialog_model.dart';

/// The translation pass' run dialog: confirm what language the CV is about
/// to be rewritten into and what will be left alone, run, then report how
/// much came back. See [CvTranslationRunPhase] for the state machine.
///
/// Takes no dialog data, unlike `AiAssistantRunDialog` — everything it
/// needs is already on the draft the ViewModel can read.
class CvTranslationRunDialog extends StackedView<CvTranslationRunDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CvTranslationRunDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget builder(
    BuildContext context,
    CvTranslationRunDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: context.l10n.studioTranslateDialogTitle,
      maxWidth: 480,
      cancelLabel: viewModel.phase == CvTranslationRunPhase.result
          ? context.l10n.commonClose
          : context.l10n.commonCancel,
      confirmLabel: switch (viewModel.phase) {
        CvTranslationRunPhase.confirm => context.l10n.commonRun,
        CvTranslationRunPhase.running => context.l10n.commonRunning,
        CvTranslationRunPhase.result => context.l10n.commonDone,
        CvTranslationRunPhase.error => context.l10n.commonTryAgain,
      },
      // Blocked while running for the same reason as the tailoring
      // dialog: closing mid-flight abandons a callback into a disposed
      // ViewModel once the request eventually completes.
      onCancel: viewModel.phase == CvTranslationRunPhase.running
          ? null
          : () => completer(DialogResponse(confirmed: false)),
      onConfirm: switch (viewModel.phase) {
        CvTranslationRunPhase.confirm ||
        CvTranslationRunPhase.error => viewModel.run,
        CvTranslationRunPhase.running => null,
        CvTranslationRunPhase.result => () => completer(
          DialogResponse(confirmed: true),
        ),
      },
      children: [const VGap.medium(), ..._body(context, viewModel)],
    );
  }

  List<Widget> _body(
    BuildContext context,
    CvTranslationRunDialogModel viewModel,
  ) {
    switch (viewModel.phase) {
      case CvTranslationRunPhase.confirm:
        return [
          // The language first: it is the whole point of the action and
          // the thing most likely to be a surprise.
          Text(
            context.l10n.studioTranslateDialogLanguageNote(
              viewModel.targetLanguageDisplayName,
            ),
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          Text(
            context.l10n.studioAiDialogPrivacy(viewModel.providerDisplayName),
            style: context.appTypography.bodySmall,
          ),
          if (viewModel.replacesExisting) ...[
            const VGap.small(),
            Text(
              context.l10n.studioTranslateDialogReplaceNote,
              style: context.appTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ];

      case CvTranslationRunPhase.running:
        return [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.appSpacing.paddingPage,
            ),
            child: Center(
              child: BrandMarkLoader(
                semanticsLabel: context.l10n.studioTranslateRunningTitle,
              ),
            ),
          ),
          Center(
            child: Text(
              context.l10n.studioTranslateRunningBody,
              style: context.appTypography.bodySmall,
            ),
          ),
          if (viewModel.total > 0) ...[
            const VGap.tiny(),
            Center(
              child: Text(
                context.l10n.studioTranslateRunningProgress(
                  viewModel.completed,
                  viewModel.total,
                ),
                style: context.appTypography.caption,
              ),
            ),
          ],
        ];

      case CvTranslationRunPhase.result:
        return [
          Text(
            context.l10n.studioTranslateResultBody(
              viewModel.result!.translatedCount,
              viewModel.result!.requestedCount,
            ),
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          Text(
            context.l10n.studioTranslateWarning,
            style: context.appTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ];

      case CvTranslationRunPhase.error:
        return [
          Text(
            viewModel.errorMessage ?? context.l10n.studioTranslateFailedTitle,
            style: context.appTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ];
    }
  }

  @override
  CvTranslationRunDialogModel viewModelBuilder(BuildContext context) =>
      CvTranslationRunDialogModel();
}
