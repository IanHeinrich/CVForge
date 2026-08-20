import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'studio_field_override_card.dart';
import 'studio_panel_heading.dart';
import 'tailorable_field.dart';
import 'vault_item_selector_list.dart';

/// The left-hand (desktop) / first-tab (tablet, mobile) Studio panel:
/// which sections are visible, which Vault items are included in the
/// current draft, and manual per-draft rewrites of every prose field —
/// summary, headline, references note, bullets, education details.
class StudioConfigPanel extends StatelessWidget {
  const StudioConfigPanel({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.appSpacing.paddingPage),
      children: [
        if (viewModel.hasPersistError) ...[
          PersistErrorBanner(
            message: "Your last selection change couldn't be saved.",
            onRetry: viewModel.retryPersist,
          ),
          const VGap.medium(),
        ],
        const StudioPanelHeading('Document'),
        const VGap.tiny(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final region in RegionProfile.values)
              ChoiceChip(
                label: Text(region.preset.displayName),
                selected: viewModel.region == region,
                onSelected: (_) => viewModel.setRegion(region),
              ),
          ],
        ),
        const VGap.medium(),
        const StudioPanelHeading('Sections'),
        const VGap.tiny(),
        for (final type in CvSectionType.values)
          if (viewModel.sectionHasData(type))
            CheckboxListTile(
              key: ValueKey('section_${type.name}'),
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
        const VGap.medium(),
        // Headline and Summary sit near the top of the page, so they sit
        // near the top of the panel too. References prints last — its
        // card sits last as well, after every selector list below.
        StudioFieldOverrideCard(
          key: const ValueKey('studio_headline_editor'),
          label: 'Headline',
          vaultValue: viewModel.vaultHeadline,
          hasOverride: viewModel.hasHeadlineOverride,
          effectiveValue: viewModel.headlineText,
          onChanged: viewModel.setHeadlineOverride,
          onRevert: viewModel.revertHeadlineToVault,
          emptyVaultMessage: 'No headline in your Vault yet.',
        ),
        StudioFieldOverrideCard(
          key: const ValueKey('studio_summary_editor'),
          label: 'Professional summary',
          vaultValue: viewModel.vaultSummary,
          hasOverride: viewModel.hasTailoredSummary,
          effectiveValue: viewModel.summaryText,
          onChanged: viewModel.setTailoredSummary,
          onRevert: viewModel.revertSummaryToVault,
          emptyVaultMessage: 'No summary in your Vault yet.',
          hidden: viewModel.isSectionHidden(CvSectionType.summary),
          onShow: () => viewModel.toggleSectionHidden(CvSectionType.summary),
        ),
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
                onAddAllBullets: () =>
                    viewModel.addAllExperienceBullets(experience),
                bullets: [
                  for (final bullet in experience.bullets)
                    SelectorItem(
                      id: bullet.id,
                      title: _bulletTitle(
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
                        onRevert: () =>
                            viewModel.revertBulletOverride(bullet.id),
                      ),
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
                onAddAllBullets: () => viewModel.addAllProjectBullets(project),
                bullets: [
                  for (final bullet in project.bullets)
                    SelectorItem(
                      id: bullet.id,
                      title: _bulletTitle(
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
                        onRevert: () =>
                            viewModel.revertBulletOverride(bullet.id),
                      ),
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
                tailorable: TailorableField(
                  hasOverride: viewModel.hasEducationDetailsOverride(entry.id),
                  effectiveText: viewModel.educationDetailsText(entry),
                  emptyMessage: 'No details in your Vault yet.',
                  onChanged: (value) =>
                      viewModel.setEducationDetailsOverride(entry, value),
                  onRevert: () =>
                      viewModel.revertEducationDetailsOverride(entry.id),
                ),
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
        StudioFieldOverrideCard(
          key: const ValueKey('studio_references_editor'),
          label: 'References',
          vaultValue: viewModel.vaultReferencesNote,
          hasOverride: viewModel.hasReferencesOverride,
          effectiveValue: viewModel.referencesText,
          onChanged: viewModel.setReferencesOverride,
          onRevert: viewModel.revertReferencesToVault,
          emptyVaultMessage: 'No references note in your Vault yet.',
          hidden: viewModel.isSectionHidden(CvSectionType.references),
          onShow: () => viewModel.toggleSectionHidden(CvSectionType.references),
        ),
      ],
    );
  }
}

String _bulletTitle(String? label, String text) =>
    label == null || label.isEmpty ? text : '$label: $text';
