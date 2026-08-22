import 'dart:typed_data';

import 'package:cv_forge/ui/common/app_colors.dart';
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

/// Sized so the thumbnail is actually legible as a page — you're picking
/// a visual design, so a stamp-sized render of it answers nothing.
const _cardWidth = 300.0;

/// A flat, wrapping grid of template cards — not grouped or filtered, see
/// [TemplateGalleryDialogModel]'s doc comment for why tag-grouping (7.5's
/// original design) was dropped. Each thumbnail is the user's own CV,
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
        // width; maxHeight caps it once there are enough templates to
        // need scrolling, but doesn't force that much height with only
        // a couple — the fixed-height box this replaced left most of
        // itself blank with two templates.
        SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 620),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: context.appSpacing.gapSmall,
                runSpacing: context.appSpacing.gapSmall,
                children: [
                  for (final template in viewModel.templates)
                    _TemplateCard(
                      template: template,
                      selected: viewModel.selectedTemplateId == template.id,
                      onTap: () => viewModel.selectTemplate(template.id),
                      thumbnailFuture: viewModel.thumbnailFor(template.id),
                      pageAspectRatio: viewModel.pageAspectRatio,
                    ),
                ],
              ),
            ),
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
    required this.onTap,
    required this.thumbnailFuture,
    required this.pageAspectRatio,
  });

  final CvTemplate template;
  final bool selected;
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
    // heading conveying that anymore now the gallery is a flat grid.
    final tags = template.tags.toList();
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.appRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.appRadius.medium),
        onTap: onTap,
        child: Container(
          width: _cardWidth,
          padding: EdgeInsets.all(context.appSpacing.paddingTight),
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      context.appRadius.small,
                    ),
                    // AspectRatio, not a fixed height — the slot takes
                    // the page's own proportions so `BoxFit.cover` fills
                    // it exactly, with no letterbox band in either
                    // direction whichever page size the draft uses.
                    child: AspectRatio(
                      aspectRatio: pageAspectRatio,
                      child: PdfPageThumbnail(future: thumbnailFuture),
                    ),
                  ),
                  if (selected)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(
                        RemixIcons.checkbox_circle_fill,
                        color: kcPrimaryColor,
                      ),
                    ),
                ],
              ),
              const VGap.tiny(),
              Text(
                template.displayName,
                style: context.appTypography.bodySmall.copyWith(
                  color: kcWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const VGap.tiny(),
              Text(
                template.description,
                style: context.appTypography.caption.copyWith(
                  color: kcLightGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (tags.isNotEmpty) ...[
                const VGap.tiny(),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in tags)
                      Chip(
                        label: Text(tag.displayLabel),
                        labelStyle: context.appTypography.caption,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
