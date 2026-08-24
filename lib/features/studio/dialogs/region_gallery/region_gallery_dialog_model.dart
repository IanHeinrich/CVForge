import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:stacked/stacked.dart';

import 'region_gallery_dialog_data.dart';

/// Backs [RegionGalleryDialog] — the same select-then-confirm shape as
/// `TemplateGalleryDialogModel`, so the two document-level pickers behave
/// identically: a tap moves the selection, only the confirm button
/// commits it.
class RegionGalleryDialogModel extends BaseViewModel {
  RegionGalleryDialogModel({required this.data})
    : _selected = data.currentRegion;

  final RegionGalleryDialogData data;

  RegionProfile _selected;
  RegionProfile get selectedRegion => _selected;

  /// Every region, in [RegionProfile]'s own declaration order.
  List<RegionProfile> get regions => RegionProfile.values;

  void selectRegion(RegionProfile region) {
    if (_selected == region) return;
    _selected = region;
    notifyListeners();
  }

  /// The three strings that differ between the dialog's two entry points.
  ///
  /// They live here rather than being passed in as part of
  /// [RegionGalleryDialogData] so the two call sites cannot word the same
  /// decision differently — which is exactly what happened while Settings
  /// had a picker of its own.
  /// This model has no BuildContext, so its copy comes from the
  /// locator-registered service rather than an inherited widget.
  AppLocalizations get strings => locator<LocalizationService>().strings;

  String get title => switch (data.context) {
    RegionGalleryContext.draft => strings.studioRegionPickerTitle,
    RegionGalleryContext.appDefault => strings.studioRegionPickerDefaultTitle,
  };

  String get introText => switch (data.context) {
    RegionGalleryContext.draft => strings.studioRegionPickerBody,
    RegionGalleryContext.appDefault => strings.studioRegionPickerDefaultBody,
  };

  String get confirmLabel => switch (data.context) {
    RegionGalleryContext.draft => strings.studioRegionPickerUse,
    RegionGalleryContext.appDefault => strings.studioRegionPickerSetDefault,
  };
}
