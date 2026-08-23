import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// The shared chrome behind both of the Vault's skill↔bullet link pickers:
/// `BulletListEditor`'s `_BulletSkillLinkPicker` (one bullet, many skills)
/// and `SkillsEditorPanel`'s `_SkillBulletLinkPicker` (one skill, many
/// bullets). Those are one control pointed in opposite directions, so the
/// summary row, the expanded surface, and the filter field live here once
/// rather than being restated — and then independently restyled — on each
/// side, which is how the two drifted into describing the same empty state
/// with different words in the first place.
///
/// Presentational only. [expanded] is controlled by whichever panel owns
/// the one-open-at-a-time accordion above it, and the filter text is
/// reported out via [onQueryChanged] rather than applied here, since what
/// a query matches differs per side.
class LinkPickerShell extends StatefulWidget {
  const LinkPickerShell({
    super.key,
    required this.icon,
    required this.label,
    required this.searchHint,
    required this.onQueryChanged,
    required this.expanded,
    required this.onToggleExpanded,
    required this.children,
    this.summary,
  });

  /// Names what this picker links *to* — the Vault's skills star, or its
  /// bullets glyph. The expand chevron sits at the far end of the row
  /// instead, so this slot can say what the row is about rather than
  /// repeating the state the chevron already shows.
  final IconData icon;
  final String label;

  /// The already-linked items spelled out, shown under [label] while
  /// collapsed — reading what a bullet or skill is linked to is the common
  /// case and shouldn't cost a click. Null when nothing is linked yet,
  /// since there'd be nothing to name.
  final String? summary;

  final String searchHint;
  final ValueChanged<String> onQueryChanged;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  /// The picker's own body, rendered under the filter field.
  final List<Widget> children;

  @override
  State<LinkPickerShell> createState() => _LinkPickerShellState();
}

class _LinkPickerShellState extends State<LinkPickerShell> {
  /// Outlives each collapse, unlike the [TextField] itself, which only
  /// exists while [LinkPickerShell.expanded]. Both owning pickers keep
  /// their query across a collapse, so a controller rebuilt empty on every
  /// re-expand would show a blank filter box sitting over a list that is
  /// still filtered.
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    widget.onQueryChanged(value);
    // Local rebuild is for the clear button appearing/disappearing; the
    // text itself is painted by the field off its own controller.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: widget.onToggleExpanded,
          borderRadius: BorderRadius.circular(context.appRadius.small),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.appSpacing.paddingTight,
              vertical: context.appSpacing.paddingHairline,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: context.appIconSize.small,
                  color: kcLightGrey,
                ),
                const HGap.small(),
                Expanded(child: _buildLabel(context)),
                Icon(
                  widget.expanded
                      ? RemixIcons.arrow_up_s_line
                      : RemixIcons.arrow_down_s_line,
                  size: context.appIconSize.medium,
                  color: kcLightGrey,
                ),
              ],
            ),
          ),
        ),
        if (widget.expanded) _buildBody(context),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    final label = Text(
      widget.label,
      style: context.appTypography.caption.copyWith(color: kcLightGrey),
    );
    final summary = widget.summary;
    // Expanded, the chips below already name every linked item, so
    // repeating them here would just be a stale-looking duplicate.
    if (summary == null || widget.expanded) return label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        Text(
          summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTypography.caption.copyWith(color: kcWhite),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(top: context.appSpacing.paddingTight),
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      decoration: BoxDecoration(
        // One tier above the Skills panel's category card
        // (`surfaceContainerLow`), so an expanded picker reads as inset
        // within that card rather than dissolving into it.
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.searchHint,
              prefixIcon: Icon(
                RemixIcons.search_line,
                size: context.appIconSize.medium,
              ),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        RemixIcons.close_line,
                        size: context.appIconSize.medium,
                      ),
                      tooltip: 'Clear search',
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged('');
                      },
                    ),
            ),
            onChanged: _onQueryChanged,
          ),
          const VGap.small(),
          ...widget.children,
        ],
      ),
    );
  }
}
