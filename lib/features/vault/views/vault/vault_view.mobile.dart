import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'vault_viewmodel.dart';

class VaultViewMobile extends ViewModelWidget<VaultViewModel> {
  const VaultViewMobile({super.key});

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    return const AppChrome(
      currentSection: AppSection.vault,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open, size: 40, color: kcLightGrey),
              verticalSpaceMedium,
              Text(
                'Your Vault is empty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kcWhite,
                ),
              ),
              verticalSpaceSmall,
              Text(
                'Add your work history, skills, and education here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kcLightGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
