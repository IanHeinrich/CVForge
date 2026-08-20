import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';

/// The slim bar above Studio's editor on every breakpoint: a way back to
/// [DraftsListView], which draft is open, and a way to rename it/edit its
/// notes without leaving Studio.
class StudioDraftHeader extends StatelessWidget {
  const StudioDraftHeader({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingPage,
        vertical: context.appSpacing.paddingTight,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kcMediumGrey)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to your CVs',
            icon: const Icon(RemixIcons.arrow_left_line, color: kcLightGrey),
            onPressed: viewModel.goToDrafts,
          ),
          Expanded(
            child: Text(
              viewModel.draftName,
              overflow: TextOverflow.ellipsis,
              style: context.appTypography.titleSmall,
            ),
          ),
          IconButton(
            tooltip: 'Edit CV details',
            icon: const Icon(RemixIcons.edit_line, color: kcLightGrey),
            onPressed: viewModel.editDraftDetails,
          ),
        ],
      ),
    );
  }
}
