import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/ai_assistant_config_card.dart';
import 'package:cv_forge/features/studio/widgets/cv_translation_card/cv_translation_card.dart';
import 'package:cv_forge/features/studio/widgets/studio_panel_heading.dart';

/// The persistent left-hand (desktop) / nav step (compact drill-down)
/// column: which sections are visible and in what order, which one the
/// editor pane is showing, the AI Assistant card, and the per-draft section
/// defaults. Short and fixed by design.
class StudioSectionNav extends StatelessWidget {
  const StudioSectionNav({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.appSpacing.paddingPage),
      children: [
        if (viewModel.hasPersistError) ...[
          PersistErrorBanner(
            message: "Your last selection change couldn't be saved.",
            onRetry: viewModel.retryPersist,
          ),
          const VGap.medium(),
        ],
        StudioPanelHeading(context.l10n.studioSectionsTitle),
        const VGap.tiny(),
        _SectionList(viewModel: viewModel),
        const VGap.medium(),
        // The matching "save this arrangement as my default" button used
        // to sit above this one. Authoring the default now happens in the
        // Vault's CV defaults panel, alongside the default region,
        // language and template — see `DocumentDefaults`. This row stays,
        // because discarding *this draft's* customisation is a fact about
        // the draft rather than about the defaults.
        _ResetButton(
          label: context.l10n.studioSectionsResetDefault,
          onPressed: viewModel.resetSectionSettings,
        ),
        // The wording counterpart, and the one control that always works:
        // "Undo AI changes" and "Remove translation" each need a snapshot,
        // where this needs only the Vault. Hidden when the draft says
        // nothing the Vault does not, so it appears only when it would do
        // something.
        if (viewModel.hasWordingOverrides)
          _ResetButton(
            label: context.l10n.studioResetWording,
            onPressed: viewModel.resetWordingToVault,
          ),
        const VGap.medium(),
        AiAssistantConfigCard(
          jobDescription: viewModel.targetJobDescription,
          onChanged: viewModel.setTargetJobDescription,
          onClear: viewModel.clearTargetJobDescription,
          canRun:
              viewModel.hasAiAssistantKey && viewModel.hasTargetJobDescription,
          onRun: viewModel.tailorWithAi,
          hasUndo: viewModel.hasAiAssistantUndo,
          onUndo: viewModel.undoAiAssistantChanges,
          hasApiKey: viewModel.hasAiAssistantKey,
          onOpenSettings: viewModel.goToAiAssistantSettings,
        ),
        CvTranslationCard(
          targetLanguage: viewModel.translationTargetLanguage,
          translatedLanguage: viewModel.translatedLanguage,
          isStale: viewModel.isTranslationStale,
          hasApiKey: viewModel.hasAiAssistantKey,
          canRemove: viewModel.hasCvTranslationUndo,
          onRun: viewModel.translateCv,
          onRemove: viewModel.removeTranslation,
          onOpenSettings: viewModel.goToAiAssistantSettings,
        ),
      ],
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final visible = viewModel.sectionOrder
        .where(viewModel.sectionHasData)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pinned above the reorderable list, and deliberately outside it:
        // both print in the name block, so neither has a position to drag
        // to. A row each all the same, because whether either appears is
        // independent of everything else — while the headline and the
        // summary shared an editor, a CV with a headline and no summary
        // could not reach it at all.
        if (viewModel.hasHeadline)
          _NavRow(
            label: context.l10n.studioSectionHeadline,
            included: viewModel.includeHeadline,
            selected: viewModel.isHeadlineOpen,
            onToggle: viewModel.toggleHeadline,
            onTap: viewModel.selectHeadline,
          ),
        if (viewModel.hasWorkAuthorization)
          _NavRow(
            label: context.l10n.studioSectionWorkAuthorization,
            included: viewModel.includeWorkAuthorization,
            selected: viewModel.isWorkAuthorizationOpen,
            onToggle: viewModel.toggleWorkAuthorization,
            onTap: viewModel.selectWorkAuthorization,
          ),
        _buildSections(context, visible),
      ],
    );
  }

  Widget _buildSections(BuildContext context, List<CvSectionType> visible) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: visible.length,
      onReorderItem: (oldIndex, newIndex) =>
          viewModel.reorderSections(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final type = visible[index];
        final selected = viewModel.openSection == type;
        return _NavRow(
          key: ValueKey('section_${type.name}'),
          label: type.displayLabel(context.l10n),
          included: !viewModel.isSectionHidden(type),
          selected: selected,
          onToggle: () => viewModel.toggleSectionHidden(type),
          onTap: () => viewModel.selectSection(type),
          dragIndex: index,
        );
      },
    );
  }
}

/// One of the section nav's two "put this draft back" controls — same
/// shape for both so they read as a pair, differing only in which axis
/// they reset (sections, or wording).
class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          RemixIcons.arrow_go_back_line,
          size: context.appIconSize.tiny,
          color: muted,
        ),
        label: Text(
          label,
          style: context.appTypography.caption.copyWith(color: muted),
        ),
      ),
    );
  }
}

/// One row of the section nav — a visibility checkbox, a tappable label,
/// and a drag handle when the row has somewhere to be dragged to.
///
/// Shared by the sections and by the pinned headline row above them, so
/// the one row that cannot be reordered still looks like the rest of the
/// list rather than like something bolted on. [dragIndex] is null for that
/// row, which is what drops the handle.
class _NavRow extends StatelessWidget {
  const _NavRow({
    super.key,
    required this.label,
    required this.included,
    required this.selected,
    required this.onToggle,
    required this.onTap,
    this.dragIndex,
  });

  final String label;
  final bool included;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // shrinkWrap tap target + compact density — the default 48px tap
        // target left the longest labels ("Professional summary",
        // "Hobbies and interests") no room and forced an ellipsis even at
        // a widened nav column; every pixel here is pixels the label
        // doesn't get.
        Checkbox(
          value: included,
          onChanged: (_) => onToggle(),
          activeColor: Theme.of(context).colorScheme.primary,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const HGap.tiny(),
        Expanded(
          child: Material(
            color: selected
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Colors.transparent,
            borderRadius: BorderRadius.circular(context.appRadius.small),
            child: InkWell(
              borderRadius: BorderRadius.circular(context.appRadius.small),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.appSpacing.paddingTight,
                  vertical: context.appSpacing.paddingTight,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        if (dragIndex case final index?)
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.appSpacing.paddingHairline,
              ),
              child: Icon(
                RemixIcons.draggable,
                color: context.appPalette.placeholder,
                size: context.appIconSize.medium,
              ),
            ),
          )
        else
          // Keeps both kinds of row ending in the same place, so the
          // pinned one doesn't read as misaligned.
          SizedBox(width: context.appIconSize.medium),
      ],
    );
  }
}
