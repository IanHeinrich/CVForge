import 'package:cv_forge/ui/common/relative_time.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/button_spinner/button_spinner.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// A card for backup export/import — one of Settings' cards, stacked by
/// `SettingsView` alongside [AiAssistantSettingsCard]. Dark container,
/// [context.appRadius.medium] — the same block-card frame
/// `AtsFindingCard` uses, so a second card-shaped feature doesn't invent
/// its own. `SettingsView` owns the outer scroll/page padding — this
/// card is just its own bordered block.
class BackupSettingsCard extends StatelessWidget {
  const BackupSettingsCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.appSpacing.paddingPanel),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsBackupTitle,
            style: context.appTypography.titleMedium,
          ),
          const VGap.tiny(),
          Text(
            context.l10n.settingsBackupBody,
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          _BackupStatusLine(
            lastBackupAt: viewModel.lastBackupAt,
            hasChangesSinceBackup: viewModel.hasChangesSinceBackup,
          ),
          const VGap.small(),
          // Wrap, not Row — on a narrow mobile viewport there isn't
          // always room for both buttons side by side; Row would clip
          // the second one instead of dropping it to its own line.
          Wrap(
            spacing: context.appSpacing.gapSmall,
            runSpacing: context.appSpacing.gapSmall,
            children: [
              FilledButton(
                onPressed: viewModel.isExporting
                    ? null
                    : viewModel.exportBackup,
                child: viewModel.isExporting
                    ? const ButtonSpinner()
                    : Text(context.l10n.settingsBackupExport),
              ),
              OutlinedButton(
                onPressed: viewModel.isImporting
                    ? null
                    : viewModel.importBackup,
                child: viewModel.isImporting
                    ? const ButtonSpinner()
                    : Text(context.l10n.settingsBackupImport),
              ),
            ],
          ),
          if (viewModel.importErrorMessage != null) ...[
            const VGap.small(),
            Text(
              viewModel.importErrorMessage!,
              style: context.appTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const VGap.medium(),
          const Divider(height: 1),
          const VGap.medium(),
          // Clear Vault lives here, not as the Vault screen's first
          // interactive element above the user's own name — this is where
          // "export first, then a destructive action replaces everything"
          // is already the established framing.
          Text(
            context.l10n.settingsDangerZone,
            style: context.appTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const VGap.tiny(),
          OutlinedButton.icon(
            onPressed: viewModel.clearVault,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            icon: Icon(
              RemixIcons.delete_bin_line,
              size: context.appIconSize.small,
            ),
            label: Text(context.l10n.settingsClearVault),
          ),
        ],
      ),
    );
  }
}

/// Everything is derived from a plain `DateTime?` and a `bool`, not a
/// widget of its own state, so it can never drift from what
/// [SettingsViewModel.hasChangesSinceBackup] actually computed.
class _BackupStatusLine extends StatelessWidget {
  const _BackupStatusLine({
    required this.lastBackupAt,
    required this.hasChangesSinceBackup,
  });

  final DateTime? lastBackupAt;
  final bool hasChangesSinceBackup;

  @override
  Widget build(BuildContext context) {
    final last = lastBackupAt;
    final IconData icon;
    final Color color;
    final String message;
    if (last == null) {
      icon = RemixIcons.time_line;
      color = Theme.of(context).colorScheme.onSurfaceVariant;
      message = context.l10n.settingsBackupNever;
    } else if (hasChangesSinceBackup) {
      icon = RemixIcons.error_warning_line;
      color = context.appPalette.warning;
      message = context.l10n.settingsBackupLastWithChanges(
        formatRelativeTime(context.l10n, last),
      );
    } else {
      icon = RemixIcons.checkbox_circle_line;
      color = context.appPalette.success;
      message = context.l10n.settingsBackupLast(
        formatRelativeTime(context.l10n, last),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.appIconSize.small, color: color),
        const HGap.small(),
        Expanded(
          child: Text(
            message,
            style: context.appTypography.bodySmall.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
