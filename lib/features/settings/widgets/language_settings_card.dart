import 'package:flutter/material.dart';

import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';

/// The app chrome's language — one of Settings' cards, in the same
/// dark-container frame [RegionSettingsCard] and its siblings use.
///
/// A plain dropdown rather than a gallery dialog, unlike the region card next
/// to it: region opens one because choosing a market carries a page of
/// consequences worth explaining, and a language carries none.
///
/// Deliberately *not* a region setting. Which market a CV targets and which
/// language its author reads the app in are independent — see
/// `RegionProfile`'s "Region is not a locale" note.
class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({super.key, required this.viewModel});

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
            context.l10n.settingsLanguageCardTitle,
            style: context.appTypography.titleMedium,
          ),
          const VGap.tiny(),
          Text(
            context.l10n.settingsLanguageCardBody,
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          DropdownButtonFormField<String?>(
            initialValue: viewModel.selectedLocaleTag,
            isExpanded: true,
            items: [
              DropdownMenuItem(
                child: Text(context.l10n.settingsLanguageFollowSystem),
              ),
              for (final locale in viewModel.availableLocales)
                DropdownMenuItem(
                  value: locale.toLanguageTag(),
                  // Each language named in itself, never translated — an
                  // autonym is what lets someone who landed in a language
                  // they cannot read find their way back out.
                  child: Text(viewModel.localeDisplayName(locale)),
                ),
            ],
            onChanged: viewModel.setLocaleTag,
          ),
        ],
      ),
    );
  }
}
