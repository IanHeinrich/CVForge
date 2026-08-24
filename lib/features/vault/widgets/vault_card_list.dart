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
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/ui/common/l10n/document_language_labels.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter/material.dart';

import 'vault_section_heading.dart';
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
            message: context.l10n.vaultPersistError,
            onRetry: viewModel.retryPersist,
          ),
          const VGap.medium(),
        ],
        TextField(
          onChanged: viewModel.setQuery,
          decoration: InputDecoration(
            isDense: true,
            hintText: context.l10n.vaultSearch,
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
    final noun = vault.documentDefaults.region.preset.documentNoun.name;

    return [
      // The list has two halves, and says so. Everything below "About you"
      // is a fact about the person; the card above it is configuration for
      // the document. Splitting them with the list's own section heading
      // keeps one idiom — tap a card, the right-hand panel opens — rather
      // than bolting a settings strip above the search field, which would
      // scroll away with the list anyway.
      //
      // Hidden while searching: the search filters career content, and a
      // config card stranded above "no matches" reads as a bug.
      if (!viewModel.isSearching)
        _HeadedSection(
          title: context.l10n.vaultSectionCvDefaults(noun),
          child: _DocumentDefaultsCard(
            key: target == VaultEditorTarget.documentDefaults
                ? _selectedCardKey
                : null,
            defaults: vault.documentDefaults,
            selected: target == VaultEditorTarget.documentDefaults,
            onTap: viewModel.openDocumentDefaultsEditor,
          ),
        ),
      _HeadedSection(
        // Only labelled when the defaults section above it is showing —
        // with nothing to separate it from, a lone "About you" over the
        // whole list is a heading that earns nothing.
        title: viewModel.isSearching ? null : context.l10n.vaultSectionAboutYou,
        child: _BasicsCard(
          key: target == VaultEditorTarget.basics ? _selectedCardKey : null,
          basics: vault.basics,
          selected: target == VaultEditorTarget.basics,
          onTap: viewModel.openBasicsEditor,
        ),
      ),
      VaultListSection<Experience>(
        title: context.l10n.vaultSectionExperience,
        addLabel: context.l10n.vaultAddExperience,
        emptyMessage: _emptyMessage(viewModel, context.l10n.vaultNoExperience),
        icon: RemixIcons.briefcase_line,
        items: viewModel.filteredExperiences,
        idOf: (e) => e.id,
        titleOf: (e) =>
            e.role.isEmpty ? context.l10n.vaultUntitledRole : e.role,
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
        title: context.l10n.vaultSectionProjects,
        addLabel: context.l10n.vaultAddProject,
        emptyMessage: _emptyMessage(viewModel, context.l10n.vaultNoProjects),
        icon: RemixIcons.rocket_line,
        items: viewModel.filteredProjects,
        idOf: (p) => p.id,
        titleOf: (p) =>
            p.title.isEmpty ? context.l10n.vaultUntitledProject : p.title,
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
        title: context.l10n.vaultSectionEducation,
        addLabel: context.l10n.vaultAddEducation,
        emptyMessage: _emptyMessage(viewModel, context.l10n.vaultNoEducation),
        icon: RemixIcons.graduation_cap_line,
        items: viewModel.filteredEducation,
        idOf: (e) => e.id,
        titleOf: (e) => e.qualification.isEmpty
            ? context.l10n.vaultUntitledQualification
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
        title: context.l10n.vaultSectionPublications,
        addLabel: context.l10n.vaultAddPublication,
        emptyMessage: _emptyMessage(
          viewModel,
          context.l10n.vaultNoPublications,
        ),
        icon: RemixIcons.article_line,
        items: viewModel.filteredPublications,
        idOf: (p) => p.id,
        titleOf: (p) =>
            p.title.isEmpty ? context.l10n.vaultUntitledPublication : p.title,
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
      viewModel.isSearching ? context.l10n.vaultNoSearchMatches : base;
}

/// A heading and the single card under it, as one item.
///
/// [VaultListSection] bundles its own heading the same way, and it has to
/// be one widget rather than two entries in [_VaultCardListState._sections]
/// — that list puts a `VGap.medium` after every item, which between a
/// heading and the card it labels would read as a gap rather than a group.
class _HeadedSection extends StatelessWidget {
  const _HeadedSection({required this.title, required this.child});

  /// Null renders the card with no heading at all.
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final heading = title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading != null) VaultSectionHeading(title: heading),
        child,
      ],
    );
  }
}

/// The Vault's one configuration card: which region and language every
/// new CV starts out as.
///
/// Deliberately the same [AppSummaryCard] shape as the content cards
/// below it, so the interaction is identical — it is the *heading* above
/// it that says this is a different kind of thing, not a different
/// control.
class _DocumentDefaultsCard extends StatelessWidget {
  const _DocumentDefaultsCard({
    super.key,
    required this.defaults,
    required this.selected,
    required this.onTap,
  });

  final DocumentDefaults defaults;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSummaryCard(
      title: defaults.region.displayName(context.l10n),
      subtitle: defaults.language.displayLabel(context.l10n),
      selected: selected,
      onTap: onTap,
      leading: RegionFlagStack(
        flags: defaults.region.preset.flags,
        size: context.appIconSize.large,
      ),
    );
  }
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
      title: basics.fullName.isEmpty
          ? context.l10n.vaultAddBasics
          : basics.fullName,
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
      title: context.l10n.vaultSkillsTitle,
      subtitle: categories.isEmpty
          ? context.l10n.vaultNoSkillsYet
          : context.l10n.vaultSkillsSummary(categories.length, skillCount),
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
      title: context.l10n.vaultHobbiesTitle,
      // A count, like Skills' "3 categories, 11 skills" — joining every
      // hobby with ", " reads fine at three but degrades into a
      // `maxLines: 1`-truncated list ("Running, Chess, Photography,
      // Cook…") the moment there are more than about four.
      subtitle: hobbies.isEmpty
          ? context.l10n.vaultHobbiesNoneYet
          : context.l10n.vaultHobbiesCount(hobbies.length),
      selected: selected,
      onTap: onTap,
      leading: Icon(
        RemixIcons.footprint_line,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
