import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/ui/common/l10n/document_language_labels.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../vault_editor_panel_scaffold.dart';

/// Edits what every new CV starts out as — the Vault's one configuration
/// surface, sitting in the same right-hand panel every career-content card
/// opens into.
///
/// Region and template each open the shared gallery rather than a control
/// of their own, the same way Studio's per-CV buttons do: both choices
/// carry a page of consequences worth explaining or showing, and one
/// surface with two entry points cannot drift on how it presents them.
/// Language is a plain dropdown, because choosing one carries neither.
///
/// The section list is the odd one out and is built here rather than
/// shared with Studio's. They look alike but answer different questions:
/// Studio arranges the sections *this draft has data for*, and this
/// arranges every section, for CVs that do not exist yet. Sharing the
/// widget would mean threading a "has data" predicate that is always true
/// on one side, which is how one list ends up quietly serving neither.
class DocumentDefaultsEditorPanel extends StatelessWidget {
  const DocumentDefaultsEditorPanel({
    super.key,
    required this.defaults,
    required this.documentNoun,
    required this.templateId,
    required this.sectionOrder,
    required this.isSectionHidden,
    required this.onClose,
    required this.onChangeRegion,
    required this.onChangeTemplate,
    required this.onLanguageChanged,
    required this.onReorderSections,
    required this.onToggleSectionHidden,
    required this.includeHeadline,
    required this.onToggleHeadline,
  });

  final DocumentDefaults defaults;

  /// `cv` or `resume` — an ICU `select` branch id, not a display word.
  final String documentNoun;

  /// Resolved by the ViewModel, so this is always a template that exists —
  /// see `VaultViewModel.defaultTemplate`.
  final String templateId;

  final List<CvSectionType> sectionOrder;
  final bool Function(CvSectionType) isSectionHidden;

  final VoidCallback onClose;
  final VoidCallback onChangeRegion;
  final VoidCallback onChangeTemplate;
  final ValueChanged<DocumentLanguage> onLanguageChanged;
  final void Function(int oldIndex, int newIndex) onReorderSections;
  final ValueChanged<CvSectionType> onToggleSectionHidden;

  /// Whether a new CV starts with its headline shown.
  final bool includeHeadline;
  final VoidCallback onToggleHeadline;

