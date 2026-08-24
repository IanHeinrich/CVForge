import 'package:cv_forge/models/settings/app_theme_mode.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// The canonical appearance control — one of Settings' cards, stacked by
/// `SettingsView` alongside [RegionSettingsCard]/[BackupSettingsCard].
///
/// Shows all three modes at once, which is what `ThemeModeToggle` in the
/// nav rail deliberately cannot: that one cycles, so it can only ever
/// display the current state. Both write through
/// `SettingsService.setThemeMode`, so the two stay in step. This card is
/// also the *only* appearance control on mobile, where there is no rail.
class AppearanceSettingsCard extends StatelessWidget {
  const AppearanceSettingsCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  /// Built from context rather than held as a `const`, since each label is
  /// now a localized lookup.
  static List<(AppThemeMode, String, IconData)> _optionsFor(
    BuildContext context,
  ) => [
    (
      AppThemeMode.system,
      context.l10n.themeModeSystem,
      RemixIcons.computer_line,
    ),
    (AppThemeMode.light, context.l10n.themeModeLight, RemixIcons.sun_line),
    (AppThemeMode.dark, context.l10n.themeModeDark, RemixIcons.moon_line),
  ];

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
            context.l10n.settingsAppearanceTitle,
            style: context.appTypography.titleMedium,
          ),
          const VGap.tiny(),
          Text(
            context.l10n.settingsAppearanceBody,
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          SegmentedButton<AppThemeMode>(
            segments: [
              for (final (mode, label, icon) in _optionsFor(context))
                ButtonSegment<AppThemeMode>(
                  value: mode,
                  label: Text(label),
                  icon: Icon(icon),
                ),
            ],
            selected: {viewModel.themeMode},
            // Single-select, so the set always has exactly one member.
            onSelectionChanged: (selection) =>
                viewModel.setThemeMode(selection.first),
          ),
        ],
      ),
    );
  }
}
