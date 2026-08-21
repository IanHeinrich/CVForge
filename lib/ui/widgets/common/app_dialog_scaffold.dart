import 'package:cv_forge/ui/common/app_colors.dart';
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

  /// Caps the dialog's width for a form-shaped body (e.g. name/notes
  /// fields) that would otherwise stretch to fill a wide viewport. Left
  /// unset for a body that already sizes itself to its content (e.g. a
  /// short confirmation message).
  final double? maxWidth;

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

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: maxWidth == null
            ? body
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: body,
              ),
      ),
    );
  }
}
