import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/ui/widgets/common/app_summary_card.dart';

class SkillsEditorCard extends StatelessWidget {
  const SkillsEditorCard({
    super.key,
    required this.categories,
    required this.selected,
    required this.onTap,
  });

  final List<SkillCategory> categories;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final skillCount = categories.fold<int>(
      0,
      (sum, c) => sum + c.skills.length,
    );

    return AppSummaryCard(
      title: 'Skills',
      subtitle: categories.isEmpty
          ? 'No skills yet'
          : '${categories.length} categories, $skillCount skills',
      selected: selected,
      onTap: onTap,
      leading: const Icon(RemixIcons.star_line, color: kcLightGrey),
    );
  }
}
