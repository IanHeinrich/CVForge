import 'package:pdf/pdf.dart';

/// Page geometry shared by Studio's two preview modes — the plain rendered
/// page (`StudioPreviewPane`) and the ATS X-Ray (`StudioXrayPane`).
///
/// Lives here rather than in either pane because the two must lay pages
/// out identically: toggling X-Ray on should overlay the document, not
/// resize or re-flow it. Two copies of these numbers is exactly how that
/// would drift.

/// A CV is a printed artefact, so the preview should never render the page
/// larger than its printed size — scaling past 100% shows a zoomed
/// fragment and answers none of the questions ("does it fit on two
/// pages", "how does the whole page look") the preview exists for. 96 is
/// the CSS reference pixel per inch, not the display's real DPI, which the
/// web cannot know.
double printedPageWidth(PdfPageFormat format) =>
    format.width / PdfPageFormat.inch * 96;

/// Horizontal gap between the two pages of a two-up row.
const double previewTwoUpGutter = 24.0;

/// Two-up is a consequence of available width, not a user toggle — the
/// same width-gated shape as Studio's existing desktop/compact split.
bool previewIsTwoUp({required double available, required double pageWidth}) =>
    available >= pageWidth * 2 + previewTwoUpGutter;
