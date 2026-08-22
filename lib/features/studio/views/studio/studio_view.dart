import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
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

  /// Below this, the three-column desktop layout (nav + editor + preview,
  /// `StudioViewDesktop`) doesn't fit comfortably: `responsive_builder`'s
  /// generic desktop cutoff is 950px of *window* width, not the content
  /// width actually available here (the window minus `AppChrome`'s own
  /// nav rail) — so a window just over that cutoff squeezed the preview
  /// pane down to an unreadably small rendering of the page before ever
  /// switching to the tabbed compact layout, where the preview gets a
  /// full dedicated tab instead of a sliver of a three-way split. Chosen
  /// to comfortably fit the fixed 300px nav column plus a usable minimum
  /// for both the editor and the preview beside it (300 + two 1px
  /// dividers + ~360 each ≈ 1020, rounded up for headroom); measured
  /// against [LayoutBuilder]'s own content-area constraints, which
  /// already exclude the nav rail — unlike the window width
  /// `responsive_builder` compared against, this is the actual space
  /// [StudioViewDesktop] gets.
  static const _desktopMinWidth = 1050.0;

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
      content: () => LayoutBuilder(
        builder: (context, constraints) =>
            constraints.maxWidth >= _desktopMinWidth
            ? const StudioViewDesktop()
            : const StudioViewCompact(),
      ),
    );
  }

  @override
  StudioViewModel viewModelBuilder(BuildContext context) =>
      StudioViewModel(requestedDraftId: draftId);
}
