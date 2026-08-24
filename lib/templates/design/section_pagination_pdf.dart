/// The one implementation of this app's orphan/split-prevention rule for
/// PDF pagination. [assembleSectionWidgets] is reused at every nesting
/// level with the shape "a heading followed by a flat list": section
/// heading + entries, an entry's header + its bullets, a promotion group's
/// company + its positions.
///
/// **A `pw.Column` nested inside another `pw.Column` does not reliably
/// split when the outer one spans.** Confirmed against `package:pdf`
/// 3.13.0's source, not assumed: `Flex.layout` hands every child an
/// unbounded max-height whatever page space is left, and
/// `Flex.hasMoreWidgets` is unconditionally true — so an oversized nested
/// child is measured at full natural size and either overflows silently or
/// drives `pw.MultiPage` past its 20-page cap (`PdfTooBigPageException`).
///
/// So bullets can only genuinely split across a page break when each is
/// its own top-level `pw.MultiPage` widget — never grouped into a nested
/// "remaining bullets" `pw.Column`, however tempting that looks.
library;

import 'package:pdf/widgets.dart' as pw;

/// One flattened widget list: [heading] (`null` for a group with none of
/// its own, e.g. Summary) glued to [body]'s first item, then the rest of
/// [body]. `pw.MultiPage` can break between items without ever stranding
/// [heading] at the foot of a page or splitting one item across two.
///
/// [gap] goes between [heading] and the first item only when both are
/// present; leave it at zero when the heading carries its own trailing
/// spacing.
///
/// With [preventOrphansAndSplits] true, the heading and first item share
/// one `pw.Inseparable` and every later item gets its own, so a single
/// bullet never splits mid-sentence.
///
/// It is an escape hatch, not a switch: `pw.Inseparable` throws
/// `PdfException` when its atomic block is taller than a page, which
/// free-form user content can be. `PdfExportService.render` catches that
/// and retries with false — a heading may then strand, but the export
/// succeeds.
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

/// Joins each entry's flattened widget list with [gap] *between* entries
/// only, never trailing after the last.
///
/// A trailing gap is not harmless: `pw.MultiPage` evaluates every
/// top-level widget independently, including a bare spacer, and one that
/// doesn't fit in the remaining page starts a new page to hold it. A
/// document ending on a `SizedBox` that doesn't fit therefore emits a
/// wholly blank final page. Interleaving keeps the last top-level widget
/// real content.
List<pw.Widget> interleaveWithGaps(List<List<pw.Widget>> entries, double gap) {
  final result = <pw.Widget>[];
  for (var i = 0; i < entries.length; i++) {
    if (i > 0) result.add(pw.SizedBox(height: gap));
    result.addAll(entries[i]);
  }
  return result;
}
