import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
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
    this.messageMaxWidth,
    this.graphic,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Rendered as a centered, wrapping row beneath [message] — empty means
  /// no action, just an explanation (e.g. a preview render failure, where
  /// the fix is "try the export button instead", not a button here).
  final List<Widget> actions;

  /// Caps [message] to a comfortable reading measure. Null (the default)
  /// leaves it unconstrained — every existing message here is already
  /// short enough that this has never mattered; set it for a longer one
  /// that would otherwise stretch to the full available width, the way
  /// the Analyzer upload prompt's did before this was added.
  final double? messageMaxWidth;

  /// Replaces [icon] with an arbitrary widget. This exists for the one
  /// first-run empty state that earns the brand mark (the CVs list, per
  /// `docs/ux/7.6-logo.md`'s decision 7) and should stay rare: the other
  /// placeholders here are *contextual* — no analysis yet, no section
  /// selected — and a brand mark says nothing about those, besides
  /// cheapening itself by appearing everywhere. [icon] stays required so
  /// that a caller passing a graphic still has to name the icon it
  /// replaces, which keeps the two in step if the graphic is ever dropped.
  final Widget? graphic;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.paddingPage,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            graphic ??
                Icon(
                  icon,
                  size: context.appIconSize.xLarge,
                  color: kcLightGrey,
                ),
            const VGap.medium(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.appTypography.titleLarge,
            ),
            const VGap.small(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: messageMaxWidth ?? double.infinity,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kcLightGrey),
              ),
            ),
            if (actions.isNotEmpty) ...[
              const VGap.medium(),
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
