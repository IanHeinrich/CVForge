import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'studio_view.compact.dart';
import 'studio_view.desktop.dart';
import 'studio_viewmodel.dart';

/// [draftId] is a query param (`/studio?draftId=…`), not a path segment —
/// registering a second `/studio/:draftId` route for the same [StudioView]
/// would collide with the existing bare `/studio` route over the generated
/// `StudioViewRoute` class name (both resolve `page: StudioView`'s own
/// constructor for path params, and a `@PathParam()` field the bare route's
/// path can't supply fails codegen). A query param needs no second route
/// registration, so `/studio` stays the one `CustomRoute` entry in
/// `app.dart`.
///
/// Absent, Studio shows whatever draft `DraftService` currently has active
/// — unchanged pre-existing behaviour. Present, `StudioViewModel` opens
/// that specific draft on load, which is what makes a drafts-list
/// open/create/duplicate action bookmarkable and survive a hard refresh or
/// the browser back button (`DraftsListViewModel` is the only place that
/// constructs a `StudioViewRoute` with one).
class StudioView extends StackedView<StudioViewModel> {
  const StudioView({super.key, @QueryParam() this.draftId});

  final String? draftId;

  @override
  Widget builder(
    BuildContext context,
    StudioViewModel viewModel,
    Widget? child,
  ) {
    return AppChrome.gated(
      section: AppSection.studio,
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.initialise,
      content: () => ScreenTypeLayout.builder(
        mobile: (_) => const StudioViewCompact(),
        tablet: (_) => const StudioViewCompact(),
        desktop: (_) => const StudioViewDesktop(),
      ),
    );
  }

  @override
  StudioViewModel viewModelBuilder(BuildContext context) =>
      StudioViewModel(requestedDraftId: draftId);
}
