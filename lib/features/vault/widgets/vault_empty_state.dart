import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// Shown only when the Vault is genuinely empty (see [CvVaultEmptiness]).
/// "Load example CV" uses the exact same fixture the golden tests are
/// built on — so this button and a deterministic test fixture are the
/// same mechanism, not two things that can drift apart.
class VaultEmptyState extends StatelessWidget {
  const VaultEmptyState({
    super.key,
    required this.onStartFromScratch,
    required this.onLoadExample,
  });

  final VoidCallback onStartFromScratch;
  final VoidCallback onLoadExample;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kdPaddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(RemixIcons.safe_line, size: 48, color: kcLightGrey),
            verticalSpaceMedium,
            const Text(
              'Your Vault is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kcWhite,
              ),
            ),
            verticalSpaceSmall,
            const Text(
              'Add your work history, skills, and education here — this '
              'is your master record, separate from any CV you export.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kcLightGrey),
            ),
            verticalSpaceMedium,
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onLoadExample,
                  child: const Text('Load example CV'),
                ),
                FilledButton(
                  onPressed: onStartFromScratch,
                  child: const Text('Start from scratch'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
