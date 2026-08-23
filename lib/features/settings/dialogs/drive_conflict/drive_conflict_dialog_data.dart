/// What [DriveConflictDialog] needs to describe the mismatch — passed in
/// as the dialog's
/// [request.data](https://pub.dev/documentation/stacked_services/latest/stacked_services/DialogRequest-class.html).
/// Not a domain model — a transport shape between `DriveSyncService`
/// (which knows both sides' timestamps) and this dialog, the same role
/// `RegionGalleryDialogData` plays for its own picker.
class DriveConflictDialogData {
  const DriveConflictDialogData({
    required this.accountEmail,
    this.localUpdatedAt,
    this.remoteModifiedAt,
  });

  final String accountEmail;

  /// The more recent of the Vault's/any Draft's own `updatedAt` — null
  /// only if somehow neither has ever been touched, in which case the
  /// dialog falls back to unqualified "This device" copy.
  final DateTime? localUpdatedAt;

  /// Drive's own `modifiedTime` for the file as last fetched — null only
  /// if the metadata read that triggered the conflict somehow didn't
  /// carry one (never expected from a real Drive response).
  final DateTime? remoteModifiedAt;
}
