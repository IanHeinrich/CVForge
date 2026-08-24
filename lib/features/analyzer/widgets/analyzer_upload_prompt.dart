import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';

/// The idle/analyzing/error states before a result exists — three thin
/// wrappers around [AppEmptyState], the house pattern `StudioEmptyPreview`/
/// `VaultEmptyState` already establish for copy-specific placeholders.
class AnalyzerUploadPrompt extends StatelessWidget {
  const AnalyzerUploadPrompt({super.key, required this.viewModel});

  final AnalyzerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isAnalyzing) {
      return AppEmptyState(
        icon: RemixIcons.loader_4_line,
        title: context.l10n.analyzerAnalyzingTitle,
        message: context.l10n.analyzerAnalyzingBody,
      );
    }

    if (viewModel.hasAnalyzeError) {
      return AppEmptyState(
        icon: RemixIcons.error_warning_line,
        title: context.l10n.analyzerErrorTitle,
        message: viewModel.analyzeErrorMessage,
        actions: [
          FilledButton(
            onPressed: viewModel.pickAndAnalyze,
            child: Text(context.l10n.commonTryAgain),
          ),
        ],
      );
    }

    return AppEmptyState(
      icon: RemixIcons.file_search_line,
      title: context.l10n.analyzerUploadTitle(viewModel.documentNoun),
      messageMaxWidth: 480,
      message: context.l10n.analyzerUploadBody(viewModel.documentNoun),
      actions: [
        FilledButton(
          onPressed: viewModel.pickAndAnalyze,
          child: Text(context.l10n.analyzerUploadCta),
        ),
      ],
    );
  }
}
