import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_summary_card.dart';
import 'package:cv_forge/ui/widgets/common/persist_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/vault/views/vault/vault_viewmodel.dart';
import 'vault_list_section.dart';

/// The main scrolling list of collapsed entity summary cards. Shared by
/// every breakpoint so desktop/tablet/mobile can't drift on which
/// sections exist or their order.
class VaultCardList extends StatelessWidget {
  const VaultCardList({super.key, required this.viewModel});

  final VaultViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.appSpacing.paddingPage),
      children: [
        if (viewModel.hasPersistError) ...[
          PersistErrorBanner(
            message: "Your last change couldn't be saved.",
            onRetry: viewModel.retryPersist,
          ),
          const VGap.medium(),
        ],
        for (final section in _sections(context)) ...[
          section,
          const VGap.medium(),
        ],
      ],
    );
  }

  /// Every section card in display order, without the spacing between
  /// them — [build] adds that.
  List<Widget> _sections(BuildContext context) {
    final vault = viewModel.vault;
    return [
      _BasicsCard(
        basics: vault.basics,
        selected: viewModel.openTarget == VaultEditorTarget.basics,
        onTap: viewModel.openBasicsEditor,
      ),
      VaultListSection<Experience>(
        title: 'Work history',
        addLabel: 'Add experience',
        emptyMessage: 'No experience yet.',
        icon: RemixIcons.briefcase_line,
        items: vault.experiences,
        idOf: (e) => e.id,
        titleOf: (e) => e.role.isEmpty ? 'Untitled role' : e.role,
        subtitleOf: (e) => e.company,
        openId: viewModel.openTarget == VaultEditorTarget.experience
            ? viewModel.openId
            : null,
        onOpen: viewModel.openExperienceEditor,
        onAdd: viewModel.addExperience,
        onDelete: viewModel.deleteExperience,
      ),
      VaultListSection<Project>(
        title: 'Projects',
        addLabel: 'Add project',
        emptyMessage: 'No projects yet.',
        icon: RemixIcons.rocket_line,
        items: vault.projects,
        idOf: (p) => p.id,
        titleOf: (p) => p.title.isEmpty ? 'Untitled project' : p.title,
        subtitleOf: (p) => p.link,
        openId: viewModel.openTarget == VaultEditorTarget.project
            ? viewModel.openId
            : null,
        onOpen: viewModel.openProjectEditor,
        onAdd: viewModel.addProject,
        onDelete: viewModel.deleteProject,
      ),
      _SkillsCard(
        categories: vault.skillCategories,
        selected: viewModel.openTarget == VaultEditorTarget.skills,
        onTap: viewModel.openSkillsEditor,
      ),
      VaultListSection<Education>(
        title: 'Education',
        addLabel: 'Add education',
        emptyMessage: 'No education yet.',
        icon: RemixIcons.graduation_cap_line,
        items: vault.education,
        idOf: (e) => e.id,
        titleOf: (e) => e.qualification.isEmpty
            ? 'Untitled qualification'
            : e.qualification,
        subtitleOf: (e) => e.institution,
        openId: viewModel.openTarget == VaultEditorTarget.education
            ? viewModel.openId
            : null,
        onOpen: viewModel.openEducationEditor,
        onAdd: viewModel.addEducation,
        onDelete: viewModel.deleteEducation,
      ),
      _HobbiesCard(
        hobbies: vault.hobbies,
        selected: viewModel.openTarget == VaultEditorTarget.hobbies,
        onTap: viewModel.openHobbiesEditor,
      ),
      VaultListSection<Publication>(
        title: 'Publications',
        addLabel: 'Add publication',
        emptyMessage: 'No publications yet.',
        icon: RemixIcons.article_line,
        items: vault.publications,
        idOf: (p) => p.id,
        titleOf: (p) => p.title.isEmpty ? 'Untitled publication' : p.title,
        subtitleOf: (p) => p.citation,
        openId: viewModel.openTarget == VaultEditorTarget.publication
            ? viewModel.openId
            : null,
        onOpen: viewModel.openPublicationEditor,
        onAdd: viewModel.addPublication,
        onDelete: viewModel.deletePublication,
      ),
    ];
  }
}

class _BasicsCard extends StatelessWidget {
  const _BasicsCard({
    required this.basics,
    required this.selected,
    required this.onTap,
  });

  final ContactBasics basics;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      basics.headline,
      basics.email,
    ].where((s) => s.isNotEmpty).join(' · ');

    return AppSummaryCard(
      title: basics.fullName.isEmpty ? 'Add your basics' : basics.fullName,
      subtitle: subtitle,
      selected: selected,
      onTap: onTap,
      leading: const Icon(RemixIcons.user_line, color: kcLightGrey),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard({
    required this.categories,
    required this.selected,
    required this.onTap,
  });

  final List<SkillCategory> categories;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final skillCount = categories.fold<int>(
      0,
      (sum, c) => sum + c.skills.length,
    );

    return AppSummaryCard(
      title: 'Skills',
      subtitle: categories.isEmpty
          ? 'No skills yet'
          : '${categories.length} categories, $skillCount skills',
      selected: selected,
      onTap: onTap,
      leading: const Icon(RemixIcons.star_line, color: kcLightGrey),
    );
  }
}

class _HobbiesCard extends StatelessWidget {
  const _HobbiesCard({
    required this.hobbies,
    required this.selected,
    required this.onTap,
  });

  final List<HobbyItem> hobbies;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSummaryCard(
      title: 'Hobbies and interests',
      // A count, like Skills' "3 categories, 11 skills" — joining every
      // hobby with ", " reads fine at three but degrades into a
      // `maxLines: 1`-truncated list ("Running, Chess, Photography,
      // Cook…") the moment there are more than about four (7.8).
      subtitle: hobbies.isEmpty
          ? 'None yet'
          : '${hobbies.length} ${hobbies.length == 1 ? 'hobby' : 'hobbies'}',
      selected: selected,
      onTap: onTap,
      leading: const Icon(RemixIcons.footprint_line, color: kcLightGrey),
    );
  }
}
