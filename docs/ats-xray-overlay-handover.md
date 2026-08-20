# Handover: ATS X-Ray overlay + reading-order flow lines

**Audience:** whoever picks up the deferred half of the ATS format
analyzer (`PR #29`, merged as `216b99b`). This document is meant to be
self-contained — you shouldn't need to dig through chat history or
scratchpad files to start, because the scratchpad probe/corpus from the
spike that shipped v1 did **not** survive past that session. Everything
load-bearing from it is reproduced here.

**Status when this was written:** v1 (upload → findings list, no visuals)
is live. `PR #30` fixed one false-positive in the garbled-text check
(justified-line spacer runs). Nothing X-Ray-related has been started.

## 1. What you're building

Two pieces from the original design, both cut from v1 deliberately (see
`plan.md`'s Phase 5, "What's deferred, and why") because the coordinate
math was flagged as the single biggest correctness risk and shipping it
half-verified was judged worse than shipping the findings list alone:

1. **X-Ray overlay** — the rasterized PDF page as a backdrop, with
   `CustomPainter`-drawn bounding boxes over each extracted text run,
   inside an `InteractiveViewer` (pinch/scroll zoom, pan). Clicking or
   hovering a finding in the results list should highlight its box(es) on
   the page; clicking a box should show what `AtsAnalyzerService` made of
   that run.
2. **Reading-order flow lines** — cubic Bézier lines connecting
   consecutive text runs in `pdf.js`'s own item order (1→2→3→...),
   overlaid on the same X-Ray page. The point is to make a column-crush
   finding *visible*: a naive reader would see the line zigzag between
   columns instead of running cleanly down one side.

A third original idea — a "Parsed Machine Ingestion" panel, i.e. a plain
scrollable list of `AtsTextNode.str` in extraction order, letting a user
see exactly what the machine sees — is much cheaper (no painter, no
coordinate math at all) and worth building first as a warm-up; see §6.

## 2. What exists today — exact current state

Read these files before changing anything; this section just orients you.

- **Models** — `lib/models/ats/`: `AtsTextNode` + `AtsTextMatrix`
  (`ats_text_node.dart`), `AtsFontInfo`, `AtsLinkAnnotation`,
  `AtsDocumentInfo`, `AtsExtractedDocument`, `AtsFinding` +
  `AtsFindingCategory`/`AtsFindingSeverity`, `AtsAnalysisResult`. None
  import `flutter` or `pdf` (a hard rule for `lib/models/`, see
  `CLAUDE.md`). None are persisted.
- **Extraction** — `lib/services/pdf_extraction_service.dart` (abstract
  interface, pure Dart) + `pdf_extraction_service_web.dart`
  (`PdfExtractionServiceWeb`, the real `dart:js_interop` implementation)
  + `pdfjs_bindings.dart` (the `@JS('pdfjsLib')` binding file). **Read
  `PdfExtractionService`'s doc comment before touching DI** — the
  interface/implementation split exists because `package:web` does not
  compile under the Dart VM at all, and `PdfExtractionServiceWeb` is
  registered manually in `main.dart`, not through `@StackedApp`'s
  `dependencies:` list. If you add any new interop-touching class, it
  needs the same treatment or you will break the entire VM-run test
  suite — this happened once already during v1's build and cost real
  time to diagnose.
- **Analysis** — `lib/services/ats_analyzer_service.dart`
  (`AtsAnalyzerService`), pure Dart, fully VM-testable. Tests in
  `test/services/ats_analyzer_service_test.dart` use node fixtures built
  from real captured `pdf.js` geometry — extend this pattern, don't
  invent new coordinate numbers from scratch when you can capture real
  ones (see §9 for how).
- **UI** — `lib/features/analyzer/`: `AnalyzerView` (single layout, no
  breakpoint split — nothing in v1 varies by screen size),
  `AnalyzerViewModel` (`BaseViewModel`, not `Initialisable` — no
  persisted state to load), `AnalyzerUploadPrompt`, `AnalyzerResultsPanel`,
  `AtsFindingCard`. Route `/analyzer`, nav rail entry "ATS Check"
  (`AppSection.analyzer` in `lib/ui/widgets/common/app_chrome/
  app_chrome.dart` — **read that enum's doc comment before adding
  anything to `AppSection`**; destination index/enum-position lockstep is
  a real, previously-hit footgun, not a hypothetical one).

### Data flow today (and where it stops short of what X-Ray needs)

```
FileUploadService.pickPdfFile()
  → Uint8List bytes                      (local var in AnalyzerViewModel._pickAndAnalyze — NOT retained)
  → PdfExtractionService.extract(bytes)
  → AtsExtractedDocument extracted       (local var — NOT retained)
  → AtsAnalyzerService.analyze(extracted)
  → AtsAnalysisResult _result            (the ONLY thing the ViewModel keeps)
```

`AtsAnalysisResult` carries `findings` (title/message/severity/category/
`pageIndex` only) and `totalNodeCount` (an `int`). **It does not carry the
raw nodes, and nothing keeps the original PDF bytes after analysis
finishes.** Concretely, three things are missing before you can paint
anything:

1. **The ViewModel needs to retain the picked bytes and the
   `AtsExtractedDocument`.** Right now both are locals that fall out of
   scope. Add `Uint8List? _pdfBytes` and `AtsExtractedDocument? _extracted`
   fields to `AnalyzerViewModel`, set alongside `_result` in
   `_pickAndAnalyze`. The Machine Ingestion panel and X-Ray overlay both
   need `_extracted.nodes`; X-Ray also needs `_pdfBytes` to raster from.
2. **`AtsFinding` has no link to the node(s)/location that caused it.**
   It only has an optional `pageIndex`. For a click-to-highlight overlay
   you need to know *which* run(s) are implicated. See §7 for a proposed
   shape — don't invent this without reading it, because the four checks
   that produce spatial findings (`columnCrush`, `garbledText`, and
   partially `noTextLayer`) each have a different natural "evidence"
   shape (a baseline pair vs. a single run vs. a whole page), and forcing
   one shape on all of them is where a first attempt usually goes wrong.
3. **No per-page geometry is captured.** `AtsDocumentInfo` has
   `pageCount` and document-level metadata, nothing per-page (width,
   height, rotation). You need this to reconcile PDF-point coordinates
   with raster pixels — see §5.

## 3. The spike facts you need (reproduced, not linked)

The original spike's probe and corpus lived in the session scratchpad and
are gone. These are the facts from it that matter for X-Ray specifically
— re-derive nothing, these are already confirmed against the real
vendored bundle (`web/pdfjs/pdf.min.mjs`, version 5.7.284):

- **`item.transform` (what `AtsTextMatrix` stores) is already in the
  page's default user space** — PDF points, origin bottom-left, y-up.
  It is **not** raster-pixel space (pixels, DPI-scaled, y-down, origin
  top-left). Confirmed by direct inspection of real extracted coordinates
  against known page geometry during the spike. Reconciling the two is
  entirely unbuilt — this is the whole task.
- **`item.height` (`AtsTextMatrix.fontSize`) is `hypot(c, d)`** — the
  rotation-invariant effective em size — confirmed correct on every real
  content run in the spike's corpus. Only empty/EOL marker runs
  (`str.isEmpty`, already filtered out before `AtsTextNode` is built —
  see `PdfExtractionServiceWeb.extract`) report `0`.
- **`item.width`/`height` are advance-box, not ink-box.** Don't draw a
  bounding rectangle directly from them without also pulling
  `ascent`/`descent` — `pdfjs_bindings.dart` doesn't currently bind
  `styles[fontName].ascent`/`.descent` (`PdfJsTextContent`/
  `PdfJsFontObj` don't expose them yet); you'll need to add that binding.
  Without it every box will sit with its top/bottom at the wrong place
  relative to the glyph ink.
- **A rotated run is real and already representable.** The spike's
  `rotated_sidebar.pdf` synthetic fixture (see §9 to regenerate it) had a
  sidebar label drawn via a content-level rotation (CTM `b`/`c` nonzero,
  not a page-level `/Rotate` entry) — confirmed `AtsTextMatrix.
  rotationRadians` (`atan2(b, a)`) computes correctly for it. **A true
  page-level `/Rotate` and a non-zero CropBox origin were never
  exercised** — no tool was available to produce one. Both are real cases
  real-world PDFs have; budget time to test them, don't assume the
  approach in §5 generalizes untested.
- **Buffer detachment is real and already handled on the extraction
  side, but not on the raster side.** `getDocument()` transfers
  (detaches) the `Uint8List` buffer it's given.
  `PdfExtractionServiceWeb.extract()` already defends against this
  (`Uint8List.fromList(bytes)` before every `getDocument()` call — see
  its doc comment). **`Printing.raster()` (in the vendored
  `third_party/printing/lib/printing_web.dart`) does not do this — it
  hands your `Uint8List` straight to `getDocument()`.** If you raster and
  extract from the same retained `_pdfBytes` field (which you will, per
  §2), pass a fresh `Uint8List.fromList(_pdfBytes!)` to *each* call, not
  the field directly, or the second call gets a detached buffer.

## 4. UI shape — what "done" looks like

Recommend following the Studio precedent for a two-pane feature:
`StudioViewDesktop` (side-by-side) / `StudioViewCompact` (tabbed, shared
by tablet+mobile) — see `lib/features/studio/views/studio/
studio_view.desktop.dart` / `.compact.dart`. Unlike v1's `AnalyzerView`
(single layout, nothing varies by breakpoint), X-Ray genuinely needs a
split on wide screens and tabs on narrow ones, so the
`CLAUDE.md` rule against gratuitous breakpoint variants doesn't apply
here — this is a case where the layouts really do differ.

Left/first pane: the existing findings list (`AnalyzerResultsPanel`,
extended so each `AtsFindingCard` gets a "Show in X-Ray" action once
evidence-linking exists — §7). Right/second pane: the X-Ray view itself —
raster backdrop, `CustomPainter` boxes, `InteractiveViewer` zoom/pan,
flow lines toggle. A third, simpler view (plain scrollable text, no
painter) for the "Machine Ingestion" panel could be a tab alongside the
X-Ray pane rather than a third top-level pane.

## 5. The coordinate reconciliation — the actual hard part

**Recommended approach: let `pdf.js` do the rotation/CropBox math, don't
hand-derive it.** `pdf.js`'s `page.getViewport({scale})` already handles
page rotation and CropBox origin correctly — that's exactly the class of
bug (getting the flip/rotation formula subtly wrong for an edge case you
didn't test) the spike flagged as the biggest risk. Ask `pdf.js` for the
matrix instead of re-implementing it.

### 5.1 — What to add to the interop layer

`pdfjs_bindings.dart` doesn't currently bind `getViewport()` (it's
unused today — `PdfExtractionServiceWeb` never calls it). Add:

```dart
@anonymous
@JS()
extension type PdfJsViewportSettings._(JSObject _) implements JSObject {
  external factory PdfJsViewportSettings({required double scale});
}

@anonymous
@JS()
extension type PdfJsViewport._(JSObject _) implements JSObject {
  external JSArray<JSNumber> get transform;
  external double get width;
  external double get height;
}
```

and on `PdfJsPage`:

```dart
external PdfJsViewport getViewport(PdfJsViewportSettings settings);
```

(`printing`'s own vendored binding at `third_party/printing/lib/src/
pdfjs.dart` already has an equivalent `Settings`/`getViewport` shape you
can look at for the pattern — **do not import it**, it's vendored,
patched, and slated for deletion; copy the shape, not the dependency,
same rule the rest of `pdfjs_bindings.dart` already follows.)

### 5.2 — What to add to `PdfExtractionService`

A new method, separate from `extract()` — don't bolt this onto the main
extraction pass, it's a different concern with a different cost profile
(one call per page-you're-about-to-render, not once per document):

```dart
abstract class PdfExtractionService {
  Future<AtsExtractedDocument> extract(Uint8List bytes);

  /// The page-space → pixel-space transform for one page at [dpi],
  /// exactly matching what `Printing.raster(bytes, [pageIndex], dpi)`
  /// rasterizes — call with the same dpi you pass to raster.
  Future<AtsTextMatrix> getPageViewportTransform(
    Uint8List bytes, {
    required int pageIndex,
    required double dpi,
  });
}
```

Implementation in `PdfExtractionServiceWeb` — mirror `extract()`'s own
buffer-copy discipline, open the doc, get the one page, call
`getViewport(PdfJsViewportSettings(scale: dpi / 72))` (72 = PDF points
per inch, matches `PdfPageFormat.inch` in `package:pdf` and matches what
`printing_web.dart`'s own `raster()` does internally — `dpi /
PdfPageFormat.inch` — so this is guaranteed to agree with whatever
`Printing.raster()` actually rastered), and marshal `viewport.transform`
into an `AtsTextMatrix` the same way `extract()` marshals `item.transform`.

**Why re-open the document instead of caching something from `extract()`:**
it was tempting to capture the viewport transform once at `scale: 1`
during the main `extract()` pass and rescale it by `dpi/72` later by
multiplying all six components — this is probably valid (PDF viewport
scale is documented as a uniform multiplier) but **was never verified
against a rotated/offset-CropBox page**, and a wrong assumption here
produces boxes that are subtly, plausibly-almost-right — the worst kind
of bug to catch in review. Re-fetching via interop is one extra ~10ms
round-trip per page-view, not per-node — not worth the risk for the
saving. If you want the optimization later, verify the multiplier
hypothesis first (raster the same rotated test page at two different
DPIs, compare `viewport.transform` component-for-component) and only
then cache+rescale.

### 5.3 — Composing the two matrices

Both `AtsTextNode.transform` and the new page-viewport transform are the
same `AtsTextMatrix` shape (`a b c d e f`, PDF's standard affine-matrix
convention: point transform is `[x y 1] · [[a b 0][c d 0][e f 1]]`).
Composing "apply the item's own transform, then the viewport transform"
— i.e. `result = item ∘ viewport` in that order — is:

```
a' = item.a * viewport.a + item.b * viewport.c
b' = item.a * viewport.b + item.b * viewport.d
c' = item.c * viewport.a + item.d * viewport.c
d' = item.c * viewport.b + item.d * viewport.d
e' = item.e * viewport.a + item.f * viewport.c + viewport.e
f' = item.e * viewport.b + item.f * viewport.d + viewport.f
```

This is the standard PDF matrix-composition formula (what `pdf.js`'s own
`Util.transform` computes) — six lines, pure Dart, put it as a method or
top-level function next to `AtsTextMatrix` (or in a new small
`lib/models/ats/ats_matrix_math.dart` if you'd rather keep `AtsTextMatrix`
itself free of transform-composition logic — either is fine, just don't
duplicate the six lines at each call site). **This is fully VM-testable
in isolation** — feed known item/viewport matrices, assert the exact
composed result — write that test before you write a single line of
painter code; it's the part most likely to have a sign or order error
and cheapest to catch with a unit test.

The composed matrix's `(e', f')` is the run's origin in **pixel space,
but still PDF-convention y-up** (pdf.js's viewport transform already
includes the y-flip needed to make canvas rasterization correct, so once
composed, `(e', f')` should already be canvas/pixel-space y-down — verify
this empirically against one real rasterized page rather than trusting
this paragraph, since it's the one place in this whole document that's
reasoning about pdf.js's internal convention rather than something
directly observed in the spike).

### 5.4 — The ink-box gap

Once you have the composed matrix, `(e', f')` is a baseline point, not a
box corner. You need `ascent`/`descent` (from `styles[fontName]` in
`getTextContent()`'s result, or from `commonObjs.get(fontName)` after
`getOperatorList()` — both already partially plumbed, see
`PdfExtractionServiceWeb`'s font-info block) to turn a baseline + advance
width into an actual rectangle: top edge at `baseline - ascent*fontSize`,
bottom edge at `baseline + descent*fontSize` (sign depends on which
space you're in — verify against a real render, don't guess the sign).
`pdfjs_bindings.dart`'s `PdfJsTextContent`/font-object bindings don't
expose `ascent`/`descent` today; add them.

## 6. Recommended build order

Don't build the whole thing before the first pixel is on screen. In
order:

1. **Machine Ingestion panel first** — zero coordinate math, just
   `_extracted.nodes.map((n) => n.str)` in a scrollable list, grouped by
   page. This alone requires the ViewModel plumbing from §2 point 1, and
   gives you something real to show while the harder part is still being
   built.
2. **One rectangle on one word, proof-of-concept.** Raster page 1 of a
   real PDF at a fixed DPI (say 150), display it in a plain `Image`
   widget (no `InteractiveViewer` yet), hardcode picking the *first* real
   `AtsTextNode` on that page, run it through §5's composition, draw
   *one* `Positioned` colored `Container` (not even a `CustomPainter`
   yet) at the computed rect. This is deliberately the spike's own
   documented exit criterion for X-Ray ("one correctly-placed bounding
   rectangle on a rasterized page") — treat it as a real go/no-go
   checkpoint, not a formality. Test it against **the rotated fixture**
   (§9), not just an easy unrotated single-column page — an unrotated
   page will hide a sign error that a rotated one won't.
3. **All boxes, still no painter** — same approach, one `Positioned`
   `Container` per node, to validate the composition holds across every
   node on a page before investing in a `CustomPainter`.
4. **Swap to `CustomPainter`** once (3) is visually confirmed —
   `Positioned` widgets don't scale to hundreds of nodes, but they're
   much faster to debug than a painter while you're still finding
   coordinate bugs.
5. **`InteractiveViewer`** for zoom/pan. `third_party/printing/lib/src/
   preview/custom.dart`'s `_zoomPreview()` is the only `InteractiveViewer`
   usage in this dependency tree — useful for the cursor-affordance
   details (`grab`/`grabbing` `MouseCursor`s gated on `kIsWeb`) but it's
   vendored, patched, slated for deletion — copy the *idea*, never import
   it.
6. **Evidence linking on findings** (§7) — wire `AtsFindingCard`'s "Show
   in X-Ray" to actually scroll/zoom to the right box.
7. **Flow lines last.** They're the most purely cosmetic piece and the
   least load-bearing for the feature's actual value (a user can already
   see the crush from the boxes' positions once boxes work). Cubic Bézier
   control points: a reasonable default is placing control points at
   `(midpoint.x, from.y)` and `(midpoint.x, to.y)` between consecutive
   node centers — check readability once real crushed-line data is on
   screen before over-engineering the curve shape. Watch performance:
   the spike measured up to ~400 nodes on a dense single page; test flow
   lines at that density before deciding whether they need throttling or
   simplification (e.g., only drawing lines that cross a large x or y
   jump, not every consecutive pair).

## 7. Evidence linking on `AtsFinding` — a starting shape

Don't ship X-Ray without this; a findings list with no way to see *where*
each problem is defeats the point of a visual overlay. Proposed addition
to `lib/models/ats/ats_finding.dart` — a value type, not a full node
reference (keep `AtsFinding` cheap to construct and comparable):

```dart
@freezed
abstract class AtsFindingEvidence with _$AtsFindingEvidence {
  const factory AtsFindingEvidence({
    required int pageIndex,
    required int nodeIndex, // index into AtsExtractedDocument.nodes for that page, or a stable id if you add one
  }) = _AtsFindingEvidence;
}
```

added to `AtsFinding` as `@Default(<AtsFindingEvidence>[]) List<AtsFindingEvidence> evidence`.
Each check in `AtsAnalyzerService` populates it differently:

- `columnCrush` — the two (or more) nodes on the shared baseline that
  triggered the gap check (`_checkColumnCrush` already has `left`/`right`
  in scope at the point it builds the finding).
- `garbledText` — the specific node(s) with the replacement char / PUA /
  phantom-glyph signature. Note the current implementation aggregates
  counts across the whole document into one finding per sub-category
  (`replacementCount`, `embeddedPuaCount`, `phantomGlyphCount`) rather
  than one finding per offending node — you'll likely want to change
  this to one finding per node (or per cluster) once evidence-linking
  exists, since "here are 3 garbled characters" is much less useful than
  "here are the 3 locations" when there's a visual to point at. This is
  a real behavior change to `_checkGarbledText`, not just an additive
  one — plan for it, and update `ats_analyzer_service_test.dart`
  accordingly.
- `noTextLayer` — page-level, no node evidence exists by definition
  (that's the whole finding). Leave `evidence` empty; the overlay should
  show "no text detected" some other way for this category (e.g., an
  empty-state message in the X-Ray pane instead of boxes).
- `missingHeadings` / `contactInfo` — document-level/heuristic findings,
  no natural node evidence either (or, for `contactInfo`, could
  optionally point at the `mailto:`/`tel:` link's page if a Link
  annotation resolved it — nice-to-have, not required).

## 8. Testing strategy

- **Matrix composition (§5.3):** plain VM unit test, no fixtures needed
  — hand-construct two `AtsTextMatrix` values with known rotation/
  translation, assert the exact composed output against numbers you
  compute by hand or with a second method (e.g. `vector_math`'s
  `Matrix3` if you want a cross-check, though don't add it as a runtime
  dependency just for this — a spreadsheet or Python one-liner to
  independently compute the expected matrix is enough for a test
  fixture).
- **The ink-box derivation (§5.4):** same — VM-testable given known
  ascent/descent/baseline inputs.
- **The real interop (`getViewport`, buffer handling):** untestable
  under `flutter test`, same as the rest of `PdfExtractionServiceWeb` —
  verify manually against the real running app, same technique used to
  verify v1 (see §9 for exactly how, since it's a real, repeatable
  recipe now, not something to reinvent).
- **The painter itself:** no established convention in this codebase yet
  (this will be the first `CustomPainter`) — a golden test comparing
  rendered output for a fixed, small `AtsExtractedDocument` fixture is
  the most direct option once the models are stable; a plain widget test
  asserting `shouldRepaint` behavior (mirroring `StudioPreviewPane`'s
  debounce-and-settle pattern, `lib/features/studio/widgets/
  studio_preview_pane.dart`) is worth doing regardless of whether you add
  a golden.

## 9. How to verify against a real PDF without a file-picker in the loop

The v1 build was verified end-to-end without ever driving a real file
picker (browser automation can't drive OS file dialogs). The recipe,
reusable for X-Ray:

1. Start the dev server: `flutter run -d web-server --web-port <port>`
   (or the `Claude_Browser` `preview_start` tool with a `.claude/
   launch.json` entry).
2. In the browser dev tools / `javascript_tool`, once the app has loaded
   `pdf.js` at least once (any prior analysis triggers this — or force
   it), `window.pdfjsLib` is populated and `window.pdfjsLib.
   GlobalWorkerOptions.workerSrc` is set. You can then call the exact
   same `getDocument`/`getTextContent`/`getViewport`/etc. sequence
   directly from the JS console against a base64-embedded real PDF's
   bytes, reproducing precisely what the Dart interop layer does, without
   needing a file dialog. This is how the phantom-glyph false positive in
   `PR #30` was actually diagnosed — capture every short/flagged run's
   exact `str`/`width`/`transform` this way rather than guessing from
   source code.
3. For a rotated/CropBox test case, you need a real fixture (see below)
   — `page.rotate` and `page.view` in the JS console will tell you
   immediately whether a given test PDF actually exercises what you
   think it does before you spend time debugging the Dart side.

### Regenerating the spike's synthetic corpus

The generator script (`gen_corpus.dart`) was scratchpad-only and did not
survive. It used `package:pdf` (already a repo dependency) directly, run
standalone via
`dart run --packages=<repo>/.dart_tool/package_config.json gen_corpus.dart`
from outside the repo (so it's never accidentally part of the app). The
rotated fixture specifically — the one case you actually need for §5 —
was built like this (reconstruct the rest of the file, or just this
function, as needed; this is the load-bearing part):

```dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> rotatedSidebar() async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Stack(
        children: [
          pw.Positioned(
            left: 20,
            top: 300,
            child: pw.Transform.rotate(
              angle: 1.5708, // 90 degrees, radians — CTM b/c nonzero
              child: pw.Text(
                'CONFIDENTIAL DRAFT',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 60),
            child: pw.Text('Jordan Alex Rivera', style: const pw.TextStyle(fontSize: 16)),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
```

This produces **content-level** rotation (CTM `b`/`c` nonzero), not
page-level `/Rotate` — you additionally need a **page-level** rotated
fixture, which `package:pdf` doesn't have a direct API for as far as was
found during the spike (worth checking again — this may have changed, or
there may be a lower-level `PdfPage` property to set directly via
`pdf.dart`'s non-widget API). If you can't produce one with `package:pdf`,
either hand-edit a minimal PDF's `/Rotate` entry directly (it's a small,
human-editable text format for a simple single-object page dict) or find
a real-world sample. **Don't skip this case** — it's structurally
different from content-level rotation (it rotates the whole page's
default coordinate system, including what `page.view`/CropBox means),
and §5's `getViewport()`-based approach is specifically supposed to
handle it for free, which is exactly the kind of claim that needs a real
test before you trust it.

Regenerate the other four spike fixtures (`single_column.pdf`,
`two_column_crush.pdf`, `pua_bullets.pdf`, `image_only_scan.pdf`) the
same way if you want them back for reference — none are strictly needed
for X-Ray work specifically, but the two_column one is a good stress
case for flow-line readability (§6 step 7).

Whatever you generate, **do not commit real-world corpus PDFs to the
repo** (potential PII) — synthetic ones built this way are fine to check
in under `test/fixtures/` if you want them to survive this time, since
nothing in them is real personal data.
