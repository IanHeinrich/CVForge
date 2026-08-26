/// PDF-side adapter for [parseCvMarkup] — turns the emphasis a user typed
/// into a CV field into styled `pw` spans.
///
/// The framework-free half lives in `models/render/cv_markup.dart`; this
/// is the `pdf` half, the same split `cv_design_tokens.dart` and
/// `cv_design_tokens_pdf.dart` already use.
///
/// **Which fields go through here, and which must not.** Everything a
/// user types and the CV prints: bullets, the summary, the references
/// note, hobbies, skills, language names, the work-authorisation
/// sentence, and every entry header field (role, company, entry location,
/// project and publication titles, citations, qualifications, grades,
/// education details, the headline).
///
/// Deliberately excluded, stated once here rather than restated in four
/// renderers:
/// - `fullName`, `email`, `phone` and the contact-block `location`. An
///   ATS matches these with regexes over the text layer, and markup
///   adjacent to an address is how a match stops happening.
/// - Every URL. A link is also its own `pw.UrlLink` destination, so
///   markup in the printed text but not the destination is a silent
///   divergence between what the page says and where it goes.
/// - Anything pre-formatted by `CvComposer` — `dateRange`, `yearLabel`,
///   a `LanguageProficiency` band — and every `section.title`, which
///   comes from `documentStrings`. None of these are typed by a user, so
///   none can contain markup to begin with.
library;

import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/cv_markup.dart';
import 'cv_design_tokens.dart';
import 'cv_design_tokens_pdf.dart';
import 'cv_font_set.dart';

/// [text]'s emphasis as a flat list of spans, each carrying a fully
/// resolved style.
///
/// Flat with explicit styles rather than a parent span the children
/// inherit from: every existing `pw.TextSpan` in this package already
/// carries its own style, and a flat list is what splices cleanly into
/// the mixed-style rows the renderers build.
///
/// Fresh spans on every call, never cached — `pw` widgets memoise their
/// computed layout box on themselves, so one span instance may not appear
/// at two positions in the tree. See `CvPdfRenderer.pageHeader`.
List<pw.InlineSpan> markupSpans(
  String text,
  CvTypeToken base,
  CvFontSet fonts,
) => [
  for (final run in parseCvMarkup(text))
    pw.TextSpan(text: run.text, style: _styleFor(run, base, fonts)),
];

/// A span of renderer-authored glue — `', '`, `' – '`, `' at '`.
///
/// Never parsed, which is the point: a separator is not something a user
/// typed, so it can never become a delimiter, and it can never let an
/// unclosed `**` in one field bleed emphasis into the next.
pw.InlineSpan literalSpan(String text, CvTypeToken base, CvFontSet fonts) =>
    pw.TextSpan(text: text, style: base.toPdfStyle(fonts));

/// [fields] each parsed independently and joined by an unparsed
/// [separator].
///
/// The alternative — joining first and parsing the result — would let a
/// trailing `*` on one hobby pair with a leading one on the next. Blank
/// fields are dropped, so the separator never doubles up.
List<pw.InlineSpan> markupJoin(
  Iterable<String> fields,
  String separator,
  CvTypeToken base,
  CvFontSet fonts,
) {
  final spans = <pw.InlineSpan>[];
  for (final field in fields.where((f) => f.trim().isNotEmpty)) {
    if (spans.isNotEmpty) spans.add(literalSpan(separator, base, fonts));
    spans.addAll(markupSpans(field, base, fonts));
  }
  return spans;
}

/// A whole standalone line of user text.
///
/// Text with no markup takes the fast path and renders through the exact
/// `pw.Text` it did before this feature existed, which is what makes the
/// change provably byte-neutral for a CV that carries no emphasis — the
/// golden baselines included. `\*` is the only escape, so "contains no
/// asterisk" is precisely "parsing would be a no-op".
pw.Widget markupText(
  String text,
  CvTypeToken base,
  CvFontSet fonts, {
  pw.TextAlign? textAlign,
}) {
  if (!text.contains('*')) {
    return pw.Text(text, textAlign: textAlign, style: base.toPdfStyle(fonts));
  }
  return pw.RichText(
    text: pw.TextSpan(children: markupSpans(text, base, fonts)),
    textAlign: textAlign,
  );
}

/// The run's emphasis laid over [base] rather than replacing it.
///
/// Passing `null` for an absent flag is what makes this additive:
/// `copyWith`'s `weight ?? this.weight` keeps the token's own value, so
/// markup can add bold or italic but can never take it away. That is the
/// right way round — `*x*` inside `classic_centered`'s already-italic
/// `company` token is a no-op, and a template's type scale wins over what
/// someone typed into a field.
pw.TextStyle _styleFor(CvTextRun run, CvTypeToken base, CvFontSet fonts) {
  if (!run.bold && !run.italic) return base.toPdfStyle(fonts);
  return base
      .copyWith(
        weight: run.bold ? CvWeight.bold : null,
        italic: run.italic ? true : null,
      )
      .toPdfStyle(fonts);
}
