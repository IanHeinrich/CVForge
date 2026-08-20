import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

import 'tailorable_field.dart';

/// The trailing icon cluster shared by every tailorable row — always
/// exactly two icons, never three: a left slot that's a plain
/// [RemixIcons.safe_line] glyph — matching the Vault nav icon, since this
/// is exactly "this value comes from the Vault" — when the field is still
/// the Vault's, or the **undo** button once it's been tailored, plus the
/// pencil/checkmark on the right. The undo button's mere presence *is* the
/// "this has been tailored" signal — a separate status icon alongside it
/// would say the same thing twice and, stacked above this row, would
/// crowd/shift the layout for no benefit. Same trick as a "reset to
/// default" control that only appears once a setting has been changed:
/// the control's presence is the indicator, no separate badge needed.
///
/// `padding: EdgeInsets.zero` + an unbounded `constraints` collapse each
/// button to exactly [kdTailorIconSize] — `IconButton` otherwise reserves
/// a ~40dp tap target box around a smaller glyph regardless of the
/// glyph's own size, which left visible dead space around it. The pencil
/// toggles [editing] (owned by the caller, not this widget — see
/// `VaultItemSelectorList._editingTextIds`) rather than opening a dialog,
/// so the edit box always appears right next to the field it belongs to.
class TailorIconButtons extends StatelessWidget {
  const TailorIconButtons({
    super.key,
    required this.hasOverride,
    required this.editing,
    required this.onToggleEdit,
    required this.onRevert,
  });

  final bool hasOverride;
  final bool editing;
  final VoidCallback onToggleEdit;
  final VoidCallback onRevert;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasOverride)
          IconButton(
            icon: const Icon(RemixIcons.arrow_go_back_line),
            iconSize: kdTailorIconSize,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: kcLightGrey,
            tooltip: 'Revert to Vault — tailored for this CV',
            onPressed: onRevert,
          )
        else
          Tooltip(
            message: 'From your Vault — not yet tailored',
            child: Icon(
              RemixIcons.safe_line,
              size: kdTailorIconSize,
              color: kcMediumGrey,
            ),
          ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(editing ? RemixIcons.check_line : RemixIcons.edit_line),
          iconSize: kdTailorIconSize,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          color: editing ? kcPrimaryColor : kcLightGrey,
          tooltip: editing ? 'Done' : 'Edit text',
          onPressed: onToggleEdit,
        ),
      ],
    );
  }
}

/// Wraps a tailorable row together with its open editor in one tinted,
/// outlined block, so the editor unambiguously belongs to the row it was
/// opened from rather than floating between two neighbours. Renders the
/// same container in both states (only the decoration changes) so
/// toggling can't restructure the subtree underneath a live
/// `TextEditingController`.
class TailoringHighlight extends StatelessWidget {
  const TailoringHighlight({
    super.key,
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? kcPrimaryColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active
              ? kcPrimaryColor.withValues(alpha: 0.45)
              : Colors.transparent,
        ),
      ),
      child: child,
    );
  }
}

/// The inline edit box for a [TailorableField] — rendered by the caller
/// only while its paired [TailorIconButtons] is toggled to editing, and
/// always inside a [TailoringHighlight] so it reads as attached to its
/// row. `AppTextField` already commits on blur/dispose, so there's no
/// explicit "save" action here; the pencil-turned-checkmark in
/// [TailorIconButtons] just collapses the box back down — [onDone] is the
/// same callback, reused so Escape does the same thing as clicking it.
///
/// The one editor for every tailorable field in Studio, page-level card
/// included — `StudioFieldOverrideCard` builds a [TailorableField] from
/// its own primitives and renders this directly rather than keeping a
/// second copy of the box/Escape/footer wiring. [maxLines]/[minLines]
/// are the only thing callers vary, since a summary is legitimately
/// longer prose than a bullet.
class InlineTextOverrideEditor extends StatelessWidget {
  const InlineTextOverrideEditor({
    super.key,
    required this.field,
    required this.onDone,
    this.maxLines = 4,
    this.minLines = 2,
  });

  final TailorableField field;
  final VoidCallback onDone;
  final int maxLines;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Focus(
            // `canRequestFocus: false` so this node never steals focus
            // from the text field itself — it only sits in the ancestor
            // chain to catch Escape, which a plain `TextField` doesn't
            // consume, as it bubbles up unhandled.
            canRequestFocus: false,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                onDone();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: AppTextField(
              initialValue: field.effectiveText,
              onChanged: field.onChanged,
              label: field.fieldLabel,
              maxLines: maxLines,
              minLines: minLines,
              autofocus: true,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Only affects this CV.',
              style: TextStyle(color: kcLightGrey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
