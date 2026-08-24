# The `printing` fork

`printing` is pinned to a fork, not to the pub.dev release:

```yaml
dependency_overrides:
  printing:
    git:
      url: https://github.com/IanHeinrich/dart_pdf.git
      ref: <commit>
      path: printing
```

The fork is <https://github.com/IanHeinrich/dart_pdf>, branch
`printing-5.15.0-pdfjs-baseurl-fix` — the `printing-5.15.0` release tag plus
one commit. `path: printing` picks the `printing` package out of the
`dart_pdf` monorepo; the `ref` is a commit SHA rather than a branch name so
the resolved source can't change under a later `pub upgrade`.

## Why

Reading the `dartPdfJsBaseUrl` JS global — the documented way to point
`PdfPreview`'s web rasterizer at a locally-bundled `pdf.js` instead of the
`unpkg.com` CDN — throws at runtime:

```
TypeError: "...": type 'String' is not a subtype of type 'Never'
```

`lib/printing_web.dart`'s `getProperty(...)` call there is missing its type
argument. Only consumers that actually *set* `dartPdfJsBaseUrl` execute that
branch, which is presumably why it survived release.

CVForge sets it deliberately (`web/index.html` → `./pdfjs/`, see
[`web/pdfjs/README.md`](../web/pdfjs/README.md)) to keep PDF rendering fully
local, in line with the app's "nothing leaves the browser" stance. So this
is a hard blocker, not a nice-to-fix: without the patch, either preview
breaks or every previewed CV round-trips through a third-party CDN.

Tracked upstream as
[DavBfr/dart_pdf#1707](https://github.com/DavBfr/dart_pdf/issues/1707).

## Why a fork rather than a vendored copy

The patch used to live as a full copy of the package under
`third_party/printing/`: ~90 files of someone else's source in this repo,
inside the reach of `dart format --set-exit-if-changed .` and
`flutter analyze`, and with no mechanical link back to the release it was
copied from. A fork keeps the diff to what's actually ours — one commit on
top of a release tag — which is also what makes it cheap to rebase onto a
later `printing-x.y.z` tag.

## Removal

Once a `printing` release carrying the fix reaches pub.dev:

1. Delete the `dependency_overrides` block in `pubspec.yaml`.
2. Bump the `printing:` constraint under `dependencies:` to that release.
3. `flutter pub get`.
4. Delete this file and the references to it (`pubspec.yaml`,
   `web/pdfjs/README.md`, and the `docs/printing-fork.md` mentions under
   `lib/`).

The fork itself can then be deleted, or left as a dead branch — nothing
depends on it after step 1.
