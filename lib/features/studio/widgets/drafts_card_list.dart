import 'dart:typed_data';

import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/common/relative_time.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/widgets/common/brand_mark/brand_mark.dart';
import 'package:cv_forge/ui/widgets/common/pdf_page_thumbnail.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/drafts_list/drafts_list_viewmodel.dart';

/// The Drafts landing page's content: every saved CV as a thumbnail card —
/// the same wrapping-grid-of-page-previews shape as
/// `TemplateGalleryDialog`, so picking a CV to open reads the same as
/// picking a template to switch to — plus a "New CV" action, a search
/// field to narrow the grid down by name/notes/template, and a sort
/// control. Kept as one widget (no empty-state/populated split via
/// separate files) since there's nothing here complex enough to warrant it
/// — see [_DraftsEmptyState] and [_NoSearchResults] below for the two
/// branches.
///
/// Stateful only to own the search field's [TextEditingController]: the
/// query itself lives on the ViewModel, but both the field's own clear
/// button and [_NoSearchResults]' "Clear search" action have to reset the
/// visible text, so the controller can't live inside the field widget.
class DraftsCardList extends StatefulWidget {
  const DraftsCardList({super.key, required this.viewModel});

  final DraftsListViewModel viewModel;

  @override
  State<DraftsCardList> createState() => _DraftsCardListState();
}

class _DraftsCardListState extends State<DraftsCardList> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.viewModel.setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    if (viewModel.isEmpty) {
      return _DraftsEmptyState(
        documentNoun: viewModel.documentNoun,
        documentNounPlural: viewModel.documentNounPlural,
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
            _fabScrollClearance,
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
              // Wrap, not Row — on a phone-width viewport the search field
              // and the sort control together are wider than the page, and
              // stacking them is better than overflowing.
              Wrap(
                spacing: context.appSpacing.gapSmall,
                runSpacing: context.appSpacing.gapSmall,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _searchFieldMaxWidth,
                    ),
                    child: _DraftsSearchField(
                      controller: _searchController,
                      hintText: 'Search ${viewModel.documentNounPlural}…',
                      onChanged: viewModel.setQuery,
                      onClear: _clearSearch,
                    ),
                  ),
                  _SortControl(
                    sortOrder: viewModel.sortOrder,
                    onChanged: viewModel.setSortOrder,
                  ),
                ],
              ),
              const VGap.medium(),
              if (viewModel.hasNoSearchResults)
                _NoSearchResults(
                  documentNounPlural: viewModel.documentNounPlural,
                  onClearSearch: _clearSearch,
                )
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
                        displayName: viewModel.displayName(draft),
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
            label: Text('New ${viewModel.documentNoun}'),
          ),
        ),
      ],
    );
  }
}

/// Bottom scroll padding, so the last row of cards can be scrolled clear of
/// the "New CV" FAB stacked over it rather than sitting permanently
/// underneath. A layout constant tied to the FAB's own height, not a
/// spacing value — it stays local for the same reason
/// `RegionGalleryDialog._twoPaneMinWidth` does.
const _fabScrollClearance = 96.0;

/// The search field, with a clear button that appears once there's
/// something to clear. Driven by a [ValueListenableBuilder] on the
/// controller rather than the ViewModel's query, which is trimmed and
/// lowercased — typing a single space would otherwise leave the field
/// looking empty while holding text.
class _DraftsSearchField extends StatelessWidget {
  const _DraftsSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          prefixIcon: Icon(
            RemixIcons.search_line,
            size: context.appIconSize.medium,
          ),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    RemixIcons.close_line,
                    size: context.appIconSize.medium,
                  ),
                  tooltip: 'Clear search',
                  onPressed: onClear,
                ),
        ),
      ),
    );
  }
}

/// The sort control: a menu rather than a `SegmentedButton`, so adding a
/// third order later doesn't have to find horizontal room beside the
/// search field. Labelled with the active order — the point of a sort
/// control you can't see the state of is lost.
class _SortControl extends StatelessWidget {
  const _SortControl({required this.sortOrder, required this.onChanged});

  final DraftSortOrder sortOrder;
  final ValueChanged<DraftSortOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DraftSortOrder>(
      initialValue: sortOrder,
      onSelected: onChanged,
      tooltip: 'Sort',
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final order in DraftSortOrder.values)
          PopupMenuItem(value: order, child: Text(order.label)),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.paddingTight,
          vertical: context.appSpacing.paddingTight,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              RemixIcons.sort_desc,
              size: context.appIconSize.medium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const HGap.tiny(),
            Text(
              sortOrder.label,
              style: context.appTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Icon(
              RemixIcons.arrow_down_s_line,
              size: context.appIconSize.medium,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of the grid once a search matches nothing, distinct from
/// [_DraftsEmptyState] — there are drafts, just none matching, so this
/// offers clearing the search rather than creating a first one.
class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    required this.documentNounPlural,
    required this.onClearSearch,
  });

