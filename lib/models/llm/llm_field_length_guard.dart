/// The one rule both LLM passes enforce on text before it can reach the
/// document: no single field may be big enough to break rendering.
///
/// `package:pdf` cannot paginate a single text widget. A paragraph taller
/// than a page throws rather than splitting, and
/// `PdfExportService.buildPdf`'s retry-without-orphan-protection does not
/// rescue that case (its own comment says so) — so an oversized field
/// takes out the live preview and the export together, leaving a CV the
/// user can edit but cannot see. It has actually happened: a translation
/// response ignored the per-id structure and returned an entire translated
/// CV inside `summary`.
///
/// Neither provider can be made to guarantee this. `JsonSchema` has no
/// length constraint, and Gemini cannot even close an object's key set
/// (see `GeminiProvider._walkSchema`). Client-side acceptance is the only
/// enforcement there is, which is why it lives here rather than in a
/// prompt.
///
/// Rejecting means the field keeps whatever it already said — the Vault's
/// own text, or a previous override. Both passes treat a missing key as
/// "leave this alone" already, so a rejected value simply rejoins that
/// path instead of failing the run.
library;

import 'package:cv_forge/models/render/cv_markup.dart';

/// The largest single field allowed through, counted in the characters
/// that actually reach the page — what [stripCvMarkup] leaves once the
/// emphasis markers come off.
///
/// Sized against the page, not against taste. At the smallest body type
/// any template uses (10pt on A4) a full page of prose is roughly 6,500
/// characters; the largest (12pt, wider margins) holds nearer 4,000. This
/// sits at the lower figure, so a field that passes fits on a page of
/// every template.
///
/// That is still around 600 words — five times any CV summary anyone
/// actually writes, and far beyond the longest bullet. The bound is here
/// to catch a field that has swallowed the document, not to police
/// verbosity.
///
/// Measured after stripping because the bound is sized against the page
/// and a `**` occupies none of it. Counting raw characters would make the
/// limit tighten as someone added emphasis, which is the wrong thing for
/// a limit that exists to keep a field renderable.
const maxRenderableFieldChars = 4000;

/// The raw bound, markers included.
///
/// Not a page constraint — [maxRenderableFieldChars] is that. This exists
/// so a field of nothing but asterisks cannot reach the parser at all:
/// markup can only ever be a constant factor over what it renders, so a
/// string far past this is malformed rather than merely emphatic.
const maxRawFieldChars = maxRenderableFieldChars * 2;

/// [value] as a translation of [source], or null if it is not usable.
///
/// Tighter than [acceptRewrittenField] because translation has something
/// tailoring does not: a known source string, and an output that should
/// resemble it. A field can therefore be judged against its own input
/// rather than only against the page.
///
/// The ratio is deliberately loose. German runs appreciably longer than
/// English and a short label can legitimately several-fold ("Skills" →
/// "Compétences techniques"), so this catches an answer that is a
/// different *kind* of thing from what was asked for, not one that is
/// merely wordy.
String? acceptTranslatedField(String source, Object? value) {
  final text = acceptRewrittenField(value);
  if (text == null) return null;
  // Stripped on both sides: this ratio is measuring how much longer the
  // prose got, and a model that legitimately preserves the source's
  // emphasis — or legitimately drops it — must not move it.
  if (stripCvMarkup(text).length > stripCvMarkup(source).length * 3 + 40) {
    return null;
  }
  return text;
}

/// [value] as a rewritten field, or null if it is not usable.
///
/// The bound is absolute because a tailoring rewrite has no length
/// relationship to its source: the pass exists to change what a line says,
/// it can expand a terse summary or write one where the Vault has none, so
/// there is no ratio to hold it to. All that can be asserted is that the
/// result still fits on a page.
String? acceptRewrittenField(Object? value) {
  if (value is! String) return null;
  if (value.trim().isEmpty) return null;
  if (value.length > maxRawFieldChars) return null;
  if (stripCvMarkup(value).length > maxRenderableFieldChars) return null;
  return value;
}
