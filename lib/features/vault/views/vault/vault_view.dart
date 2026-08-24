import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'vault_view.desktop.dart';
import 'vault_view.mobile.dart';
import 'vault_viewmodel.dart';

/// [invalidUrl] is a query param (`/vault?invalidUrl=true`), set only by
/// `app.dart`'s wildcard `RedirectRoute` for a URL that matched no route —
/// it's how [VaultViewModel] knows to surface the "that page doesn't exist"
/// notice once, versus a plain, direct `/vault` visit. String rather than
/// bool because `@QueryParam()` values come off the URL as strings; `'true'`
/// is the only value the redirect ever produces.
class VaultView extends StackedView<VaultViewModel> {
  const VaultView({super.key, @QueryParam() this.invalidUrl});

  final String? invalidUrl;

  @override
  Widget builder(
    BuildContext context,
    VaultViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.consumeInvalidUrlNotice()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.vaultInvalidUrlNotice)),
        );
      });
    }
    return AppChrome.gated(
      section: AppSection.vault,
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.initialise,
      content: () => ScreenTypeLayout.builder(
        mobile: (_) => const VaultViewMobile(),
        tablet: (_) => const VaultViewDesktop(editorPanelWidth: 440),
        desktop: (_) => const VaultViewDesktop(),
      ),
    );
  }

  @override
  VaultViewModel viewModelBuilder(BuildContext context) =>
      VaultViewModel(cameFromInvalidUrl: invalidUrl == 'true');
}
