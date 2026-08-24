import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// The "BETA" chip sitting beside a feature's heading.
///
/// Shared rather than per-feature because it is a statement about the
/// app's confidence in a feature, not about the feature itself — two
/// badges that drifted apart in colour or wording would read as two
/// different degrees of "beta", which is not a distinction this app makes.
/// Both LLM-backed features (tailoring and translation) carry it.
class AppBetaBadge extends StatelessWidget {
  const AppBetaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.appPalette.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(context.appRadius.small),
        border: Border.all(
          color: context.appPalette.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        context.l10n.commonBeta,
        style: context.appTypography.caption.copyWith(
          color: context.appPalette.warning,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
