import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/widgets/common/drive_sync_indicator/drive_sync_indicator.dart';
import 'package:cv_forge/ui/widgets/common/storage_unavailable_card.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked_services/stacked_services.dart';

/// One rail/bottom-bar destination's icon pair + label — shared between
/// [_RailChrome] (desktop/tablet) and [_MobileChrome] (mobile) so the two
/// layouts can never drift on which icon or label represents a section.
class _NavDestination {
  const _NavDestination({
    required this.section,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final AppSection section;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The three workspace sections with a real indexed rail destination —
/// [AppSection.settings] is deliberately excluded here since the rail
/// pins it to its own `trailing` slot; see [_NavDestination]'s call sites
/// for where each layout adds it back.
///
/// A function rather than a top-level `const`, since the drafts
/// destination's label follows `AppSettings.defaultRegion`'s document noun
/// ("CVs" for a UK default, "Résumés" for a US one), read straight off the
/// locator — this file is deliberately modelless (see [AppChrome]'s class
/// doc), so there's no ViewModel to hold it as reactive state instead.
List<_NavDestination> _workspaceDestinations() => [
  const _NavDestination(
    section: AppSection.vault,
    icon: RemixIcons.safe_line,
    selectedIcon: RemixIcons.safe_fill,
    label: 'Vault',
  ),
  _NavDestination(
    section: AppSection.drafts,
    icon: RemixIcons.file_text_line,
    selectedIcon: RemixIcons.file_text_fill,
    label: locator<SettingsService>()
        .settings
        .preferences
        .defaultRegion
        .preset
        .documentNoun
        .pluralCapitalized,
  ),
  const _NavDestination(
    section: AppSection.analyzer,
    icon: RemixIcons.file_search_line,
    selectedIcon: RemixIcons.file_search_fill,
    label: 'ATS Check',
  ),
];

const _settingsDestination = _NavDestination(
  section: AppSection.settings,
  icon: RemixIcons.settings_line,
  selectedIcon: RemixIcons.settings_fill,
  label: 'Settings',
);

/// The top-level sections of the app.
///
/// [studio] is deliberately not a rail destination — the editor only ever
/// makes sense once a CV has been chosen from [drafts], so it's reached by
/// opening a card there (or via `StudioDocumentBar`'s back link once
/// inside), never clicked into directly. It still exists as an enum value
/// so `StudioView` has a [AppSection] to pass; [AppChrome] just renders it
/// as [drafts] being the highlighted rail entry (see [_visualSection]).
///
/// [settings], unlike [studio], *is* a real peer section — its own
/// highlighted state, reachable directly — but it's pinned to the rail's
/// `trailing` slot rather than its indexed `destinations` list, since it's
/// a utility surface rather than a workspace. That's why it's excluded from
/// `destinations` further down even though it participates fully in
/// [_visualSection]/highlighting.
enum AppSection { vault, drafts, analyzer, studio, settings }

/// The shared shell every top-level View wraps itself in: a left nav rail
/// (Vault / CVs or Résumés, per `AppSettings.defaultRegion`) over the dark
/// scaffold backdrop (`buildAppTheme()`'s
/// `kcSurfaceSunken`), with [child] filling the rest.
///
/// Deliberately modelless — it holds no state, and navigation is a single
/// direct call to [RouterService] rather than routed through a
/// ViewModel, since there's nothing here to unit test that isn't already
/// covered by the router itself.
class AppChrome extends StatelessWidget {
  const AppChrome({
    super.key,
    required this.currentSection,
    required this.child,
  });

  final AppSection currentSection;
  final Widget child;

  /// The loading/error/ready gate every top-level View needs: a refresh
  /// or deep-link straight to a route skips `StartupView`, so that View's
  /// own ViewModel loads its services on its own account (via
  /// `Initialisable.initialise`), and this is what that load looks like
  /// in progress or failed, before there's real content to show.
  /// [content] is called only once neither is true, so building it never
  /// has to guard against a not-yet-loaded ViewModel.
  factory AppChrome.gated({
    Key? key,
    required AppSection section,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
    required Widget Function() content,
  }) {
    if (isLoading) {
      return AppChrome(
        key: key,
        currentSection: section,
        child: const Center(
          child: CircularProgressIndicator(color: kcPrimaryColor),
        ),
      );
    }
    if (hasError) {
      return AppChrome(
        key: key,
        currentSection: section,
        child: StorageUnavailableCard(onRetry: onRetry),
      );
    }
    return AppChrome(key: key, currentSection: section, child: content());
  }

  /// [AppSection.studio] has no rail entry of its own — being in Studio
  /// visually highlights the drafts tab it was reached from.
  AppSection get _visualSection =>
      currentSection == AppSection.studio ? AppSection.drafts : currentSection;

  /// Below `responsive_builder`'s tablet cutoff, a permanently-docked side
  /// rail (`NavigationRailLabelType.all` needs ~80–100 logical px) eats a
  /// fifth to a quarter of a phone-width viewport before any real content
  /// is shown — every top-level View's mobile layout was fighting that
  /// stolen width on top of its own page/card padding, which is what made
  /// Settings' side-by-side backup buttons and the template gallery's
  /// fixed-width cards overflow. Mobile trades the rail for a bottom
  /// `NavigationBar` instead, so [child] gets the full viewport width;
  /// tablet/desktop are untouched.
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (_) => _MobileChrome(
        section: _visualSection,
        onSelect: _navigateTo,
        child: child,
      ),
      tablet: (_) => _RailChrome(
        section: _visualSection,
        onSelect: _navigateTo,
        child: child,
      ),
      desktop: (_) => _RailChrome(
        section: _visualSection,
        onSelect: _navigateTo,
        child: child,
      ),
    );
  }

  void _navigateTo(AppSection section) {
    if (section == _visualSection) return;
    final router = locator<RouterService>();
    switch (section) {
      case AppSection.vault:
        router.replaceWith(VaultViewRoute());
      case AppSection.drafts:
        router.replaceWith(DraftsListViewRoute());
      case AppSection.analyzer:
        router.replaceWith(AnalyzerViewRoute());
      case AppSection.studio:
        break; // Unreachable — not a rail destination, see the class doc.
      case AppSection.settings:
        router.replaceWith(SettingsViewRoute());
    }
  }
}

/// Tablet/desktop chrome: the original permanently-docked side rail, with
/// `settings` pinned to its own `trailing` slot since it's a utility
/// surface rather than a peer workspace tab (see [AppChrome]'s doc).
class _RailChrome extends StatelessWidget {
  const _RailChrome({
    required this.section,
    required this.onSelect,
    required this.child,
  });

