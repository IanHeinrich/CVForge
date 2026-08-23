import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_skill_selector/studio_skill_selector.dart';

/// The [CvSectionType.skills] editor — a thin wrapper so the router's
/// switch stays a flat list of one editor per section type.
class SkillsSectionEditor extends StatelessWidget {
  const SkillsSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) =>
      StudioSkillSelector(viewModel: viewModel);
}
