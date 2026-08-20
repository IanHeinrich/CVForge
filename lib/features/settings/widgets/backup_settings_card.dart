import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// Settings' whole content in this PR: one card for backup export/import.
/// Same block-card frame `StudioFieldOverrideCard` uses (dark container,
/// [context.appRadius.medium]) so Settings reads as part of the same visual
/// system rather than inventing its own.
class BackupSettingsCard extends StatelessWidget {
  const BackupSettingsCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.appSpacing.paddingPage),
      child: Container(
        padding: EdgeInsets.all(context.appSpacing.paddingPanel),
        decoration: BoxDecoration(
          color: kcDarkGreyColor,
          borderRadius: BorderRadius.circular(context.appRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup', style: context.appTypography.titleMedium),
            const VGap.tiny(),
            Text(
              'Export your whole Vault and every CV as one JSON file, or '
              'restore from a previous export. Restoring replaces '
              'everything currently on this device — your current data '
              'downloads as a backup first.',
              style: context.appTypography.bodySmall,
            ),
            const VGap.medium(),
            Row(
              children: [
                FilledButton(
                  onPressed: viewModel.isExporting
                      ? null
                      : viewModel.exportBackup,
                  child: viewModel.isExporting
                      ? const _ButtonSpinner()
                      : const Text('Export backup'),
                ),
                const HGap.small(),
                OutlinedButton(
                  onPressed: viewModel.isImporting
                      ? null
                      : viewModel.importBackup,
                  child: viewModel.isImporting
                      ? const _ButtonSpinner()
                      : const Text('Import backup'),
                ),
              ],
            ),
            if (viewModel.importErrorMessage != null) ...[
              const VGap.small(),
              Text(
                viewModel.importErrorMessage!,
                style: context.appTypography.bodySmall.copyWith(
                  color: kcErrorColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: kcWhite),
    );
  }
}
