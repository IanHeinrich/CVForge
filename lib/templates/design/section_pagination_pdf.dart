/// Shared `pw`-only pagination-assembly logic, factored out of both
/// templates' renderers so a second template doesn't have to re-derive
/// the same orphan/split-prevention rule independently.
///
/// The same [assembleSectionWidgets] function is reused at every nesting
/// level that has this shape — a heading followed by a flat list of
/// smaller pieces — not just at the top (section heading + entries), but
/// recursively one level down (an entry's own header + its bullets, and a
/// promotion group's company name + its positions). Confirmed against the
/// actual `package:pdf` 3.13.0 implementation, not assumed: a `pw.Column`
/// handed directly to `pw.MultiPage` as a top-level widget can safely
/// move as a whole to the next page (or throw, if wrapped in
/// [pw.Inseparable] and too tall for any single page) — but a `pw.Column`
/// *nested inside* another `pw.Column` does NOT reliably split further
/// when the outer widget spans: `Flex.layout` hands every child an
/// unbounded max-height regardless of how much page space is actually
/// left, so a single oversized nested child is measured at its full
/// natural size and either overflows silently or (via `Flex`'s
/// unconditional `hasMoreWidgets => true`) drives `pw.MultiPage` into
/// re-rendering the same widget past its 20-page safety cap
/// (`PdfTooBigPageException`). The only way bullets can genuinely split
/// *between* each other across a page break is for each bullet to be its
/// own top-level `pw.MultiPage` widget — never grouped into a nested
/// `pw.Column` "remaining bullets" block, however tempting that looks.
library;

import 'package:pdf/widgets.dart' as pw;

/// Assembles one flattened widget list — [heading] (`null` for a group
/// with no heading of its own, e.g. the Summary section) glued to
/// [body]'s first item, followed by the rest of [body] — so `pw.MultiPage`
/// can place a page break between items without ever leaving [heading]
/// stranded alone at the bottom of a page, or splitting a single item
/// across two pages.
///
/// [gap] is inserted as a `pw.SizedBox` between [heading] and [body]'s
/// first item only when both are present — callers whose heading already
/// ends with its own trailing spacing (a section heading's rule-and-gap,
/// for instance) should leave this at the default zero.
///
/// When [preventOrphansAndSplits] is true (the normal case):
/// - [heading] is glued to [body]'s first item in one `pw.Inseparable`
///   block, so a page break can never separate a heading from everything
///   under it — only later items can end up on the next page, the same as
///   splitting between any other two items in [body].
/// - Every other item is individually wrapped in `pw.Inseparable`, so
///   (when [body]'s items are individual bullets, per this file's own doc
///   comment) a single bullet's text never splits mid-sentence across a
///   page break.
///
/// [preventOrphansAndSplits] is a caller-supplied escape hatch, not a
/// permanent switch: `pw.Inseparable`'s non-spanning path throws a
/// `PdfException` if the atomic block it wraps is taller than a full
/// page — a real (if narrow, now that grouping is per-bullet rather than
/// per-entry) risk, since a heading-plus-first-bullet combination or a
/// single bullet's own text is free-form user content.
/// `PdfExportService.render` catches exactly that and retries with this
/// set to false, which drops both the heading-to-first-item glue and the
/// individual-item wrapping (a heading may strand, an item may end up
/// wherever `pw.MultiPage` naturally places it) rather than failing the
/// export outright.
List<pw.Widget> assembleSectionWidgets({
  required pw.Widget? heading,
  required List<pw.Widget> body,
  required bool preventOrphansAndSplits,
  double gap = 0,
}) {
  final headingGap = heading != null && gap > 0
      ? pw.SizedBox(height: gap)
      : null;

  if (!preventOrphansAndSplits) {
    return [?heading, ?headingGap, ...body];
  }
  if (body.isEmpty) {
    return [?heading];
  }
  final firstBlock = pw.Inseparable(
    child: heading == null
        ? body.first
        : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [heading, ?headingGap, body.first],
          ),
  );
  return [
    firstBlock,
    for (final entry in body.skip(1)) pw.Inseparable(child: entry),
  ];
}
