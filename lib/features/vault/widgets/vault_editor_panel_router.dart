import 'package:cv_forge/models/identified_list.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/vault/views/vault/vault_viewmodel.dart';
import 'basics_editor_panel.dart';
import 'bullet_list_editor.dart';
import 'education_editor_panel.dart';
import 'experience_editor_panel.dart';
import 'hobbies_editor_panel.dart';
import 'project_editor_panel.dart';
import 'publication_editor_panel.dart';
import 'skills_editor_panel.dart';

/// Resolves [VaultViewModel.openTarget]/[openId] to the correct editor
/// panel widget. Kept in one place so desktop/tablet/mobile layouts don't
/// each reimplement this switch.
class VaultEditorPanelRouter extends StatelessWidget {
  const VaultEditorPanelRouter({super.key, required this.viewModel});

  final VaultViewModel viewModel;

  /// Builds the shared bullet-callbacks object for whichever entity
  /// [owner] identifies, all routed through the matching
  /// `VaultViewModel` pass-throughs — see `VaultService`'s bullet API for
  /// why one [BulletOwner] parameter replaces four near-identical methods
  /// per action.
  BulletEditorCallbacks _bulletCallbacksFor(BulletOwner owner, String ownerId) {
    switch (owner) {
      case BulletOwner.experience:
        return BulletEditorCallbacks(
          onAdd: () => viewModel.addBullet(ownerId),
          onChanged: (bullet) => viewModel.updateBullet(ownerId, bullet),
          onDelete: (bulletId) => viewModel.deleteBullet(ownerId, bulletId),
          onReorder: (ids) => viewModel.reorderBullets(ownerId, ids),
        );
      case BulletOwner.project:
        return BulletEditorCallbacks(
          onAdd: () => viewModel.addProjectBullet(ownerId),
          onChanged: (bullet) => viewModel.updateProjectBullet(ownerId, bullet),
          onDelete: (bulletId) =>
              viewModel.deleteProjectBullet(ownerId, bulletId),
          onReorder: (ids) => viewModel.reorderProjectBullets(ownerId, ids),
        );
      case BulletOwner.education:
        return BulletEditorCallbacks(
          onAdd: () => viewModel.addEducationBullet(ownerId),
          onChanged: (bullet) =>
              viewModel.updateEducationBullet(ownerId, bullet),
          onDelete: (bulletId) =>
              viewModel.deleteEducationBullet(ownerId, bulletId),
          onReorder: (ids) => viewModel.reorderEducationBullets(ownerId, ids),
        );
      case BulletOwner.publication:
        return BulletEditorCallbacks(
          onAdd: () => viewModel.addPublicationBullet(ownerId),
          onChanged: (bullet) =>
              viewModel.updatePublicationBullet(ownerId, bullet),
          onDelete: (bulletId) =>
              viewModel.deletePublicationBullet(ownerId, bulletId),
          onReorder: (ids) => viewModel.reorderPublicationBullets(ownerId, ids),
        );
    }
  }

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
        final experience = viewModel.vault.experiences.findById(
          viewModel.openId,
          (e) => e.id,
        );
        if (experience == null) return const SizedBox.shrink();
        return ExperienceEditorPanel(
          experience: experience,
          allExperiences: viewModel.vault.experiences,
          skillCategories: viewModel.vault.skillCategories,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateExperience,
          onGroupChanged: (withId) =>
              viewModel.groupExperience(experience.id, withId),
          bulletCallbacks: _bulletCallbacksFor(
            BulletOwner.experience,
            experience.id,
          ),
          startYearError: viewModel.experienceStartYearError(experience.id),
          endYearError: viewModel.experienceEndYearError(experience.id),
          onStartYearChanged: (v) =>
              viewModel.updateExperienceStartYear(experience, v),
          onEndYearChanged: (v) =>
              viewModel.updateExperienceEndYear(experience, v),
        );

      case VaultEditorTarget.project:
        final project = viewModel.vault.projects.findById(
          viewModel.openId,
          (p) => p.id,
        );
        if (project == null) return const SizedBox.shrink();
        return ProjectEditorPanel(
          project: project,
          skillCategories: viewModel.vault.skillCategories,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateProject,
          bulletCallbacks: _bulletCallbacksFor(BulletOwner.project, project.id),
        );

      case VaultEditorTarget.education:
        final education = viewModel.vault.education.findById(
          viewModel.openId,
          (e) => e.id,
        );
        if (education == null) return const SizedBox.shrink();
        return EducationEditorPanel(
          education: education,
          skillCategories: viewModel.vault.skillCategories,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateEducation,
          bulletCallbacks: _bulletCallbacksFor(
            BulletOwner.education,
            education.id,
          ),
          yearError: viewModel.educationYearError(education.id),
          onYearChanged: (v) => viewModel.updateEducationYear(education, v),
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

      case VaultEditorTarget.publication:
        final publication = viewModel.vault.publications.findById(
          viewModel.openId,
          (p) => p.id,
        );
        if (publication == null) return const SizedBox.shrink();
        return PublicationEditorPanel(
          publication: publication,
          skillCategories: viewModel.vault.skillCategories,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updatePublication,
          bulletCallbacks: _bulletCallbacksFor(
            BulletOwner.publication,
            publication.id,
          ),
        );
    }
  }
}
