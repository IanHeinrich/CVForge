# CVForge

A client-side, privacy-first CV/resume builder for Flutter Web. No backend,
no account, no server — everything you enter stays on your device and never
leaves your browser.

**Live app:** https://ianheinrich.github.io/CVForge/

## What it does

CVForge separates your master career history (**the Vault**) from any one
tailored CV (**the Studio**), so you can curate a targeted CV for a specific
application without editing or losing your full history. Pick which
experiences, projects, skills, and sections go into a draft, preview it as a
real PDF, and export a genuinely ATS-readable file — vector text you can
select and copy, not a rasterized image of your CV.

## Privacy

Nothing you enter is sent anywhere. All data is stored locally in your
browser via IndexedDB, and PDF generation happens entirely on-device — there
is no server component to this app at all. That also means your data is only
as durable as your browser's local storage: clearing site data/history for
this site, or using a private/incognito window, will lose it. There's no
backup or sync (yet).

## Development

See [CLAUDE.md](CLAUDE.md) for conventions: Stacked CLI usage, freezed
models, testing philosophy, and repo-specific gotchas.

```bash
flutter pub get
flutter run -d chrome
```

### Golden tests

```bash
flutter test --update-goldens
```

Golden baselines live under `test/golden/goldens/` and are OS-dependent —
regenerate them via the `update-goldens.yml` GitHub Actions workflow
(`workflow_dispatch`) rather than committing locally-generated PNGs, since a
Windows-rendered baseline can fail on the Linux CI runner over sub-pixel
font rendering differences even with no relevant code change.
