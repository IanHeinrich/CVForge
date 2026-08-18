import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'studio_viewmodel.dart';

class StudioViewDesktop extends ViewModelWidget<StudioViewModel> {
  const StudioViewDesktop({super.key});

  @override
  Widget build(BuildContext context, StudioViewModel viewModel) {
    return const AppChrome(
      currentSection: AppSection.studio,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.design_services_outlined, size: 48, color: kcLightGrey),
            verticalSpaceMedium,
            Text(
              'Nothing to preview yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kcWhite,
              ),
            ),
            verticalSpaceSmall,
            Text(
              'Add something to your Vault, then come back to build a CV.',
              style: TextStyle(color: kcLightGrey),
            ),
          ],
        ),
      ),
    );
  }
}
