import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
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
    this.cancelLabel,
    this.destructive = false,
    this.maxWidth,
  });

  final String title;
  final List<Widget> children;

  /// Null disables that button — used by a multi-phase dialog (e.g. the
  /// AI Assistant run dialog) to block dismissal while a request is in flight,
  /// the same disabled-via-null convention `FilledButton`/`TextButton`
  /// already use.
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String confirmLabel;

  /// Null means the standard "Cancel" label — see
  /// [AppDeleteIconButton.tooltip] for why this isn't a constructor default.
  final String? cancelLabel;

  /// True for an irreversible action (e.g. delete) — the confirm button
  /// uses `colorScheme.error` instead of the theme's default filled-button
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

  /// `Dialog`'s own built-in default, made explicit here (rather than
  /// left as `insetPadding: null`) so it can be subtracted from the
  /// viewport height below — see [build]'s `maxHeight` comment.
  static const _defaultInsetPadding = EdgeInsets.symmetric(
    horizontal: 40,
    vertical: 24,
  );

  @override
  Widget build(BuildContext context) {
    // Material's own `AlertDialog` structure: a pinned title, a body that
    // scrolls on its own, and a pinned action row. Previously the whole
    // column (title and buttons included) sat inside one
    // `SingleChildScrollView`, so a tall body — the template gallery's
    // card grid, notably — pushed the confirm button off-screen and you
    // had to scroll the entire dialog to reach it. `Flexible` bounds the
    // scrolling body against the `maxHeight` cap below; a dialog shorter
    // than the cap still lays out at its natural height and never
    // scrolls.
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.appTypography.titleMedium),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        const VGap.medium(),
        // OverflowBar, not Row — a confirm label is caller-supplied and
        // has no length guarantee (the template gallery's "Use this
        // template" is already long enough to be marginal on a narrow
        // phone). It lays the two buttons out exactly like the Row this
        // replaced whenever they fit, but stacks them instead of
        // overflowing past the dialog's edge when they don't — the same
        // widget `AlertDialog.actions` itself uses for this.
        OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: context.appSpacing.gapSmall,
          overflowSpacing: context.appSpacing.gapSmall,
          children: [
            TextButton(
              onPressed: onCancel,
              child: Text(cancelLabel ?? context.l10n.commonCancel),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    )
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
    final insetPadding = isMobile
        ? EdgeInsets.symmetric(
            horizontal: context.appSpacing.paddingDefault,
            vertical: context.appSpacing.paddingPanel,
          )
        : _defaultInsetPadding;
    final contentPadding = isMobile
        ? context.appSpacing.paddingDefault
        : context.appSpacing.paddingPage;

    return Dialog(
      insetPadding: insetPadding,
      child: Padding(
        padding: EdgeInsets.all(contentPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? _defaultMaxWidth,
            // Caps the whole dialog (title + body + button row) to
            // whatever height the viewport actually has left after
            // `Dialog`'s own inset and this padding. Without this the
            // body's `Flexible` has nothing to bound against, and a tall
            // body (the template gallery's card grid, on a phone short on
            // height) simply extends past the screen: not clipped with an
            // overflow warning, just silently unreachable. This cap and
            // that `Flexible` are one mechanism — neither works alone.
            maxHeight:
                MediaQuery.sizeOf(context).height -
                insetPadding.vertical -
                contentPadding * 2,
          ),
          child: body,
        ),
      ),
    );
  }
}
