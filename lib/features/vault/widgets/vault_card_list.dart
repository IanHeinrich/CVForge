import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:flutter/material.dart';

import '../views/vault/vault_viewmodel.dart';
import 'basics_editor_card.dart';
import 'education_list_section.dart';
import 'experience_list_section.dart';
import 'hobbies_editor_card.dart';
import 'project_list_section.dart';
import 'skills_editor_card.dart';

/// The main scrolling list of collapsed entity summary cards. Shared by
/// every breakpoint so desktop/tablet/mobile can't drift on which
/// sections exist or their order.
class VaultCardList extends StatelessWidget {
  const VaultCardList({super.key, required this.viewModel});

  final VaultViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vault = viewModel.vault;

    return ListView(
      padding: const EdgeInsets.all(kdPaddingPage),
      children: [
        if (viewModel.hasPersistError) ...[
          PersistErrorBanner(
            message: "Your last change couldn't be saved.",
            onRetry: viewModel.retryPersist,
          ),
          verticalSpaceMedium,
        ],
        BasicsEditorCard(
          basics: vault.basics,
          selected: viewModel.openTarget == VaultEditorTarget.basics,
          onTap: viewModel.openBasicsEditor,
        ),
        verticalSpaceMedium,
        ExperienceListSection(
          experiences: vault.experiences,
          openId: viewModel.openTarget == VaultEditorTarget.experience
              ? viewModel.openId
              : null,
          onOpen: viewModel.openExperienceEditor,
          onAdd: viewModel.addExperience,
          onDelete: viewModel.deleteExperience,
        ),
        verticalSpaceMedium,
        ProjectListSection(
          projects: vault.projects,
          openId: viewModel.openTarget == VaultEditorTarget.project
              ? viewModel.openId
              : null,
          onOpen: viewModel.openProjectEditor,
          onAdd: viewModel.addProject,
          onDelete: viewModel.deleteProject,
        ),
        verticalSpaceMedium,
        SkillsEditorCard(
          categories: vault.skillCategories,
          selected: viewModel.openTarget == VaultEditorTarget.skills,
          onTap: viewModel.openSkillsEditor,
        ),
        verticalSpaceMedium,
        EducationListSection(
          education: vault.education,
          openId: viewModel.openTarget == VaultEditorTarget.education
              ? viewModel.openId
              : null,
          onOpen: viewModel.openEducationEditor,
          onAdd: viewModel.addEducation,
          onDelete: viewModel.deleteEducation,
        ),
        verticalSpaceMedium,
        HobbiesEditorCard(
          hobbies: vault.hobbies,
          selected: viewModel.openTarget == VaultEditorTarget.hobbies,
          onTap: viewModel.openHobbiesEditor,
        ),
      ],
    );
  }
}
