import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/relative_time.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'drive_sync_indicator_model.dart';

/// A small, out-of-the-way Google Drive sync status glyph — dropped into
/// `AppChrome`'s nav rail next to the Settings button, the one other
/// persistent chrome element every top-level View already shares. Renders
/// nothing at all when Drive sync isn't configured for this build or has
/// never been connected — this is a status glyph for a feature in use,
/// not an invitation to turn it on. Tapping it opens Settings, where the
/// full `DriveSettingsCard` explains and can act on whatever the current
/// state is.
class DriveSyncIndicator extends StackedView<DriveSyncIndicatorModel> {
  const DriveSyncIndicator({super.key});

  @override
  Widget builder(
    BuildContext context,
    DriveSyncIndicatorModel viewModel,
    Widget? child,
  ) {
    if (!viewModel.isAvailable) return const SizedBox.shrink();
    final glyph = _glyphFor(context, viewModel.status);
    if (glyph == null) return const SizedBox.shrink();

    return Tooltip(
      message: glyph.tooltip,
      child: IconButton(
        onPressed: () => locator<RouterService>().replaceWithSettingsView(),
        icon: glyph.icon,
      ),
    );
  }

  _Glyph? _glyphFor(BuildContext context, DriveSyncStatus status) {
    return switch (status) {
      DriveSyncDisconnected() || DriveSyncConnecting() => null,
      DriveSyncIdle(:final lastSyncedAt) => _Glyph(
        tooltip: lastSyncedAt == null
            ? context.l10n.driveSyncSynced
            : context.l10n.driveSyncSyncedAt(
                formatRelativeTime(context.l10n, lastSyncedAt),
              ),
        icon: _StatusIcon(
          icon: RemixIcons.cloud_fill,
          color: context.appPalette.success,
        ),
      ),
      DriveSyncPending() => _Glyph(
        tooltip: context.l10n.driveSyncPending,
        icon: _StatusIcon(
          icon: RemixIcons.cloud_line,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      DriveSyncSyncing() => _Glyph(
        tooltip: context.l10n.driveSyncSyncing,
        icon: _SyncingIcon(),
      ),
      DriveSyncMerged() => _Glyph(
        tooltip: context.l10n.driveSyncMerged,
        icon: _StatusIcon(
          icon: RemixIcons.git_merge_line,
          color: context.appPalette.success,
        ),
      ),
      DriveSyncNeedsReauth() => _Glyph(
        tooltip: context.l10n.driveSyncNeedsReauth,
        icon: _StatusIcon(
          icon: RemixIcons.error_warning_line,
          color: context.appPalette.warning,
        ),
      ),
      DriveSyncErrorState(:final message) => _Glyph(
        tooltip: message,
        icon: const _StatusIcon(
          icon: RemixIcons.cloud_off_line,
          color: kcErrorColor,
        ),
      ),
    };
  }

  @override
  DriveSyncIndicatorModel viewModelBuilder(BuildContext context) =>
      DriveSyncIndicatorModel();
}

/// Tooltip text paired with the icon widget to render — kept together so
/// [DriveSyncIndicator._glyphFor]'s `switch` can never return one without
/// the other.
class _Glyph {
  const _Glyph({required this.tooltip, required this.icon});

  final String tooltip;
  final Widget icon;
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Icon(icon, size: context.appIconSize.small, color: color);
}

/// A small spinner sized to match [_StatusIcon] rather than
/// `ButtonSpinner` (hardcoded white — built for sitting on a filled
/// button's colored background, not this chrome's dark surface).
class _SyncingIcon extends StatelessWidget {
  const _SyncingIcon();

  @override
  Widget build(BuildContext context) {
    final size = context.appIconSize.small;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