  final AppSection section;
  final ValueChanged<AppSection> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final destinations = _workspaceDestinations();
    return Scaffold(
      body: Row(
        // Row's own default cross-axis alignment is center, which gives
        // `Expanded(child: child)` below only a *loose* height constraint
        // (0 up to the full body height, not forced to it). A content
        // widget that shrink-wraps under loose constraints — notably
        // `SingleChildScrollView`, unlike `ListView`'s always-fill-to-max
        // viewport — then renders shorter than the page whenever its own
        // content doesn't reach the bottom, and this Row centers that
        // now-shorter box vertically: a settings page (or any other short
        // page) read as vertically centered rather than pinned to the
        // top, and a page-level FAB positioned relative to that shrunk
        // box landed partway up the screen rather than at its true
        // bottom. `stretch` forces every top-level View's own content to
        // actually claim the full body height, regardless of how it's
        // built internally — the fix belongs here once, not repeated in
        // every View that happens to use a shrink-wrapping scroll view.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            // `settings` sits outside the indexed `destinations` list below
            // (it's rendered via `trailing` instead), so it has no valid
            // index to report here — `null` is "no destination selected",
            // and the trailing settings button draws its own selected state.
            selectedIndex: section == AppSection.settings
                ? null
                : destinations.indexWhere((d) => d.section == section),
            labelType: NavigationRailLabelType.all,
            // The icon and label already recolour to the brand purple when
            // selected; Material's pill behind them adds a second, weaker
            // signal in a colour that belongs to nothing else here.
            useIndicator: false,
            selectedIconTheme: const IconThemeData(color: kcPrimaryColor),
            selectedLabelTextStyle: const TextStyle(color: kcPrimaryColor),
            unselectedIconTheme: const IconThemeData(color: kcLightGrey),
            unselectedLabelTextStyle: const TextStyle(color: kcLightGrey),
            onDestinationSelected: (index) =>
                onSelect(destinations[index].section),
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.appSpacing.paddingDefault,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Renders nothing at all when Drive sync isn't
                      // configured or has never been connected — see its
                      // own doc comment. Sits above Settings rather than
                      // below so it never shifts the settings button's
                      // position depending on whether it's showing.
                      const DriveSyncIndicator(),
                      IconButton(
                        tooltip: _settingsDestination.label,
                        icon: Icon(
                          section == AppSection.settings
                              ? _settingsDestination.selectedIcon
                              : _settingsDestination.icon,
                          color: section == AppSection.settings
                              ? kcPrimaryColor
                              : kcLightGrey,
                        ),
                        onPressed: () => onSelect(AppSection.settings),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Mobile chrome: no docked rail — [child] gets the full viewport width,
/// with all four sections (including Settings, which the rail instead
/// pins to a separate `trailing` slot — there's no equivalent slot on a
/// bottom bar) reachable from a bottom `NavigationBar`.
class _MobileChrome extends StatelessWidget {
  const _MobileChrome({
    required this.section,
    required this.onSelect,
    required this.child,
  });

  final AppSection section;
  final ValueChanged<AppSection> onSelect;
  final Widget child;

  List<_NavDestination> get _destinations => [
    ..._workspaceDestinations(),
    _settingsDestination,
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;
    return Scaffold(
      // Same loose-constraint issue as `_RailChrome`'s `Row` (see its
      // comment) — `SizedBox.expand` is this widget's equivalent fix for
      // `Scaffold.body`'s loose constraint, surfaced here by the drafts
      // page's floating "New CV"/"New Résumé" button landing partway up
      // the screen instead of at its true bottom.
      body: SizedBox.expand(child: child),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kcBorderColor)),
        ),
        child: NavigationBar(
          selectedIndex: destinations.indexWhere((d) => d.section == section),
          onDestinationSelected: (index) =>
              onSelect(destinations[index].section),
          indicatorColor: kcPrimaryColor.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => context.appTypography.caption.copyWith(
              color: states.contains(WidgetState.selected)
                  ? kcPrimaryColor
                  : kcLightGrey,
            ),
          ),
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon, color: kcLightGrey),
                selectedIcon: Icon(d.selectedIcon, color: kcPrimaryColor),
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }
}
