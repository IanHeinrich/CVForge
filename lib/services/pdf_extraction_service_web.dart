import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:web/web.dart' as web;

import 'package:cv_forge/models/ats/ats_document_info.dart';
import 'package:cv_forge/models/ats/ats_extracted_document.dart';
import 'package:cv_forge/models/ats/ats_font_info.dart';
import 'package:cv_forge/models/ats/ats_link_annotation.dart';
import 'package:cv_forge/models/ats/ats_text_node.dart';
import 'pdf_extraction_service.dart';
import 'pdfjs_bindings.dart' as pdfjs;

/// The real [PdfExtractionService] — split into its own file specifically
/// so `package:web` (which does not compile under the Dart VM at all) is
/// never imported by anything the VM-run test suite touches. See
/// [PdfExtractionService]'s doc comment for the full reasoning, and
/// `main.dart` for how this gets registered (manually, not through the
/// normal `@StackedApp(dependencies: [...])` list every other service
/// uses, for the same reason).
///
/// `pdf.js` 5.7.284 is already vendored at `web/pdfjs/` and loaded lazily
/// by the `printing` package (see its `lib/printing_web.dart`) via a
/// dynamic `import()` parked on
/// `window.pdfjsLib`. This service reuses exactly that module rather than
/// vendoring a second copy, and coexists with `printing`'s own init:
/// `importModule`'s import-map memoization means whichever of the two
/// runs first "wins" and the other's call resolves to the same module
/// instance — confirmed by inspecting `printing_web.dart`'s own
/// `typeof pdfjsLib !== "undefined" && workerSrc != ""` guard, which this
/// service's [_hasWorkerSrc] check mirrors.
class PdfExtractionServiceWeb implements PdfExtractionService {
  bool _loaded = false;

  @override
  Future<AtsExtractedDocument> extract(Uint8List bytes) async {
    await _ensureLoaded();

    final pdfjs.PdfJsDoc doc;
    try {
      // A fresh copy, never the caller's own bytes directly: getDocument()
      // transfers (detaches) the underlying buffer, confirmed against the
      // bundle. The same source bytes are also handed to
      // `Printing.raster()` for the X-Ray backdrop, so reusing the same
      // typed list here would silently break that second call.
      final copy = Uint8List.fromList(bytes);
      doc = await pdfjs
          .getDocument(pdfjs.PdfJsGetDocumentSettings(data: copy.toJS))
          .promise
          .toDart;
    } catch (e) {
      throw PdfExtractionException(PdfExtractionFailure.invalidPdf, e);
    }

    if (doc.isPureXfa) {
      throw const PdfExtractionException(
        PdfExtractionFailure.unsupportedXfa,
        'XFA forms have no getTextContent() geometry',
      );
    }

    String? producer, creator, language;
    try {
      final meta = await doc.getMetadata().toDart;
      producer = meta.info.producer;
      creator = meta.info.creator;
      language = meta.info.language;
    } catch (_) {
      // Metadata is best-effort — its absence shouldn't fail extraction.
    }

    final nodes = <AtsTextNode>[];
    final fonts = <String, AtsFontInfo>{};
    final links = <AtsLinkAnnotation>[];
    var hasStructTree = false;

    for (var pageIndex = 0; pageIndex < doc.numPages; pageIndex++) {
      final page = await doc.getPage(pageIndex + 1).toDart;
      final items = (await page.getTextContent().toDart).items.toDart;

      for (final item in items) {
        // The synthetic line-boundary/whitespace-only entries `pdf.js`
        // still emits without `includeMarkedContent` show up as `str: ""`
        // rather than a structurally distinct shape — confirmed against
        // the real bundle. They carry no useful geometry
        // (their transform belongs to the next real run's line, not a
        // run of their own), so they're dropped here rather than passed
        // through as zero-width nodes.
        final str = item.str;
        final transform = item.transform;
        if (str == null || str.isEmpty || transform == null) continue;
        if (transform.length < 6) continue;

        nodes.add(
          AtsTextNode(
            pageIndex: pageIndex,
            str: str,
            transform: AtsTextMatrix(
              a: transform[0].toDartDouble,
              b: transform[1].toDartDouble,
              c: transform[2].toDartDouble,
              d: transform[3].toDartDouble,
              e: transform[4].toDartDouble,
              f: transform[5].toDartDouble,
            ),
            width: item.width ?? 0,
            fontName: item.fontName ?? '',
          ),
        );
      }

      try {
        final annotations = await page.getAnnotations().toDart;
        for (final annotation in annotations.toDart) {
          final url = annotation.url;
          if (annotation.subtype == 'Link' && url != null && url.isNotEmpty) {
            links.add(AtsLinkAnnotation(pageIndex: pageIndex, url: url));
          }
        }
      } catch (_) {
        // Annotations are a nice-to-have contact-info source; their
        // absence shouldn't fail extraction.
      }

      try {
        if (await page.getStructTree().toDart != null) hasStructTree = true;
      } catch (_) {
        // Tag detection is a nice-to-have; its absence shouldn't fail
        // extraction.
      }

      // Font metadata (bold/italic/embedded) is only populated on
      // `page.commonObjs` after `getOperatorList()` has run for that page
      // — confirmed necessary against the real bundle.
      try {
        await page.getOperatorList().toDart;
        final seenFontNames = items
            .map((it) => it.fontName)
            .whereType<String>()
            .toSet();
        for (final fontName in seenFontNames) {
          if (fonts.containsKey(fontName)) continue;
          if (!page.commonObjs.has(fontName)) continue;
          final f = page.commonObjs.get(fontName);
          fonts[fontName] = AtsFontInfo(
            missingFile: f.missingFile ?? false,
            ascent: f.ascent,
            descent: f.descent,
          );
        }
      } catch (_) {
        // Font metadata is a nice-to-have; text nodes remain usable
        // without it.
      }
    }

    return AtsExtractedDocument(
      info: AtsDocumentInfo(
        pageCount: doc.numPages,
        producer: producer,
        creator: creator,
        language: language,
        hasStructTree: hasStructTree,
      ),
      nodes: nodes,
      fonts: fonts,
      links: links,
    );
  }

