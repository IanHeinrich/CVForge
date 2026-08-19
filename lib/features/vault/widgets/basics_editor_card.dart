import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/ui/widgets/common/app_summary_card.dart';

class BasicsEditorCard extends StatelessWidget {
  const BasicsEditorCard({
    super.key,
    required this.basics,
    required this.selected,
    required this.onTap,
  });

  final ContactBasics basics;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      basics.headline,
      basics.email,
    ].where((s) => s.isNotEmpty).join(' · ');

    return AppSummaryCard(
      title: basics.fullName.isEmpty ? 'Add your basics' : basics.fullName,
      subtitle: subtitle,
      selected: selected,
      onTap: onTap,
      leading: const Icon(RemixIcons.user_line, color: kcLightGrey),
    );
  }
}
