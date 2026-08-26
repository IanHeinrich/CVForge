import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The bold and italic buttons for a field that prints on the CV.
///
/// Callbacks rather than the field's `TextEditingController`: pressing a
/// button and pressing the keyboard shortcut have to be the same edit,
/// and the shortcut path also restores the selection the press destroyed
/// and pushes the result to the ViewModel. Reaching for the controller
/// from here did neither, so a bolded word sat unsaved until the field
/// lost focus. `AppTextField._wrap` is the one lever both pull.
///
/// Shown only while its field has focus. Markup is undiscoverable without
/// a control saying it exists, but a row of buttons over every field in a
/// dense Vault panel is noise; revealed on focus, at most one is on
/// screen at a time and it costs nothing at rest.
class MarkupToolbar extends StatelessWidget {
  const MarkupToolbar({
    super.key,
    required this.onBold,
    required this.onItalic,
    this.onExpand,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;

  /// Opens this field in a roomier editor. Null for a single-line field,
  /// which has nothing to gain from more room.
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _MarkupButton(
          icon: RemixIcons.bold,
          tooltip: context.l10n.commonFormatBold,
          onPressed: onBold,
        ),
        const HGap.tiny(),
        _MarkupButton(
          icon: RemixIcons.italic,
          tooltip: context.l10n.commonFormatItalic,
          onPressed: onItalic,
        ),
        if (onExpand case final expand?) ...[
          const HGap.tiny(),
          _MarkupButton(
            icon: RemixIcons.expand_diagonal_line,
            tooltip: context.l10n.commonExpandEditor,
            onPressed: expand,
          ),
        ],
      ],
    );
  }
}

class _MarkupButton extends StatelessWidget {
  const _MarkupButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: context.appIconSize.medium),
      tooltip: tooltip,
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      // Tighter than IconButton's 40dp default, so revealing the row does
      // not shove the field it belongs to down the panel.
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.all(context.appSpacing.paddingHairline),
      constraints: const BoxConstraints(),
    );
  }
}
