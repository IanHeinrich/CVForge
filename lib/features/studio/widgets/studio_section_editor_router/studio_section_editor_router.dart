import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/education_section_editor/education_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/experience_section_editor/experience_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/hobbies_section_editor/hobbies_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/projects_section_editor/projects_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/publications_section_editor/publications_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/references_section_editor/references_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/skills_section_editor/skills_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/sections/summary_section_editor/summary_section_editor.dart';

/// Resolves [StudioViewModel.openSection] to the correct section editor
/// widget. Kept in one place so desktop/compact layouts don't each
/// reimplement this switch — same rationale as `VaultEditorPanelRouter`.
class StudioSectionEditorRouter extends StatelessWidget {
  const StudioSectionEditorRouter({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final type = viewModel.openSection;
    // A hidden/no-data section can't normally reach here — the nav only
    // ever selects a visible section, and `toggleSectionHidden` clears the
    // selection the moment it hides the one that's open — but a null
    // `openSection` and a stale one both read as "nothing to show", so one
    // empty state covers both rather than trusting that invariant to hold
    // everywhere forever.
    if (type == null || !viewModel.sectionHasData(type)) {
      return AppEmptyState(
        icon: RemixIcons.list_check_2,
        title: context.l10n.studioNoSectionSelectedTitle,
        message: context.l10n.studioNoSectionSelectedBody,
      );
    }

    final editor = switch (type) {
      CvSectionType.summary => SummarySectionEditor(viewModel: viewModel),
      CvSectionType.skills => SkillsSectionEditor(viewModel: viewModel),
      CvSectionType.experience => ExperienceSectionEditor(viewModel: viewModel),
      CvSectionType.projects => ProjectsSectionEditor(viewModel: viewModel),
      CvSectionType.education => EducationSectionEditor(viewModel: viewModel),
      CvSectionType.hobbies => HobbiesSectionEditor(viewModel: viewModel),
      CvSectionType.references => ReferencesSectionEditor(viewModel: viewModel),
      CvSectionType.publications => PublicationsSectionEditor(
        viewModel: viewModel,
      ),
    };

    // A distinct `PageStorageKey` per section so switching sections and
    // back restores each one's own scroll offset rather than bleeding a
    // stale one in from whichever section was open before it.
    return SingleChildScrollView(
      key: PageStorageKey('studio_section_editor_${type.name}'),
      padding: EdgeInsets.all(context.appSpacing.paddingPage),
      child: editor,
    );
  }
}
