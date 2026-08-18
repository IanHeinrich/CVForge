import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'vault_viewmodel.dart';

class VaultViewTablet extends ViewModelWidget<VaultViewModel> {
  const VaultViewTablet({super.key});

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    return const AppChrome(
      currentSection: AppSection.vault,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: kcLightGrey),
            verticalSpaceMedium,
            Text(
              'Your Vault is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kcWhite,
              ),
            ),
            verticalSpaceSmall,
            Text(
              'Add your work history, skills, and education here.',
              style: TextStyle(color: kcLightGrey),
            ),
          ],
        ),
      ),
    );
  }
}
