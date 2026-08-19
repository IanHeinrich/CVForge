/// The name/notes pair [EditDraftDialog] collects, passed in as the
/// dialog's initial [request.data](https://pub.dev/documentation/stacked_services/latest/stacked_services/DialogRequest-class.html)
/// and handed back as [DialogResponse.data] on confirm. Not a domain
/// model — purely a transport shape between a caller and this one dialog.
class EditDraftDialogData {
  const EditDraftDialogData({required this.name, required this.notes});

  final String name;
  final String notes;
}
