import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [CvSectionType.experience] editor.
class ExperienceSectionEditor extends StatelessWidget {
  const ExperienceSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VaultItemSelectorList(
      title: 'Work history',
      unselectedCount: viewModel.unselectedExperiences.length,
      onAddAll: viewModel.addAllExperiences,
      items: [
        for (final experience in viewModel.experiences)
          SelectorItem(
            id: experience.id,
            title: experience.role.isEmpty ? 'Untitled role' : experience.role,
            subtitle: experience.company,
            selected: viewModel.isExperienceIncluded(experience.id),
            onToggle: () => viewModel.toggleExperience(experience),
            onAddAllBullets: () =>
                viewModel.addAllExperienceBullets(experience),
            bullets: [
              for (final bullet in experience.bullets)
                SelectorItem(
                  id: bullet.id,
                  title: bulletTitle(
                    bullet.label,
                    viewModel.bulletText(bullet),
                  ),
                  selected: viewModel.isExperienceBulletIncluded(
                    experience.id,
                    bullet.id,
                  ),
                  onToggle: () =>
                      viewModel.toggleExperienceBullet(experience, bullet),
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