  final String documentNounPlural;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.appSpacing.paddingPage),
      child: Column(
        children: [
          Text(
            'No $documentNounPlural match your search.',
            style: context.appTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const VGap.tiny(),
          TextButton(
            onPressed: onClearSearch,
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }
}

/// Smaller than `TemplateGalleryDialog._cardWidth` — a template card's own
/// description and tags need the extra width, but a CV card is mostly its
/// thumbnail, and a full CVs page tends to hold more drafts at once than a
/// template gallery dialog holds templates.
const _cardWidth = 200.0;

/// Caps the search field's width so it doesn't stretch to fill the grid's
/// full row width on wide monitors — matches
/// `StudioSkillSelector`'s own filter field.
const _searchFieldMaxWidth = 320.0;

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.displayName,
    required this.templateName,
    required this.thumbnailFuture,
    required this.pageAspectRatio,
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final CvDraft draft;

  /// Resolved by the ViewModel, not here, so the untitled fallback the card
  /// shows is the same string [DraftSortOrder.nameAtoZ] sorts on.
  final String displayName;
  final String templateName;
  final Future<Uint8List> thumbnailFuture;
  final double pageAspectRatio;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
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
                      displayName,
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
                      color: muted,
                      size: context.appIconSize.medium,
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
              // The flags lead a two-line block rather than sitting inline
              // with the template name: `RegionFlagStack`'s own doc rules
              // out the caption sizes an inline mark would use, since a
              // four-country region renders as a 2x2 grid that turns to
              // mush much below `appIconSize.large`.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                    message: draft.region.preset.displayName,
                    child: RegionFlagStack(
                      flags: draft.region.preset.flags,
                      size: context.appIconSize.large,
                    ),
                  ),
                  const HGap.small(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          templateName,
                          style: context.appTypography.caption.copyWith(
                            color: muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Relative, matching `BackupSettingsCard` and
                        // `DriveSyncIndicator` — with the exact timestamp
                        // kept on the tooltip, since "3 days ago" is the
                        // more useful default but not the more precise
                        // one.
                        //
                        // No line cap, unlike the template name above it:
                        // when a CV was last touched is the one piece of
                        // metadata that reliably tells two drafts apart,
                        // so it wraps rather than ellipsising. Every
                        // phrasing fits the width left beside the flag
                        // today; this is what stops a longer one added
                        // later from silently clipping instead.
                        Tooltip(
                          message: _absoluteDateTime(draft.updatedAt),
                          child: Text(
                            'Updated ${formatRelativeTime(draft.updatedAt)}',
                            style: context.appTypography.caption.copyWith(
                              color: muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // `targetJobDescription` is persisted but was invisible here,
              // leaving nothing to distinguish a CV tailored to a specific
              // ad from a generic one. Named in full: a bare "Tailored"
              // doesn't say tailored to what.
              if (draft.targetJobDescription?.isNotEmpty ?? false) ...[
                const VGap.tiny(),
                Row(
                  children: [
                    Icon(
                      RemixIcons.briefcase_line,
                      size: context.appIconSize.tiny,
                      color: muted,
                    ),
                    const HGap.tiny(),
                    Expanded(
                      child: Text(
                        'Tailored to a job ad',
                        style: context.appTypography.caption.copyWith(
                          color: muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (draft.notes.isNotEmpty) ...[
                const VGap.tiny(),
                Text(
                  draft.notes,
                  style: context.appTypography.caption.copyWith(
                    color: muted,
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
  const _DraftsEmptyState({
    required this.documentNoun,
    required this.documentNounPlural,
    required this.onNewCv,
  });

  final String documentNoun;
  final String documentNounPlural;
  final VoidCallback onNewCv;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      // The one placeholder in the app that gets the brand mark: it is the
      // first thing a new user sees, and there is nothing else on the page
      // to carry the product. Every other empty state keeps its icon.
      graphic: BrandMark(color: context.appPalette.placeholder),
      icon: RemixIcons.file_text_line,
      title: 'No $documentNounPlural yet',
      message:
          'Create a $documentNoun to start tailoring your Vault for a '
          'specific application.',
      actions: [
        FilledButton(onPressed: onNewCv, child: Text('New $documentNoun')),
      ],
    );
  }
}

/// The precision [formatRelativeTime] deliberately drops, kept on the
/// "Updated" line's tooltip.
String _absoluteDateTime(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year} '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';
