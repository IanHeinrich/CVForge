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

/// Below this the two panes won't both fit and the list folds into an
/// accordion instead. Layout breakpoints rather than spacing values, so
/// they stay here rather than moving into `AppSpacing`.
const _twoPaneMinWidth = 560.0;
const _listWidth = 280.0;

/// The region picker: a list of regions beside a pane explaining the
/// selected one's conventions.
///
/// Was a grid of cards, which stopped working once regions carried real
/// guidance — eight fixed-width cards each needing a paragraph of
/// conventions is a wall, not a picker. Separating selection from
/// explanation keeps the list scannable while letting the detail pane say
/// as much as a region actually needs.
///
/// One dialog serves both Studio's per-CV choice and Settings' default —
/// see [RegionGalleryContext]. Its copy comes from the model, so neither
/// entry point can word the decision its own way.
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
      title: viewModel.title,
      maxWidth: 760,
      cancelLabel: 'Cancel',
      confirmLabel: viewModel.confirmLabel,
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
        Text(viewModel.introText, style: context.appTypography.bodySmall),
        const VGap.medium(),
        // AppDialogScaffold already caps height and wraps this whole body
        // in one SingleChildScrollView, so neither pane adds a scrollable
        // of its own — a nested one would leave the confirm row
        // unreachable on a short viewport, the bug that scaffold's own
        // maxHeight comment documents.
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _twoPaneMinWidth) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _listWidth,
                    child: _RegionList(viewModel: viewModel),
                  ),
                  const HGap.small(),
                  Expanded(
                    child: _RegionDetail(region: viewModel.selectedRegion),
                  ),
                ],
              );
            }
            return _RegionList(viewModel: viewModel, inlineDetail: true);
          },
        ),
      ],
    );
  }

  @override
  RegionGalleryDialogModel viewModelBuilder(BuildContext context) =>
      RegionGalleryDialogModel(data: _data);
}

class _RegionList extends StatelessWidget {
  const _RegionList({required this.viewModel, this.inlineDetail = false});

  final RegionGalleryDialogModel viewModel;

  /// Narrow layouts drop the detail pane under the *selected row* rather
  /// than under the whole list — below eight rows it would be off-screen
  /// and read as unrelated content.
  final bool inlineDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final region in viewModel.regions) ...[
          _RegionListRow(
            region: region,
            selected: viewModel.selectedRegion == region,
            onTap: () => viewModel.selectRegion(region),
          ),
          if (inlineDetail && viewModel.selectedRegion == region) ...[
            const VGap.tiny(),
            _RegionDetail(region: region),
          ],
          const VGap.tiny(),
        ],
      ],
    );
  }
}

class _RegionListRow extends StatelessWidget {
  const _RegionListRow({
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
    final radius = BorderRadius.circular(context.appRadius.medium);
    return Material(
      // A fill for the selected row rather than the outline the old cards
      // used — eight stacked borders read as noise at row density.
      color: selected
          ? Theme.of(context).colorScheme.surfaceContainerHigh
          : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(context.appSpacing.paddingTight),
          child: Row(
            children: [
              // The flags carry their own colour, so they need no icon
              // treatment — sized up to read as the row's mark, the way a
              // template card's thumbnail does.
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
                    // Wraps rather than ellipsising: the country list is
                    // how a reader knows "Nordics" includes Finland, and
                    // the longest two would otherwise lose their last
                    // entry. Uneven row heights are the cheaper cost.
                    Text(
                      preset.coverage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTypography.caption.copyWith(
                        color: kcLightGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const HGap.small(),
                Icon(
                  RemixIcons.checkbox_circle_fill,
                  color: kcPrimaryColor,
                  size: context.appIconSize.medium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// What picking this region actually changes — the values a renderer or the
/// app's own copy reads — followed by the market conventions behind them.
///
/// Where a convention names something CVForge has no field for (a
/// photograph, a date of birth), the bullet says so outright rather than
/// leaving the reader to assume it is handled.
class _RegionDetail extends StatelessWidget {
  const _RegionDetail({required this.region});

  final RegionProfile region;

  @override
  Widget build(BuildContext context) {
    final preset = region.preset;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            icon: RemixIcons.file_paper_2_line,
            label: 'Page size',
            value: preset.page.displayLabel,
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.file_list_2_line,
            label: 'Typical length',
            value: preset.lengthNote,
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.translate_2,
            label: 'Spelling',
            value: preset.spelling.displayLabel,
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.user_line,
            label: 'Photo',
            value: preset.photo.displayLabel,
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.profile_line,
            label: 'Personal details',
            value: preset.personalDetails.displayLabel,
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
          const VGap.small(),
          Text(preset.toneNote, style: context.appTypography.bodySmall),
          const VGap.small(),
          for (final convention in preset.conventions)
            Padding(
              padding: EdgeInsets.only(bottom: context.appSpacing.gapTiny),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: context.appTypography.caption.copyWith(
                      color: kcLightGrey,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      convention,
                      style: context.appTypography.caption.copyWith(
                        color: kcLightGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
