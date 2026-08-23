import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/settings/widgets/backup_settings_card.dart';
import 'package:cv_forge/features/settings/widgets/copilot_settings_card.dart';
import 'package:cv_forge/features/settings/widgets/drive_settings_card.dart';
import 'package:cv_forge/features/settings/widgets/region_settings_card.dart';
import 'settings_viewmodel.dart';

/// The only top-level surface that previously had neither a page header
/// nor a content max-width — at 1600px its cards' description paragraphs
/// ran to ~1,100px lines. 720px, left-aligned rather than centred: a
/// settings column drifting to the middle of a very wide screen is worse
/// than one anchored where the nav rail already draws the eye.
const _contentMaxWidth = 720.0;

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return AppChrome.gated(
      section: AppSection.settings,
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.initialise,
      content: () => SingleChildScrollView(
        padding: EdgeInsets.all(context.appSpacing.paddingPage),
        // Align relaxes SingleChildScrollView's tight cross-axis (width)
        // constraint to loose before ConstrainedBox caps it — without it,
        // ConstrainedBox's own minWidth still inherits the full tight
        // viewport width and the cap has no effect.
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RegionSettingsCard(viewModel: viewModel),
                const VGap.medium(),
                // DriveSettingsCard renders nothing when Drive sync isn't
                // configured for this build — skipped here too, rather
                // than left in with its own VGap either side, so an
                // unconfigured build shows no stray gap between Region
                // and Backup.
                if (viewModel.isDriveAvailable) ...[
                  DriveSettingsCard(viewModel: viewModel),
                  const VGap.medium(),
                ],
                BackupSettingsCard(viewModel: viewModel),
                const VGap.medium(),
                CopilotSettingsCard(viewModel: viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();
}
