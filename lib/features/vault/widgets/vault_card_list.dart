import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_motion.dart';
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
///
/// Stateful only for [_selectedCardKey]/[_lastOpenKey]: opening an entry
/// on desktop/tablet can collapse `VaultListSection`'s two-column grid
/// down to one (see `VaultViewDesktop.editorPanelWidth`'s doc comment),
/// which pushes everything below the opened card further down the
/// scrolling list — the card you just clicked (and its selected
/// highlight) can end up scrolled out of view even though it's still
/// the one open in the editor. Comparing [VaultViewModel.openTarget]/
/// [openId] against the last value seen — directly in [build], the same
/// "compare fresh state against what was last acted on" shape
/// `StudioPreviewPane` uses for its own debounce — is what notices a
/// *new* selection (as opposed to a rebuild for any other reason) and
/// scrolls it back into view once the column-reflow transition has had
/// time to settle.
class VaultCardList extends StatefulWidget {
  const VaultCardList({super.key, required this.viewModel});

  final VaultViewModel viewModel;

  @override
  State<VaultCardList> createState() => _VaultCardListState();
}

class _VaultCardListState extends State<VaultCardList> {
  /// Reassigned to whichever card is currently selected (see
  /// [_sections]) — safe as a single reused [GlobalKey] because at most
  /// one card is ever selected at once.
  final _selectedCardKey = GlobalKey();

