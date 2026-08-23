import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';

/// The bar above Studio's three-column layout: a way back to
/// [DraftsListView] and the draft name/edit affordance (absorbing what
/// `studio_draft_header.dart` used to own), the template and region
/// pickers, the page count, and Export — moved off the preview pane's
/// floating button so it reads as document-level, not preview-level. See
/// `docs/ux/7.4-studio-restructure.md` and
/// `docs/ux/7.5-template-region-scaling.md`.
///
/// Three zones, grouped by what each control is about: identity (back,
/// name, edit) on the left, the document's *setup* (template, region)
/// centred, and its *output* (page count, Export) on the right.
///
/// The centre group is centred on the **bar**, not merely placed between
/// the other two — which is why the side groups are equal-flex
/// [Expanded]s rather than natural-width siblings. A `Row` hands each
/// flexible child `freeSpace * flex / totalFlex`, so two equal flexes
/// always split the surplus evenly and leave the natural-width centre
/// group exactly in the middle regardless of how long the draft name is
/// or whether the page count is showing. Each side then aligns its own
/// content outward (start on the left, end on the right) inside its half.
///
/// Aligning within an [Expanded] also matters for the right group
/// specifically: a `Row` gives a loose flexible child only what it asks
/// for and lets the remainder collect at the row's end, so the earlier
/// "one `Expanded` on the left, natural width after it" arrangement left
/// Export short of the right edge by whatever share of the surplus a
/// short draft name didn't spend.
class StudioDocumentBar extends StatelessWidget {
  const StudioDocumentBar({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  /// Every control in the bar shares this height, so buttons whose own
  /// default padding differs still line up as one row of controls.
  static const _controlHeight = 40.0;

  /// Below this the bar splits into two rows — identity above, controls
  /// below. Squeezing all of it onto one row instead used to push the
  /// template picker off-screen behind an unmarked horizontal scroll;
  /// wrapping keeps every control visible and reachable at any width.
  ///
  /// Higher than it needs to be for the controls alone, because the
  /// three-zone single row costs more than a two-zone one: the centre
  /// group is centred on the bar, so the *wider* of the two side groups
  /// dictates how much room both get. Set so the right group still fits
  /// its half once the left group's name has ellipsised as far as it
  /// usefully can.
  static const _singleRowMinWidth = 900.0;

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
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= _singleRowMinWidth) {
                return Row(
                  children: [
                    // Equal flexes, each aligning its content outward —
                    // see the class doc comment for why that, and not
                    // natural-width siblings, is what actually centres
                    // the setup group and pins Export to the edge.
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _Identity(viewModel: viewModel),
                      ),
                    ),
                    const HGap.small(),
                    _SetupControls(viewModel: viewModel),
                    const HGap.small(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _OutputControls(viewModel: viewModel),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Identity(viewModel: viewModel),
                  const VGap.tiny(),
                  // Too narrow to centre anything meaningfully, so the
                  // two control groups just take an end each — but on a
                  // phone-width bar even that end-each pair (template +
                  // region buttons on one side, page count + Export on
                  // the other) doesn't always fit one line. A plain `Row`
                  // let Export run off the bar's right edge with nothing
                  // to scroll it back into view; `Wrap` drops it to its
                  // own line instead once the two groups' combined width
                  // stops fitting, while still reproducing the same
                  // side-by-side look whenever there's room for it.
                  // `compact: true` — a phone-width bar doesn't have
                  // room for full labels on every control, and the
                  // uncapped version of this row (each button sized to
                  // its own display name, Export spelled out in full)
                  // was wide enough that `Wrap` fell back to two extra
                  // rows on essentially every phone, not just
                  // exceptionally narrow ones — a tall bar eating real
                  // content height to stay "safe" for a case that was
                  // actually the common one. Bounding each label's width
                  // (see `_BarButton.labelMaxWidth`) and dropping Export
                  // to icon-only keeps everything on this one line at
                  // any realistic phone width; `Wrap` stays as the
                  // fallback only a genuinely tiny viewport should ever
                  // trigger.
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: context.appSpacing.gapSmall,
                    children: [
                      _SetupControls(viewModel: viewModel, compact: true),
                      _OutputControls(viewModel: viewModel, compact: true),
                    ],
                  ),
                ],
              );
            },
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

/// How the document is built — the centre group.
class _SetupControls extends StatelessWidget {
  const _SetupControls({required this.viewModel, this.compact = false});

  final StudioViewModel viewModel;

  /// Caps each button's own label width (see [_BarButton.labelMaxWidth])
  /// instead of letting it size to the template's/region's full display
  /// name — see the mobile branch's own doc comment for why.
  final bool compact;

  /// Narrow enough that the name is still recognisable (not just an
  /// initial) but short enough that two of these plus icon-only Export
  /// reliably share one line on a phone-width bar.
  static const _compactLabelMaxWidth = 56.0;

