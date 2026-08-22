import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [CvSectionType.projects] editor.
class ProjectsSectionEditor extends StatelessWidget {
  const ProjectsSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VaultItemSelectorList(
      title: 'Projects',
      unselectedCount: viewModel.unselectedProjects.length,
      onAddAll: viewModel.addAllProjects,
      items: [
        for (final project in viewModel.projects)
          SelectorItem(
            id: project.id,
            title: project.title.isEmpty ? 'Untitled project' : project.title,
            subtitle: project.link,
            selected: viewModel.isProjectIncluded(project.id),
            onToggle: () => viewModel.toggleProject(project),
            onAddAllBullets: () => viewModel.addAllProjectBullets(project),
            bullets: [
              for (final bullet in project.bullets)
                SelectorItem(
                  id: bullet.id,
                  title: bulletTitle(
                    bullet.label,
                    viewModel.bulletText(bullet),
                  ),
                  selected: viewModel.isProjectBulletIncluded(
                    project.id,
                    bullet.id,
                  ),
                  onToggle: () =>
                      viewModel.toggleProjectBullet(project, bullet),
                  tailorable: TailorableField(
                    hasOverride: viewModel.hasBulletOverride(bullet.id),
                    effectiveText: viewModel.bulletText(bullet),
                    fieldLabel: bullet.label,
                    onChanged: (value) =>
                        viewModel.setBulletOverride(bullet, value),
                    onRevert: () => viewModel.revertBulletOverride(bullet.id),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
