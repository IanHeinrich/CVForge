import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';

/// A card for the default region every *new* CV is created with — one of
/// Settings' cards, stacked by `SettingsView` alongside
/// [BackupSettingsCard]/[AiAssistantSettingsCard]. Same dark-container,
/// `context.appRadius.medium` frame those use.
///
/// A summary row opening `RegionGalleryDialog`, not a picker of its own.
/// This was a chip row listing every region by name, which stopped being
/// honest once regions carried real conventions: the chips could say
/// *which* regions existed but had nowhere to explain what choosing one
/// changes, and their copy drifted from the per-CV picker that did. One
/// surface, two entry points.
class RegionSettingsCard extends StatelessWidget {
  const RegionSettingsCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final preset = viewModel.defaultRegion.preset;
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
            'The region every new CV starts with. Change it any time for an '
            'individual CV from Studio.',
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          Row(
            children: [
              RegionFlagStack(
                flags: preset.flags,
                size: context.appIconSize.large,
              ),
              const HGap.small(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.displayName,
                      style: context.appTypography.bodySmall.copyWith(
                        color: kcWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      preset.coverage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTypography.caption.copyWith(
                        color: kcLightGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const HGap.small(),
              OutlinedButton(
                onPressed: viewModel.openDefaultRegionPicker,
                child: const Text('Change'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