  @override
  Future<AtsTextMatrix> getPageViewportTransform(
    Uint8List bytes, {
    required int pageIndex,
    required double dpi,
  }) async {
    await _ensureLoaded();

    // Same buffer-copy discipline as extract() — getDocument() detaches
    // whatever it's handed.
    final copy = Uint8List.fromList(bytes);
    final doc = await pdfjs
        .getDocument(pdfjs.PdfJsGetDocumentSettings(data: copy.toJS))
        .promise
        .toDart;
    final page = await doc.getPage(pageIndex + 1).toDart;
    // dpi / 72 (PdfPageFormat.inch) — the same scale `Printing.raster()`
    // computes internally (see `printing_web.dart`'s own `raster()`), so
    // this is guaranteed to agree with whatever it actually rasterized.
    final viewport = page.getViewport(
      pdfjs.PdfJsViewportSettings(scale: dpi / PdfPageFormat.inch),
    );
    final t = viewport.transform.toDart;
    return AtsTextMatrix(
      a: t[0].toDartDouble,
      b: t[1].toDartDouble,
      c: t[2].toDartDouble,
      d: t[3].toDartDouble,
      e: t[4].toDartDouble,
      f: t[5].toDartDouble,
    );
  }

  Future<void> _ensureLoaded() async {
    if (_loaded || _hasWorkerSrc()) {
      _loaded = true;
      return;
    }
    final baseUrl = _resolvedBaseUrl();
    try {
      await importModule('${baseUrl}pdf.min.mjs'.toJS).toDart;
    } catch (e) {
      throw PdfExtractionException(PdfExtractionFailure.moduleLoadFailed, e);
    }
    pdfjs.globalWorkerOptions.workerSrc = '${baseUrl}pdf.worker.min.mjs';
    _loaded = true;
  }

  /// Mirrors `printing_web.dart`'s own
  /// `typeof pdfjsLib !== "undefined" && workerSrc != ""` guard so either
  /// side loading first is a no-op for the other.
  bool _hasWorkerSrc() {
    final win = web.window;
    if (!win.hasProperty('pdfjsLib'.toJS).toDart) return false;
    final lib = win.getProperty<JSObject?>('pdfjsLib'.toJS);
    if (lib == null) return false;
    if (!lib.hasProperty('GlobalWorkerOptions'.toJS).toDart) return false;
    final opts = lib.getProperty<JSObject?>('GlobalWorkerOptions'.toJS);
    if (opts == null) return false;
    final src = opts.getProperty<JSString?>('workerSrc'.toJS)?.toDart;
    return src != null && src.isNotEmpty;
  }

  /// Reads the same `window.dartPdfJsBaseUrl` `web/index.html` sets for
  /// `printing` — one source of truth for the pdf.js URL — and resolves
  /// it to an absolute URL before importing. `import()`'s relative-URL
  /// resolution base differs between dart2js (the classic-script
  /// `main.dart.js`, resolved against the document base href) and
  /// dart2wasm (a module, resolved against its own URL); resolving here
  /// removes that divergence rather than relying on the leading `./`
  /// happening to work under both.
  String _resolvedBaseUrl() {
    final win = web.window;
    var raw = './pdfjs/';
    if (win.hasProperty('dartPdfJsBaseUrl'.toJS).toDart) {
      raw = win.getProperty<JSString?>('dartPdfJsBaseUrl'.toJS)?.toDart ?? raw;
    }
    final resolved = Uri.base.resolve(raw).toString();
    return resolved.endsWith('/') ? resolved : '$resolved/';
  }
}
