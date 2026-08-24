import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_warning_surface.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';

/// The bar above Studio's three-column layout: a way back to
/// [DraftsListView] and the draft name/edit affordance (absorbing what
/// `studio_draft_header.dart` used to own), the template and region
/// pickers, the page count, and Export — moved off the preview pane's
/// floating button so it reads as document-level, not preview-level.
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
        // A button opening a card dialog, not a `DropdownMenu`: region sits
        // beside template here and is the same kind of decision, so it
        // gets the same affordance — and
        // unlike a dropdown, the dialog has room to say what picking a
        // region actually changes. The flag leads, as on that dialog's
        // own cards.
        _BarButton(
          onPressed: viewModel.openRegionGallery,
          // A globe rather than the region's flags. Four flags at this
          // size are ~8px each and unreadable, but showing just the first
          // is worse than showing none: "UK & Ireland" would be marked
          // with the UK flag alone. The label already names the region,
          // and this matches the icon treatment on the template button
          // beside it. The flags appear in the picker and in Settings,
          // where there is room to show all of them.
          icon: Icon(RemixIcons.earth_line, size: context.appIconSize.small),
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
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          )
        : Icon(RemixIcons.download_line, size: context.appIconSize.medium);
    final exportTooltip = viewModel.isExporting ? 'Exporting…' : 'Export PDF';

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Both badges are warnings, and a warning is actionable rather
          // than informational, so each earns the width here — and costs
          // none in the ordinary case, because neither exists unless there
          // is something to say. (The *neutral* page count, by contrast,
          // stays hidden in this layout — see [compact].)
          if (viewModel.photoRegionWarning != null) ...[
            _PhotoRegionBadge(
              warning: viewModel.photoRegionWarning!,
              height: StudioDocumentBar._controlHeight,
            ),
            const HGap.tiny(),
          ],
          if (viewModel.pageCountWarning != null) ...[
            _PageCountBadge(
              count: viewModel.pageCount!,
              height: StudioDocumentBar._controlHeight,
              warning: viewModel.pageCountWarning,
              iconOnly: true,
            ),
            const HGap.tiny(),
          ],
          SizedBox(
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
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.photoRegionWarning != null) ...[
          _PhotoRegionBadge(
            warning: viewModel.photoRegionWarning!,
            height: StudioDocumentBar._controlHeight,
          ),
          const HGap.tiny(),
        ],
        if (viewModel.pageCount != null) ...[
          _PageCountBadge(
            count: viewModel.pageCount!,
            height: StudioDocumentBar._controlHeight,
            warning: viewModel.pageCountWarning,
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
    // This draft's own region, not `AppSettings.defaultRegion` — a draft
    // already created under one region keeps calling itself by that
    // region's noun regardless of what the global default is set to now.
    final preset = viewModel.region.preset;
    return Row(
      children: [
        IconButton(
          tooltip: 'Back to your ${preset.documentNoun.pluralCapitalized}',
          icon: Icon(
            RemixIcons.arrow_left_line,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
          tooltip: 'Edit ${preset.documentNoun.capitalized} details',
          icon: Icon(
            RemixIcons.edit_line,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          padding: EdgeInsets.symmetric(
            horizontal: context.appSpacing.paddingCompact,
          ),
        ),
      ),
    );
  }
}

/// How many pages the CV came out at, and — when [warning] is non-null —
/// that this is more than the draft's region typically expects.
///
/// The comparison itself lives on `StudioViewModel.pageCountWarning`; this
/// only renders what it decided.
class _PageCountBadge extends StatelessWidget {
  const _PageCountBadge({
    required this.count,
    required this.height,
    this.warning,
    this.iconOnly = false,
  });

  final int count;
  final double height;

  /// Null renders the plain badge, unchanged.
  final String? warning;

  /// Drops the label, leaving a [height]-square warning icon with the same
  /// footprint as the compact Export button. Only meaningful with a
  /// [warning] to explain via the tooltip.
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final isWarning = warning != null;
    final width = iconOnly ? height : null;
    final padding = iconOnly
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(horizontal: context.appSpacing.paddingCompact);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWarning) ...[
          AppWarningSurface.icon(context),
          if (!iconOnly) const HGap.tiny(),
        ],
        if (!iconOnly)
          Text(
            count == 1 ? '1 page' : '$count pages',
            style: isWarning
                ? context.appTypography.caption.copyWith(
                    color: context.appPalette.warning,
                  )
                : context.appTypography.caption,
          ),
      ],
    );

    if (!isWarning) {
      return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(context.appRadius.medium),
        ),
        child: content,
      );
    }

    // Long-press reaches the message on touch, where there is no hover.
    return Tooltip(
      message: warning!,
      child: AppWarningSurface(
        height: height,
        width: width,
        alignment: Alignment.center,
        padding: padding,
        radius: context.appRadius.medium,
        child: content,
      ),
    );
  }
}

/// Flags a photo template aimed at a market that doesn't want one.
///
/// Icon-only in both layouts, unlike [_PageCountBadge]: there is no
/// neutral value to show here, so the badge exists only when there is
/// something wrong, and the sentence explaining it is longer than any
/// label that would fit a bar control.
///
/// The judgement itself lives on `StudioViewModel.photoRegionWarning`;
/// this only renders what it decided.
class _PhotoRegionBadge extends StatelessWidget {
  const _PhotoRegionBadge({required this.warning, required this.height});

  final String warning;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Long-press reaches the message on touch, where there is no hover —
    // same reason as [_PageCountBadge].
    return Tooltip(
      message: warning,
      child: AppWarningSurface(
        height: height,
        width: height,
        alignment: Alignment.center,
        radius: context.appRadius.medium,
        child: Icon(
          RemixIcons.user_line,
          size: context.appIconSize.small,
          color: context.appPalette.warning,
        ),
      ),
    );
  }
}
