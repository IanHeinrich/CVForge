import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// Shown when a service's most recent write to local storage failed — the
/// change is only in memory. Inline and dismiss-free by design: it should
/// stay visible for as long as the failure persists, not just flash and
/// disappear like a `SnackBar` would. Shared by every feature with a
/// `persistError` (see `VaultService`/`DraftService`) so a failed write
/// can never go unsurfaced just because nothing happened to wire it up
/// yet — see `CLAUDE.md`'s "never fire-and-forget a write of user data"
/// rule.
class PersistErrorBanner extends StatelessWidget {
  const PersistErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingDefault,
        vertical: context.appSpacing.paddingCompact,
      ),
      decoration: BoxDecoration(
        color: kcErrorColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(context.appRadius.medium),
        border: Border.all(color: kcErrorColor),
      ),
      child: Row(
        children: [
          const Icon(RemixIcons.error_warning_line, color: kcErrorColor),
          const HGap.small(),
          Expanded(
            child: Text(message, style: const TextStyle(color: kcWhite)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
