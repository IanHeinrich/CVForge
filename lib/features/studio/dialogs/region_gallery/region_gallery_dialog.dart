import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
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
/// selected one's conventions. Separating selection from explanation keeps
/// the list scannable while letting the detail pane say as much as a
/// region needs.
///
/// One dialog serves both Studio's per-CV choice and the Vault's default —
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
      cancelLabel: context.l10n.commonCancel,
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
                      region.displayName(context.l10n),
                      style: context.appTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Wraps rather than ellipsising: the country list is
                    // how a reader knows "Nordics" includes Finland, and
                    // the longest two would otherwise lose their last
                    // entry. Uneven row heights are the cheaper cost.
                    Text(
                      region.coverage(context.l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const HGap.small(),
                Icon(
                  RemixIcons.checkbox_circle_fill,
                  color: Theme.of(context).colorScheme.primary,
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
            label: context.l10n.studioRegionPageSize,
            value: preset.page.displayLabel(context.l10n),
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.file_list_2_line,
            label: context.l10n.studioRegionTypicalLength,
            value: region.lengthNote(context.l10n),
          ),
          const VGap.tiny(),
          _DetailRow(
            // Not translate_2, which the document-language control uses.
            // Region's spelling row is about which English variant a market
            // reads as native, not about what language the CV is in, and
            // sharing an icon with the language picker said otherwise.
            icon: RemixIcons.a_b,
            label: context.l10n.studioRegionSpelling,
            value: preset.spelling.displayLabel(context.l10n),
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.user_line,
            label: context.l10n.studioRegionPhoto,
            value: preset.photo.displayLabel(context.l10n),
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.profile_line,
            label: context.l10n.studioRegionPersonalDetails,
            value: preset.personalDetails.displayLabel(context.l10n),
          ),
          const VGap.tiny(),
          _DetailRow(
            icon: RemixIcons.text,
            label: context.l10n.studioRegionLocalName,
            value: preset.localName,
          ),
          const VGap.small(),
          Text(
            region.toneNote(context.l10n),
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          for (final convention in region.conventions(context.l10n))
            Padding(
              padding: EdgeInsets.only(bottom: context.appSpacing.gapTiny),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: context.appTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      convention,
                      style: context.appTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        Icon(
          icon,
          size: context.appIconSize.tiny,
          color: context.appPalette.placeholder,
        ),
        const HGap.tiny(),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.appTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(text: context.l10n.studioRegionDetailRow(label)),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
