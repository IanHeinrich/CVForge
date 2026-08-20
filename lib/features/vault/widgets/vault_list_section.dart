import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/widgets/common/app_summary_card.dart';
import 'package:flutter/material.dart';

import 'vault_section_heading.dart';

/// One titled list of entity summary cards — work history, projects, or
/// education — plus an "add" affordance and an empty-state message. One
/// widget shared by every entity type rather than three near-identical
/// widgets, since the only thing that differs between them is which
/// collection, icon, and copy feed it; [idOf]/[titleOf]/[subtitleOf] are
/// how a given [T] supplies those.
class VaultListSection<T> extends StatelessWidget {
  const VaultListSection({
    super.key,
    required this.title,
    required this.addLabel,
    required this.emptyMessage,
    required this.icon,
    required this.items,
    required this.idOf,
    required this.titleOf,
    required this.subtitleOf,
    required this.openId,
    required this.onOpen,
    required this.onAdd,
    required this.onDelete,
  });

  final String title;
  final String addLabel;
  final String emptyMessage;
  final IconData icon;
  final List<T> items;
  final String Function(T item) idOf;
  final String Function(T item) titleOf;
  final String? Function(T item) subtitleOf;

  /// The id of the item currently open in the editor panel, if any —
  /// drives which card renders selected.
  final String? openId;
  final ValueChanged<String> onOpen;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaultSectionHeading(title: title, onAdd: onAdd, addLabel: addLabel),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: kdPaddingTight),
            child: Text(
              emptyMessage,
              style: const TextStyle(color: kcLightGrey),
            ),
          ),
        for (final item in items)
          AppSummaryCard(
            title: titleOf(item),
            subtitle: subtitleOf(item),
            selected: idOf(item) == openId,
            onTap: () => onOpen(idOf(item)),
            onDelete: () => onDelete(idOf(item)),
            leading: Icon(icon, color: kcLightGrey),
          ),
      ],
    );
  }
}