  @override
  Widget build(BuildContext context) {
    final region = defaults.region;

    return VaultEditorPanelScaffold(
      title: context.l10n.vaultCvDefaultsPanelTitle(documentNoun),
      onClose: onClose,
      children: [
        Text(
          context.l10n.vaultCvDefaultsPanelBody,
          style: context.appTypography.bodySmall,
        ),
        const VGap.medium(),

        _FieldLabel(
          label: context.l10n.vaultCvDefaultsRegionLabel,
          help: context.l10n.vaultCvDefaultsRegionHelp,
        ),
        const VGap.tiny(),
        Row(
          children: [
            RegionFlagStack(
              flags: region.preset.flags,
              size: context.appIconSize.large,
            ),
            HGap.small(),
            Expanded(
              child: Text(
                region.displayName(context.l10n),
                style: context.appTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            HGap.small(),
            OutlinedButton(
              onPressed: onChangeRegion,
              child: Text(context.l10n.vaultCvDefaultsChange),
            ),
          ],
        ),
        const VGap.medium(),

        _FieldLabel(
          label: context.l10n.vaultCvDefaultsLanguageLabel,
          help: context.l10n.vaultCvDefaultsLanguageHelp,
        ),
        const VGap.tiny(),
        DropdownButtonFormField<DocumentLanguage>(
          initialValue: defaults.language,
          isExpanded: true,
          items: [
            for (final language in DocumentLanguage.values)
              DropdownMenuItem(
                value: language,
                child: Text(language.displayLabel(context.l10n)),
              ),
          ],
          onChanged: (language) {
            if (language != null) onLanguageChanged(language);
          },
        ),
        const VGap.medium(),

        _FieldLabel(
          label: context.l10n.vaultCvDefaultsTemplateLabel,
          help: context.l10n.vaultCvDefaultsTemplateHelp,
        ),
        const VGap.tiny(),
        Row(
          children: [
            Icon(
              RemixIcons.layout_2_line,
              size: context.appIconSize.large,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const HGap.small(),
            Expanded(
              child: Text(
                templateDisplayName(context.l10n, templateId),
                style: context.appTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const HGap.small(),
            OutlinedButton(
              onPressed: onChangeTemplate,
              child: Text(context.l10n.vaultCvDefaultsChange),
            ),
          ],
        ),
        const VGap.medium(),

        _FieldLabel(
          label: context.l10n.vaultCvDefaultsSectionsLabel,
          help: context.l10n.vaultCvDefaultsSectionsHelp,
        ),
        const VGap.tiny(),
        // Pinned above the list and outside it, exactly as Studio's own
        // section nav pins its headline row: the headline prints in the
        // name block, so it has no position to drag to.
        _DefaultRow(
          label: context.l10n.vaultCvDefaultsHeadline,
          included: includeHeadline,
          onToggle: onToggleHeadline,
        ),
        _DefaultSectionList(
          sectionOrder: sectionOrder,
          isSectionHidden: isSectionHidden,
          onReorder: onReorderSections,
          onToggleHidden: onToggleSectionHidden,
        ),
      ],
    );
  }
}

/// Every section, in default order, each with a drag handle and a "include
/// by default" checkbox.
///
/// Shrink-wrapped with physics disabled because the panel scaffold already
/// scrolls — a nested scrollable here would strand the rows below it, the
/// same reason `RegionGalleryDialog` gives for not adding one of its own.
class _DefaultSectionList extends StatelessWidget {
  const _DefaultSectionList({
    required this.sectionOrder,
    required this.isSectionHidden,
    required this.onReorder,
    required this.onToggleHidden,
  });

  final List<CvSectionType> sectionOrder;
  final bool Function(CvSectionType) isSectionHidden;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<CvSectionType> onToggleHidden;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: sectionOrder.length,
      onReorderItem: onReorder,
      itemBuilder: (context, index) {
        final type = sectionOrder[index];
        return _DefaultRow(
          key: ValueKey('default_section_${type.name}'),
          label: type.displayLabel(context.l10n),
          included: !isSectionHidden(type),
          onToggle: () => onToggleHidden(type),
          dragIndex: index,
        );
      },
    );
  }
}

/// One row of the defaults list — an "include by default" checkbox, a
/// label, and a drag handle when the row has somewhere to be dragged to.
///
/// Shared by the sections and by the pinned headline row above them, so
/// the one row that cannot be reordered still looks like the rest of the
/// list rather than something bolted on. [dragIndex] is null for that row,
/// which is what drops the handle. Same arrangement as
/// `StudioSectionNav`'s `_NavRow`, which answers the per-draft version of
/// this question — see this file's class doc for why the two lists are
/// not one widget.
class _DefaultRow extends StatelessWidget {
  const _DefaultRow({
    super.key,
    required this.label,
    required this.included,
    required this.onToggle,
    this.dragIndex,
  });

  final String label;
  final bool included;
  final VoidCallback onToggle;
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    final index = dragIndex;
    return Row(
      children: [
        // Matches Studio's own section list: the compact density is what
        // lets the longest labels sit on one line.
        Checkbox(
          value: included,
          onChanged: (_) => onToggle(),
          activeColor: Theme.of(context).colorScheme.primary,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Text(
            label,
            style: context.appTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (index != null)
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsetsDirectional.all(context.appSpacing.gapTiny),
              child: Icon(
                RemixIcons.draggable,
                size: context.appIconSize.tiny,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.help});

  final String label;
  final String help;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.appTypography.titleSmall),
        Text(
          help,
          style: context.appTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
