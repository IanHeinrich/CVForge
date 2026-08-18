import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:flutter/material.dart';

import '../views/vault/vault_viewmodel.dart';
import 'basics_editor_card.dart';
import 'education_editor_panel.dart';
import 'experience_editor_panel.dart';
import 'hobbies_editor_section.dart';
import 'skills_editor_section.dart';

/// Resolves [VaultViewModel.openTarget]/[openId] to the correct editor
/// panel widget. Kept in one place so desktop/tablet/mobile layouts don't
/// each reimplement this switch.
class VaultEditorPanelRouter extends StatelessWidget {
  const VaultEditorPanelRouter({super.key, required this.viewModel});

  final VaultViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    switch (viewModel.openTarget) {
      case VaultEditorTarget.none:
        return const SizedBox.shrink();

      case VaultEditorTarget.basics:
        return BasicsEditorPanel(
          basics: viewModel.vault.basics,
          referencesNote: viewModel.vault.referencesNote,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateBasics,
          onReferencesChanged: viewModel.updateReferencesNote,
          onAddLink: viewModel.addProfileLink,
          onLinkChanged: viewModel.updateProfileLink,
          onLinkDeleted: viewModel.deleteProfileLink,
        );

      case VaultEditorTarget.experience:
        final experience = _findExperience(viewModel);
        if (experience == null) return const SizedBox.shrink();
        final experienceId = experience.id;
        return ExperienceEditorPanel(
          experience: experience,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateExperience,
          onAddBullet: () => viewModel.addBullet(experienceId),
          onBulletChanged: (bullet) =>
              viewModel.updateBullet(experienceId, bullet),
          onBulletDeleted: (bulletId) =>
              viewModel.deleteBullet(experienceId, bulletId),
          onBulletsReordered: (ids) =>
              viewModel.reorderBullets(experienceId, ids),
        );

      case VaultEditorTarget.education:
        final education = _findEducation(viewModel);
        if (education == null) return const SizedBox.shrink();
        return EducationEditorPanel(
          education: education,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateEducation,
        );

      case VaultEditorTarget.skills:
        return SkillsEditorPanel(
          categories: viewModel.vault.skillCategories,
          onClose: viewModel.closeEditor,
          onAddCategory: () => viewModel.addSkillCategory('New category'),
          onUpdateCategory: viewModel.updateSkillCategory,
          onDeleteCategory: viewModel.deleteSkillCategory,
          onAddSkill: (categoryId) => viewModel.addSkill(categoryId, ''),
          onUpdateSkill: viewModel.updateSkill,
          onDeleteSkill: viewModel.deleteSkill,
        );

      case VaultEditorTarget.hobbies:
        return HobbiesEditorPanel(
          hobbies: viewModel.vault.hobbies,
          onClose: viewModel.closeEditor,
          onAdd: () => viewModel.addHobby(''),
          onChanged: viewModel.updateHobby,
          onDelete: viewModel.deleteHobby,
        );
    }
  }

  Experience? _findExperience(VaultViewModel viewModel) {
    for (final e in viewModel.vault.experiences) {
      if (e.id == viewModel.openId) return e;
    }
    return null;
  }

  Education? _findEducation(VaultViewModel viewModel) {
    for (final e in viewModel.vault.education) {
      if (e.id == viewModel.openId) return e;
    }
    return null;
  }
}
