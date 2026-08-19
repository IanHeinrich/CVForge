import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:stacked_services/stacked_services.dart';

/// The top-level sections of the app. Declaration order matches the nav
/// rail's destination order.
///
/// [studio] is deliberately not a rail destination — the editor only ever
/// makes sense once a CV has been chosen from [drafts], so it's reached by
/// opening a card there (or via `StudioDraftHeader`'s back link once
/// inside), never clicked into directly. It still exists as an enum value
/// so `StudioView` has a [AppSection] to pass; [AppChrome] just renders it
/// as [drafts] being the highlighted rail entry (see [_visualSection]).
enum AppSection { vault, drafts, studio }

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
            selectedIndex: _visualSection.index,
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
            ],
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
      case AppSection.studio:
        break; // Unreachable — not a rail destination, see the class doc.
    }
  }
}
