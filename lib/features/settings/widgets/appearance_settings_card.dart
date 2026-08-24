import 'package:cv_forge/models/settings/app_theme_mode.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
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

  static const _options = <(AppThemeMode, String, IconData)>[
    (AppThemeMode.system, 'Match device', RemixIcons.computer_line),
    (AppThemeMode.light, 'Light', RemixIcons.sun_line),
    (AppThemeMode.dark, 'Dark', RemixIcons.moon_line),
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
          Text('Appearance', style: context.appTypography.titleMedium),
          const VGap.tiny(),
          Text(
            "Applies to CVForge's own interface. Your CV always renders on "
            'white paper, whichever theme you pick.',
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          SegmentedButton<AppThemeMode>(
            segments: [
              for (final (mode, label, icon) in _options)
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
