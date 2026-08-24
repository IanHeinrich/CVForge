import 'dart:typed_data';

import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/widgets/common/brand_mark/brand_mark.dart';
import 'package:cv_forge/ui/widgets/common/pdf_page_thumbnail.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/drafts_list/drafts_list_viewmodel.dart';

/// The Drafts landing page's content: every saved CV as a thumbnail card —
/// the same wrapping-grid-of-page-previews shape as
/// `TemplateGalleryDialog`, so picking a CV to open reads the same as
/// picking a template to switch to — plus a "New CV" action and a search
/// field to narrow the grid down by name/notes/template. Kept as one widget
/// (no empty-state/populated split via separate files) since there's
/// nothing here complex enough to warrant it — see [_DraftsEmptyState] and
/// [_NoSearchResults] below for the two branches.
class DraftsCardList extends StatelessWidget {
  const DraftsCardList({super.key, required this.viewModel});

  final DraftsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isEmpty) {
      return _DraftsEmptyState(
        documentNoun: viewModel.documentNoun,
        onNewCv: viewModel.createDraft,
      );
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
                  message: context.l10n.studioDraftsPersistError,
                  onRetry: viewModel.retryPersist,
                ),
                const VGap.medium(),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _searchFieldMaxWidth,
                ),
                child: TextField(
                  onChanged: viewModel.setQuery,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: context.l10n.studioDraftsSearch(
                      viewModel.documentNoun,
                    ),
                    prefixIcon: Icon(
                      RemixIcons.search_line,
                      size: context.appIconSize.medium,
                    ),
                  ),
                ),
              ),
              const VGap.medium(),
              if (viewModel.hasNoSearchResults)
                _NoSearchResults(documentNoun: viewModel.documentNoun)
              else
                Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: context.appSpacing.gapSmall,
                  runSpacing: context.appSpacing.gapSmall,
                  children: [
                    for (final draft in viewModel.filteredDrafts)
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
            icon: Icon(RemixIcons.add_line),
            label: Text(
              context.l10n.studioNewDraftTitle(viewModel.documentNoun),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown instead of the grid once a search matches nothing, distinct from
/// [_DraftsEmptyState] — there are drafts, just none matching, so this
/// suggests clearing the search rather than creating a first one.
class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.documentNoun});

  final String documentNoun;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.appSpacing.paddingPage),
      child: Center(
        child: Text(
          context.l10n.studioDraftsNoMatches(documentNoun),
          style: context.appTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Smaller than `TemplateGalleryDialog._cardWidth` (300) — a template
/// card's own description/tags need the extra width, but a CV card is
/// mostly its thumbnail, and a full CVs page tends to hold more drafts at
/// once than a template gallery dialog holds templates.
const _cardWidth = 200.0;

/// Caps the search field's width so it doesn't stretch to fill the grid's
/// full row width on wide monitors — matches
/// `StudioSkillSelector`'s own filter field.
const _searchFieldMaxWidth = 320.0;

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
                      draft.name.isEmpty
                          ? context.l10n.studioDraftUntitled(
                              draft.region.preset.documentNoun.name,
                            )
                          : draft.name,
                      style: context.appTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<_DraftCardAction>(
                    icon: Icon(
                      RemixIcons.more_2_line,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: context.l10n.commonMore,
                    onSelected: (action) => switch (action) {
                      _DraftCardAction.edit => onEdit(),
                      _DraftCardAction.duplicate => onDuplicate(),
                      _DraftCardAction.delete => onDelete(),
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _DraftCardAction.edit,
                        child: Text(context.l10n.studioDraftRename),
                      ),
                      PopupMenuItem(
                        value: _DraftCardAction.duplicate,
                        child: Text(context.l10n.studioDraftDuplicate),
                      ),
                      PopupMenuItem(
                        value: _DraftCardAction.delete,
                        child: Text(context.l10n.commonDelete),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                templateName,
                style: context.appTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                context.l10n.studioDraftUpdated(draft.updatedAt),
                style: context.appTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (draft.notes.isNotEmpty) ...[
                const VGap.tiny(),
                Text(
                  draft.notes,
                  style: context.appTypography.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  const _DraftsEmptyState({required this.documentNoun, required this.onNewCv});

  final String documentNoun;
  final VoidCallback onNewCv;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      // The one placeholder in the app that gets the brand mark: it is the
      // first thing a new user sees, and there is nothing else on the page
      // to carry the product. Every other empty state keeps its icon.
      graphic: BrandMark(color: context.appPalette.placeholder),
      icon: RemixIcons.file_text_line,
      title: context.l10n.studioDraftsEmptyTitle(documentNoun),
      message: context.l10n.studioDraftsEmptyBody(documentNoun),
      actions: [
        FilledButton(
          onPressed: onNewCv,
          child: Text(context.l10n.studioNewDraftTitle(documentNoun)),
        ),
      ],
    );
  }
}
