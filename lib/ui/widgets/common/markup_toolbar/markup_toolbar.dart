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
    required this.boldActive,
    required this.italicActive,
    this.onExpand,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;

  /// Whether the selection already carries each emphasis, from
  /// [selectionEmphasis]. Required rather than defaulted to false: a
  /// toggle that can be built without being told its state is a toggle
  /// that will silently render as off.
  final bool boldActive;
  final bool italicActive;

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
          active: boldActive,
        ),
        const HGap.tiny(),
        _MarkupButton(
          icon: RemixIcons.italic,
          tooltip: context.l10n.commonFormatItalic,
          onPressed: onItalic,
          active: italicActive,
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
    this.active,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  /// Null for a button that is an action rather than a state — the expand
  /// button, which is never "on".
  final bool? active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final on = active ?? false;
    return IconButton(
      icon: Icon(icon, size: context.appIconSize.medium),
      tooltip: tooltip,
      onPressed: onPressed,
      // Also what tells a screen reader this is a toggle and which way it
      // is set; the colours below are only the sighted half of that.
      isSelected: active,
      style: IconButton.styleFrom(
        // The brand pair, not M3's `secondaryContainer`/`on-` toggle pair:
        // those two slots are seed-derived rather than designed (see
        // `buildAppTheme`), and in the light theme the container lands a
        // shade of the same lavender the editor card is already painted
        // in — an "on" state invisible against its own background.
        // `primary`/`onPrimary` are pinned in both themes.
        foregroundColor: on ? scheme.onPrimary : scheme.onSurfaceVariant,
        backgroundColor: on ? scheme.primary : null,
      ),
      // Tighter than IconButton's 40dp default, so revealing the row does
      // not shove the field it belongs to down the panel.
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.all(context.appSpacing.paddingHairline),
      constraints: const BoxConstraints(),
    );
  }
}
