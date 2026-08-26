import 'package:cv_forge/features/vault/widgets/document_defaults_row/document_defaults_row.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

/// Every section, in default order, each with a drag handle and an
/// "include by default" checkbox.
///
/// Deliberately not shared with Studio's section list. They look alike but
/// answer different questions: Studio arranges the sections *this draft
/// has data for*, and this arranges every section, for CVs that do not
/// exist yet. Sharing the widget would mean threading a "has data"
/// predicate that is always true on one side, which is how one list ends
/// up quietly serving neither.
///
/// Shrink-wrapped with physics disabled because the panel scaffold already
/// scrolls — a nested scrollable here would strand the rows below it, the
/// same reason `RegionGalleryDialog` gives for not adding one of its own.
class DocumentDefaultsSectionList extends StatelessWidget {
  const DocumentDefaultsSectionList({
    super.key,
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
        return DocumentDefaultsRow(
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
