import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// A card for the default region every *new* CV is created with — one of
/// Settings' cards, stacked by `SettingsView` alongside
/// [BackupSettingsCard]/[CopilotSettingsCard]. Same dark-container,
/// `context.appRadius.medium` frame those use. Deliberately a plain chip
/// row rather than `RegionGalleryDialog`'s bigger per-draft picker cards —
/// this is a background default a user sets once, not a per-document
/// decision that needs page-size/date-style detail spelled out each time.
class RegionSettingsCard extends StatelessWidget {
  const RegionSettingsCard({super.key, required this.viewModel});

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
          Text('Default region', style: context.appTypography.titleMedium),
          const VGap.tiny(),
          Text(
            'Sets the region every new CV starts with — page size, date '
            'format, and what the document is called. Change it any time '
            "for an individual CV from Studio; this only affects what's "
            'picked by default.',
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          Wrap(
            spacing: context.appSpacing.gapSmall,
            runSpacing: context.appSpacing.gapSmall,
            children: [
              for (final region in viewModel.regions)
                _RegionChip(
                  region: region,
                  selected: viewModel.defaultRegion == region,
                  onTap: () => viewModel.setDefaultRegion(region),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final RegionProfile region;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preset = region.preset;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Text(
        preset.flag,
        style: TextStyle(fontSize: context.appIconSize.small),
      ),
      label: Text(preset.displayName),
      labelStyle: context.appTypography.bodySmall,
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.18),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
