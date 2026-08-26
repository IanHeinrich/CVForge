import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/education_section_editor/education_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/headline_editor/headline_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/experience_section_editor/experience_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/hobbies_section_editor/hobbies_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/languages_section_editor/languages_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/projects_section_editor/projects_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/publications_section_editor/publications_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/references_section_editor/references_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/skills_section_editor/skills_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/summary_section_editor/summary_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/work_authorization_editor/work_authorization_editor.dart';

/// Resolves [StudioViewModel.openSection] to the correct section editor
/// widget. Kept in one place so desktop/compact layouts don't each
/// reimplement this switch — same rationale as `VaultEditorPanelRouter`.
class StudioSectionEditorRouter extends StatelessWidget {
  const StudioSectionEditorRouter({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final Widget editor;

    /// Distinguishes this editor's scroll offset from every other one's —
    /// `CvSectionType.name` for a section, and `StudioHeaderField.name`
    /// for the two fields that are not sections. The two enums share no
    /// case names, so one namespace is safe (see
    /// [StudioViewModel.openHeaderField]).
    final String storageKey;

    final headerField = viewModel.openHeaderField;
    if (headerField != null) {
      editor = switch (headerField) {
        StudioHeaderField.headline => HeadlineEditor(viewModel: viewModel),
        StudioHeaderField.workAuthorization => WorkAuthorizationEditor(
          viewModel: viewModel,
        ),
      };
      storageKey = headerField.name;
    } else {
      final type = viewModel.openSection;
      // A hidden/no-data section can't normally reach here — the nav only
      // ever selects a visible section, and `toggleSectionHidden` clears
      // the selection the moment it hides the one that's open — but a
      // null `openSection` and a stale one both read as "nothing to
      // show", so one empty state covers both rather than trusting that
      // invariant to hold everywhere forever.
      if (type == null || !viewModel.sectionHasData(type)) {
        return AppEmptyState(
          icon: RemixIcons.list_check_2,
          title: context.l10n.studioNoSectionSelectedTitle,
          message: context.l10n.studioNoSectionSelectedBody,
        );
      }

      editor = switch (type) {
        CvSectionType.summary => SummarySectionEditor(viewModel: viewModel),
        CvSectionType.skills => SkillsSectionEditor(viewModel: viewModel),
        CvSectionType.experience => ExperienceSectionEditor(
          viewModel: viewModel,
        ),
        CvSectionType.projects => ProjectsSectionEditor(viewModel: viewModel),
        CvSectionType.education => EducationSectionEditor(viewModel: viewModel),
        CvSectionType.hobbies => HobbiesSectionEditor(viewModel: viewModel),
        CvSectionType.languages => LanguagesSectionEditor(viewModel: viewModel),
        CvSectionType.references => ReferencesSectionEditor(
          viewModel: viewModel,
        ),
        CvSectionType.publications => PublicationsSectionEditor(
          viewModel: viewModel,
        ),
      };
      storageKey = type.name;
    }

    // Every editor is wrapped here rather than padding itself, so the
    // two header-field editors — structurally identical to the summary's,
    // one card in a column — cannot end up flush against the pane edge
    // while the summary sits inset. The headline used to, by returning
    // early.
    //
    // A distinct `PageStorageKey` per editor so switching and coming back
    // restores each one's own scroll offset rather than bleeding a stale
    // one in from whatever was open before it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TailoringPaneNote(),
        Expanded(
          child: SingleChildScrollView(
            key: PageStorageKey('studio_section_editor_$storageKey'),
            padding: EdgeInsets.all(context.appSpacing.paddingPage),
            child: editor,
          ),
        ),
      ],
    );
  }
}

/// Says once, for the whole pane, which layer everything in it edits.
///
/// This used to live inside each open inline editor, which meant it
/// printed once per editor when several were open at once, and said
/// nothing at all when none were — exactly backwards, since the moment
/// you most need to know whether you're editing the Vault or this CV is
/// before you start typing. Pinned above the scroll view rather than
/// inside it so it can't scroll away from the rows it describes.
class _TailoringPaneNote extends StatelessWidget {
  const _TailoringPaneNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(
        context.appSpacing.paddingPage,
        context.appSpacing.paddingTight,
        context.appSpacing.paddingPage,
        context.appSpacing.paddingTight,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            RemixIcons.safe_line,
            size: context.appIconSize.small,
            color: context.appPalette.placeholder,
          ),
          const HGap.small(),
          Expanded(
            child: Text(
              context.l10n.studioTailoringPaneNote,
              style: context.appTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
