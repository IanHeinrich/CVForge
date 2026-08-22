import 'dart:typed_data';

import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/widgets/common/pdf_page_thumbnail.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/drafts_list/drafts_list_viewmodel.dart';

/// The Drafts landing page's content: every saved CV as a thumbnail card —
/// the same wrapping-grid-of-page-previews shape as
/// `TemplateGalleryDialog`, so picking a CV to open reads the same as
/// picking a template to switch to — plus a "New CV" action. Kept as one
/// widget (no empty-state/populated split via separate files) since
/// there's nothing here complex enough to warrant it — see
/// [_DraftsEmptyState] below for the one branch.
class DraftsCardList extends StatelessWidget {
  const DraftsCardList({super.key, required this.viewModel});

  final DraftsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isEmpty) {
      return _DraftsEmptyState(onNewCv: viewModel.createDraft);
    }
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.appSpacing.paddingPage,
            context.appSpacing.paddingPage,
            context.appSpacing.paddingPage,
            96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (viewModel.hasPersistError) ...[
                PersistErrorBanner(
                  message: "Your last change couldn't be saved.",
                  onRetry: viewModel.retryPersist,
                ),
                const VGap.medium(),
              ],
              Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: context.appSpacing.gapSmall,
                runSpacing: context.appSpacing.gapSmall,
                children: [
                  for (final draft in viewModel.drafts)
                    _DraftCard(
                      draft: draft,
                      templateName: viewModel.templateName(draft.templateId),
                      thumbnailFuture: viewModel.thumbnailFor(draft),
                      pageAspectRatio: viewModel.pageAspectRatio(draft),
                      onOpen: () => viewModel.openDraft(draft.id),
                      onEdit: () => viewModel.editDraft(draft),
                      onDuplicate: () => viewModel.duplicateDraft(draft),
                      onDelete: () => viewModel.deleteDraft(draft),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: context.appSpacing.paddingPage,
          bottom: context.appSpacing.paddingPage,
          child: FloatingActionButton.extended(
            onPressed: viewModel.createDraft,
            icon: const Icon(RemixIcons.add_line),
            label: const Text('New CV'),
          ),
        ),
      ],
    );
  }
}

/// Smaller than `TemplateGalleryDialog._cardWidth` (300) — a template
/// card's own description/tags need the extra width, but a CV card is
/// mostly its thumbnail, and a full CVs page tends to hold more drafts at
/// once than a template gallery dialog holds templates.
const _cardWidth = 200.0;

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.templateName,
    required this.thumbnailFuture,
    required this.pageAspectRatio,
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final CvDraft draft;
  final String templateName;
  final Future<Uint8List> thumbnailFuture;
  final double pageAspectRatio;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.appRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.appRadius.medium),
        onTap: onOpen,
        child: Container(
          width: _cardWidth,
          padding: EdgeInsets.all(context.appSpacing.paddingTight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(context.appRadius.small),
                // AspectRatio, not a fixed height — matches the template
                // gallery's own reasoning: the slot takes the page's own
                // proportions so a US Letter draft's thumbnail doesn't
                // letterbox inside an A4-shaped box.
                child: AspectRatio(
                  aspectRatio: pageAspectRatio,
                  child: PdfPageThumbnail(future: thumbnailFuture),
                ),
              ),
              const VGap.tiny(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      draft.name.isEmpty ? 'Untitled CV' : draft.name,
                      style: context.appTypography.bodySmall.copyWith(
                        color: kcWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<_DraftCardAction>(
                    icon: const Icon(
                      RemixIcons.more_2_line,
                      color: kcLightGrey,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'More',
                    onSelected: (action) => switch (action) {
                      _DraftCardAction.edit => onEdit(),
                      _DraftCardAction.duplicate => onDuplicate(),
                      _DraftCardAction.delete => onDelete(),
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _DraftCardAction.edit,
                        child: Text('Rename / edit notes'),
                      ),
                      PopupMenuItem(
                        value: _DraftCardAction.duplicate,
                        child: Text('Duplicate'),
                      ),
                      PopupMenuItem(
                        value: _DraftCardAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                templateName,
                style: context.appTypography.caption.copyWith(
                  color: kcLightGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Its own line, and never truncated — combined with the
              // template name on one `maxLines: 1` line, a longer
              // template name pushed this off the end entirely, hiding
              // the one piece of metadata (when a CV was last touched)
              // that's actually useful for telling drafts apart.
              Text(
                'Updated ${_formatDateTime(draft.updatedAt)}',
                style: context.appTypography.caption.copyWith(
                  color: kcLightGrey,
                ),
              ),
              if (draft.notes.isNotEmpty) ...[
                const VGap.tiny(),
                Text(
                  draft.notes,
                  style: context.appTypography.caption.copyWith(
                    color: kcLightGrey,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _DraftCardAction { edit, duplicate, delete }

class _DraftsEmptyState extends StatelessWidget {
  const _DraftsEmptyState({required this.onNewCv});

  final VoidCallback onNewCv;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: RemixIcons.file_text_line,
      title: 'No CVs yet',
      message:
          'Create a CV to start tailoring your Vault for a specific '
          'application.',
      actions: [FilledButton(onPressed: onNewCv, child: const Text('New CV'))],
    );
  }
}

String _formatDateTime(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year} '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';