  @override
  Widget build(BuildContext context) {
    // Wrap, not Row — the template button's label is the template's own
    // (potentially long) display name, and on a narrow phone-width bar
    // the two buttons together don't always fit one line. A plain Row
    // let the region button run off the bar's edge with no way to reach
    // it; Wrap drops it to its own line instead, same fix as the parent
    // bar's own two-group Wrap just above this in the widget tree.
    return Wrap(
      spacing: context.appSpacing.gapTiny,
      runSpacing: context.appSpacing.gapTiny,
      children: [
        _BarButton(
          onPressed: viewModel.openTemplateGallery,
          icon: Icon(
            RemixIcons.layout_grid_line,
            size: context.appIconSize.small,
          ),
          label: viewModel.template.displayName,
          labelMaxWidth: compact ? _compactLabelMaxWidth : null,
        ),
        // A button opening a card dialog, not the `DropdownMenu` 7.5
        // originally chose: region sits beside template here and is the
        // same kind of decision, so it gets the same affordance — and
        // unlike a dropdown, the dialog has room to say what picking a
        // region actually changes. The flag leads, as on that dialog's
        // own cards.
        _BarButton(
          onPressed: viewModel.openRegionGallery,
          icon: Text(
            viewModel.region.preset.flag,
            style: TextStyle(fontSize: context.appIconSize.small),
          ),
          label: viewModel.region.preset.displayName,
          labelMaxWidth: compact ? _compactLabelMaxWidth : null,
        ),
      ],
    );
  }
}

/// What comes out of it — the right group. Page count sits immediately
/// left of Export because both describe the produced PDF, where template
/// and region describe how it gets built.
class _OutputControls extends StatelessWidget {
  const _OutputControls({required this.viewModel, this.compact = false});

  final StudioViewModel viewModel;

  /// Drops Export to icon-only and hides the page-count badge — on a
  /// phone-width bar there isn't room for "Export PDF" spelled out
  /// alongside the (already-compacted) template/region buttons without
  /// pushing this group onto its own line; the page count is the lower
  /// -priority of the two (it's also visible on the Preview tab), so
  /// it's the one dropped rather than further squeezing Export's own
  /// tap target.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final exportIcon = viewModel.isExporting
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: kcWhite),
          )
        : Icon(RemixIcons.download_line, size: context.appIconSize.medium);
    final exportTooltip = viewModel.isExporting ? 'Exporting…' : 'Export PDF';

    if (compact) {
      return SizedBox(
        height: StudioDocumentBar._controlHeight,
        width: StudioDocumentBar._controlHeight,
        child: Tooltip(
          message: exportTooltip,
          child: FilledButton(
            onPressed: viewModel.isExporting ? null : viewModel.exportPdf,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            child: exportIcon,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.pageCount != null) ...[
          _PageCountBadge(
            count: viewModel.pageCount!,
            height: StudioDocumentBar._controlHeight,
          ),
          const HGap.tiny(),
        ],
        SizedBox(
          height: StudioDocumentBar._controlHeight,
          child: FilledButton.icon(
            onPressed: viewModel.isExporting ? null : viewModel.exportPdf,
            icon: exportIcon,
            label: Text(exportTooltip),
          ),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back to your CVs',
          icon: const Icon(RemixIcons.arrow_left_line, color: kcLightGrey),
          onPressed: viewModel.goToDrafts,
        ),
        Flexible(
          child: Text(
            viewModel.draftName,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.titleSmall,
          ),
        ),
        IconButton(
          tooltip: 'Edit CV details',
          icon: const Icon(RemixIcons.edit_line, color: kcLightGrey),
          onPressed: viewModel.editDraftDetails,
        ),
      ],
    );
  }
}

/// The template and region pickers' shared shape. A plain outlined button
/// on the bar's own ground, not one banded onto a filled container — the
/// container's fill ended flush against each button's border with no
/// breathing room between the two edges, which read as a rendering
/// artefact rather than as grouping. Spacing groups these instead.
class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.labelMaxWidth,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String label;

  /// Caps the label to a fixed width (ellipsised past that) instead of
  /// sizing to the full display name — the mobile bar's compact mode
  /// needs a predictable, small button width regardless of how long a
  /// given template's or region's name happens to be. Null (desktop/
  /// tablet) leaves the label at its natural width, unchanged.
  final double? labelMaxWidth;

  @override
  Widget build(BuildContext context) {
    final maxWidth = labelMaxWidth;
    final label = Text(
      this.label,
      overflow: maxWidth == null ? null : TextOverflow.ellipsis,
      maxLines: maxWidth == null ? null : 1,
      softWrap: maxWidth == null ? null : false,
    );
    return SizedBox(
      height: StudioDocumentBar._controlHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: maxWidth == null
            ? label
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: label,
              ),
        style: OutlinedButton.styleFrom(
          foregroundColor: kcWhite,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          padding: EdgeInsets.symmetric(
            horizontal: context.appSpacing.paddingCompact,
          ),
        ),
      ),
    );
  }
}

class _PageCountBadge extends StatelessWidget {
  const _PageCountBadge({required this.count, required this.height});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingCompact,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Text(
        count == 1 ? '1 page' : '$count pages',
        style: context.appTypography.caption,
      ),
    );
  }
}
