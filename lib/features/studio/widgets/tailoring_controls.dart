import 'package:cv_forge/ui/common/cv_markup_flutter.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/tokens/app_motion.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

import 'tailorable_field.dart';

/// One [kdTailorHitSize] square in a [TailorIconButtons]-style cluster.
///
/// Both a button and a plain glyph go in one, so the two states of the
/// same slot never differ in width — an undo button appearing where a
/// Vault glyph was must not shift the row it sits in.
class TailorIconSlot extends StatelessWidget {
  const TailorIconSlot({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: kdTailorHitSize,
    child: Center(child: child),
  );
}

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
/// Every slot is exactly [kdTailorHitSize] square, buttons and plain
/// glyphs alike, so the two states of the left slot are the same width
/// and a column of rows lines up on one trailing edge. See that constant
/// for why the tap target is pinned rather than left to `IconButton`'s
/// default or collapsed onto the glyph. The pencil toggles [editing]
/// (owned by the caller, not this widget — see
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
          TailorIconSlot(
            child: IconButton(
              icon: const Icon(RemixIcons.arrow_go_back_line),
              iconSize: kdTailorIconSize,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: kdTailorHitSize,
                height: kdTailorHitSize,
              ),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              tooltip: context.l10n.studioTailoringReverted,
              onPressed: onRevert,
            ),
          )
        else
          TailorIconSlot(
            child: Tooltip(
              message: context.l10n.studioTailoringFromVault,
              child: Icon(
                RemixIcons.safe_line,
                size: kdTailorIconSize,
                color: context.appPalette.placeholder,
              ),
            ),
          ),
        const SizedBox(width: kdTailorIconGap),
        TailorIconSlot(
          child: IconButton(
            icon: Icon(editing ? RemixIcons.check_line : RemixIcons.edit_line),
            iconSize: kdTailorIconSize,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(
              width: kdTailorHitSize,
              height: kdTailorHitSize,
            ),
            color: editing
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            tooltip: editing
                ? context.l10n.commonDone
                : context.l10n.studioTailoringEditText,
            onPressed: onToggleEdit,
          ),
        ),
      ],
    );
  }
}

/// The [TailorIconButtons] counterpart for a field that prints from the
/// Vault and can't be rewritten for one CV — a lock in the left,
/// where-does-this-come-from slot, carrying the reason.
///
/// The right slot holds either nothing, for a field that always prints,
/// or the drop-it toggle for one that doesn't have to. Both keep the slot
/// itself, so a column of mixed rows lines up on a single trailing edge.
/// A locked field that can still be left off is the reason this widget
/// has an action at all: "you can't say something else here" and "you can
/// leave it off" are different claims, and the row makes both.
class VaultLockIcon extends StatelessWidget {
  const VaultLockIcon({
    super.key,
    required this.reason,
    this.omitted = false,
    this.onToggleOmitted,
  });

  final String reason;
  final bool omitted;
  final Future<void> Function()? onToggleOmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TailorIconSlot(
          child: Tooltip(
            message: reason,
            child: Icon(
              RemixIcons.lock_line,
              size: kdTailorIconSize,
              color: context.appPalette.placeholder,
            ),
          ),
        ),
        const SizedBox(width: kdTailorIconGap),
        if (onToggleOmitted case final toggle?)
          TailorIconSlot(
            child: IconButton(
              icon: Icon(
                omitted ? RemixIcons.eye_off_line : RemixIcons.eye_line,
              ),
              iconSize: kdTailorIconSize,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: kdTailorHitSize,
                height: kdTailorHitSize,
              ),
              color: omitted
                  ? context.appPalette.placeholder
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              tooltip: omitted
                  ? context.l10n.studioFieldPrintAgain
                  : context.l10n.studioFieldDoNotPrint,
              onPressed: toggle,
            ),
          )
        else
          const SizedBox(width: kdTailorHitSize),
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
      duration: context.appMotion.fast,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.appRadius.small),
        border: Border.all(
          color: active
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.45)
              : Colors.transparent,
        ),
      ),
      child: child,
    );
  }
}

/// The inline edit box for a [TailorableField] — rendered by
/// `StudioEntryFieldRow` only while its paired [TailorIconButtons] is
/// toggled to editing, and always inside a [TailoringHighlight] so it
/// reads as attached to its row. `AppTextField` already commits on
/// blur/dispose, so there's no explicit "save" action here; the
/// pencil-turned-checkmark in [TailorIconButtons] just collapses the box
/// back down — [onDone] is the same callback, reused so Escape does the
/// same thing as clicking it.
///
/// The one editor for every tailorable field in Studio. [maxLines]/
/// [minLines] are the only thing callers vary, since a summary is
/// legitimately longer prose than a bullet.
///
/// Carries no "only affects this CV" note of its own: several editors can
/// be open at once, which printed it several times, and with none open it
/// said nothing at all. `StudioSectionEditorRouter` states it once for
/// the whole pane instead.
class InlineTextOverrideEditor extends StatelessWidget {
  const InlineTextOverrideEditor({
    super.key,
    required this.field,
    required this.onDone,
    this.maxLines = 4,
    this.minLines = 2,
    this.markup = true,
  });

  final TailorableField field;
  final VoidCallback onDone;
  final int maxLines;
  final int minLines;

  /// Whether this field's text prints on the CV.
  ///
  /// True for every tailorable field, which is what this editor is for.
  /// False for the one caller that borrows it to edit something the CV
  /// never shows — `AiAssistantConfigCard`'s job-description box, which
  /// wraps a pasted job ad in a synthetic [TailorableField]. Offering to
  /// bold a word in a job ad would be offering to change nothing.
  final bool markup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.appSpacing.paddingHairline,
      ),
      child: Focus(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // What the Vault still says, when this CV says otherwise.
            // The undo button beside the row reports *that* a field was
            // tailored but never *from what*, which left no way to see
            // the original short of reverting and losing the rewrite.
            if (vaultOriginal case final original?) ...[
              cvMarkupText(
                context.l10n.commonVaultOriginal(original),
                style: context.appTypography.caption.copyWith(
                  color: context.appPalette.placeholder,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const VGap.tiny(),
            ],
            AppTextField(
              initialValue: field.effectiveText,
              onChanged: field.onChanged,
              // No label of its own: the row that opened this already names
              // the field directly above, and printing it twice read as
              // "Grade" stacked over "Grade".
              maxLines: maxLines,
              minLines: minLines,
              autofocus: true,
              markup: markup,
            ),
          ],
        ),
      ),
    );
  }

  /// The Vault's wording, or null when there is nothing worth showing —
  /// no override, no recorded original, or an original identical to what
  /// is in the box.
  String? get vaultOriginal {
    if (!field.hasOverride) return null;
    final original = field.vaultText?.trim();
    if (original == null || original.isEmpty) return null;
    if (original == field.effectiveText.trim()) return null;
    return original;
  }
}