  /// `'$openTarget:$openId'` as of the last time a scroll was scheduled,
  /// so a rebuild for any other reason (a field edit inside the open
  /// entry, a persist-error banner appearing) doesn't re-trigger the
  /// scroll — only an actual change of *which* entry is open does.
  String? _lastOpenKey;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final openTarget = viewModel.openTarget;
    final openKey = openTarget == VaultEditorTarget.none
        ? null
        : '$openTarget:${viewModel.openId}';
    if (openKey != null && openKey != _lastOpenKey) {
      _lastOpenKey = openKey;
      // `VaultViewDesktop`'s own width/column-reflow transition — wait
      // for it to settle before measuring where the card ended up, or
      // this measures a position the transition is about to move away
      // from.
      final revealDelay = context.appMotion.layout;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollSelectedIntoView(revealDelay),
      );
    }

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
        TextField(
          onChanged: viewModel.setQuery,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search your Vault…',
            prefixIcon: Icon(
              RemixIcons.search_line,
              size: context.appIconSize.medium,
            ),
          ),
        ),
        const VGap.medium(),
        for (final section in _sections(context)) ...[
          section,
          const VGap.medium(),
        ],
      ],
    );
  }

  Future<void> _scrollSelectedIntoView(Duration delay) async {
    await Future.delayed(delay);
    final targetContext = _selectedCardKey.currentContext;
    if (targetContext == null || !targetContext.mounted) return;
    await Scrollable.ensureVisible(
      targetContext,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  /// Every section card in display order, without the spacing between
  /// them — [build] adds that. [_selectedCardKey] is handed only to
  /// whichever single card matches [VaultViewModel.openTarget]/[openId],
  /// via each section's own `selected`/`selectedItemKey` plumbing.
  List<Widget> _sections(BuildContext context) {
    final viewModel = widget.viewModel;
    final vault = viewModel.vault;
    final target = viewModel.openTarget;
    return [
      _BasicsCard(
        key: target == VaultEditorTarget.basics ? _selectedCardKey : null,
        basics: vault.basics,
        selected: target == VaultEditorTarget.basics,
        onTap: viewModel.openBasicsEditor,
      ),
      VaultListSection<Experience>(
        title: 'Work history',
        addLabel: 'Add experience',
        emptyMessage: _emptyMessage(viewModel, 'No experience yet.'),
        icon: RemixIcons.briefcase_line,
        items: viewModel.filteredExperiences,
        idOf: (e) => e.id,
        titleOf: (e) => e.role.isEmpty ? 'Untitled role' : e.role,
        subtitleOf: (e) => e.company,
        openId: target == VaultEditorTarget.experience
            ? viewModel.openId
            : null,
        selectedItemKey: target == VaultEditorTarget.experience
            ? _selectedCardKey
            : null,
        onOpen: viewModel.openExperienceEditor,
        onAdd: viewModel.addExperience,
        onDelete: viewModel.deleteExperience,
      ),
      VaultListSection<Project>(
        title: 'Projects',
        addLabel: 'Add project',
        emptyMessage: _emptyMessage(viewModel, 'No projects yet.'),
        icon: RemixIcons.rocket_line,
        items: viewModel.filteredProjects,
        idOf: (p) => p.id,
        titleOf: (p) => p.title.isEmpty ? 'Untitled project' : p.title,
        subtitleOf: (p) => p.link,
        openId: target == VaultEditorTarget.project ? viewModel.openId : null,
        selectedItemKey: target == VaultEditorTarget.project
            ? _selectedCardKey
            : null,
        onOpen: viewModel.openProjectEditor,
        onAdd: viewModel.addProject,
        onDelete: viewModel.deleteProject,
      ),
      _SkillsCard(
        key: target == VaultEditorTarget.skills ? _selectedCardKey : null,
        categories: vault.skillCategories,
        selected: target == VaultEditorTarget.skills,
        onTap: viewModel.openSkillsEditor,
      ),
      VaultListSection<Education>(
        title: 'Education',
        addLabel: 'Add education',
        emptyMessage: _emptyMessage(viewModel, 'No education yet.'),
        icon: RemixIcons.graduation_cap_line,
        items: viewModel.filteredEducation,
        idOf: (e) => e.id,
        titleOf: (e) => e.qualification.isEmpty
            ? 'Untitled qualification'
            : e.qualification,
        subtitleOf: (e) => e.institution,
        openId: target == VaultEditorTarget.education ? viewModel.openId : null,
        selectedItemKey: target == VaultEditorTarget.education
            ? _selectedCardKey
            : null,
        onOpen: viewModel.openEducationEditor,
        onAdd: viewModel.addEducation,
        onDelete: viewModel.deleteEducation,
      ),
      _HobbiesCard(
        key: target == VaultEditorTarget.hobbies ? _selectedCardKey : null,
        hobbies: vault.hobbies,
        selected: target == VaultEditorTarget.hobbies,
        onTap: viewModel.openHobbiesEditor,
      ),
      VaultListSection<Publication>(
        title: 'Publications',
        addLabel: 'Add publication',
        emptyMessage: _emptyMessage(viewModel, 'No publications yet.'),
        icon: RemixIcons.article_line,
        items: viewModel.filteredPublications,
        idOf: (p) => p.id,
        titleOf: (p) => p.title.isEmpty ? 'Untitled publication' : p.title,
        subtitleOf: (p) => p.citation,
        openId: target == VaultEditorTarget.publication
            ? viewModel.openId
            : null,
        selectedItemKey: target == VaultEditorTarget.publication
            ? _selectedCardKey
            : null,
        onOpen: viewModel.openPublicationEditor,
        onAdd: viewModel.addPublication,
        onDelete: viewModel.deletePublication,
      ),
    ];
  }

  /// [base] once nothing is being searched for; while a search is active
  /// and this section's filtered list came up empty, a "no matches"
  /// message instead — otherwise a genuinely non-empty section (say, work
  /// history with entries, none of which match the current search) would
  /// misleadingly claim to have no entries at all.
  String _emptyMessage(VaultViewModel viewModel, String base) =>
      viewModel.isSearching ? 'No matches for your search.' : base;
}

class _BasicsCard extends StatelessWidget {
  const _BasicsCard({
    super.key,
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
      leading: Icon(
        RemixIcons.user_line,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard({
    super.key,
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
      leading: Icon(
        RemixIcons.star_line,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _HobbiesCard extends StatelessWidget {
  const _HobbiesCard({
    super.key,
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
      // Cook…") the moment there are more than about four.
      subtitle: hobbies.isEmpty
          ? 'None yet'
          : '${hobbies.length} ${hobbies.length == 1 ? 'hobby' : 'hobbies'}',
      selected: selected,
      onTap: onTap,
      leading: Icon(
        RemixIcons.footprint_line,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
