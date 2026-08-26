import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/entity_bullet_section_editor.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';

/// The [CvSectionType.experience] editor.
class ExperienceSectionEditor extends StatelessWidget {
  const ExperienceSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) => EntityBulletSectionEditor(
    title: context.l10n.vaultSectionExperience,
    items: viewModel.experiences,
    untitledLabel: context.l10n.vaultUntitledRole,
    idOf: (e) => e.id,
    titleOf: viewModel.roleText,
    // The employer stays the row's subtitle rather than becoming another
    // field row beneath it: two positions can share a role title, and
    // this is what tells them apart in a collapsed list. It gets a row of
    // its own once it's editable, and loses the subtitle then.
    subtitleOf: (e) => e.company,
    bulletsOf: (e) => e.bullets,
    unselectedCount: viewModel.unselectedExperiences.length,
    selectedCount: viewModel.selectedExperiences.length,
    onAddAll: viewModel.addAllExperiences,
    onRemoveAll: viewModel.removeAllExperiences,
    isIncluded: (e) => viewModel.isExperienceIncluded(e.id),
    onToggle: viewModel.toggleExperience,
    onAddAllBullets: viewModel.addAllExperienceBullets,
    onRemoveAllBullets: viewModel.removeAllExperienceBullets,
    isBulletIncluded: (e, b) =>
        viewModel.isExperienceBulletIncluded(e.id, b.id),
    onToggleBullet: viewModel.toggleExperienceBullet,
    bulletText: viewModel.bulletText,
    hasBulletOverride: viewModel.hasBulletOverride,
    onSetBulletOverride: viewModel.setBulletOverride,
    onRevertBulletOverride: viewModel.revertBulletOverride,
    titleFieldOf: (e) => TailorableField(
      hasOverride: viewModel.hasRoleOverride(e.id),
      effectiveText: viewModel.roleText(e),
      vaultText: e.role,
      fieldLabel: context.l10n.studioFieldRole,
      onChanged: (value) => viewModel.setRoleOverride(e, value),
      onRevert: () => viewModel.revertRoleOverride(e.id),
    ),
    fieldsOf: (e) => [
      TailorableField(
        hasOverride: viewModel.hasExperienceLocationOverride(e.id),
        effectiveText: viewModel.experienceLocationText(e),
        vaultText: e.location,
        fieldLabel: context.l10n.studioFieldLocation,
        emptyMessage: context.l10n.studioNoLocation,
        onChanged: (value) => viewModel.setExperienceLocationOverride(e, value),
        onRevert: () => viewModel.revertExperienceLocationOverride(e.id),
      ),
    ],
  );
}
