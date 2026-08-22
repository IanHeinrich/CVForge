import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/entity_bullet_section_editor.dart';

/// The [CvSectionType.publications] editor.
class PublicationsSectionEditor extends StatelessWidget {
  const PublicationsSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) => EntityBulletSectionEditor(
    title: 'Publications',
    items: viewModel.publications,
    untitledLabel: 'Untitled publication',
    idOf: (p) => p.id,
    titleOf: (p) => p.title,
    subtitleOf: (p) => p.citation,
    bulletsOf: (p) => p.bullets,
    unselectedCount: viewModel.unselectedPublications.length,
    selectedCount: viewModel.selectedPublications.length,
    onAddAll: viewModel.addAllPublications,
    onRemoveAll: viewModel.removeAllPublications,
    isIncluded: (p) => viewModel.isPublicationIncluded(p.id),
    onToggle: viewModel.togglePublication,
    onAddAllBullets: viewModel.addAllPublicationBullets,
    onRemoveAllBullets: viewModel.removeAllPublicationBullets,
    isBulletIncluded: (p, b) =>
        viewModel.isPublicationBulletIncluded(p.id, b.id),
    onToggleBullet: viewModel.togglePublicationBullet,
    bulletText: viewModel.bulletText,
    hasBulletOverride: viewModel.hasBulletOverride,
    onSetBulletOverride: viewModel.setBulletOverride,
    onRevertBulletOverride: viewModel.revertBulletOverride,
  );
}
