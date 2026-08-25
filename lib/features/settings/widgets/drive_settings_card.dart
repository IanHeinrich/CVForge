import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/ui/common/relative_time.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/button_spinner/button_spinner.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';
import 'package:cv_forge/ui/widgets/common/app_settings_card/app_settings_card.dart';

/// Google Drive sync setup — connect, see live status, sync now, resolve
/// a conflict, disconnect. Same block-card frame as [BackupSettingsCard]/
/// [AiAssistantSettingsCard], placed above [BackupSettingsCard] in
/// `SettingsView` since it's the more seamless of the two save paths once
/// connected. Returns an empty widget entirely (not just a disabled
/// state) when [SettingsViewModel.isDriveAvailable] is false — no
/// `GOOGLE_OAUTH_CLIENT_ID` was compiled into this build, so there is
/// nothing this card could do.
class DriveSettingsCard extends StatelessWidget {
  const DriveSettingsCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.isDriveAvailable) return const SizedBox.shrink();

    return AppSettingsCard(
      title: context.l10n.settingsDriveTitle,
      body: context.l10n.settingsDriveBody,
      children: [const VGap.medium(), ..._body(context)],
    );
  }

  List<Widget> _body(BuildContext context) {
    final status = viewModel.driveSyncStatus;
    return switch (status) {
      DriveSyncDisconnected() => _disconnected(context),
      DriveSyncConnecting() => [
        _StatusLine(icon: null, label: context.l10n.settingsDriveConnecting),
      ],
      DriveSyncIdle() => _connected(
        context,
        status.accountEmail,
        status.lastSyncedAt,
      ),
      DriveSyncPending() => _connected(
        context,
        status.accountEmail,
        null,
        pending: true,
      ),
      DriveSyncSyncing() => _connected(
        context,
        status.accountEmail,
        null,
        syncing: true,
      ),
      DriveSyncMerged() => _connected(
        context,
        status.accountEmail,
        status.lastSyncedAt,
        merged: true,
      ),
      DriveSyncNeedsReauth() => _needsReauth(context, status.accountEmail),
      DriveSyncErrorState() => _error(
        context,
        status.accountEmail,
        status.message,
      ),
    };
  }

  List<Widget> _disconnected(BuildContext context) => [
    if (viewModel.driveConnectErrorMessage != null) ...[
      _StatusLine(
        icon: RemixIcons.error_warning_line,
        color: Theme.of(context).colorScheme.error,
        label: viewModel.driveConnectErrorMessage!,
      ),
      const VGap.small(),
    ],
    FilledButton(
      onPressed: viewModel.isDriveConnecting ? null : viewModel.connectDrive,
      child: viewModel.isDriveConnecting
          ? const ButtonSpinner()
          : Text(context.l10n.settingsDriveConnect),
    ),
  ];

  List<Widget> _connected(
    BuildContext context,
    String email,
    DateTime? lastSyncedAt, {
    bool pending = false,
    bool syncing = false,
    bool merged = false,
  }) {
    final statusLabel = syncing
        ? context.l10n.settingsDriveSyncing
        : pending
        ? context.l10n.settingsDriveWaiting
        : merged
        ? context.l10n.settingsDriveMerged
        : lastSyncedAt == null
        ? context.l10n.settingsDriveNotYetSynced
        : context.l10n.settingsDriveLastSynced(
            formatRelativeTime(context.l10n, lastSyncedAt),
          );
    return [
      _StatusLine(
        icon: syncing || pending ? null : RemixIcons.checkbox_circle_line,
        color: syncing || pending ? null : context.appPalette.success,
        label: context.l10n.settingsDriveConnectedAs(email),
      ),
      const VGap.tiny(),
      Text(
        statusLabel,
        style: context.appTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const VGap.small(),
      Wrap(
        spacing: context.appSpacing.gapSmall,
        runSpacing: context.appSpacing.gapSmall,
        children: [
          OutlinedButton(
            onPressed: viewModel.isDriveSyncingNow || syncing
                ? null
                : viewModel.syncDriveNow,
            child: viewModel.isDriveSyncingNow
                ? const ButtonSpinner()
                : Text(context.l10n.settingsDriveSyncNow),
          ),
          TextButton(
            onPressed: viewModel.disconnectDrive,
            child: Text(context.l10n.commonDisconnect),
          ),
        ],
      ),
    ];
  }

  List<Widget> _needsReauth(BuildContext context, String email) => [
    _StatusLine(
      icon: RemixIcons.error_warning_line,
      color: context.appPalette.warning,
      label: context.l10n.settingsDriveReconnectPrompt(email),
    ),
    const VGap.small(),
    Wrap(
      spacing: context.appSpacing.gapSmall,
      runSpacing: context.appSpacing.gapSmall,
      children: [
        FilledButton(
          onPressed: viewModel.isDriveConnecting
              ? null
              : viewModel.connectDrive,
          child: viewModel.isDriveConnecting
              ? const ButtonSpinner()
              : Text(context.l10n.settingsDriveReconnect),
        ),
        TextButton(
          onPressed: viewModel.disconnectDrive,
          child: Text(context.l10n.commonDisconnect),
        ),
      ],
    ),
  ];

  List<Widget> _error(BuildContext context, String email, String message) => [
    _StatusLine(
      icon: RemixIcons.error_warning_line,
      color: Theme.of(context).colorScheme.error,
      label: context.l10n.settingsDriveConnectedAs(email),
    ),
    const VGap.tiny(),
    Text(
      message,
      style: context.appTypography.bodySmall.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    ),
    const VGap.small(),
    Wrap(
      spacing: context.appSpacing.gapSmall,
      runSpacing: context.appSpacing.gapSmall,
      children: [
        OutlinedButton(
          onPressed: viewModel.isDriveSyncingNow
              ? null
              : viewModel.syncDriveNow,
          child: viewModel.isDriveSyncingNow
              ? const ButtonSpinner()
              : Text(context.l10n.commonRetry),
        ),
        TextButton(
          onPressed: viewModel.disconnectDrive,
          child: Text(context.l10n.commonDisconnect),
        ),
      ],
    ),
  ];
}

/// A single icon+label line — [icon]/[color] null renders a small inline
/// spinner instead (the "Syncing…"/"Waiting to sync…" states), the same
/// icon-or-spinner-in-place-of-status shape [BackupSettingsCard]'s own
/// status line doesn't need since a local write never has a "pending"
/// state visible to the user.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.icon, this.color, required this.label});

  final IconData? icon;
  final Color? color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Icon(icon, size: context.appIconSize.small, color: color)
        else
          const ButtonSpinner(),
        const HGap.small(),
        Expanded(
          child: Text(
            label,
            style: context.appTypography.bodySmall.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
