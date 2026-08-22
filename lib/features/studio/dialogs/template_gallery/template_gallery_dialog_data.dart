import 'package:pdf/pdf.dart';

import 'package:cv_forge/models/render/resolved_cv.dart';

/// What [TemplateGalleryDialog] needs to render a thumbnail per template
/// and mark the current one — passed in as the dialog's
/// [request.data](https://pub.dev/documentation/stacked_services/latest/stacked_services/DialogRequest-class.html).
/// Not a domain model — a transport shape between `StudioViewModel` (which
/// already owns [cv]/[pageFormat]/the active template id) and this dialog,
/// the same role `CopilotRunDialogData` plays for its own dialog.
class TemplateGalleryDialogData {
  const TemplateGalleryDialogData({
    required this.currentTemplateId,
    required this.cv,
    required this.pageFormat,
  });

  final String currentTemplateId;
  final ResolvedCv cv;
  final PdfPageFormat pageFormat;
}
