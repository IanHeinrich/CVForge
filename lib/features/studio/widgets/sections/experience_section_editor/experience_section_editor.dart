import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/entity_bullet_section_editor.dart';

/// The [CvSectionType.experience] editor.
class ExperienceSectionEditor extends StatelessWidget {
  const ExperienceSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) => EntityBulletSectionEditor(
    title: 'Work history',
    items: viewModel.experiences,
    untitledLabel: 'Untitled role',
    idOf: (e) => e.id,
    titleOf: (e) => e.role,
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
  );
}
