import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/button_spinner/button_spinner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// A card for backup export/import — one of Settings' cards, stacked by
/// `SettingsView` alongside [CopilotSettingsCard]. Dark container,
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
          _BackupStatusLine(
            lastBackupAt: viewModel.lastBackupAt,
            hasChangesSinceBackup: viewModel.hasChangesSinceBackup,
          ),
          const VGap.small(),
          Row(
            children: [
              FilledButton(
                onPressed: viewModel.isExporting
                    ? null
                    : viewModel.exportBackup,
                child: viewModel.isExporting
                    ? const ButtonSpinner()
                    : const Text('Export backup'),
              ),
              const HGap.small(),
              OutlinedButton(
                onPressed: viewModel.isImporting
                    ? null
                    : viewModel.importBackup,
                child: viewModel.isImporting
                    ? const ButtonSpinner()
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
          const VGap.medium(),
          const Divider(height: 1),
          const VGap.medium(),
          // Clear Vault lives here now, not as the Vault screen's first
          // interactive element above the user's own name (7.8) — this is
          // where "export first, then a destructive action replaces
          // everything" is already the established framing.
          Text(
            'Danger zone',
            style: context.appTypography.bodySmall.copyWith(color: kcLightGrey),
          ),
          const VGap.tiny(),
          OutlinedButton.icon(
            onPressed: viewModel.clearVault,
            style: OutlinedButton.styleFrom(
              foregroundColor: kcErrorColor,
              side: const BorderSide(color: kcErrorColor),
            ),
            icon: Icon(
              RemixIcons.delete_bin_line,
              size: context.appIconSize.small,
            ),
            label: const Text('Clear Vault'),
          ),
        ],
      ),
    );
  }
}

/// The state 7.7 gives Backup — "a pair of verbs with no nouns" before
/// this existed. Everything is derived from a plain `DateTime?` and a
/// `bool`, not a widget of its own state, so it can never drift from what
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
      color = kcLightGrey;
      message = 'Never backed up';
    } else if (hasChangesSinceBackup) {
      icon = RemixIcons.error_warning_line;
      color = kcWarningColor;
      message =
          'Last backed up ${_formatRelative(last)} — you have '
          'changes since then';
    } else {
      icon = RemixIcons.checkbox_circle_line;
      color = kcSuccessColor;
      message = 'Last backed up ${_formatRelative(last)}';
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

  /// "today" / "yesterday" / "N days ago", falling back to an absolute
  /// date past a month — "47 days ago" stops being a useful unit for a
  /// backup you may not think about for months at a time.
  String _formatRelative(DateTime time) {
    final days = DateTime.now().difference(time).inDays;
    if (days <= 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 30) return '$days days ago';
    return 'on ${time.day.toString().padLeft(2, '0')}/'
        '${time.month.toString().padLeft(2, '0')}/${time.year}';
  }
}
