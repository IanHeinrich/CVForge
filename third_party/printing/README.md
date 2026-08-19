# Patched `printing` 5.15.0

A locally-patched copy of the published `printing` 5.15.0 package (identical
source, fetched from `pub.dev`'s archive), overridden via
`dependency_overrides` in the root `pubspec.yaml`.

## Why

`printing`'s web plugin has an upstream bug: reading the `dartPdfJsBaseUrl`
JS global (the documented way to point `PdfPreview`'s web rasterizer at a
locally-bundled `pdf.js` instead of the `unpkg.com` CDN) throws
`TypeError: "...": type 'String' is not a subtype of type 'Never'` —
`lib/printing_web.dart`'s `getProperty(...)` call there is missing an
explicit type argument. Anyone who actually *sets* `dartPdfJsBaseUrl` hits
this; it's presumably gone unnoticed upstream because most consumers use
the default CDN path, which doesn't execute this branch.

cv-forge sets `dartPdfJsBaseUrl` deliberately (`web/index.html`) to keep PDF
preview rendering fully local/offline, in line with the app's "nothing
leaves the browser" privacy stance — so this bug is a hard blocker, not a
nice-to-fix.

Tracked upstream: <https://github.com/DavBfr/dart_pdf/issues/1707> (open,
unmerged fix PR exists on a contributor's fork — not depended on directly
here, since an external fork branch isn't a stable thing to pin a public
deploy's build to). The one-line fix applied here — changing
`getProperty(_dartPdfJsBaseUrl.toJS)` to
`getProperty<js.JSString?>(_dartPdfJsBaseUrl.toJS)!.toDart` in
`lib/printing_web.dart` — mirrors that PR.

## Removal

Once a `printing` release with this fix reaches `pub.dev`:
1. Delete this directory.
2. Delete the `dependency_overrides.printing` entry in the root
   `pubspec.yaml`.
3. Bump the `printing:` version constraint in `dependencies:` if needed.
4. `flutter pub get`.
