import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// The chrome shared by every dialog in the app — rounded dark card,
/// title, body, and an end-aligned cancel/confirm button row — so a third
/// dialog can't drift on padding, title style, or button order. Only
/// [children] (the body between title and buttons) is dialog-specific.
class AppDialogScaffold extends StatelessWidget {
  const AppDialogScaffold({
    super.key,
    required this.title,
    required this.children,
    required this.onCancel,
    required this.onConfirm,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.maxWidth,
  });

  final String title;
  final List<Widget> children;

  /// Null disables that button — used by a multi-phase dialog (e.g. the
  /// Copilot run dialog) to block dismissal while a request is in flight,
  /// the same disabled-via-null convention `FilledButton`/`TextButton`
  /// already use.
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final String cancelLabel;

  /// True for an irreversible action (e.g. delete) — the confirm button
  /// uses [kcErrorColor] instead of the theme's default filled-button
  /// color, so the button itself signals the risk.
  final bool destructive;

  /// Caps the dialog's width. Defaults to [_defaultMaxWidth] when unset —
  /// a bare confirmation `Text` has no width of its own to size itself
  /// to, and `Dialog`'s own default constraints don't cap width tightly
  /// enough to stop one stretching to an awkward fraction of a wide
  /// viewport, which is what every dialog that didn't pass this
  /// explicitly (`ConfirmDeleteDialog`, notably) actually did. Pass a
  /// larger value for a form-shaped or grid body that genuinely needs
  /// more room (e.g. the template gallery's 760).
  final double? maxWidth;

  static const _defaultMaxWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.appTypography.titleMedium),
        ...children,
        const VGap.medium(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onCancel, child: Text(cancelLabel)),
            const HGap.small(),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: kcErrorColor)
                  : null,
              onPressed: onConfirm,
              child: Text(confirmLabel),
            ),
          ],
        ),
      ],
    );

    // `Dialog`'s own default `insetPadding` (40px horizontal) plus this
    // scaffold's page padding left almost no room for a wide body (the
    // template gallery's card grid, notably) on a phone-width viewport —
    // narrow enough that fixed-width content overflowed past the dialog's
    // edge rather than shrinking to fit. Below the tablet breakpoint both
    // insets shrink; tablet/desktop keep the original spacing untouched.
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Dialog(
      insetPadding: isMobile
          ? EdgeInsets.symmetric(
              horizontal: context.appSpacing.paddingDefault,
              vertical: context.appSpacing.paddingPanel,
            )
          : null,
      child: Padding(
        padding: EdgeInsets.all(
          isMobile
              ? context.appSpacing.paddingDefault
              : context.appSpacing.paddingPage,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? _defaultMaxWidth),
          child: body,
        ),
      ),
    );
  }
}
