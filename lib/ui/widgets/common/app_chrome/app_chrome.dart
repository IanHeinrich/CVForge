import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

/// The two top-level sections of the app. Declaration order matches the
/// nav rail's destination order.
enum AppSection { vault, studio }

/// The shared shell every top-level View wraps itself in: a left nav rail
/// (Vault / Studio) over the dark [kcBackgroundColor] backdrop, with
/// [child] filling the rest.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: kcDarkGreyColor,
            selectedIndex: currentSection.index,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: kcPrimaryColor),
            selectedLabelTextStyle: const TextStyle(color: kcPrimaryColor),
            unselectedIconTheme: const IconThemeData(color: kcLightGrey),
            unselectedLabelTextStyle: const TextStyle(color: kcLightGrey),
            onDestinationSelected: (index) =>
                _navigateTo(AppSection.values[index]),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.lock_outline),
                selectedIcon: Icon(Icons.lock),
                label: Text('Vault'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.design_services_outlined),
                selectedIcon: Icon(Icons.design_services),
                label: Text('Studio'),
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
    if (section == currentSection) return;
    final router = locator<RouterService>();
    switch (section) {
      case AppSection.vault:
        router.replaceWith(VaultViewRoute());
      case AppSection.studio:
        router.replaceWith(StudioViewRoute());
    }
  }
}
