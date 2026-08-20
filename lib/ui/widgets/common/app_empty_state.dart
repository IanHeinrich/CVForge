import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/app_text_styles.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// The icon/title/message/actions anatomy shared by every "nothing here
/// yet" or "something went wrong" placeholder in the app — an empty
/// Vault, an empty Studio preview, an empty Drafts list, a storage
/// failure, a preview render failure. One widget rather than five
/// near-identical `Center(Padding(Column(...)))` trees, so a placeholder
/// can't quietly pick its own icon size or heading weight.
///
/// Self-centering — callers should not wrap this in their own `Center`.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String message;

  /// Rendered as a centered, wrapping row beneath [message] — empty means
  /// no action, just an explanation (e.g. a preview render failure, where
  /// the fix is "try the export button instead", not a button here).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kdPaddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: kcLightGrey),
            verticalSpaceMedium,
            Text(title, textAlign: TextAlign.center, style: ktsTitleLarge),
            verticalSpaceSmall,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kcLightGrey),
            ),
            if (actions.isNotEmpty) ...[
              verticalSpaceMedium,
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
