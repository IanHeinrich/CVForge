import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/widgets/common/app_summary_card.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/drafts_list/drafts_list_viewmodel.dart';

/// The Drafts landing page's content: every saved CV as a card, plus a
/// "New CV" action. Kept as one widget (no empty-state/populated split
/// via separate files) since there's nothing here complex enough to
/// warrant it — see [_DraftsEmptyState] below for the one branch.
class DraftsCardList extends StatelessWidget {
  const DraftsCardList({super.key, required this.viewModel});

  final DraftsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (viewModel.isEmpty)
          _DraftsEmptyState(onNewCv: viewModel.createDraft)
        else
          ListView(
            padding: const EdgeInsets.fromLTRB(
              kdPaddingPage,
              kdPaddingPage,
              kdPaddingPage,
              96,
            ),
            children: [
              if (viewModel.hasPersistError) ...[
                PersistErrorBanner(
                  message: "Your last change couldn't be saved.",
                  onRetry: viewModel.retryPersist,
                ),
                verticalSpaceMedium,
              ],
              for (final draft in viewModel.drafts)
                _DraftCard(
                  draft: draft,
                  templateName: viewModel.templateName(draft.templateId),
                  onOpen: () => viewModel.openDraft(draft.id),
                  onEdit: () => viewModel.editDraft(draft),
                  onDuplicate: () => viewModel.duplicateDraft(draft),
                  onDelete: () => viewModel.deleteDraft(draft),
                ),
            ],
          ),
        Positioned(
          right: kdPaddingPage,
          bottom: kdPaddingPage,
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

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.templateName,
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final CvDraft draft;
  final String templateName;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppSummaryCard(
      title: draft.name.isEmpty ? 'Untitled CV' : draft.name,
      subtitle: '$templateName · Updated ${_formatDate(draft.updatedAt)}',
      notes: draft.notes,
      onTap: onOpen,
      leading: const Icon(RemixIcons.file_text_line, color: kcLightGrey),
      actions: [
        PopupMenuButton<_DraftCardAction>(
          icon: const Icon(RemixIcons.more_2_line, color: kcLightGrey),
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

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
