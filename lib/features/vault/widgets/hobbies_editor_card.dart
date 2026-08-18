import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

import 'vault_summary_card.dart';

class HobbiesEditorCard extends StatelessWidget {
  const HobbiesEditorCard({
    super.key,
    required this.hobbies,
    required this.selected,
    required this.onTap,
  });

  final List<HobbyItem> hobbies;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return VaultSummaryCard(
      title: 'Hobbies and interests',
      subtitle: hobbies.isEmpty
          ? 'None yet'
          : hobbies.map((h) => h.text).join(', '),
      selected: selected,
      onTap: onTap,
      leading: const Icon(Icons.hiking_outlined, color: kcLightGrey),
    );
  }
}
