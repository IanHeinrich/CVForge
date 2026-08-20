import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
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
      return const AppEmptyState(
        icon: RemixIcons.loader_4_line,
        title: 'Analyzing…',
        message: 'Reading the PDF and checking for ATS parsing issues.',
      );
    }

    if (viewModel.hasAnalyzeError) {
      return AppEmptyState(
        icon: RemixIcons.error_warning_line,
        title: "Couldn't analyze that file",
        message: viewModel.analyzeErrorMessage,
        actions: [
          FilledButton(
            onPressed: viewModel.pickAndAnalyze,
            child: const Text('Try again'),
          ),
        ],
      );
    }

    return AppEmptyState(
      icon: RemixIcons.file_search_line,
      title: 'Check your CV for ATS issues',
      message:
          'Upload a PDF resume to check for formatting that applicant '
          'tracking software commonly misreads — missing text layers, '
          'multi-column layouts, garbled characters, and more. Nothing '
          'leaves your browser.',
      actions: [
        FilledButton(
          onPressed: viewModel.pickAndAnalyze,
          child: const Text('Upload PDF'),
        ),
      ],
    );
  }
}
