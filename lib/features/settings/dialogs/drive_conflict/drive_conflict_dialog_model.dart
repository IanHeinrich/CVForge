import 'package:stacked/stacked.dart';

/// Backs [DriveConflictDialog]. No selection state of its own, unlike
/// `RegionGalleryDialogModel` — a conflict has exactly two peer choices,
/// each its own button that completes the dialog immediately, so there's
/// nothing to hold between "select" and "confirm" the way a gallery
/// picker needs.
class DriveConflictDialogModel extends BaseViewModel {}
