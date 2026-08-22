import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/studio/widgets/studio_document_bar/studio_document_bar.dart';
import 'package:cv_forge/features/studio/widgets/studio_tabbed_layout.dart';
import 'studio_viewmodel.dart';

/// Shared by tablet and mobile — too narrow at either breakpoint for the
/// desktop side-by-side split, so both get the same tabbed layout instead.
/// `AppChrome` is applied once, by `StudioView.builder` via
/// `AppChrome.gated`, not here — this is pure content.
class StudioViewCompact extends ViewModelWidget<StudioViewModel> {
  const StudioViewCompact({super.key});

  @override
  Widget build(BuildContext context, StudioViewModel viewModel) {
    return Column(
      children: [
        StudioDocumentBar(viewModel: viewModel),
        Expanded(child: StudioTabbedLayout(viewModel: viewModel)),
      ],
    );
  }
}
