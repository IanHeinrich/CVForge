import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'region_gallery_dialog_data.dart';
import 'region_gallery_dialog_model.dart';

const _cardWidth = 220.0;

/// The region picker, deliberately built as the same
/// card-grid-in-a-dialog shape as `TemplateGalleryDialog` rather than the
/// `DropdownMenu` it replaced — the two live side by side in
/// `StudioDocumentBar` and are the same kind of decision (pick one
/// document-level preset from a small closed set), so they should look and
/// behave the same. The dropdown also had nowhere to explain itself: a bare
/// "United Kingdom" gives no clue that the choice changes anything, and
/// each card here spells out what it actually does.
class RegionGalleryDialog extends StackedView<RegionGalleryDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const RegionGalleryDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  RegionGalleryDialogData get _data => request.data as RegionGalleryDialogData;

  @override
  Widget builder(
    BuildContext context,
    RegionGalleryDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: 'Choose a region',
      maxWidth: 560,
      cancelLabel: 'Cancel',
      confirmLabel: 'Use this region',
      onCancel: () =>
          completer(DialogResponse<RegionProfile>(confirmed: false)),
      onConfirm: () => completer(
        DialogResponse<RegionProfile>(
          confirmed: true,
          data: viewModel.selectedRegion,
        ),
      ),
      children: [
        const VGap.small(),
        Text(
          'Regional conventions differ. This only affects how your CV is '
          'built — it never changes what your Vault stores.',
          style: context.appTypography.bodySmall,
        ),
        const VGap.medium(),
        SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: context.appSpacing.gapSmall,
            runSpacing: context.appSpacing.gapSmall,
            children: [
              for (final region in viewModel.regions)
                _RegionCard(
                  region: region,
                  selected: viewModel.selectedRegion == region,
                  onTap: () => viewModel.selectRegion(region),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  RegionGalleryDialogModel viewModelBuilder(BuildContext context) =>
      RegionGalleryDialogModel(data: _data);
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({
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
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.appRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.appRadius.medium),
        onTap: onTap,
        child: Container(
          width: _cardWidth,
          padding: EdgeInsets.all(context.appSpacing.paddingCompact),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.appRadius.medium),
            border: Border.all(
              color: selected ? kcPrimaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // The flags carry their own colour, so they need no icon
                  // treatment — sized up to read as the card's mark, the
                  // way a template card's thumbnail does.
                  RegionFlagStack(
                    flags: preset.flags,
                    size: context.appIconSize.large,
                  ),
                  const HGap.small(),
                  Expanded(
                    child: Text(
                      preset.displayName,
                      style: context.appTypography.bodySmall.copyWith(
                        color: kcWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      RemixIcons.checkbox_circle_fill,
                      color: kcPrimaryColor,
                      size: context.appIconSize.medium,
                    ),
                ],
              ),
              const VGap.small(),
              // Only differences that a renderer or the app's own copy
              // actually reads today — see RegionPreset's doc comment for
              // why speculative fields (photo, date of birth, phone
              // format) are deliberately absent rather than listed here
              // as "coming soon".
              _DetailRow(
                icon: RemixIcons.file_paper_2_line,
                label: 'Page size',
                value: preset.page.displayLabel,
              ),
              const VGap.tiny(),
              _DetailRow(
                icon: RemixIcons.calendar_line,
                label: 'Dates',
                value: preset.dateStyle.displayLabel,
              ),
              const VGap.tiny(),
              _DetailRow(
                icon: RemixIcons.text,
                label: 'Known locally as',
                value: preset.localName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.appIconSize.tiny, color: kcMediumGrey),
        const HGap.tiny(),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.appTypography.caption.copyWith(color: kcLightGrey),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: kcWhite),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
