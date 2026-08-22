import 'package:cv_forge/models/render/region_profile.dart';
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
}
