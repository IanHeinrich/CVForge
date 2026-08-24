/// The job description [AiAssistantRunDialog] runs against, passed in as the
/// dialog's [request.data](https://pub.dev/documentation/stacked_services/latest/stacked_services/DialogRequest-class.html).
/// Not a domain model — purely a transport shape between `StudioViewModel`
/// (which already owns the persisted `CvDraft.targetJobDescription`) and
/// this one dialog.
class AiAssistantRunDialogData {
  const AiAssistantRunDialogData({required this.jobDescription});

  final String jobDescription;
}
