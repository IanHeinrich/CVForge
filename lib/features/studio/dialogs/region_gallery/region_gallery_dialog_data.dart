import 'package:cv_forge/models/region/region_profile.dart';

/// What [RegionGalleryDialog] needs to mark the current region — passed in
/// as the dialog's
/// [request.data](https://pub.dev/documentation/stacked_services/latest/stacked_services/DialogRequest-class.html).
/// Not a domain model — a transport shape between `StudioViewModel` (which
/// owns the draft's active region) and this dialog, the same role
/// `TemplateGalleryDialogData` plays for its own.
///
/// Deliberately thinner than that one: a region card is rendered entirely
/// from [RegionPreset]'s own declared values, so unlike a template
/// thumbnail there's no `ResolvedCv` to hand over.
class RegionGalleryDialogData {
  const RegionGalleryDialogData({required this.currentRegion});

  final RegionProfile currentRegion;
}
