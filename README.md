<div align="center">

<img src="docs/images/logo.png" alt="" width="112">

# CVForge

**Tailor a CV to every application — without losing your history.**

A client-side, privacy-first CV builder for the web. No backend, no account,
no tracking. Everything you type stays in your browser.

[![CI](https://github.com/IanHeinrich/CVForge/actions/workflows/ci.yml/badge.svg)](https://github.com/IanHeinrich/CVForge/actions/workflows/ci.yml)
[![Deploy](https://github.com/IanHeinrich/CVForge/actions/workflows/deploy.yml/badge.svg)](https://github.com/IanHeinrich/CVForge/actions/workflows/deploy.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

**[Open the app](https://ianheinrich.github.io/CVForge/)**

[Features](#features) · [Getting started](#getting-started) ·
[Architecture](#architecture) · [Contributing](CONTRIBUTING.md)

</div>

---

## The idea

Most CV tools make you keep one CV and edit it into the ground. Every time you
tailor it for a role, you lose something you might have wanted next time.

CVForge splits the two jobs apart:

- **The Vault** is your master record — every role, project, bullet point,
  skill, publication and qualification you have ever had. It is never what you
  send anyone.
- **The Studio** is where you build one CV for one application, by picking
  from the Vault. Toggle sections, choose which bullets make the cut, reorder
  them, and watch a real PDF update as you go.

Delete a bullet from a CV and it is still in your Vault. Build twenty CVs from
one history without a single copy-paste.

<div align="center">
<img src="docs/images/studio.png" alt="The Studio: section picker, bullet selection, and a live PDF preview" width="900">
</div>

---

## Features

### Vault — your master record

Work history with per-role bullets, projects, skills grouped into categories,
education, publications, references and hobbies. Bullets can be linked to
skills, so selecting a skill for a CV can pull in the evidence that backs it.

<div align="center">
<img src="docs/images/vault.png" alt="The Vault, with an entry open in the editor panel" width="900">
</div>

### Studio — one CV per application

Pick sections and individual bullets, reorder them, and preview the result as
a real PDF. The preview *is* the export — Studio rasterises the same bytes
that `Export PDF` writes, so what you see cannot drift from what you send.

<div align="center">
<img src="docs/images/cvs.png" alt="The CVs grid, each card showing a rendered first page" width="900">
</div>

### Genuinely ATS-readable output

Exports are vector PDFs with selectable, copyable text — not an image of a CV.
Two templates ship today, both single-column by design, because multi-column
layouts are what most often confuse a resume parser:

| Template | Shape |
|---|---|
| **Compact** | Clean, single-column, sans-serif. Built to pass through ATS parsers without friction. |
| **Traditional** | Centred, whitespace-led, with a two-row entry header and a justified summary. |

<div align="center">
<img src="docs/images/templates.png" alt="The template gallery, previewing each template against your own CV" width="820">
</div>

### ATS Check — x-ray any PDF

Upload *any* existing CV, not just one CVForge made, and see what a resume
parser sees. **X-Ray** highlights the format problems that make extractors
misread a document — the big one being multi-column layouts, where two columns
sharing a baseline get merged into one nonsense line. **Reading order** traces
the exact path a position-sorting extractor takes through the page.

<div align="center">
<img src="docs/images/ats-check.png" alt="ATS Check tracing a parser's reading order across a two-column CV" width="900">
</div>

### Region-aware conventions

CV norms are not universal. Pick a region and CVForge adjusts page size,
expected length, date format, the document's own name, and the guidance it
shows you. Eight regions ship: UK & Ireland, US & Canada, Australia & New
Zealand, DACH, Nordics, Europe (international), Mexico/Colombia/Chile, and
Brazil & Southern Cone.

<div align="center">
<img src="docs/images/regions.png" alt="Region picker, showing UK and Ireland conventions" width="820">
</div>

### Optional extras, all off by default

- **Tailor with AI** *(beta)* — paste a job ad and have a model select and
  rewrite bullets for it. Bring your own API key; Anthropic and Google Gemini
  are supported. Off until you add a key.
- **Google Drive sync** — mirrors your Vault and every CV to your Drive's
  hidden app folder, so a second browser picks up where you left off. Off
  until you sign in.
- **JSON backup** — export your whole world to a file and import it back.

---

## Privacy

**By default, CVForge makes no network calls with your data at all.** There is
no server component to this project. Your Vault and CVs live in your browser's
IndexedDB, and PDF generation happens on-device.

That cuts both ways, so it is worth being blunt about it: **your data is only
as durable as your browser's site storage.** Clearing site data, or working in
a private window, will lose it. Turn on Drive sync or take a JSON backup if
that matters to you.

Two optional features change the picture, and only if you turn them on:

| Feature | What leaves your browser | Where it goes |
|---|---|---|
| **Tailor with AI** | The job ad, and your CV's career content — experience, projects, skills, education | Straight to Anthropic or Google, using *your* API key |
| **Google Drive sync** | Your Vault and CVs, as the same JSON the backup export produces | Your own Google Drive, hidden app folder |

Neither routes through a CVForge server, because there still isn't one.

For AI tailoring specifically: your identifying details — name, email, phone,
location and profile links — are **stripped before the request is built** and
are never part of it. The feature always shows you exactly what is about to be
sent, before it sends it.

---

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) **3.47.0** — the
  version CI pins; newer stable releases will usually work
- Chrome, for `flutter run -d chrome`

### Run it

```bash
git clone https://github.com/IanHeinrich/CVForge.git
cd CVForge
flutter pub get
flutter run -d chrome
```

That is the whole setup. No environment variables, no services to stand up and
no API keys — the app runs fully featured without them, minus the two optional
integrations above.

### Build a release

```bash
flutter build web --release
```

For a deploy under a sub-path, as GitHub Pages does, pass the base href:

```bash
flutter build web --release --base-href /CVForge/
```

---

## Architecture

Flutter Web, [Stacked](https://stacked.filledstacks.com/) MVVM, with
[freezed](https://pub.dev/packages/freezed) for immutable models.

A few decisions worth knowing before reading the code:

**Package by feature, not by layer.** Views, dialogs and feature-specific
widgets live together under `lib/features/<feature>/`. Only genuinely shared
things — services, common widgets, routing and DI — stay global, because
Stacked's routing and locator are centralised by design.

**Models never import Flutter.** `lib/models/` is pure Dart.
`render/cv_composer.dart` is the single place Vault data and Draft selections
are joined into the `ResolvedCv` a template renders.

**One renderer, not two.** A template owns exactly one `pdf`-package renderer.
Studio's live preview rasterises that same PDF rather than maintaining a
parallel Flutter widget tree, so preview and export can never disagree — on
content or on pixels.

**Pagination is a solved trap.** Splitting a CV across pages correctly is
harder than it looks in `package:pdf`, and
`templates/design/section_pagination_pdf.dart` is the one place it is
implemented. New templates must route through it. The reasoning is written up
in [CLAUDE.md](CLAUDE.md) — read that before writing a template.

### Project layout

```
lib/
├── app/            # Stacked wiring: routes, locator (generated)
├── features/       # Vertical slices
│   ├── analyzer/   #   ATS Check
│   ├── settings/
│   ├── studio/     #   Building one CV
│   └── vault/      #   The master record
├── models/         # Pure Dart, freezed. No Flutter, no pdf.
│   ├── draft/      #   What a CV selects from the Vault
│   ├── render/     #   Vault + Draft -> ResolvedCv
│   └── vault/      #   The master record's shape
├── services/       # Always global, even single-consumer ones
├── templates/      # One pdf renderer per template, plus design tokens
└── ui/             # Shared chrome: theme, tokens, common widgets
```

---

## Development

Full conventions, gotchas and the reasoning behind them live in
**[CONTRIBUTING.md](CONTRIBUTING.md)** and [CLAUDE.md](CLAUDE.md). The short
version:

```bash
stacked generate                  # freezed, json_serializable, locator, router
dart format .                     # always, immediately after generating
flutter analyze
flutter test --exclude-tags=golden
```

> [!NOTE]
> Golden tests are baselined on Linux and show small pixel diffs on macOS or
> Windows even with no real change. `--exclude-tags=golden` is the signal that
> is actually green locally; CI verifies the goldens for real on every PR.

---

## Deployment

Pushing to `main` runs [`deploy.yml`](.github/workflows/deploy.yml), which
detects a version bump in `pubspec.yaml`, builds with `--base-href /CVForge/`,
publishes to GitHub Pages, and tags the release.

`404.html` handles deep links: GitHub Pages has no rewrite rules, so it
encodes the requested path into a query string and `index.html` restores it
before the router ever reads the URL.

---

## Contributing

Issues and pull requests are welcome. **[CONTRIBUTING.md](CONTRIBUTING.md)**
covers setup, the conventions this codebase actually enforces, and what CI
will check.

The one rule worth stating up front: **scaffold with the Stacked CLI, never by
hand.** Hand-written views, services and widgets miss the route and DI wiring
the CLI maintains, and drift from the generated conventions.

---

## License

[Apache License 2.0](LICENSE), Copyright 2026 Ian Heinrich.

---

## Acknowledgements

Built with [Stacked](https://stacked.filledstacks.com/),
[freezed](https://pub.dev/packages/freezed),
[pdf and printing](https://github.com/DavBfr/dart_pdf),
[Hive CE](https://pub.dev/packages/hive_ce) and
[Remix Icon](https://remixicon.com/). Deep-link handling on GitHub Pages
follows [spa-github-pages](https://github.com/rafgraph/spa-github-pages).
