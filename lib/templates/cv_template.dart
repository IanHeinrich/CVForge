import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'design/cv_design_tokens.dart';
import 'design/cv_font_set.dart';

/// Coarse classification surfaced as chips on a template gallery card —
/// not a styling input, and no renderer reads this. Originally drove the
/// gallery's grouping; dropped once two templates produced one card per
/// group and a mostly-empty dialog (see
/// `TemplateGalleryDialogModel`'s doc comment), so this is informational
/// only now. A new value here is cheap while there are only two templates
/// to update; keep the set small (four or five values) and require every
/// template to declare at least one.
/// [TemplateTag.photo] is the one value here that anything other than the
/// gallery reads: `StudioViewModel.photoRegionWarning` uses it to tell
/// whether the chosen template prints `ContactBasics.photo`, so a market
/// that rejects photographs can be flagged. Keep that the exception — the
/// rest of this enum stays informational.
enum TemplateTag {
  atsSafe,
  academic,
  twoColumn,
  compact,
  traditional,
  modern,
  photo,
}

/// The single-renderer boundary. A template never sees `CvVault`/`CvDraft`
/// — only the [ResolvedCv] `CvComposer` produces — so Studio's live
/// preview (a rasterized render of [buildDocument]'s real output, via
/// `printing.PdfPreview`) and the exported PDF can never drift on content
/// *or* pixels: they're the same bytes.
abstract interface class CvTemplate {
  String get id;
  String get displayName;
  String get description;
  CvDesignTokens get tokens;

  /// Kept on the interface rather than in a separate registry-side map so
  /// a template and its own description of itself can't drift. Rendered
  /// as chips on the template gallery's card — see [TemplateTag]'s doc
  /// comment. Every template must declare at least one.
  Set<TemplateTag> get tags;

  /// This template's suggested section order — a permutation of every
  /// [CvSectionType], not a subset (a case missing from it would silently
  /// drop that section wherever it's used as a seed). Only consulted once,
  /// as the starting order for a brand-new draft (see
  /// `DraftService.createDraft`); an existing draft's print order is its
  /// own `CvDraft.effectiveSectionOrder`, user-reorderable in Studio, and
  /// never re-derived from this getter — switching a draft's template
  /// never reorders its sections. Declared per template rather than as
  /// one global constant because different reference CVs genuinely
  /// suggest sections in a different order (e.g. skills near the top vs.
  /// near the bottom).
  List<CvSectionType> get sectionOrder;

  /// The complete exportable document. [compress] defaults to `true`;
  /// tests pass `false` so the resulting PDF's content streams stay
  /// greppable. MUST hand `pw.MultiPage.build` a FLAT `List<pw.Widget>` —
  /// wrapping the body in a single `pw.Column` silently defeats page
  /// splitting.
  ///
  /// [preventOrphansAndSplits] (default `true`) glues each heading (a
  /// section's, an entry's, a promotion group's) to its first item, and
  /// wraps every bullet individually, in `pw.Inseparable` — see
  /// `assembleSectionWidgets`'s doc comment. Pass `false` only as
  /// `PdfExportService.render`'s fallback after that throws
  /// `PdfException` for a glued block too tall to fit on any one page.
  pw.Document buildDocument(
    ResolvedCv cv,
    PdfPageFormat format,
    CvFontSet fonts, {
    bool compress = true,
    bool preventOrphansAndSplits = true,
  });
}
