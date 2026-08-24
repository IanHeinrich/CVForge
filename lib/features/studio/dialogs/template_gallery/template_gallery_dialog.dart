import 'dart:typed_data';

import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/pdf_page_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:cv_forge/templates/cv_template.dart';
import 'template_gallery_dialog_data.dart';
import 'template_gallery_dialog_model.dart';

/// The card's ideal width: wide enough that the thumbnail still reads as a
/// page — you're picking a visual design, so a stamp-sized render of it
/// answers nothing — but narrow enough that every registered template fits
/// on one row of the dialog's 760 max width, so choosing between them
/// never involves scrolling. Only ever shrunk from this by
/// [_TemplateCard]'s own `LayoutBuilder`, on a viewport too narrow to fit
/// even one at full size.
const _cardWidth = 220.0;

/// A flat, wrapping grid of template cards — not grouped or filtered, see
/// [TemplateGalleryDialogModel]'s doc comment for why tag-grouping was
/// dropped. Each thumbnail is the user's own CV,
/// rendered through the same [TemplateThumbnailService] pipeline the
/// exported PDF uses, so a card can never show something switching to
/// that template wouldn't actually produce.
class TemplateGalleryDialog extends StackedView<TemplateGalleryDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const TemplateGalleryDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  TemplateGalleryDialogData get _data =>
      request.data as TemplateGalleryDialogData;

  @override
  Widget builder(
    BuildContext context,
    TemplateGalleryDialogModel viewModel,
    Widget? child,
  ) {
    return AppDialogScaffold(
      title: 'Choose a template',
      maxWidth: 760,
      cancelLabel: 'Cancel',
      confirmLabel: 'Use this template',
      onCancel: () => completer(DialogResponse<String>(confirmed: false)),
      onConfirm: () => completer(
        DialogResponse<String>(
          confirmed: true,
          data: viewModel.selectedTemplateId,
        ),
      ),
      children: [
        const VGap.medium(),
        // width: double.maxFinite forces the grid to use the dialog's
        // full available width so `Wrap` actually flows cards across
        // several columns instead of shrink-wrapping to one card's
        // width. No height cap or scroll view of its own here —
        // `AppDialogScaffold` now bounds and scrolls the whole dialog
        // body against the actual viewport height, which a fixed height
        // picked for this one dialog can't do (that's exactly what left
        // the confirm/cancel row unreachable on a short mobile screen).
        SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: context.appSpacing.gapSmall,
            runSpacing: context.appSpacing.gapSmall,
            children: [
              for (final template in viewModel.templates)
                _TemplateCard(
                  template: template,
                  selected: viewModel.selectedTemplateId == template.id,
                  current: viewModel.currentTemplateId == template.id,
                  onTap: () => viewModel.selectTemplate(template.id),
                  thumbnailFuture: viewModel.thumbnailFor(template.id),
                  pageAspectRatio: viewModel.pageAspectRatio,
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  TemplateGalleryDialogModel viewModelBuilder(BuildContext context) =>
      TemplateGalleryDialogModel(data: _data);
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.selected,
    required this.current,
    required this.onTap,
    required this.thumbnailFuture,
    required this.pageAspectRatio,
  });

  final CvTemplate template;
  final bool selected;

  /// Whether this is the template the draft is on today. Distinct from
  /// [selected], which is what the confirm button would apply.
  final bool current;
  final VoidCallback onTap;
  final Future<Uint8List> thumbnailFuture;

  /// Width ÷ height of the page the thumbnail actually renders, so the
  /// slot matches the image and the render fills it edge to edge. Fixing
  /// this at A4 left a US Letter draft's shorter, wider page letterboxed
  /// inside an A4-shaped box with a dark band above and below it.
  final double pageAspectRatio;

  @override
  Widget build(BuildContext context) {
    // Every tag, not just the ones beyond a "primary" — there's no group
    // heading conveying that anymore now the gallery is a flat grid. One
    // caption line rather than a `Chip` each: three Material chips wrap to
    // two or three rows at this card width, and carry far more visual
    // weight than one line of text is worth.
    final tags = template.tags.map((tag) => tag.displayLabel).join(' · ');
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.appRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.appRadius.medium),
        onTap: onTap,
        // `LayoutBuilder`'s `constraints.maxWidth` here is the `Wrap`'s
        // own available width (a `Wrap` gives every child a loose
        // constraint capped at its own width, not a per-child share of
        // it) — so a card only ever shrinks below `_cardWidth` on a
        // viewport too narrow to fit one at full size, instead of
        // overflowing past the dialog's edge the way a bare fixed width
        // did on mobile.
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth < _cardWidth
                ? constraints.maxWidth
                : _cardWidth,
            padding: EdgeInsets.all(context.appSpacing.paddingTight),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.appRadius.medium),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.appRadius.small),
                  // AspectRatio, not a fixed height — the slot takes
                  // the page's own proportions so `BoxFit.cover` fills
                  // it exactly, with no letterbox band in either
                  // direction whichever page size the draft uses.
                  child: AspectRatio(
                    aspectRatio: pageAspectRatio,
                    child: PdfPageThumbnail(future: thumbnailFuture),
                  ),
                ),
                const VGap.tiny(),
                // The check sits in the name row, not over the thumbnail:
                // there it was a primary-coloured glyph on top of a
                // rendered white page, barely legible, and redundant with
                // the border this card already draws when selected. Same
                // placement `RegionGalleryDialog._RegionListRow` uses.
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.displayName,
                        style: context.appTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (current) ...[
                      const HGap.tiny(),
                      Text(
                        'Current',
                        style: context.appTypography.caption.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                    if (selected) ...[
                      const HGap.tiny(),
                      Icon(
                        RemixIcons.checkbox_circle_fill,
                        color: Theme.of(context).colorScheme.primary,
                        size: context.appIconSize.medium,
                      ),
                    ],
                  ],
                ),
                const VGap.tiny(),
                // Wraps in full, with no line cap: a description is the
                // only thing on the card that distinguishes two
                // similar-looking templates, and clipping it withheld
                // exactly the part that decides the choice — the photo
                // template's own description ends by warning that a photo
                // invites a rejection in the US and UK, which is useless
                // as an ellipsis. Cards in the `Wrap` end up different
                // heights; that's the cheaper cost, the same call
                // `RegionGalleryDialog._RegionListRow` makes for its
                // country list.
                Text(
                  template.description,
                  style: context.appTypography.caption.copyWith(color: muted),
                ),
                if (tags.isNotEmpty) ...[
                  const VGap.tiny(),
                  Text(
                    tags,
                    style: context.appTypography.caption.copyWith(color: muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
