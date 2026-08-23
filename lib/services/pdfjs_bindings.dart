// ignore_for_file: public_member_api_docs
//
// `dart:js_interop` bindings for `pdfjsLib`, the module `web/pdfjs/
// pdf.min.mjs` exposes on `window` once imported. Modeled on (never
// imports — that package is vendored, patched, and slated for deletion,
// see `third_party/printing/README.md`) `third_party/printing/lib/src/
// pdfjs.dart`'s loading-task-vs-promise shape, extended with the members
// `getTextContent`/`getMetadata`/`getAnnotations`/`getStructTree`/
// `getOperatorList`/`commonObjs` need — none of which `printing`'s own
// binding covers, since it only ever rasterizes.
//
// Binding-correctness notes:
//  - Never declare an `external set` anywhere on this library. Depending
//    on init order, `pdfjsLib` may be the frozen ES module namespace
//    object `import()` resolves to (writes fail — silently on dart2js's
//    sloppy-mode classic script output, with a thrown TypeError on
//    dart2wasm's strict-mode module output). Only `GlobalWorkerOptions.
//    workerSrc` needs to be set, and `GlobalWorkerOptions` is a separate,
//    genuinely mutable object.
//  - `transform`/matrix arrays are `JSArray<JSNumber>`, not `List<double>`
//    — the latter compiles on dart2js by accident and breaks on
//    dart2wasm.
//  - `getDocument()` returns a loading task, not a promise directly —
//    read `.promise`.
//  - `commonObjs.get(id)` only returns real data once `getOperatorList()`
//    (or `render()`) has populated it for that page — guard with `.has()`
//    first, confirmed necessary and sufficient against the real bundle
//    (no callback needed for an already-resolved id).
@JS('pdfjsLib')
library;

import 'dart:js_interop';

@JS('GlobalWorkerOptions')
external PdfJsGlobalWorkerOptions get globalWorkerOptions;

@JS()
external String get version;

@JS()
external PdfJsDocLoader getDocument(PdfJsGetDocumentSettings data);

@anonymous
@JS()
extension type PdfJsGlobalWorkerOptions._(JSObject _) implements JSObject {
  external set workerSrc(String value);
}

@anonymous
@JS()
extension type PdfJsGetDocumentSettings._(JSObject _) implements JSObject {
  external factory PdfJsGetDocumentSettings({required JSUint8Array data});
}

@anonymous
@JS()
extension type PdfJsDocLoader._(JSObject _) implements JSObject {
  external JSPromise<PdfJsDoc> get promise;
}

@anonymous
@JS()
extension type PdfJsDoc._(JSObject _) implements JSObject {
  external JSPromise<PdfJsPage> getPage(int num);
  external JSPromise<PdfJsMetadataResult> getMetadata();
  external int get numPages;
  external bool get isPureXfa;
}

@anonymous
@JS()
extension type PdfJsMetadataResult._(JSObject _) implements JSObject {
  external PdfJsDocInfo get info;
}

@anonymous
@JS()
extension type PdfJsDocInfo._(JSObject _) implements JSObject {
  @JS('Producer')
  external String? get producer;
  @JS('Creator')
  external String? get creator;
  @JS('Language')
  external String? get language;
}

@anonymous
@JS()
extension type PdfJsPage._(JSObject _) implements JSObject {
  external JSPromise<PdfJsTextContent> getTextContent();
  external JSPromise<JSArray<PdfJsAnnotation>> getAnnotations();
  external JSPromise<JSAny?> getStructTree();
  external JSPromise<JSAny?> getOperatorList();
  external PdfJsObjCache get commonObjs;
  external int get rotate;

  /// `[x0, y0, x1, y1]` in default page space — a nonzero `x0`/`y0` means
  /// an offset CropBox origin, an untested case (no tool available to
  /// produce one) worth a coordinate-math guard rather than an
  /// assumption.
  external JSArray<JSNumber> get view;

  /// The page-space → target-space transform for a given render scale —
  /// lets `pdf.js` do the rotation/CropBox math instead of hand-deriving
  /// it. `printing`'s own vendored `pdfjs.dart` binds an equivalent
  /// `getViewport`/`Settings`
  /// pair purely to drive `render()`; this binds the same native method
  /// with a wider settings/result shape (`transform` in particular) since
  /// the X-Ray overlay needs the matrix itself, not just pixel
  /// dimensions.
  external PdfJsViewport getViewport(PdfJsViewportSettings settings);
}

@anonymous
@JS()
extension type PdfJsViewportSettings._(JSObject _) implements JSObject {
  external factory PdfJsViewportSettings({required double scale});
}

@anonymous
@JS()
extension type PdfJsViewport._(JSObject _) implements JSObject {
  /// `[a, b, c, d, e, f]`, the same six-value affine convention as
  /// [PdfJsTextItem.transform] — already includes the y-flip needed for
  /// canvas rasterization (verify empirically before trusting the sign of
  /// anything derived from it).
  external JSArray<JSNumber> get transform;
  external double get width;
  external double get height;
}

@anonymous
@JS()
extension type PdfJsTextContent._(JSObject _) implements JSObject {
  /// Without `includeMarkedContent` (which this binding never requests,
  /// since turning it on changes chunking), every
  /// entry carries `str`/`fontName`/`transform`, but a synthetic
  /// line-boundary marker still shows up as `str: ""` (confirmed against
  /// the real bundle) rather than being a structurally different shape —
  /// filter on `str.isNotEmpty`, not on which fields are present.
  external JSArray<PdfJsTextItem> get items;
}

@anonymous
@JS()
extension type PdfJsTextItem._(JSObject _) implements JSObject {
  external String? get str;
  external String? get fontName;
  external JSArray<JSNumber>? get transform;
  external double? get width;
}

@anonymous
@JS()
extension type PdfJsAnnotation._(JSObject _) implements JSObject {
  external String? get subtype;
  external String? get url;
}

@anonymous
@JS()
extension type PdfJsObjCache._(JSObject _) implements JSObject {
  external bool has(String objId);
  external PdfJsFontObj get(String objId);
}

@anonymous
@JS()
extension type PdfJsFontObj._(JSObject _) implements JSObject {
  external bool? get missingFile;

  /// Fraction of em, PDF font-metric convention (ascent positive, descent
  /// negative) — not populated for every font `pdf.js` reports (e.g. some
  /// standard/substituted fonts), hence nullable; see `AtsFontInfo.ascent`/
  /// `.descent`.
  external double? get ascent;
  external double? get descent;
}
