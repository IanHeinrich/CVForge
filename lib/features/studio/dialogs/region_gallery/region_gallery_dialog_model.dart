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
  String get title => switch (data.context) {
    RegionGalleryContext.draft => 'Choose a region',
    RegionGalleryContext.appDefault => 'Default region',
  };

  String get introText => switch (data.context) {
    RegionGalleryContext.draft =>
      'Conventions differ by market. This changes how this CV is built — '
          'page size, expected length, and the guidance below. It never '
          'changes what your Vault stores.',
    RegionGalleryContext.appDefault =>
      'Sets the region every new CV starts with. Changing it never touches '
          'a CV you have already created — switch those individually from '
          'Studio.',
  };

  String get confirmLabel => switch (data.context) {
    RegionGalleryContext.draft => 'Use this region',
    RegionGalleryContext.appDefault => 'Set as default',
  };
}
