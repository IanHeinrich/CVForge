import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// Shown when [VaultViewModel.hasPersistError] is true — a save to local
/// storage failed and the change is only in memory. Inline and dismiss-
/// free by design: it should stay visible for as long as the failure
/// persists, not just flash and disappear like a `SnackBar` would.
class VaultPersistErrorBanner extends StatelessWidget {
  const VaultPersistErrorBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kdPaddingDefault,
        vertical: kdPaddingCompact,
      ),
      decoration: BoxDecoration(
        color: kcErrorColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kcErrorColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kcErrorColor),
          horizontalSpaceSmall,
          const Expanded(
            child: Text(
              "Your last change couldn't be saved.",
              style: TextStyle(color: kcWhite),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
