import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/relative_time.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/button_spinner/button_spinner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// Google Drive sync setup — connect, see live status, sync now, resolve
/// a conflict, disconnect. Same block-card frame as [BackupSettingsCard]/
/// [CopilotSettingsCard], placed above [BackupSettingsCard] in
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

    return Container(
      padding: EdgeInsets.all(context.appSpacing.paddingPanel),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Google Drive', style: context.appTypography.titleMedium),
          const VGap.tiny(),
          Text(
            'Sign in with Google to keep your Vault and every CV synced to '
            'your own Google Drive — sign in again on another browser and '
            "they're all there. CVForge never sees or stores your Google "
            'credentials; only a single hidden file this app creates for '
            'itself.',
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          ..._body(context),
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final status = viewModel.driveSyncStatus;
    return switch (status) {
      DriveSyncDisconnected() => _disconnected(context),
      DriveSyncConnecting() => const [
        _StatusLine(icon: null, label: 'Connecting…'),
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
      DriveSyncConflict() => _conflict(context, status.accountEmail),
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
        color: kcErrorColor,
        label: viewModel.driveConnectErrorMessage!,
      ),
      const VGap.small(),
    ],
    FilledButton(
      onPressed: viewModel.isDriveConnecting ? null : viewModel.connectDrive,
      child: viewModel.isDriveConnecting
          ? const ButtonSpinner()
          : const Text('Connect Google Drive'),
    ),
  ];

  List<Widget> _connected(
    BuildContext context,
    String email,
    DateTime? lastSyncedAt, {
    bool pending = false,
    bool syncing = false,
  }) {
    final statusLabel = syncing
        ? 'Syncing…'
        : pending
        ? 'Waiting to sync…'
        : lastSyncedAt == null
        ? 'Not yet synced'
        : 'Last synced ${formatRelativeTime(lastSyncedAt)}';
    return [
      _StatusLine(
        icon: syncing || pending ? null : RemixIcons.checkbox_circle_line,
        color: syncing || pending ? null : kcSuccessColor,
        label: 'Connected as $email',
      ),
      const VGap.tiny(),
      Text(
        statusLabel,
        style: context.appTypography.caption.copyWith(color: kcLightGrey),
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
                : const Text('Sync now'),
          ),
          TextButton(
            onPressed: viewModel.disconnectDrive,
            child: const Text('Disconnect'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _conflict(BuildContext context, String email) => [
    _StatusLine(
      icon: RemixIcons.error_warning_line,
      color: kcWarningColor,
      label: 'This device and Google Drive have both changed',
    ),
    const VGap.small(),
    FilledButton(
      onPressed: viewModel.resolveDriveConflict,
      child: const Text('Resolve'),
    ),
    const VGap.small(),
    TextButton(
      onPressed: viewModel.disconnectDrive,
      child: const Text('Disconnect'),
    ),
  ];

  List<Widget> _needsReauth(BuildContext context, String email) => [
    _StatusLine(
      icon: RemixIcons.error_warning_line,
      color: kcWarningColor,
      label: 'Connected as $email — reconnect to keep syncing',
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
              : const Text('Reconnect'),
        ),
        TextButton(
          onPressed: viewModel.disconnectDrive,
          child: const Text('Disconnect'),
        ),
      ],
    ),
  ];

  List<Widget> _error(BuildContext context, String email, String message) => [
    _StatusLine(
      icon: RemixIcons.error_warning_line,
      color: kcErrorColor,
      label: 'Connected as $email',
    ),
    const VGap.tiny(),
    Text(
      message,
      style: context.appTypography.bodySmall.copyWith(color: kcErrorColor),
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
              : const Text('Retry'),
        ),
        TextButton(
          onPressed: viewModel.disconnectDrive,
          child: const Text('Disconnect'),
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
