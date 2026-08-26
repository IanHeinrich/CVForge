import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/markup/markup_selection.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The bold and italic buttons for a field that prints on the CV.
///
/// Both press the same lever the keyboard shortcuts do
/// ([wrapSelectionInMarker]), so a field behaves identically however the
/// formatting was asked for — including toggling back off on a second
/// press rather than accumulating markers.
///
/// Shown only while its field has focus. Markup is undiscoverable without
/// a control saying it exists, but a row of buttons over every field in a
/// dense Vault panel is noise; revealed on focus, at most one is on
/// screen at a time and it costs nothing at rest.
class MarkupToolbar extends StatelessWidget {
  const MarkupToolbar({super.key, required this.controller, this.onExpand});

  final TextEditingController controller;

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
          onPressed: () => wrapSelectionInMarker(controller, boldMarker),
        ),
        const HGap.tiny(),
        _MarkupButton(
          icon: RemixIcons.italic,
          tooltip: context.l10n.commonFormatItalic,
          onPressed: () => wrapSelectionInMarker(controller, italicMarker),
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
