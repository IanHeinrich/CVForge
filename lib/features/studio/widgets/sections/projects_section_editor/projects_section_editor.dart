import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/entity_bullet_section_editor.dart';

/// The [CvSectionType.projects] editor.
class ProjectsSectionEditor extends StatelessWidget {
  const ProjectsSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) => EntityBulletSectionEditor(
    title: 'Projects',
    items: viewModel.projects,
    untitledLabel: 'Untitled project',
    idOf: (p) => p.id,
    titleOf: (p) => p.title,
    subtitleOf: (p) => p.link,
    bulletsOf: (p) => p.bullets,
    unselectedCount: viewModel.unselectedProjects.length,
    selectedCount: viewModel.selectedProjects.length,
    onAddAll: viewModel.addAllProjects,
    onRemoveAll: viewModel.removeAllProjects,
    isIncluded: (p) => viewModel.isProjectIncluded(p.id),
    onToggle: viewModel.toggleProject,
    onAddAllBullets: viewModel.addAllProjectBullets,
    onRemoveAllBullets: viewModel.removeAllProjectBullets,
    isBulletIncluded: (p, b) => viewModel.isProjectBulletIncluded(p.id, b.id),
    onToggleBullet: viewModel.toggleProjectBullet,
    bulletText: viewModel.bulletText,
    hasBulletOverride: viewModel.hasBulletOverride,
    onSetBulletOverride: viewModel.setBulletOverride,
    onRevertBulletOverride: viewModel.revertBulletOverride,
  );
}
