import 'package:cv_forge/models/region/region_profile.dart';

/// Which of the two region decisions [RegionGalleryDialog] is open for.
///
/// The surface is identical either way — same regions, same conventions to
/// explain — and only the copy differs, so the two entry points share one
/// dialog rather than each growing their own. Settings used to have its own
/// chip row, which meant two places wording the same decision and only one
/// of them explaining it.
enum RegionGalleryContext {
  /// Opened from Studio's document bar, changing this one CV's region.
  draft,

  /// Opened from Settings, changing the region new CVs start with.
  appDefault,
}

/// What [RegionGalleryDialog] needs to mark the current region — passed in
/// as the dialog's
/// [request.data](https://pub.dev/documentation/stacked_services/latest/stacked_services/DialogRequest-class.html).
/// Not a domain model — a transport shape between the ViewModel that owns
/// the region being changed and this dialog, the same role
/// `TemplateGalleryDialogData` plays for its own.
///
/// Deliberately thinner than that one: a region row is rendered entirely
/// from [RegionPreset]'s own declared values, so unlike a template
/// thumbnail there's no `ResolvedCv` to hand over.
class RegionGalleryDialogData {
  const RegionGalleryDialogData({
    required this.currentRegion,
    required this.context,
  });

  final RegionProfile currentRegion;
  final RegionGalleryContext context;
}
