import 'dart:typed_data';

import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_dialog_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:cv_forge/templates/cv_template.dart';
import 'template_gallery_dialog_data.dart';
import 'template_gallery_dialog_model.dart';

const _cardWidth = 200.0;
const _thumbnailHeight = 140.0;

/// A responsive grid of template cards, grouped under tag headings rather
/// than filtered — see `docs/ux/7.5-template-region-scaling.md` decision
/// 5. Each thumbnail is the user's own CV, rendered through the same
/// [TemplateThumbnailService] pipeline the exported PDF uses, so a card
/// can never show something switching to that template wouldn't actually
/// produce.
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
        SizedBox(
          height: 480,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final group in viewModel.tagGroups) ...[
                  Text(
                    group.key.displayLabel,
                    style: context.appTypography.titleSmall,
                  ),
                  const VGap.small(),
                  Wrap(
                    spacing: context.appSpacing.gapSmall,
                    runSpacing: context.appSpacing.gapSmall,
                    children: [
                      for (final template in group.value)
                        _TemplateCard(
                          template: template,
                          selected: viewModel.selectedTemplateId == template.id,
                          onTap: () => viewModel.selectTemplate(template.id),
                          thumbnailFuture: viewModel.thumbnailFor(template.id),
                        ),
                    ],
                  ),
                  const VGap.medium(),
                ],
              ],
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
  });

  final CvTemplate template;
  final bool selected;
  final VoidCallback onTap;
  final Future<Uint8List> thumbnailFuture;

  @override
  Widget build(BuildContext context) {
    final remainingTags = template.tags.skip(1).toList();
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
                    child: SizedBox(
                      height: _thumbnailHeight,
                      width: double.infinity,
                      child: _Thumbnail(future: thumbnailFuture),
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
              if (remainingTags.isNotEmpty) ...[
                const VGap.tiny(),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in remainingTags)
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

/// A thumbnail's loading/failed/ready states. The failed state matters —
/// see `docs/ux/7.5-template-region-scaling.md`'s "What changes" section:
/// a font-load failure under a deployed `--base-href` would fail every
/// thumbnail at once, and the gallery should degrade to a name-and-
/// description card rather than an error grid.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.future});

  final Future<Uint8List> future;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: FutureBuilder<Uint8List>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Icon(RemixIcons.file_paper_2_line, color: kcMediumGrey),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return Image.memory(snapshot.data!, fit: BoxFit.contain);
        },
      ),
    );
  }
}
