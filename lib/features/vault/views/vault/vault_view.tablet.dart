import 'vault_view.desktop.dart';

/// Same layout as desktop, just a narrower editor panel relative to the
/// card list — see [VaultViewDesktop] for the shared implementation.
class VaultViewTablet extends VaultViewDesktop {
  const VaultViewTablet({super.key});

  @override
  int get cardListFlex => 2;

  @override
  int get editorPanelFlex => 3;
}
