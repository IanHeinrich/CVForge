import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import '../views/studio/studio_viewmodel.dart';
import 'vault_item_selector_list.dart';

/// The left-hand (desktop) / first-tab (tablet, mobile) Studio panel:
/// which sections are visible, and which Vault items are included in the
/// current draft.
class StudioConfigPanel extends StatelessWidget {
  const StudioConfigPanel({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(kdPaddingPage),
      children: [
        const Text(
          'Sections',
          style: TextStyle(
            color: kcWhite,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        verticalSpaceTiny,
        for (final type in CvSectionType.values)
          if (viewModel.sectionHasData(type))
            CheckboxListTile(
              value: !viewModel.isSectionHidden(type),
              onChanged: (_) => viewModel.toggleSectionHidden(type),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: kcPrimaryColor,
              title: Text(
                type.displayLabel,
                style: const TextStyle(color: kcWhite),
              ),
            ),
        verticalSpaceMedium,
        VaultItemSelectorList(
          title: 'Work history',
          unselectedCount: viewModel.unselectedExperiences.length,
          onAddAll: viewModel.addAllExperiences,
          items: [
            for (final experience in viewModel.experiences)
              SelectorItem(
                id: experience.id,
                title: experience.role.isEmpty
                    ? 'Untitled role'
                    : experience.role,
                subtitle: experience.company,
                selected: viewModel.isExperienceIncluded(experience.id),
                onToggle: () => viewModel.toggleExperience(experience),
                bullets: [
                  for (final bullet in experience.bullets)
                    SelectorItem(
                      id: bullet.id,
                      title: _bulletTitle(bullet),
                      selected: viewModel.isExperienceBulletIncluded(
                        experience.id,
                        bullet.id,
                      ),
                      onToggle: () =>
                          viewModel.toggleExperienceBullet(experience, bullet),
                    ),
                ],
              ),
          ],
        ),
        VaultItemSelectorList(
          title: 'Projects',
          unselectedCount: viewModel.unselectedProjects.length,
          onAddAll: viewModel.addAllProjects,
          items: [
            for (final project in viewModel.projects)
              SelectorItem(
                id: project.id,
                title: project.title.isEmpty
                    ? 'Untitled project'
                    : project.title,
                subtitle: project.link,
                selected: viewModel.isProjectIncluded(project.id),
                onToggle: () => viewModel.toggleProject(project),
                bullets: [
                  for (final bullet in project.bullets)
                    SelectorItem(
                      id: bullet.id,
                      title: _bulletTitle(bullet),
                      selected: viewModel.isProjectBulletIncluded(
                        project.id,
                        bullet.id,
                      ),
                      onToggle: () =>
                          viewModel.toggleProjectBullet(project, bullet),
                    ),
                ],
              ),
          ],
        ),
        VaultItemSelectorList(
          title: 'Skills',
          unselectedCount: viewModel.unselectedSkills.length,
          onAddAll: viewModel.addAllSkills,
          items: [
            for (final category in viewModel.skillCategories)
              for (final skill in category.skills)
                SelectorItem(
                  id: skill.id,
                  title: skill.label,
                  subtitle: category.name,
                  selected: viewModel.isSkillIncluded(skill.id),
                  onToggle: () => viewModel.toggleSkill(skill),
                ),
          ],
        ),
        VaultItemSelectorList(
          title: 'Education',
          unselectedCount: viewModel.unselectedEducation.length,
          onAddAll: viewModel.addAllEducation,
          items: [
            for (final entry in viewModel.education)
              SelectorItem(
                id: entry.id,
                title: entry.qualification.isEmpty
                    ? 'Untitled qualification'
                    : entry.qualification,
                subtitle: entry.institution,
                selected: viewModel.isEducationIncluded(entry.id),
                onToggle: () => viewModel.toggleEducation(entry),
              ),
          ],
        ),
        VaultItemSelectorList(
          title: 'Hobbies and interests',
          unselectedCount: viewModel.unselectedHobbies.length,
          onAddAll: viewModel.addAllHobbies,
          items: [
            for (final hobby in viewModel.hobbies)
              SelectorItem(
                id: hobby.id,
                title: hobby.text,
                selected: viewModel.isHobbyIncluded(hobby.id),
                onToggle: () => viewModel.toggleHobby(hobby),
              ),
          ],
        ),
      ],
    );
  }
}

String _bulletTitle(CvBullet bullet) =>
    bullet.label == null || bullet.label!.isEmpty
    ? bullet.text
    : '${bullet.label}: ${bullet.text}';
