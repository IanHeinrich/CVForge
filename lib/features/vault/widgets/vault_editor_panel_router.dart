import 'package:cv_forge/models/identified_list.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/vault/views/vault/vault_viewmodel.dart';
import 'basics_editor_panel.dart';
import 'document_defaults_editor_panel/document_defaults_editor_panel.dart';
import 'bullet_list_editor.dart';
import 'education_editor_panel.dart';
import 'experience_editor_panel.dart';
import 'hobbies_editor_panel.dart';
import 'languages_editor_panel.dart';
import 'project_editor_panel.dart';
import 'publication_editor_panel.dart';
import 'skills_editor_panel.dart';

/// Resolves [VaultViewModel.openTarget]/[openId] to the correct editor
/// panel widget. Kept in one place so desktop/tablet/mobile layouts don't
/// each reimplement this switch.
class VaultEditorPanelRouter extends StatelessWidget {
  const VaultEditorPanelRouter({super.key, required this.viewModel});

  final VaultViewModel viewModel;

  /// The bullet callbacks for whichever entity [owner]/[ownerId] identify
  /// — see `VaultService`'s bullet API for why the owner travels as a
  /// parameter rather than picking one of four methods per action.
  BulletEditorCallbacks _bulletCallbacksFor(
    BulletOwner owner,
    String ownerId,
  ) => BulletEditorCallbacks(
    onAdd: () => viewModel.addBullet(owner, ownerId),
    onChanged: (bullet) => viewModel.updateBullet(owner, ownerId, bullet),
    onDelete: (bulletId) => viewModel.deleteBullet(owner, ownerId, bulletId),
    onReorder: (ids) => viewModel.reorderBullets(owner, ownerId, ids),
  );

  @override
  Widget build(BuildContext context) {
    switch (viewModel.openTarget) {
      case VaultEditorTarget.none:
        return const SizedBox.shrink();

      case VaultEditorTarget.documentDefaults:
        return DocumentDefaultsEditorPanel(
          defaults: viewModel.documentDefaults,
          documentNoun:
              viewModel.documentDefaults.region.preset.documentNoun.name,
          templateId: viewModel.defaultTemplate.id,
          sectionOrder: viewModel.defaultSectionOrder,
          isSectionHidden: viewModel.isDefaultSectionHidden,
          onClose: viewModel.closeEditor,
          onChangeRegion: viewModel.openDefaultRegionPicker,
          onChangeTemplate: viewModel.openDefaultTemplatePicker,
          onLanguageChanged: viewModel.setDocumentLanguage,
          onReorderSections: viewModel.reorderDefaultSections,
          onToggleSectionHidden: viewModel.toggleDefaultSectionHidden,
          includeHeadline: viewModel.includeDefaultHeadline,
          onToggleHeadline: viewModel.toggleDefaultHeadline,
        );

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
          onPickPhoto: viewModel.pickPhoto,
          onRemovePhoto: viewModel.removePhoto,
          photoBusy: viewModel.photoBusy,
          photoError: viewModel.photoError,
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
          onUpdateSkill: viewModel.updateSkill,
          onAddSkill: viewModel.addSkill,
          onAddCategory: viewModel.addSkillCategory,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateExperience,
          onGroupChanged: (withId) =>
              viewModel.groupExperience(experience.id, withId),
          bulletCallbacks: _bulletCallbacksFor(
            BulletOwner.experience,
            experience.id,
          ),
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
          onUpdateSkill: viewModel.updateSkill,
          onAddSkill: viewModel.addSkill,
          onAddCategory: viewModel.addSkillCategory,
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
          onUpdateSkill: viewModel.updateSkill,
          onAddSkill: viewModel.addSkill,
          onAddCategory: viewModel.addSkillCategory,
          onClose: viewModel.closeEditor,
          onChanged: viewModel.updateEducation,
          bulletCallbacks: _bulletCallbacksFor(
            BulletOwner.education,
            education.id,
          ),
        );

      case VaultEditorTarget.skills:
        return SkillsEditorPanel(
          categories: viewModel.vault.skillCategories,
          experiences: viewModel.vault.experiences,
          projects: viewModel.vault.projects,
          education: viewModel.vault.education,
          publications: viewModel.vault.publications,
          onClose: viewModel.closeEditor,
          // Deliberately blank, not a "New category" placeholder: an
          // unnamed category is then indistinguishable from any other
          // unfilled entry and gets dropped on write like the rest of
          // them — see `CvVaultPruning.withoutBlankEntries`.
          onAddCategory: () => viewModel.addSkillCategory(''),
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

      case VaultEditorTarget.languages:
        return LanguagesEditorPanel(
          languages: viewModel.vault.languages,
          onClose: viewModel.closeEditor,
          // Blank, like a new skill category: an unnamed language is
          // indistinguishable from any other unfilled entry and gets
          // dropped on write with the rest of them — see
          // `CvVaultPruning.withoutBlankEntries`.
          onAdd: () => viewModel.addLanguage(''),
          onChanged: viewModel.updateLanguage,
          onDelete: viewModel.deleteLanguage,
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
          onUpdateSkill: viewModel.updateSkill,
          onAddSkill: viewModel.addSkill,
          onAddCategory: viewModel.addSkillCategory,
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
