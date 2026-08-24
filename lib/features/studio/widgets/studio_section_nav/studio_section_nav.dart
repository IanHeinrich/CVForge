import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
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
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () async {
              await viewModel.saveSectionSettingsAsDefault();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.studioSectionsSavedDefault),
                ),
              );
            },
            child: Text(context.l10n.studioSectionsSaveDefault),
          ),
        ),
        const VGap.small(),
        // A quieter, visually distinct row rather than a second purple
        // text button next to "Save" — this one discards the current
        // draft's order/hidden-section customisation, "Save" doesn't.
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: viewModel.resetSectionSettings,
            icon: Icon(
              RemixIcons.arrow_go_back_line,
              size: context.appIconSize.tiny,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(
              context.l10n.studioSectionsResetDefault,
              style: context.appTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
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
        return Row(
          key: ValueKey('section_${type.name}'),
          children: [
            // shrinkWrap tap target + compact density — the default 48px
            // tap target left the longest labels ("Professional summary",
            // "Hobbies and interests") no room and forced an ellipsis
            // even at a widened nav column; every pixel here is pixels
            // the label doesn't get.
            Checkbox(
              value: !viewModel.isSectionHidden(type),
              onChanged: (_) => viewModel.toggleSectionHidden(type),
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
                  onTap: () => viewModel.selectSection(type),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.appSpacing.paddingTight,
                      vertical: context.appSpacing.paddingTight,
                    ),
                    child: Text(
                      type.displayLabel(context.l10n),
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
            ),
          ],
        );
      },
    );
  }
}
