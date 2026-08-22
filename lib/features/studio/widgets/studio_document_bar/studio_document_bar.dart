import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';

/// The one-row bar above Studio's three-column layout: a way back to
/// [DraftsListView] and the draft name/edit affordance (absorbing what
/// `studio_draft_header.dart` used to own), the template gallery button
/// and region dropdown (7.5), the page count (7.3), and Export — moved
/// off the preview pane's floating button so it reads as document-level,
/// not preview-level. See `docs/ux/7.4-studio-restructure.md` and
/// `docs/ux/7.5-template-region-scaling.md`.
class StudioDocumentBar extends StatelessWidget {
  const StudioDocumentBar({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingPage,
        vertical: context.appSpacing.paddingTight,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to your CVs',
                icon: const Icon(
                  RemixIcons.arrow_left_line,
                  color: kcLightGrey,
                ),
                onPressed: viewModel.goToDrafts,
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        viewModel.draftName,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTypography.titleSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit CV details',
                      icon: const Icon(
                        RemixIcons.edit_line,
                        color: kcLightGrey,
                      ),
                      onPressed: viewModel.editDraftDetails,
                    ),
                  ],
                ),
              ),
              // The remaining controls never wrap onto a second line (the
              // bar stays one row, per the doc's target layout) — on a
              // narrow compact breakpoint they scroll horizontally instead
              // of overflowing, rather than risking a `RenderFlex` error.
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: viewModel.openTemplateGallery,
                        icon: const Icon(RemixIcons.layout_grid_line, size: 16),
                        label: Text(viewModel.template.displayName),
                      ),
                      const HGap.small(),
                      // A plain dropdown, not a chip row — 5-6 regions
                      // fit in one menu without scrolling, and a chip
                      // row of that many wouldn't fit this one-row bar.
                      // See 7.5 decision 8.
                      DropdownMenu<RegionProfile>(
                        initialSelection: viewModel.region,
                        textStyle: context.appTypography.bodySmall,
                        onSelected: (region) {
                          if (region != null) viewModel.setRegion(region);
                        },
                        dropdownMenuEntries: [
                          for (final region in RegionProfile.values)
                            DropdownMenuEntry(
                              value: region,
                              label: region.preset.displayName,
                            ),
                        ],
                      ),
                      if (viewModel.pageCount != null) ...[
                        const HGap.small(),
                        _PageCountBadge(count: viewModel.pageCount!),
                      ],
                      const HGap.small(),
                      FilledButton.icon(
                        onPressed: viewModel.isExporting
                            ? null
                            : viewModel.exportPdf,
                        icon: viewModel.isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kcWhite,
                                ),
                              )
                            : const Icon(RemixIcons.download_line),
                        label: Text(
                          viewModel.isExporting ? 'Exporting…' : 'Export PDF',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (viewModel.hasExportError) ...[
            const VGap.tiny(),
            PersistErrorBanner(
              message: viewModel.exportErrorMessage,
              onRetry: viewModel.exportPdf,
            ),
          ],
        ],
      ),
    );
  }
}

class _PageCountBadge extends StatelessWidget {
  const _PageCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Text(
        count == 1 ? '1 page' : '$count pages',
        style: context.appTypography.caption,
      ),
    );
  }
}
