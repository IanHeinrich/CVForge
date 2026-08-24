import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'design/cv_design_tokens.dart';
import 'design/cv_font_set.dart';

/// Coarse classification listed on a template gallery card. Informational
/// only, and no renderer reads it. A new value costs an edit to every
/// registered template, so keep the set small and require at least one.
///
/// [TemplateTag.photo] is the one exception: `StudioViewModel
/// .photoRegionWarning` reads it to flag a market that rejects
/// photographs. Keep the rest informational.
enum TemplateTag {
  /// The rendered PDF parses cleanly: real text, single column, no tables
  /// or text-in-image. Strictly a machine-readability claim — a template
  /// whose content carries market risk (a photograph) still earns it if it
  /// parses, and says so in its `description` instead.
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

  /// No `displayName`/`description` here — those are translated, so they
  /// live in the ARB keyed by [id] and are read through
  /// `templateDisplayName`/`templateDescriptionFor`.
  CvDesignTokens get tokens;

  /// On the interface rather than a registry-side map, so a template and
  /// its own description of itself can't drift. At least one required.
  Set<TemplateTag> get tags;

  /// This template's suggested section order — a permutation of every
  /// [CvSectionType], never a subset: a missing case silently drops that
  /// section wherever this seeds one.
  ///
  /// Only consulted when a draft is created. An existing draft prints its
  /// own `CvDraft.effectiveSectionOrder` and never re-derives from here,
  /// so switching template never reorders its sections.
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
