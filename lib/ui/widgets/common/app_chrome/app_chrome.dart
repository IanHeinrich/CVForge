import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/widgets/common/storage_unavailable_card.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:stacked_services/stacked_services.dart';

/// The top-level sections of the app. Declaration order matches the nav
/// rail's main destination order.
///
/// [studio] is deliberately not a rail destination — the editor only ever
/// makes sense once a CV has been chosen from [drafts], so it's reached by
/// opening a card there (or via `StudioDraftHeader`'s back link once
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
///
/// [analyzer] is declared right after [drafts] (before [studio]) rather
/// than appended at the end — `_navigateTo`'s `onDestinationSelected` maps
/// a rail tap straight to `AppSection.values[index]`, so every section
/// with a real indexed destination must keep its enum position in lockstep
/// with its position in `destinations` below. [studio] and [settings] can
/// sit anywhere else because both are special-cased out of that indexing
/// ([studio] has no destination at all; [settings] always resolves to a
/// `null` index), but inserting a new *real* destination after either of
/// them would silently desync every following index.
enum AppSection { vault, drafts, analyzer, studio, settings }

/// The shared shell every top-level View wraps itself in: a left nav rail
/// (Vault / CVs) over the dark [kcBackgroundColor] backdrop, with [child]
/// filling the rest.
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
  /// visually highlights the "CVs" tab it was reached from.
  AppSection get _visualSection =>
      currentSection == AppSection.studio ? AppSection.drafts : currentSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: kcDarkGreyColor,
            // `settings` sits outside the indexed `destinations` list below
            // (it's rendered via `trailing` instead), so it has no valid
            // index to report here — `null` is "no destination selected",
            // and the trailing settings button draws its own selected state.
            selectedIndex: _visualSection == AppSection.settings
                ? null
                : _visualSection.index,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: kcPrimaryColor),
            selectedLabelTextStyle: const TextStyle(color: kcPrimaryColor),
            unselectedIconTheme: const IconThemeData(color: kcLightGrey),
            unselectedLabelTextStyle: const TextStyle(color: kcLightGrey),
            onDestinationSelected: (index) =>
                _navigateTo(AppSection.values[index]),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(RemixIcons.safe_line),
                selectedIcon: Icon(RemixIcons.safe_fill),
                label: Text('Vault'),
              ),
              NavigationRailDestination(
                icon: Icon(RemixIcons.file_text_line),
                selectedIcon: Icon(RemixIcons.file_text_fill),
                label: Text('CVs'),
              ),
              NavigationRailDestination(
                icon: Icon(RemixIcons.file_search_line),
                selectedIcon: Icon(RemixIcons.file_search_fill),
                label: Text('ATS Check'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.appSpacing.paddingDefault,
                  ),
                  child: IconButton(
                    tooltip: 'Settings',
                    icon: Icon(
                      _visualSection == AppSection.settings
                          ? RemixIcons.settings_fill
                          : RemixIcons.settings_line,
                      color: _visualSection == AppSection.settings
                          ? kcPrimaryColor
                          : kcLightGrey,
                    ),
                    onPressed: () => _navigateTo(AppSection.settings),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: kcMediumGrey),
          Expanded(child: child),
        ],
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
