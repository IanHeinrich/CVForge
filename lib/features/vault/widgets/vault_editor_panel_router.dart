import 'package:flutter/material.dart';

import '../views/vault/vault_viewmodel.dart';
import 'basics_editor_panel.dart';
import 'education_editor_panel.dart';
import 'experience_editor_panel.dart';
import 'hobbies_editor_panel.dart';
import 'skills_editor_panel.dart';

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
        final experience = _findById(
          viewModel.vault.experiences,
          viewModel.openId,
          (e) => e.id,
        );
        if (experience == null) return const SizedBox.shrink();
        final experienceId = experience.id;
        return ExperienceEditorPanel(
          experience: experience,
          allExperiences: viewModel.vault.experiences,
          skillCategories: viewModel.vault.skillCategories,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateExperience,
          onGroupChanged: (withId) =>
              viewModel.groupExperience(experienceId, withId),
          onAddBullet: () => viewModel.addBullet(experienceId),
          onBulletChanged: (bullet) =>
              viewModel.updateBullet(experienceId, bullet),
          onBulletDeleted: (bulletId) =>
              viewModel.deleteBullet(experienceId, bulletId),
          onBulletsReordered: (ids) =>
              viewModel.reorderBullets(experienceId, ids),
        );

      case VaultEditorTarget.education:
        final education = _findById(
          viewModel.vault.education,
          viewModel.openId,
          (e) => e.id,
        );
        if (education == null) return const SizedBox.shrink();
        return EducationEditorPanel(
          education: education,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateEducation,
        );

      case VaultEditorTarget.skills:
        return SkillsEditorPanel(
          categories: viewModel.vault.skillCategories,
          experiences: viewModel.vault.experiences,
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

  /// Finds the item whose [idOf] matches [id], or `null` if it's been
  /// deleted since the panel was opened (or [id] itself is `null`).
  T? _findById<T>(List<T> items, String? id, String Function(T item) idOf) {
    for (final item in items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }
}
