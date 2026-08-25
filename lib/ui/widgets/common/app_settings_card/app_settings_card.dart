import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// The frame every configuration card renders in: a tinted container, a
/// title, and an explanatory line under it.
///
/// Shared by Settings' five cards and by the Vault's CV-defaults panel, so
/// the app's two configuration surfaces read as the same surface. Content
/// cards are a different family — see [AppSummaryCard], which is a tappable
/// row rather than a titled block.
///
/// **This owns the frame and the header only — deliberately not the gap
/// below [body].** Callers supply their own as [children]'s first entry,
/// because they genuinely differ: most want `VGap.medium` before their
/// control, but `AiAssistantSettingsCard` wants `VGap.small` to keep its
/// status line tight against the body text. Folding one of them in here
/// would silently move the other.
class AppSettingsCard extends StatelessWidget {
  const AppSettingsCard({
    super.key,
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;

  /// One line saying what the setting does, under [title].
  final String body;

  /// The controls, starting with this card's own leading gap — see the
  /// class doc comment.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.appSpacing.paddingPanel),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.appTypography.titleMedium),
          const VGap.tiny(),
          Text(body, style: context.appTypography.bodySmall),
          ...children,
        ],
      ),
    );
  }
}
