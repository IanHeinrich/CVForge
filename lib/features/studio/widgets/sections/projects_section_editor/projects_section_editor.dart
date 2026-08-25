import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/sections/entity_bullet_section_editor.dart';
import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';

/// The [CvSectionType.projects] editor.
class ProjectsSectionEditor extends StatelessWidget {
  const ProjectsSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) => EntityBulletSectionEditor(
    title: context.l10n.vaultSectionProjects,
    items: viewModel.projects,
    untitledLabel: context.l10n.vaultUntitledProject,
    idOf: (p) => p.id,
    titleOf: viewModel.projectTitleText,
    // A project is identified by its title alone, so the link is a field
    // row rather than a subtitle. As a subtitle it read as a string
    // nobody had got round to wiring up — indistinguishable from a bug.
    subtitleOf: (p) => null,
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
    titleFieldOf: (p) => TailorableField(
      hasOverride: viewModel.hasProjectTitleOverride(p.id),
      effectiveText: viewModel.projectTitleText(p),
      vaultText: p.title,
      fieldLabel: context.l10n.studioFieldProjectTitle,
      onChanged: (value) => viewModel.setProjectTitleOverride(p, value),
      onRevert: () => viewModel.revertProjectTitleOverride(p.id),
    ),
    fieldsOf: (p) => [
      VaultOnlyField(
        fieldLabel: context.l10n.studioFieldLink,
        value: p.link ?? '',
        reason: context.l10n.studioLockedFromVault,
        omitted: viewModel.isFieldOmitted(
          DraftOmittableField.projectLink,
          p.id,
        ),
        onToggleOmitted: () =>
            viewModel.toggleFieldOmitted(DraftOmittableField.projectLink, p.id),
      ),
    ],
  );
}
