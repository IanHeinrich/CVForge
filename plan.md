# CVForge — Phase 1 (MVP) Implementation Plan

## Context

`cv-forge` is currently a bare `stacked_cli` scaffold: a counter demo, three placeholder views, and a verified CI/CD pipeline (PR-only merges to `main`, auto-deploy to GitHub Pages on `pubspec.yaml` version bump, auto-tagging). No product code exists.

**CVForge** is a client-side, privacy-first, zero-backend CV generator for Flutter Web. It exists to solve two problems:

1. **ATS readability & print fidelity** — compile true *vector* PDFs with selectable text streams via `pdf`'s parallel `pw.Widget` tree, rather than rasterising HTML or relying on `window.print()`.
2. **Master career management** — separate raw career history (**The Vault**) from tailored presentation (**The Studio**), so a candidate curates targeted CVs without destroying their master history.

Phase 1 must deliver an end-to-end local workflow: data entry → curated draft → downloadable, ATS-compliant PDF. Phase 2 (BYOK LLM Copilot, more templates, regional presets, JSON backup, multi-draft CVs) is designed *for* but not built.

---

## Decisions locked

| # | Decision | Rationale |
|---|---|---|
| 1 | **Web-only MVP** | Matches scaffold + Pages pipeline. Desktop addable later via `flutter create --platforms` with no rework — Hive and `file_saver` already abstract the platform. |
| 2 | **`hive_ce`/`hive_ce_flutter` replaces `hive_flutter`** | `hive` 2.2.3 stable is ~4–5 years old, repo last pushed Jun 2024, 568 open issues, predates `package:web`/wasm (relies on `dart:html`-era interop). `hive_ce` is near drop-in, actively released, IndexedDB-format compatible. |
| 3 | ~~Approximate live preview; no `printing`~~ **Reversed post-P1.6 — see note below.** | ~~Flutter widgets laid out in PDF points + `Transform.scale`. Preview is explicitly "approximate — the PDF is the authority".~~ |
| 4 | **One PR per sub-phase**; version bump only at user-visible milestones | Keeps Pages deploys meaningful rather than noisy. |
| 5 | **Template #1 = faithful clone of Ian's CV**, named `classic_serif`. `modern_tech` dropped | `modern_tech` was illustrative, not a requirement. Cloning a known-good reference makes fidelity verifiable. |
| 6 | **Two-column Skills** | Matches the reference CV, saves vertical space (matters for a 2-page UK target). Extraction risk is low: skill groups are self-contained, so all-of-left-then-all-of-right still reads coherently. |
| 7 | **Hobbies + References are first-class, toggleable sections** | Present in the reference CV; one list field and one string field. |
| 8 | **Persist freezed models as JSON strings, not Hive TypeAdapters** | Tiny dataset; avoids the freezed×`hive_generator` minefield (silent no-op adapter generation, typeId/field-index landmines); makes Phase 2 JSON export/import free. |
| 9 | **Fictional example fixture** | **Repo is verified PUBLIC.** Real contact details would be permanently greppable in git history. |

> **Decision 3 reversed post-P1.6:** the two-render-tree approach (a Flutter widget tree for preview, a separate `pw.Widget` tree for export) turned out to be a real, ongoing bug source — a session spent chasing a bullet-glyph vertical-centering bug traced directly back to the two renderers disagreeing on box/line-height metrics, a category of bug that only exists because there are two trees to keep in sync. A spike wired `printing`'s `PdfPreview` widget to the *exact* bytes `PdfExportService.render()` already produces for export, measured against real CV data (20–90ms Dart-side generation per render, no perceptible end-to-end lag across many live interactions), and confirmed the original latency/complexity concern no longer holds. Studio's live preview is now a rasterized render of the real PDF — preview and export can't drift on pixels because they're the same bytes. The entire Flutter screen-renderer stack (`*_screen_renderer.dart`, `cv_design_tokens_flutter.dart`, `CvPageSurface`, `CvTemplate.buildPreview`) was deleted, not deprecated.
>
> Two gotchas from wiring this up, worth knowing before touching `printing`/`web/pdfjs/`/`third_party/printing/` again:
> - `pdf.js` (the rasterizer, used only on Web) is bundled locally under `web/pdfjs/` rather than fetched from `printing`'s default `unpkg.com` CDN, to keep this consistent with decision 9's spirit and the "nothing leaves the browser" pitch — `web/index.html` sets `window.dartPdfJsBaseUrl` before Flutter boots. That value **must** start with `./` (`./pdfjs/`, not `pdfjs/`) — `printing` feeds it straight into a dynamic `import()`, and browsers reject a bare relative specifier there with a confusing "Failed to resolve module specifier" error.
> - Setting `dartPdfJsBaseUrl` at all trips an upstream bug in `printing` 5.15.0's web plugin (`getProperty(...)` missing an explicit type argument → `TypeError: "...": type 'String' is not a subtype of type 'Never'` at runtime, only when this override is actually used — presumably why it's gone unnoticed, most consumers use the default CDN). Fixed locally via a one-line-patched vendor copy at `third_party/printing/` (`dependency_overrides` in `pubspec.yaml`) rather than depending on an external contributor's unmerged-PR fork branch. **Once `printing` publishes a fix (tracked: <https://github.com/DavBfr/dart_pdf/issues/1707>), delete `third_party/printing/` and the override** — see `third_party/printing/README.md` for the exact steps.

---

## Architecture

### Feature slices

Two slices only — `templates/` and `models/` have no Views, so the `stacked create` machinery (which is what `stacked_configs/*.json` steers) doesn't apply.

```
lib/
  app/                    # unchanged: central routing + DI
  features/
    vault/                # master career store: entry + CRUD UI
    studio/               # assembly, selection, preview, export trigger
    settings/             # RESERVED — Phase 2 only, do not create now
  models/                 # pure Dart freezed. NO flutter, NO pdf imports.
    vault/ draft/ render/
  templates/              # the dual-renderer boundary
    cv_template.dart
    design/               # tokens, adapters, font set, small-caps helper
    classic_serif/
  services/               # global, per root stacked.json
  ui/common/  ui/widgets/common/
```

`stacked_configs/vault.json` and `studio.json` are copies of root `stacked.json` with **only** these five keys repointed — `services_path`, `stacked_app_file_path`, `test_helpers_file_path` stay global:

```json
"views_path":         "features/vault/views",
"widgets_path":       "features/vault/widgets",
"dialogs_path":       "features/vault/dialogs",
"bottom_sheets_path": "features/vault/bottom_sheets",
"test_views_path":    "features/vault/viewmodels",
"test_widgets_path":  "features/vault/widget_models"
```

**No shell slice.** Stacked's `navigator2` router has no ergonomic nested-shell story and a shell route fights the URL model. Instead: top-level `/vault` and `/studio` routes, plus a shared `AppChrome` widget in `lib/ui/widgets/common/` that each View wraps itself in. Browser back/forward works for free.

### Domain models

All `@freezed`, pure Dart. **No `Color`, no `TextStyle`, no `pw.*`, no `toDisplayString()`.**

**Vault** (`lib/models/vault/`) — one aggregate root, persisted as one JSON string:

```
CvVault      : int schemaVersion, ContactBasics basics, List<Experience> experiences,
               List<SkillCategory> skillCategories, List<Education> education,
               List<HobbyItem> hobbies, String? referencesNote, DateTime updatedAt
ContactBasics: String fullName, headline, email, phone, location,
               String? summary, List<ProfileLink> links
ProfileLink  : String id, label, url          // label e.g. "LinkedIn"
Experience   : String id, role, company, location,
               YearMonth start, YearMonth? end, bool isCurrent,
               List<ExperienceBullet> bullets
ExperienceBullet : String id, String? label, String text
SkillCategory: String id, String name, List<Skill> skills
Skill        : String id, String label
Education    : String id, qualification, institution, String? location,
               int? year, String? grade, String? details
HobbyItem    : String id, String text
YearMonth    : int year, int month
```

Shape decisions driven by the reference CV:

- **`ExperienceBullet.label` is structural, not baked into `text`.** The reference CV renders every work bullet as *italic label* + `:` + regular body ("*Proactive Mitigation:* Collaborated with…"). Making it a field lets the template style it and lets Phase 2's Copilot rewrite body text without clobbering the label. Nullable, because the Rappid and Adeptic entries have unlabelled lead paragraphs.
- **`Education.year` is `int?`, not a `YearMonth` range.** The reference CV shows year only ("Computing Science, 2021").
- **`YearMonth` over `DateTime`** — CVs have month precision; `DateTime` drags in timezone noise and false precision the UI would have to hide. Two ints serialise with no custom `JsonConverter`.

**Draft** (`lib/models/draft/cv_draft.dart`):

```
CvDraft : int schemaVersion, String id, String name, String templateId,
          List<String> experienceIds,              // ordered, opt-in
          Map<String, List<String>> bulletIds,     // expId -> ordered bulletIds
          List<String> skillIds, educationIds, hobbyIds,
          Set<CvSectionType> hiddenSections,
          String? tailoredSummary,                 // Phase 2 writes; Phase 1 honours
          Map<String, String> bulletOverrides,     // bulletId -> rewritten text
          DateTime updatedAt
CvSectionType : enum { summary, experience, skills, education, hobbies, references }
                // declaration order IS the canonical semantic order
```

- **References are by id, opt-in.** A `List<String>` is both a filter and a permutation, so draft-level reordering comes free in Phase 2. **Cost you must design for:** a newly-added Vault entry does *not* appear in an existing draft — the Studio config panel needs an explicit "N items in your Vault aren't in this draft / Add all" affordance. Don't skip it; without it the model feels broken.
- **Dangling ids are normal.** Deleting a Vault entry must not require touching every draft; the composer silently drops unknown ids. No referential integrity anywhere.
- **`bulletOverrides` + `tailoredSummary` ship in Phase 1 with no UI.** This is the single most important Phase-2-proofing decision: without them the Copilot can only rewrite by *mutating the Vault*, which destroys the Vault/Studio separation the product exists for. Two fields and ~4 lines of composer code now; a schema migration plus composer and dual-renderer rework later.
- **Section order is a domain constant, not a template property.** Templates render whatever ordered list they're handed, so Phase 2 user-reordering touches only the draft model and composer.

**IDs:** add `uuid: ^4.5.0`; generate `const Uuid().v4()` **in services only**, never in a model constructor. Models stay deterministic; tests never assert on id values.

**Render model** (`lib/models/render/`) — the key to keeping presentation out of domain models:

```
ResolvedCv      : ResolvedHeader header, List<ResolvedSection> sections
ResolvedSection : freezed union — .summary / .experience / .skills
                                  / .education / .hobbies / .references
ResolvedRole    : String role, company, location,
                  String dateRange,               // PRE-FORMATTED
                  List<ResolvedBullet> bullets
ResolvedBullet  : String? label, String text
CvComposer.compose(CvVault, CvDraft, {required RegionProfile region}) -> ResolvedCv
```

`ResolvedCv` is pure data, never persisted, containing **only what will be printed, in print order, already filtered, ordered, and date-formatted**. Templates never see `CvVault` or `CvDraft` — so the two render trees cannot drift on *content*, only on pixels.

`RegionProfile` ships in Phase 1 with one value (`uk`). Costs nothing now; it's where Phase 2's spelling normalisation and date-format differences plug in without re-signing every call site.

### `CvTemplate` Strategy interface

```dart
// lib/templates/cv_template.dart
abstract interface class CvTemplate {
  String get id;                 // 'classic_serif'
  String get displayName;
  String get description;
  CvDesignTokens get tokens;

  /// Page content laid out in PDF points. Caller owns scaling.
  Widget buildPreview(ResolvedCv cv, PdfPageFormat format);

  /// Complete document, theme + fonts + margins applied.
  /// MUST hand pw.MultiPage.build a FLAT List<pw.Widget> — wrapping the body
  /// in a single pw.Column silently defeats page splitting (see R5).
  pw.Document buildDocument(ResolvedCv cv, PdfPageFormat format, CvFontSet fonts,
      {bool compress = true});   // false in tests -> greppable streams
}
```

```
lib/templates/classic_serif/
  classic_serif_template.dart        # implements CvTemplate, delegates only
  classic_serif_tokens.dart          # const CvDesignTokens instance
  classic_serif_screen_renderer.dart # Flutter widgets only
  classic_serif_pdf_renderer.dart    # pw widgets only
```

`buildPreview` returns content at natural height, **not** pre-scaled — scaling is the caller's job (`CvPageSurface`). Keeping the template viewport-unaware makes it reusable for a Phase 2 thumbnail picker.

**Registry:** `TemplateRegistryService`, backed by a plain `const` list (no reflection, tree-shake friendly). Exposes `List<CvTemplateDescriptor> get available` (id/name/description only, so the picker never touches a renderer), `CvTemplate byId(String)` (falls back to default, never throws), `CvTemplate get defaultTemplate`.

### Design tokens — the shared layout vocabulary

`lib/templates/design/cv_design_tokens.dart` — **pure Dart, imports nothing**. Colours as `int` ARGB, all dimensions in **PDF points**:

```
CvDesignTokens : marginTop/Right/Bottom/Left, sectionGap, sectionRuleGap, itemGap,
                 bulletGap, bulletIndent, ruleThickness, ruleColorArgb,
                 inkArgb, mutedInkArgb, skillColumnCount, skillColumnGap,
                 CvTypeToken name, contact, sectionHeading, role, company,
                              meta, body, bulletLabel, bullet
CvTypeToken    : double sizePt, CvWeight weight, bool italic, bool smallCaps,
                 double lineSpacingPt, double letterSpacingPt, int? colorArgb
```

Two thin adapters, each importing exactly one framework:
- `cv_design_tokens_flutter.dart` → `CvTypeToken.toTextStyle(family)`, `CvDesignTokens.pageMargins → EdgeInsets`
- `cv_design_tokens_pdf.dart` → `CvTypeToken.toPdfStyle(CvFontSet)`, `→ pw.EdgeInsets`

**The load-bearing detail:** `pw.TextStyle.lineSpacing` is *extra* points between lines; Flutter's `TextStyle.height` is a *multiplier* of font size over the whole line box. Store one `lineSpacingPt` token and have the Flutter adapter compute `height: (sizePt + lineSpacingPt) / sizePt`. This is what keeps the two renderers within a line or two over a full page. Store the pt-based value because the PDF is the source of truth.

**Small caps** (`lib/templates/design/small_caps.dart`): the reference CV sets the name and every section heading in small caps. `package:pdf` has no OpenType `smcp` support, so this is faked — pure-Dart `List<SmallCapsRun> build(String)` splitting each word into a full-size leading char plus an uppercased, ~0.78× remainder. Each adapter converts runs to `TextSpan` / `pw.TextSpan`. Shared logic means both renderers break identically.

### Services (`lib/services/`, all via `stacked create service`)

| Service | Owns | Depends on |
|---|---|---|
| `LocalStorageService` | The **only** file importing `hive_ce`. `ensureInitialized()`, `read/write/delete/keys`. Values are always JSON strings. | — |
| `VaultService` | The `CvVault` aggregate. CRUD, id generation, schema migration on read, debounced writes. | `LocalStorageService` |
| `DraftService` | The current `CvDraft`. Selection toggles, section visibility, template choice. | `LocalStorageService` |
| `TemplateRegistryService` | Template lookup. | — |
| `FontService` | `rootBundle.load` → `pw.Font.ttf`, cached. `warmUp()` + `load()`. | — |
| `PdfExportService` | `ResolvedCv` + templateId + format → bytes → downloader. Filename policy. | Registry, Font, FileDownload |
| `FileDownloadService` | The **only** file importing `file_saver`. | — |

Strictly downward, no cycles. `VaultService` and `DraftService` don't know about each other (the draft holds ids, not references).

Two wrappers exist for non-cosmetic reasons:
- **`LocalStorageService`** — Hive on web is IndexedDB; `flutter test` runs on the VM. Mocking at this boundary keeps Vault tests pure, fast, and platform-free.
- **`FileDownloadService`** — `FileSaver.instance` is a static singleton and therefore unmockable. Wrapping it is the only way to assert the exporter produced a real PDF and called the saver with the right args.

**No `CvComposerService`** — `compose` is a pure static function; making it a service adds a mock every ViewModel test would stub, *reducing* coverage of the most correctness-critical code. It's exercised for real through `StudioViewModel` tests.

### Persistence

- Boxes (all `Box<String>`): `cvforge_vault`, `cvforge_drafts`, `cvforge_settings` (opened but unused until Phase 2).
- Keys centralised in `lib/services/storage_keys.dart`. Vault has one key: `profile`. Drafts keyed by draft id; Phase 1 always uses `current`.
- **Whole-aggregate writes** — the entire `CvVault` is one JSON string. Atomic, no orphan states, and Phase 2's export is a single `read()`. Debounce writes ~300ms so live typing doesn't thrash IndexedDB.
- **Multi-tab is last-write-wins.** Acceptable for MVP — but don't claim otherwise.
- **`schemaVersion` lives on the model**, not in a meta box, so the identical migration path serves Phase 2's "import a JSON file exported six months ago". Start at `1`; `_migrate` is identity with a `switch` ready for v2.
- On decode failure: quarantine the unparseable string under `profile_corrupt_<timestamp>` **before** falling back to an empty vault. Silent data loss is worse than a crash.

### Startup wiring

`Hive.initFlutter()` goes in **`LocalStorageService.ensureInitialized()`**, not `main.dart` — `stacked create service` registers a sync-constructor `LazySingleton`, and doing async init in `main.dart` means hand-editing `app.dart`'s registration, which fights the CLI-owns-the-wiring rule. It also gives a place to surface failure: IndexedDB is genuinely unavailable in Firefox strict-privacy mode.

`StartupViewModel.runStartupLogic()`: `ensureInitialized()` → `VaultService.load()` → `DraftService.load()` → `FontService.warmUp()` (**not awaited** — fonts are ~1.5MB; blocking first paint for a user who may never export is the wrong trade) → `replaceWith(VaultViewRoute())`. On storage failure, set an error state and render a retry card rather than navigating.

**Deep-link hazard — build this in P1.2, don't bolt it on:** this is a web app with real URLs. Refreshing on `/studio` bypasses `StartupView` entirely. So `ensureInitialized()` must be idempotent and return a cached future, and `VaultService`/`DraftService` must `await _ready` internally on every read path. `StartupView` then becomes an optimisation, not a correctness requirement.

---

## Template spec: `classic_serif`

Derived from the reference CV. Single column except Skills.

| Element | Spec |
|---|---|
| Name | Centred, **small caps**, large. Double rule beneath (thick + thin). |
| Contact | Centred, `◆`-separated: `Location ◆ Phone ◆ Email` |
| Links | Centred; **bold label** + regular value (`LinkedIn: linkedin.com/in/…`) |
| Section heading | Centred **small caps**, flanked left and right by horizontal rules |
| Work entry L1 | **Bold role**`, MM/YYYY - MM/YYYY` (regular; `current` when `isCurrent`) |
| Work entry L2 | **Bold company** ` - Location` (regular) |
| Work bullets | ***Italic label***`:` + regular body. **No bullet glyphs.** Unlabelled bullets render as plain paragraphs. |
| Skills | **Two columns**, ***italic category***`:` + regular comma-separated skills |
| Education | **Bold qualification**`: ` regular field`, ` year / **bold institution** |
| Hobbies | Real `•` bulleted list — deliberately different from work history |
| References | Single regular line |

**Font — `Liberation Serif`** (OFL 1.1), four static TTFs (Regular/Italic/Bold/BoldItalic) under `assets/fonts/` with `OFL.txt`. Chosen because it's metrically compatible with Times New Roman, so it reproduces the reference CV's look faithfully, is licence-clean for redistribution, and covers Latin-1 + Latin Extended-A + smart quotes + en/em dashes + €/£ — which is the actual failure set from a Word paste.

Two hard constraints: **static TTFs, never variable** (`package:pdf` has no variable-axis support) and **TTF not OTF** (`package:pdf` wants TrueType `glyf` outlines, not CFF).

⚠️ **Verify `◆` (U+25C6) glyph coverage in Liberation Serif during P1.5.** If absent it renders `.notdef`. Substitute `•` (U+2022) — present in effectively every font — and make the separator a token so it's a one-line change.

> **Drift note (2026-08-18):** P1.5 actually shipped a template named `ats_minimal` (sans-serif, Roboto, no small caps — modelled on the r/EngineeringResumes community template per a reference PDF) instead of the `classic_serif` spec described above. The architecture (tokens, dual-renderer boundary, registry) is unchanged; only the concrete template identity/spec differs from what's written in this section. P1.6 builds `ats_minimal`'s PDF renderer, not `classic_serif`'s — see the sub-phase detail below.

---

## Sub-phase sequence

| # | Name | Bump | Depends on |
|---|---|---|---|
| P1.0 | Dependency & codegen groundwork | — | — |
| P1.1 | Design tokens + domain models + composer | — | P1.0 |
| P1.2 | Storage + Vault/Draft services | — | P1.1 |
| P1.3 | App chrome, theme, routing; retire demo | — | P1.2 |
| P1.4 | Vault CRUD UI | **0.2.0** | P1.3 |
| P1.5 | Template contract + `classic_serif` screen + Studio | **0.3.0** | P1.4 |
| P1.6 | PDF renderer + direct export | **0.4.0** | P1.5 |
| P1.7 | Hardening, states, docs | **1.0.0** | P1.6 |

One PR each. Bumps only where a deploy is worth eyeballing in a real browser — bumping at P1.3 would deploy an empty shell.

**Status (2026-08-19): P1.0–P1.5 merged to `main` (PR #6–#10). P1.6 is open as [PR #11](https://github.com/IanHeinrich/cv-forge/pull/11), CI green, not yet merged.** P1.5 also picked up, beyond its original spec: per-bullet inclusion in Studio (collapsible bullet lists, per-entry select-all, bullet labels shown), a fix for a runaway relayout loop in `CvPageSurface`, whole-page-rounded pagination in the preview, and `ats_minimal` template accuracy fixes (ink color, no Professional-summary heading, "Experience" not "Work history") against the reference PDF. **P1.6's own scope is done; see its "Actually shipped" note below for the post-export polish round, the manual acceptance checklist, and everything that grew beyond the original spec (the live-preview architecture change is the big one — see decision 3's reversal note above). Once PR #11 merges, P1.7 is next, not yet started.**

> **Status (2026-08-20):** the above is stale as of P1.6 merging — kept verbatim rather than rewritten, matching this doc's existing drift-note convention. Actual state: **P1.0 through P2.3.2 are all shipped** (PR #3–#14; see each sub-phase's "✅ shipped" marker and shipped-note above for what actually landed vs. the original spec). One more PR landed with no corresponding sub-phase in this doc — **[PR #15](https://github.com/IanHeinrich/cv-forge/pull/15), "Code review cleanup"**: dead code, DRY, docs, and correctness fixes found in a review pass, not tied to a feature. Repo version is still `1.1.0` (P2.1's bump); nothing since has warranted another. **Phase 3 — Theming system & UI polish** (PR #16–#23) is also done; see its own section below, after the Phase 2 sketch. Three items flagged during Phase 2/Phase 3 as deliberately deferred (the chip selection color, `/studio` deep-linking, and export error classification) were picked up together afterward — see [PR #25](https://github.com/IanHeinrich/cv-forge/pull/25) ("Follow-up fixes" below, after Phase 3).

---

## Sub-phase detail

### P1.0 — Dependency & codegen groundwork
Satisfy every library constraint in config before any feature code exists. No `stacked create`.

- **`pubspec.yaml`**: **remove `hive_flutter`** (coexistence gives ambiguous `Hive` symbols — see R3); add `hive_ce`, `hive_ce_flutter`, `uuid: ^4.5.0`. Add `assets: [assets/fonts/]` **and** a `fonts:` block for `Liberation Serif`. Declaring both is deliberate: `fonts:` makes `TextStyle(fontFamily:)` work in the preview, `assets:` guarantees `rootBundle.load()` finds the path.
- **`build.yaml`**: add a `json_serializable` target with **`explicit_to_json: true`**. Without it, nested freezed objects inside `CvVault` serialise as `Instance of 'Experience'` and persistence silently produces garbage. Highest-value four lines in the plan (R4).
- Add the four TTFs + `OFL.txt`.

Gate: `flutter pub get`, `flutter analyze`, existing suite green.

### P1.1 — Design tokens, domain models, composer
Everything above under *Domain models*, *Design tokens*, plus `small_caps.dart`, `region_profile.dart`, and `lib/models/vault/example_vault.dart` (**fictional persona**, structured to mirror the reference CV: labelled work bullets, two skill categories, two education entries, hobbies, references note — so it exercises every branch of the template).

Run `stacked generate`, then **`dart format .`** before committing (freezed 3.x output isn't always CI-format-clean — R6).

**Tests: none.** `CvComposer` is the correctness heart of the app, but a dedicated test file is exactly the "unit test for a function" the conventions forbid. It gets real coverage via `StudioViewModel` tests in P1.5. ⚠️ Flagging explicitly: that's a four-sub-phase gap on the most correctness-critical code. If you want it covered earlier, say so now rather than discovering it in P1.5.

### P1.2 — Storage and stateful services
```bash
stacked create service local_storage
stacked create service vault
stacked create service draft
stacked create service file_download
```
(no `-c` — services are always global)

CLI modifies `lib/app/app.dart` (4 `LazySingleton`s) and `test/helpers/test_helpers.dart` (4 `MockSpec`s + `getAndRegister*` factories).

Implement Hive init/box opening, JSON read/write, `_migrate`, corrupt-payload quarantine, debounced writes, id generation, full CRUD, and the idempotent `ensureInitialized()` + internal `await _ready` on every read path.

**Tests** (`test/services/`, outside-in against `MockLocalStorageService`):
- `vault_service_test.dart` — first run creates empty vault; add/update/delete experience; add/reorder/delete bullet; deleting an experience doesn't touch drafts; unknown `schemaVersion` falls back cleanly *and* quarantines the original; **round-trip persistence proves `explicit_to_json` works**.
- `draft_service_test.dart` — toggling an experience id; toggling a section; selections survive reload.
- Skip `file_download_service_test` — one-line delegation to a static singleton, nothing to assert but the mock.

### P1.3 — App chrome, theme, routing; retire demo
```bash
stacked create view vault  -c stacked_configs/vault.json
stacked create view studio -c stacked_configs/studio.json
stacked create widget app_chrome --no-model
```
`app_chrome` uses the root config (shared by both features, so no `-c`); `--no-model` because it holds no state.

Add `stacked_configs/*.json`, `lib/ui/common/app_theme.dart`. Modify `main.dart` (add `theme:`, `title: 'CVForge'`, `debugShowCheckedModeBanner: false`) and `startup_viewmodel.dart`.

**Delete:** `ui/views/home/*`, `ui/widgets/mouse_transforms/*`, `extensions/hover_extensions.dart`, `test/viewmodels/home_viewmodel_test.dart`, `test/golden/home_view_golden_test.dart`, `test/golden/goldens/home_view_default.png`, and the Stacked boilerplate strings in `app_strings.dart`. Keep `UnknownView` (real 404), `app_colors.dart`, `ui_helpers.dart`, `app_constants.dart`.

**Chrome:** keep `kcBackgroundColor` (`0xFF1A1B1E`) for the shell and render the A4 canvas as a **white sheet floating on dark** — reuses the existing palette verbatim, reads as a document editor, makes the paper boundary self-evident. `kcPrimaryColor` (`0xFF9600FF`) is the accent for *selection state only* and must never appear in the CV itself.

**Tests:** `startup_viewmodel_test.dart` (init + both loads called, navigates to `VaultViewRoute`; storage failure sets error state and does **not** navigate). First golden: `vault_view` empty state — **generate the baseline on the Linux CI runner** (see R1).

⚠️ Run `git status` after every `stacked create` — a `-c` typo silently drops files into `lib/ui/views/`.

### P1.4 — Vault CRUD UI → **bump 0.2.0**
```bash
stacked create dialog confirm_delete -c stacked_configs/vault.json
```

**UI shape:** a single scrolling page of collapsible entity cards, with a right-hand editor panel that slides in when a card opens. No sub-routes, no modal forms — avoids a route explosion across six entity types, mirrors the Studio's split-screen so both halves feel like one app, and a 10-bullet experience form doesn't fit in a dialog. Editor panels are `ViewModelWidget<VaultViewModel>` subclasses (Stacked idiom — no prop drilling).

**No `@FormView`** — it generates one form per View, which fits `ContactBasics` but not N repeated experiences; mixing two form mechanisms in one screen is worse than one slightly manual one. Use plain `TextEditingController`s in stateful editor panels, pushing to the ViewModel debounced and on blur. Controllers carry *text*; every validation/mutation/id decision stays in the VM.

Widgets under `lib/features/vault/widgets/`: `basics_editor_card`, `experience_list_section`, `experience_editor_panel`, `bullet_list_editor` (label + text fields per bullet), `skills_editor_section`, `education_list_section`, `hobbies_editor_section`, `vault_empty_state`.

**Delete** `ui/dialogs/info_alert/*` + its test — but only now that a real dialog is registered (R2).

**Tests:** `vault_viewmodel_test.dart` against `MockVaultService` — adding an experience delegates typed values; deleting prompts via `MockDialogService` and only deletes on confirm; cancelling deletes nothing; "Load example CV" populates. Golden: `vault_view` populated from `exampleVault`.

### P1.5 — Template contract, screen renderer, Studio → **bump 0.3.0** ✅ shipped
```bash
stacked create service template_registry
stacked create widget cv_page_surface --no-model
```

Add `lib/templates/cv_template.dart`, the `classic_serif` template + tokens + screen renderer, `cv_page_surface`, and Studio widgets: `studio_config_panel`, `experience_selector`, `skill_selector`, `section_toggle_list`, `unselected_vault_items_banner`.

`StudioView` uses `ScreenTypeLayout.builder`: desktop = `Row(config 380px | preview Expanded)`; tablet/mobile = tabbed with preview second. Scaling:

```dart
LayoutBuilder(builder: (_, c) => Transform.scale(
  scale: c.maxWidth / format.width,
  alignment: Alignment.topLeft,
  child: SizedBox(width: format.width, child: templateContent)))
```

**No `FittedBox` anywhere** — it throws inside `AspectRatio` inside a fixed-width `Container` (flutter#142910), and there's no reason to go near it.

**No screen pagination.** Render one continuous column at `format.width` with intrinsic height, overlaying dashed page-break guides every `format.height`. Real pagination means reimplementing `MultiPage`'s splitting in Flutter — large effort for a preview already declared approximate. Guides are honest about roughly where the break lands; the PDF is the authority.

> **Actually shipped:** the preview now rounds its background up to whole page-height multiples (never shrink-wraps shorter content) rather than sizing exactly to intrinsic height — a direct response to how odd a content-hugging "page" looked in practice. The dashed page-break guide behavior for multi-page content is unchanged from the spec above.

Read margins and aspect ratio off the `PdfPageFormat` object throughout — **never hardcode 595.28/841.89** — so Phase 2's Letter switch flows through with no template edits.

**Tests:** `studio_viewmodel_test.dart` with `MockVaultService` returning `exampleVault` — toggling an experience off removes it from the resolved model; hiding Education removes that section; a `bulletOverride` wins over the vault text; a draft id referencing a deleted experience is silently dropped. **This is where `CvComposer` gets its coverage.** Plus `template_registry_service_test.dart` (unknown id falls back, doesn't throw) and a `studio_view` desktop golden.

### P1.6 — PDF renderer + direct export → **bump 0.4.0** ✅ shipped
```bash
stacked create service font
stacked create service pdf_export
```

Add `ats_minimal_pdf_renderer.dart` (see the P1.5 drift note above — this is `ats_minimal`, not `classic_serif`). `AtsMinimalTemplate.buildDocument` currently exists as a stub that throws `UnimplementedError`; this sub-phase fills it in. Modify `studio_viewmodel.dart` (export action, busy state, error surfacing) and `studio_config_panel.dart` (export button).

Renderer rules, all ATS-driven: everything in `pw.Text`; **no `pw.Image`**; no `pw.Table`; `pw.MultiPage` fed a **flat child list**; role/date via `pw.Row` + `pw.Expanded`. Skills use `pw.Row` of two `pw.Column`s (per decision 6) — or one column, matching whatever `ats_minimal`'s actual `skillColumnCount` token says now (drift note applies here too).

Filename: slugify `${fullName}_${draft.name}` → `name:` with **no extension**, `fileExtension: 'pdf'`, `mimeType: MimeType.pdf`. Extension in `name` yields `cv.pdf.pdf`. Note `file_saver` 0.4.0 renamed `ext`→`fileExtension` (0.3.1) and lowercased `MimeType` (0.2.0) — every pre-2024 tutorial is wrong.

Fire export straight from `onPressed` with fonts already warm — web needs a real user gesture and Safari gets stricter the longer the async gap.

**Tests — `pdf_export_service_test.dart`, the highest-value test in the project.** Real `FontService` + real template + fixture `ResolvedCv` + `MockFileDownloadService`. Assert on bytes handed to the mock: non-empty; starts with `%PDF-`; with `compress: false`, contains `/Identity-H` and `/ToUnicode` — **those two markers *are* the ATS-extractability guarantee**, proving a CID font with a reverse-mapping CMap was embedded rather than the Latin-1 base-14 fallback. Assert saver args (`name` has no `.pdf`, `fileExtension == 'pdf'`). **Unicode regression case:** a bullet containing `'` `"` `€` `–` `…` must not throw — this single test is the entire justification for the font work.

⚠️ Don't assert the PDF contains the candidate's name as plain text — Identity-H encodes text as hex glyph IDs, not ASCII.

⚠️ **Verify early in this sub-phase that `rootBundle` resolves declared assets under `flutter_test`.** I believe it does but haven't proven it in this repo; the whole test design depends on it.

⚠️ `ats_minimal` uses Roboto (sans-serif), not Liberation Serif — confirm Roboto's glyph coverage for the Unicode regression set (smart quotes, en/em dash, €/£) before assuming the Liberation Serif research above transfers unchanged.

> **Actually shipped:** beyond the spec above, a post-export polish round against a real PDF fixed header centering, experience ordering (now sorted reverse-chronological, independent of `draft.experienceIds` order), date formatting ("Mon YYYY"), PDF metadata, clickable links, one-line education rows, and overall density.
>
> The bullet glyph (`•`) took several rounds to get right, and the fix ended up **different per renderer** — worth reading if either renderer's bullet code looks inconsistent later:
> - **PDF renderer** (`ats_minimal_pdf_renderer.dart`): `Transform.scale`'s default anchor is the *font's full ascent/descent box*, not the glyph's own ink, and Roboto's `•` ink sits off that box's center by an amount that grows with the scale factor. Fixed by anchoring the scale on the glyph's real ink center instead (`_bulletGlyphAlignmentY`, derived from `Roboto-Regular.ttf`'s actual glyph metrics via the `pdf` package's `TtfParser`, not eyeballed) — verified scale-invariant by regenerating a real PDF at 2.5× and 4× and checking the ink lands at the same position both times.
> - **Flutter screen renderer** (`ats_minimal_screen_renderer.dart`, now only used for Studio's *old* preview path — see decision 3's reversal note, this file no longer exists): the same ink-anchor trick, ported naively (sign-flipped for Flutter's opposite `Alignment.y` direction), was wrong — Flutter's `TextStyle.height` is a *per-line* multiplier (unlike the `pdf` package's `lineSpacing`, extra points *between* lines only), so a box-height assumption that held for `pdf` didn't hold for Flutter. Chasing the exact multiplier math wasn't worth it: switched the bullet `Row` to `CrossAxisAlignment.baseline` instead, which sidesteps needing to know box heights at all (Flutter computes each child's baseline directly), and dropped back to `Transform.scale`'s plain default `Alignment.center` for the ink offset, since the residual box-vs-ink gap was small enough to be a non-issue once the *reference point* (baseline, not box-top) was right. Moot now that this file is deleted, but the lesson generalizes: box-height parity between the two Flutter-side style systems is not safe to assume.
> - Tuned values, if retuning later: `bulletGlyph.sizePt` 25 → 20, `_bulletGlyphGap` 4 → 6 (both in `ats_minimal_tokens.dart`), and bullets that wrap to multiple lines now align the glyph to the *first* line only, not the vertical center of the whole wrapped block (matches the reference template).
>
> Also added this session: a project-scoped `.mcp.json` for the Dart MCP server (gitignored — its `command`/`env.PATH` are pinned to this machine's Flutter SDK location, not portable).
>
> **Manual acceptance checklist (all passed)**, run against a `flutter build web --release --base-href /cv-forge/` build served locally under a `/cv-forge/` path prefix, not just the dev server: text is real embedded CID-font glyphs (not rasterized) confirmed via the PDF's own `/ToUnicode` CMap; reading order confirmed correct **in the actual content stream** (role/company immediately followed by its date range, not batched separately); smart quotes, en/em dash, ellipsis, `€`, `£`, and `•` all round-trip correctly; filename slugs correctly (`jordan_ellery_backend_roles.pdf`, no double extension); every `assets/fonts/*.ttf` request resolved `200 OK` under the deployed base-href. One caveat worth knowing, not a defect: the `pdftotext.exe` bundled with Git for Windows (xpdf 4.06) regroups the date-range column together across rows when run in its default non-`-layout` mode — its own reading-order heuristic getting confused by a recurring right-aligned column, not a reflection of the PDF's actual (correct) structure. Re-run with `-enc UTF-8` and it extracts cleanly; a poppler-based extractor wasn't available to cross-check further.
>
> **Also shipped this session, beyond P1.6's original scope** (see decision 3's reversal note above for the big one):
> - Studio's live preview is now a rasterized render of the real exported PDF (`printing.PdfPreview`), not a second hand-maintained Flutter render tree — the entire motivation for the bullet-renderer-parity pain documented above. Full detail, including the vendored `printing` patch this required, is in decision 3's note.
> - A first-time user (no draft ever persisted) now gets everything in their Vault selected by default in Studio, instead of an empty CV — `DraftService.isFreshDraft` / `StudioViewModel`'s `_selectAllFromVault`-style wiring in `startup_viewmodel.dart`. Fires once; any manual check/uncheck becomes the real persisted selection and this never re-fires for that draft.
> - The two pre-existing `VaultView` golden test failures (Linux-vs-Windows baseline drift, flagged as R1 below) were actually failing on CI too, not just locally — regenerated via the existing `update-goldens.yml` workflow and committed. If a future PR hits the same two tests failing on CI, that workflow is the fix, not a code change.

### P1.7 — Hardening, states, docs → **bump 1.0.0**

**Scoping pass (2026-08-19), before any code:** a code audit against the original bullet list ("empty states per Vault section", "no experiences selected", "storage-unavailable card", "export failure surfaced") found most of it already shipped in P1.4–P1.6 — `VaultEmptyState`, per-section "No X yet." rows, `VaultPersistErrorBanner`, the Studio export-error chip, and a storage-unavailable retry card on `StartupView` all already exist. The audit also surfaced two data-loss-class bugs in the same area that the original bullet list didn't anticipate. Revised scope below supersedes the one-paragraph version above; **still one PR, still bump 1.0.0** (decision 4 — these are all part of the same "make Phase 1 hold together" milestone, not separate user-visible releases).

**G1 — deep-link/refresh into `/vault` or `/studio` shows an empty app, and "Load example CV" then overwrites real persisted data.** Confirmed live (not just from reading code), twice — once to prove the bug, once to prove the fix: loaded the example Vault via the UI, hard-navigated straight to `/vault` (full page reload, `.dart.lib.js` bundle re-fetched) pre-fix and got "Your Vault is empty" with real data still sitting untouched in IndexedDB; same steps post-fix rendered the real Vault correctly. `StartupView` is the *only* place that called `VaultService.load()`/`DraftService.load()`, and it only ever runs on the `/` initial route; `VaultView`/`StudioView` read `vault`/`draft` as plain getters with no load trigger of their own. This is exactly the hazard the plan's P1.2 section warned about ("`ensureInitialized()` must be idempotent... `StartupView` then becomes an optimisation, not a correctness requirement") — the idempotent-init half was built, the "every View awaits `_ready` on its own" half wasn't.
  - **Shipped:** `VaultViewModel`/`StudioViewModel` now `implements Initialisable` (Stacked calls `initialise()` automatically on construction — no manual `onViewModelReady` wiring needed) and load their services with a keyed `runBusyFuture`, so `isLoading`/`hasLoadError` can't collide with `StudioViewModel`'s existing export busy/error state. `VaultView`/`StudioView`'s top-level `builder()` branches on `isLoading`/`hasLoadError` before delegating to the breakpoint-specific View, each wrapped in `AppChrome` so the nav rail stays usable throughout.
  - **A live-testing trap worth flagging for next time:** reusing the same Browser-pane tab across several `preview_stop`/`preview_start` cycles kept the JS console's log history *and*, apparently, some IndexedDB state around across restarts — this produced a very convincing false "the fix isn't working, data is still getting wiped" signal (complete with what looked like a runaway write loop) that took real effort to chase before `tabs_close` + a fresh tab showed the fix was correct all along. If a browser-based repro looks contradictory or flaky, close and reopen the tab before trusting the result.

**G2 — a failed first load is cached forever; "Try again" can never succeed.** `VaultService._ready()` and `DraftService._ready()` are both `Future<void> _ready() => _readyFuture ??= _load();` with no reset on failure — if `_load()` throws (storage unavailable), that failed `Future` is memoized and every subsequent await, including from `StartupViewModel.retry()`, replays the same rejection.
  - **First attempt was wrong, and the wrong version shipped-then-got-caught by the new regression test, not by review:** the obvious fix — catch inside `_load()`, `_readyFuture = null;`, `rethrow` — mirrors what looked like the existing `LocalStorageService.ensureInitialized()` pattern, but is actually broken. `_readyFuture ??= _load()` assigns `_readyFuture` *after* `_load()` returns; if the very first awaited call throws *synchronously* (real storage failures won't, but `MockLocalStorageService.ensureInitialized()` stubbed with `thenThrow` does — mockito's `thenThrow` throws synchronously at the call site regardless of the mocked method's declared return type), `_load()`'s entire body — including a same-method reset to `null` — runs to completion before the `??=` in `_ready()` ever executes, so that outer assignment immediately clobbers the reset with the rejected future anyway. Confirmed with a minimal standalone repro before touching the fix (see scratchpad session notes) — worth remembering as a general pattern, not just for this file.
  - **Shipped fix:** the reset lives in `_ready()` itself, chained via `.catchError()` on `_load()`'s result, not inside `_load()`. `Future` callbacks (`.then`/`.catchError`/etc.) are always deferred to a later microtask even on an already-completed future, which guarantees the reset callback can only run *after* the `??=` assignment has already happened — no ordering race regardless of whether the failure is synchronous or genuinely asynchronous. Applied to `VaultService` and `DraftService`, **and to `LocalStorageService.ensureInitialized()` too** — it had the identical pre-existing bug (the ORIGINAL "already gets this right" read of its code was wrong; it has the exact same clobber-order defect, just never exercised by a test that stubs a synchronous throw).
  - **Test:** `vault_service_test.dart`/`draft_service_test.dart` each gained "a failed load can be retried" — stub `ensureInitialized()` to throw, confirm the load rejects, re-stub it to succeed, confirm a second `load()` call actually re-reads storage rather than replaying the cached rejection. These are the tests that caught the ordering bug above; an assertion-shaped test wouldn't have (the first version of the fix made them fail with the *original* mocked exception reappearing on the retry, which is what led to the repro).

**G3 — storage-unavailable card only exists on `StartupView`.** Once G1 makes `/vault` and `/studio` load on their own, that load can now fail there too, with nothing to show for it.
  - Fix: extract `_StartupError` (`lib/ui/views/startup/startup_view.dart`) into a shared `lib/ui/widgets/common/storage_unavailable_card.dart` (copy unchanged — it's already good), render it from `VaultView`/`StudioView` when their new `initialise()` load fails, alongside `StartupView`.

**G4 — Studio's single `hasContent` boolean conflates "Vault is empty" with "nothing selected", and has no link back.** Resolved via discussion + code check: `CvComposer`'s per-section builders already implement the right rule for *sub-item* emptiness — e.g. `_buildExperience` drops the whole Experience section if `groups.isEmpty` (no experience selected), but an *included* experience with zero selected bullets still contributes a `ResolvedPosition` with `bullets: []` and the section stays (matches "no sub-bullets selected still counts as meaningful content, but zero experiences selected removes the section" exactly — no composer change needed). What's missing is Studio-level UI acknowledging *why* the preview is empty:
  - New 3-way state on `StudioViewModel` (replacing the single `hasContent` bool):
    | State | Condition | Copy | Action |
    |---|---|---|---|
    | `vaultEmpty` | `vault.isEmpty` (the existing `CvVaultEmptiness` predicate) | current `StudioEmptyPreview` copy | **Go to Vault** → `VaultViewRoute` |
    | `nothingSelected` | `!vault.isEmpty && resolvedCv.sections.isEmpty` | "Nothing selected yet — your Vault has N items, but none are included in this CV." | **Select all** (existing `addAllExperiences`/`addAllProjects`/`addAllSkills`/`addAllEducation`/`addAllHobbies`, run together) |
    | `ready` | otherwise | render preview | — |
  - All-sections-hidden (every `CvSectionType` in `draft.hiddenSections`) counts as `nothingSelected` too — same dead-preview symptom as nothing-toggled-on, same fix (unhide + select all).
  - "Select all" over a "go configure" hint on tablet/mobile, since the config panel there is a separate tab, not visible alongside the empty preview.
  - Reachable only by deliberate deselection now that P1.6's `isFreshDraft` auto-selects everything on first run — still reachable (uncheck everything, or hide every section), so still worth handling.
  - **Shipped exactly as spec'd** — `StudioPreviewState` enum, `previewState`/`vaultItemCount`/`goToVault`/`includeEverything` on `StudioViewModel`, `StudioEmptyPreview` generalized to take title/message/action params instead of one hardcoded copy.

**G5 — `PdfPreview` render failure falls through to the vendored package's raw `ErrorWidget(error)`**, not app copy. No `onError:` is passed at the call site (`studio_view.desktop.dart`). Likeliest real-world trigger is the exact failure class the plan already flags — font/asset resolution under `--base-href /cv-forge/` on the deployed build.
  - **Shipped:** `onError:` now points at an app-styled card explaining the export button uses the same PDF generation and may still work.

**G6 — `DraftService.persistError` is reactive but has zero consumers.** Only `VaultService.persistError` is surfaced (via `VaultPersistErrorBanner` in `VaultCardList`); a failed *draft/selection* write is completely silent — the exact "never fire-and-forget a write of user data" case `CLAUDE.md` calls out.
  - **Shipped:** `VaultPersistErrorBanner` → `lib/ui/widgets/common/persist_error_banner.dart` (generic `message` param), rendered at the top of `StudioConfigPanel` wired to `StudioViewModel.hasPersistError`/`retryPersist`, which forward to `DraftService`.

**G7 — export error copy is one generic message for every failure mode.** Already meets the plan's bar ("surfaced visibly, never silent"); classifying failure modes is pure polish. **Deferred, not in scope for this PR — resolved 2026-08-20, see "Follow-up fixes" ([PR #25](https://github.com/IanHeinrich/cv-forge/pull/25)) below.**

**Housekeeping:** attempt deletion of `ui/bottom_sheets/notice/*` — confirmed genuinely unused (only self-referencing files and the `@StackedApp` registration mention it).
  - **R2 resolved, and the answer is "keep it":** actually tried the deletion. `stacked generate` succeeds either way, but `flutter analyze` fails on an empty `bottomsheets: []` — the generated `enum BottomSheetType {}` trips `enum_without_constants` (an *error*, not just info, so R7's "info-level fails CI" bar doesn't even need invoking). Reverted; `NoticeSheet` stays until there's a second real bottom sheet to keep the enum non-empty.

**Update `CLAUDE.md`.** Correction on the original ask: `lib/models/`/`lib/templates/` documentation already exists (added in an earlier session, this bullet was stale). The two genuinely missing pieces — the flat-`MultiPage`-child-list rule and an explicit `dart format .` after `stacked generate` reminder — are now added.

README: what it is, privacy stance (nothing leaves the browser), deployed URL.

**Golden drift, resolved:** both `VaultView` goldens failed locally (Windows) after the changes above, initially assumed to be real content drift from the new loading state. Dispatched `update-goldens.yml` on the Linux runner to check — the regenerated PNGs came back **byte-identical (SHA256-equal)** to what was already committed. So the loading state never actually reaches the golden capture (it resolves before `pumpWidget` settles) and there was no content drift at all; the two local failures were purely R1's pre-existing Windows-vs-Linux rendering difference. Nothing to commit — CI passes against the existing baselines unchanged.

---

## Risks

| | Risk | Mitigation |
|---|---|---|
| **R1** | **Golden baselines are OS-dependent.** Already bit us once this session — a Windows-generated PNG failed on ubuntu CI with a 0.13% diff. | We solved it ad-hoc by dispatching a temporary job on the Linux runner and downloading the artifact. **Make that permanent in P1.3**: add a `workflow_dispatch` `update-goldens.yml` that runs `flutter test --update-goldens` and uploads the PNGs. Do it before there are four goldens. **Done — `update-goldens.yml` exists and was used again for real in P1.5 (Projects section changed the populated Vault fixture) and again in P1.6 (drift with no apparent content cause — CI was red on `main`'s current `VaultView` goldens by the time P1.6 opened its PR; not caused by P1.6's changes, `VaultView` isn't touched by it). If this keeps recurring without a code reason, it's worth asking whether something upstream (Flutter SDK patch version, font package version) is genuinely unstable rather than re-running the workflow forever.** |
| **R2** | Empty `dialogs:`/`bottomsheets:` lists in `@StackedApp` — `main.dart` calls `setupDialogUi()`/`setupBottomSheetUi()` unconditionally; whether the generator emits those files for an empty list is **unverified**. | Sequencing: never let `dialogs:` empty (create `confirm_delete` *before* deleting `info_alert`); defer the notice-sheet deletion to P1.7 where it's cheap to abandon. |
| **R3** | `hive_flutter` + `hive_ce_flutter` coexisting → ambiguous `Hive` imports. | P1.0 removes `hive_flutter` outright. Do **not** "add now, remove later". |
| **R4** | Missing `explicit_to_json` silently serialises nested freezed objects as `Instance of '…'` — will look like a Hive bug. | Fixed in P1.0; proven by P1.2's round-trip assertions. |
| **R5** | `pw.MultiPage` fed a single root `pw.Column` can't split pages — everything overflows page 1 and reads like a package limitation. | Encode the flat-list rule in the `CvTemplate` doc comment in P1.5, *before* the PDF renderer exists. |
| **R6** | CI's `dart format --set-exit-if-changed` + generated files is this repo's highest-frequency failure mode. | `dart format .` after every `stacked generate`, before commit. |
| **R7** | `flutter analyze` fails on **info-level** too (bit us twice already). | Keep models to shapes `json_serializable` handles cleanly. Run analyze locally before pushing. |
| **R8** | Preview/PDF metrics will never match exactly — Flutter's shaper and `package:pdf`'s layout differ. | Same TTF + pt-based tokens gets close. Label it "approximate preview" in the UI; don't spend P1.5 chasing parity. |
| **R9** | Small-caps faking is bespoke in both renderers; divergence between them is likely. | Shared pure-Dart `SmallCapsRun` splitter; adapters only map runs to span types. **Moot for now** — `ats_minimal` (what actually shipped in P1.5) uses no small caps at all; revisit if a future template wants them. |
| **R10** | `◆` (U+25C6) may be missing from Liberation Serif → `.notdef` boxes. | Verify in P1.5; make the separator a token so substituting `•` is one line. **Moot for now** — same reason as R9. |
| **R11** | *(new, 2026-08-18)* A widget that self-corrects its measured size via `setState` in a `WidgetsBinding.addPostFrameCallback` can silently loop for dozens of frames if the measured child's constraints are contaminated by the very estimate being corrected. Hit this for real in `CvPageSurface`: a `Column` (`MainAxisSize.max` by default) laid out under a shrinking outer height reported that shrinking height back as its own, so each "correction" made the estimate worse instead of fixing it — the live preview visibly collapsed toward zero height, and cost real frame budget (60+ silent relayouts) that read as "the whole app is laggy" in Studio, not as a preview-only bug. | Any future measure-then-correct widget must give the measured subtree unconstrained/decoupled constraints (`OverflowBox` with `maxHeight: double.infinity` is what fixed it here) so it always reports its true intrinsic size regardless of the current (possibly wrong) estimate feeding its ancestor's layout. |

### Phase 2 corners avoided

| Phase 2 feature | What Phase 1 already does |
|---|---|
| Copilot bullet rewriting | `bulletOverrides` + `tailoredSummary` exist and the composer honours them. **Non-negotiable** — without it the Copilot must mutate the Vault, breaking the product premise. |
| Multi-draft ("multiple CVs") | `CvDraft` carries `id` + `name`; `cvforge_drafts` is keyed by id. Phase 1 just always uses `current`. **Not actually free** — see the P2 sketch below; `DraftService` still needs reshaping from one hardcoded key to an indexed collection plus migration. |
| Regional presets (A4/Letter, spelling) | `PdfPageFormat` is a parameter everywhere, never a template constant. `compose` already takes `RegionProfile`. Margins are pt tokens. |
| Templates #2/#3 | Section order is domain-level; `ResolvedSection` is a union so a new template is a `switch`; registry already returns descriptors. |
| JSON export/import | Everything is already a JSON string with in-model `schemaVersion` and a migrate-on-read path identical for a file or a box value. |
| BYOK key storage | `cvforge_settings` opened in Phase 1. **Be honest in Phase 2:** keys sit in plaintext IndexedDB, readable by any XSS on the origin. Mitigation is an explicit warning, not a false claim of secure storage. |

---

## Phase 2 — Multi-draft CVs (sketch)

*Sketched 2026-08-18, ahead of the rest of Phase 2, at the user's request — corrects the "Free" claim above. `CvDraft.id`/`name` existing is necessary but not sufficient: `DraftService` still only ever persists one draft under one hardcoded key (`current`), and Studio jumps straight into it rather than offering a choice.*

The point of the whole product is a centralized Vault that lets you assemble a new tailored CV quickly for each application — that only actually works once there can be more than one saved, named draft to pick up, duplicate, or start fresh from.

### Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Storage: one box entry per draft (`draft_<id>`), plus a small index entry (`draftIds` + `activeDraftId`) | Matches the existing per-key debounced-write pattern (decision 8, P1.2) — an autosave on one draft shouldn't rewrite every other draft's JSON. |
| 2 | Migrate the existing single `current` draft into the new shape on first load, don't discard it | Same no-silent-data-loss rule P1.2 already applies to Vault's corrupt-payload quarantine. |
| 3 | `DraftService.draft` getter stays, now resolving `drafts.firstWhere(id == activeDraftId)` | Every existing call site — `StudioViewModel`, `CvComposer`, every `setXIncluded` — keeps working unchanged; only what backs the getter changes. |
| 4 | Studio's landing route becomes a drafts list, not the editor | The actual ask — "quickly put new CVs together for different applications" implies choosing/creating a CV before editing one, not always resuming one implicit draft. |
| 5 | `duplicateDraft` ships in the first cut, not deferred | Directly serves the stated goal: cloning a tailored draft as the starting point for the next application is the fast path this feature exists for. |
| 6 | Per-draft professional-summary override ships independently, first, ahead of the rest | `tailoredSummary` + `CvComposer._buildSummary`'s vault-fallback already exist end-to-end since P1.1/decision (`bulletOverrides` + `tailoredSummary` Phase-2-proofing) — it's a text field away from working. No reason to gate it behind the storage rework. |

### Sub-phase sequence

| # | Name | Depends on |
|---|---|---|
| P2.1 | Per-draft manual text overrides UI (summary, headline, references, bullets, education details) — **1.1.0, shipped** | P1.5 (mergeable independently) |
| P2.2 | `DraftService` multi-draft rewrite + migration — **shipped** | P1.5 |
| P2.3 | Drafts list view + routing + rename/duplicate/delete — **shipped** | P2.2 |

### P2.1 — Per-draft manual text overrides → **bump 1.1.0** ✅ shipped
Started as summary-only, then widened in the same PR at the user's request to cover every prose field: professional summary, headline, references note, experience/project bullets, and education `details`. Explicitly out of scope — contact identity, computed date ranges, company/role/institution names, skill labels, hobby text — anything factual/structural stays Vault-sourced only, mirroring the distinction `CvBullet`'s doc comment already draws between a bullet's structural `label` and its prose `text`.

**Two deliberately different widgets, not one, because the fields aren't structurally alike:**
- **Page-level singular fields** (headline, summary, references — one value each, not tied to a list) use a generalized block card, `StudioFieldOverrideCard` (renamed from the summary-only `StudioSummaryEditor`, now decoupled from `StudioViewModel` and driven by primitives instead). Collapsed — showing the Vault's value, or the override once tailored — until the user taps the pencil; only then does an editable box open, pre-filled and autofocused. Typing text identical to the Vault's (or blank) stores `null` rather than a spurious override — `StudioViewModel`'s override setters all funnel through one `_normalizeOverride` helper for this. All three cards (Headline, Summary, References) sit together below Sections, in roughly print order; References previously had no Studio UI presence at all beyond its Sections checkbox and now gets the same permanent card.
- **Entity-scoped repeated fields** (a bullet's own text, one education entry's `details`) use a compact inline "pencil to edit" affordance (`tailorable_field.dart`: `TailorableField`, `TailorIconButtons`, `InlineTextOverrideEditor`) nested under the item they belong to, wired into `VaultItemSelectorList`/`SelectorItem` via a new optional `tailorable` field. A block card repeated per-bullet in an already-indented, already-checkbox-dense list would have been far too heavy. Education's `details` has no pre-existing display, so it gets its own always-visible-once-selected preview-or-"Add details" row.

**Both widgets ended up sharing one interaction, not two similar ones** — `StudioFieldOverrideCard` builds a `TailorableField` from its own primitives and renders the exact same `TailorIconButtons`/`InlineTextOverrideEditor` the entity rows use, so Escape-to-collapse, the "Only affects this CV." footer, and the collapse behaviour can't drift between the two call sites. This wasn't the first design — see "Iteration on the tailored/from-Vault indicator" below for what didn't survive contact with the actual rendered UI.

**Regression risk found and guarded against, not just theorized — twice, at two nesting depths:** (1) writing a draft's first-ever headline/summary/references override flips its `sectionHasData` check true, inserting a new checkbox row into `StudioConfigPanel`'s `ListView` above the cards; (2) writing a bullet's first-ever override, or toggling a *sibling* bullet's inclusion while mid-edit on another, reorders `_BulletSublist`'s children. Without explicit `ValueKey`s at every level (section checkboxes, the three cards, each bullet's checkbox row, each bullet's inline editor, each top-level tailorable row), Flutter's positional widget-list reconciliation could hand a live text editor's element slot to a different widget, destroying its `TextEditingController` and focus. Both were verified live, not just reasoned about: typing into an empty headline/summary box while its Sections row appeared above it, and — the deeper case — starting an edit on one bullet's text, then toggling a *different* bullet's checkbox mid-edit (shrinking the sub-list by one row), confirming the in-progress edit kept its focus and text throughout.

`VaultTextField` was promoted to `lib/ui/widgets/common/app_text_field.dart` as `AppTextField` (gaining `minLines`/`autofocus`) so Studio could reuse its debounced-commit-on-type/flush-on-blur behavior without a vertical-slice-breaking cross-feature import; all 7 Vault call sites were repointed at the shared widget.

**Model:** `CvDraft` gained `headlineOverride`, `referencesOverride`, `educationDetailsOverrides` (id-keyed, same shape as the pre-existing `bulletOverrides`) — no schema version bump, same precedent as `bulletOverrides`/`tailoredSummary` originally. `bulletOverrides` itself already existed since P1.1 with zero UI call sites until now (the same "no production API only tests call" gap `tailoredSummary` had before this PR started).

**Bug found and fixed in the same PR: bullet-level "Select all" only ever selected one bullet.** `_BulletSublist`'s handler fired every bullet's toggle in one synchronous loop with no `await` between them; each `toggleExperienceBullet`/`toggleProjectBullet` call reads `_draft.bulletIds` fresh to compute its own updated list, so firing all of them synchronously means every call reads the *same* pre-toggle draft and only the last write survives. Fixed with `StudioViewModel.addAllExperienceBullets`/`addAllProjectBullets`, which `await` each toggle before starting the next — matching the pattern `addAllExperiences` etc. already used. Regression test simulates the mock draft updating between calls (a naive re-implementation of the bug would fail it).

**Studio's config panel now scales up to 676px** (was a fixed 380px, then briefly a 520px cap) via a `LayoutBuilder` in `StudioViewDesktop`, `(constraints.maxWidth * 0.32).clamp(380, 676)` — past a point extra window width buys the PDF preview nothing (it's a fixed-aspect-ratio page), so it's better spent on the panel's checklists and tailoring editors.

**Wording/UI consistency pass, done after the feature worked but before merge, at the user's explicit request** ("the wording across the studio is very inconsistent... please do a full pass"): bullet-level bulk-include renamed from "Select all" to "Add all (N)", matching the category-level control it's the same action one level down from; the global empty-preview "Select all" action renamed to "Add all" for the same reason; Education's empty-details message unified to "No details in your Vault yet." matching the "No X in your Vault yet." template the other three fields already used.

**Iteration on the tailored/from-Vault indicator — kept here because the rejected designs are exactly the kind of thing to not redo:**
1. First cut: a text pill ("Custom" / "From Vault") on page-level cards, shown only when tailored on entity rows (a density compromise for long checklists). Rejected for wording drift ("Custom" vs. a separately-worded "Custom for this CV" marker on entity rows) once actually compared side by side.
2. Unified to one shared pill widget, then to an icon (`folder_outlined`/`auto_awesome`) shown in *every* state everywhere, reasoning that an icon is cheap enough to not need the density compromise. `auto_awesome` (sparkle) was picked for "tailored" — then rejected: this app has no AI-assisted rewriting yet, and a future one would want the sparkle for itself, not find it already spent on plain manual edits. Swapped to `Icons.tune`.
3. Stacking the status icon above `TailorIconButtons` on entity rows overflowed `CheckboxListTile`'s `secondary` slot (it sizes to `title`/`subtitle` alone, not a 2-row trailing widget) — caught live via a real `RenderFlex` overflow banner, not by inspection. Fixed by rendering the pill+icons cluster as a `Row` sibling instead of nesting it in the tile.
4. Final design, after the user asked "can't the undo button work as the edited icon, serve two purposes": dropped the separate status icon entirely. `TailorIconButtons` now shows exactly two icons, always — a plain `Icons.lock` glyph in the left slot when untailored, replaced by the **undo** button once tailored. The undo button's mere presence *is* the "this differs from the Vault" signal (same trick as a "reset to default" control that only appears once a setting has changed), which also fixed the icons-shifting-between-rows complaint since every row now renders exactly two icons, never three. `Icons.lock`/`Icons.lock_outline` also replaced `Icons.folder_outlined` for "from Vault" everywhere it appeared — the nav rail's Vault entry (`app_chrome.dart`) and the empty-Vault illustration (`vault_empty_state.dart`) — since a lock reads as "a secured store of the master data" where a folder just reads as "a directory". Flutter's default Material Icons set has no literal safe/vault glyph; `lock` was the closest available.

### P2.2 — `DraftService` multi-draft rewrite → ✅ shipped
- `ReactiveValue<CvDraft> _draft` → `ReactiveValue<List<CvDraft>> _drafts` + `ReactiveValue<String?> _activeDraftId`.
- New API: `createDraft({name, notes, templateId})`, `openDraft(id)`, `updateDraftDetails(id, {name, notes})`, `duplicateDraft(id)`, `deleteDraft(id)`. Ids via `const Uuid().v4()`, same convention as Vault entity ids (decision, P1.1 "IDs").
- Migration in `_load()`: if the new index key is absent but the legacy `current` key has data, wrap it as the first entry and write once under the new shape; the old key is then dead but left alone (no destructive delete needed).

**Tests** (`draft_service_test.dart`, extended, outside-in against `MockLocalStorageService`): create/open/rename/duplicate/delete; migration from the single-draft format round-trips the existing draft's selections intact; a corrupted per-draft index entry is quarantined and dropped without losing its siblings.

**Shipped, beyond the sketch above:**
- **`CvDraft` gained a `notes` field** (free-text, never rendered into the CV) — the user's actual ask ("namable, and have a notes section... to let the user track what it's for") went beyond just naming. Same `@Default('')` treatment as other Phase-1-added fields; no schema bump, same precedent as `bulletOverrides`.
- **A new `DraftIndex` freezed model** (`lib/models/draft/draft_index.dart`: `schemaVersion`, `draftIds`, `activeDraftId`) backs the index entry, rather than a hand-rolled JSON shape — matches this repo's "everything persisted is a versioned freezed model" convention (`CvVault`, `CvDraft`).
- **Storage key naming**: `StorageKeys.draftIndex` (`'index'`) for the manifest, `StorageKeys.draftEntry(id)` (`'draft_<id>'`) for each draft — not literally `draft_<id>` as a bare string built inline at each call site.
- **`renameDraft(id, name)` became `updateDraftDetails(id, {name, notes})`** — folds the notes edit into the same call so a "New CV" / "Edit CV details" dialog can save both fields in one round trip.
- **The "select all from Vault on a fresh draft" behaviour moved from `StartupViewModel` into `StudioViewModel`.** It only ever mattered for whichever draft Studio was about to render, and with multiple drafts that's "whichever one you just opened/created," not "the one draft that exists at app startup." `StartupViewModel` now only brings storage/Vault/draft-index online; `StudioViewModel._load()` checks `DraftService.isFreshDraft` and runs the same Vault-derived selection itself. This also means opening a **newly created** draft (not just the very first app-ever draft) gets the same "starts fully populated" treatment.
- **A real generic-dialog-typing bug, caught live in the browser, not in tests:** `EditDraftDialog`'s `completer(DialogResponse(confirmed: true, data: result))` — with no explicit type argument — was constructing a `DialogResponse<dynamic>`, because Dart infers the constructor's type parameter from the surrounding `Function(DialogResponse)` context (`dynamic`), not from the `data:` argument's actual type. `StudioViewModel.editDraftDetails`/`DraftsListViewModel`'s dialog calls use `showCustomDialog<EditDraftDialogData, EditDraftDialogData>` (explicit generics, so the route expects `GetDialogRoute<DialogResponse<EditDraftDialogData>>`), so popping the mismatched `DialogResponse<dynamic>` threw a `_debugCheckCanConsumeResult` assertion on every Save/Cancel click. Fixed by giving both `DialogResponse<EditDraftDialogData>(...)` constructions in `edit_draft_dialog.dart` an explicit type argument. Mockito's generated mocks have the identical inference gap — the same fix (explicit `DialogResponse<EditDraftDialogData>(...)` in `when(...).thenAnswer(...)`) was needed in every test that stubs this dialog variant, or the stub's cast throws instead of the assertion. Worth remembering for any future dialog that calls `showCustomDialog` with explicit generic type arguments — the bare-generics `ConfirmDeleteDialog`/`showCustomDialog(variant: ...)` pattern (no explicit `<T, R>`) doesn't hit this, since both sides agree on `dynamic`.

### P2.3 — Drafts list view → ✅ shipped
```bash
stacked create view drafts_list -c stacked_configs/studio.json
stacked create dialog edit_draft -c stacked_configs/studio.json
```
Card list (name, template, last-updated, notes preview) at `/drafts` (`DraftsListView`, under `features/studio/views/drafts_list/` — no new `stacked_configs/drafts.json`; reuses `studio.json` since it's the same feature's data), with a per-card menu (rename/edit notes, duplicate, delete) and a "+ New CV" FAB.

**Deliberate deviation from the sketch: `/studio` stays a single route, not `/studio/:draftId`.** `DraftService.draft` resolves via `activeDraftId` (decision 3), and `openDraft`/`createDraft`/`duplicateDraft` all set it before navigating to `StudioViewRoute()` — so which draft Studio shows is real persisted state, just not URL-addressable per draft yet. This repo's router had no precedent anywhere for a path-param route (`app.router.dart` is entirely generated, and every existing route is a bare `CustomRoute(page: X, path: '/x')`), and the deep-link/refresh hazard P1.2/P1.7-G1 already solved — `await _ready()` on every read path plus each View loading its own services in `initialise()` — covers this fine as-is: refreshing on `/studio` re-resolves whatever `activeDraftId` was last persisted, same as `/vault` always shows the one Vault. A `/studio/:draftId` route (letting a browser back-button or a bookmarked link jump straight to a specific draft) is a reasonable follow-up, not done here — it wasn't needed to satisfy "save and load multiple different CVs," and taking on stacked_generator's path-param convention for the first time felt like more risk than the ask justified. **Resolved 2026-08-20 — see [PR #25](https://github.com/IanHeinrich/cv-forge/pull/25)** (as a query param, not a path segment, for exactly the collision reason anticipated here).

**Nav rail gained a third `AppSection.drafts` entry** (`app_chrome.dart`) between Vault and Studio — Vault → Drafts → Studio reads as the natural left-to-right workflow. The Studio rail entry still opens `/studio` directly (whatever draft is currently active), so a user mid-edit can jump back into it without detouring through the list.

**No template picker in the "New CV" dialog** — `createDraft` takes an optional `templateId` (defaulting to `TemplateRegistryService.defaultTemplate.id` when the caller omits it, which `DraftsListViewModel.createDraft` does today) precisely so a picker is a UI-only addition later, once a second template exists. Building a one-item picker now would just be a dropdown nobody can meaningfully use yet.

**`AppSummaryCard`** (promoted from Vault's `VaultSummaryCard`, `lib/ui/widgets/common/app_summary_card.dart`, gaining an optional `notes` line and an `actions` slot for more than one trailing control) backs both the Drafts cards and every pre-existing Vault entity card — same promotion pattern P2.1 used for `AppTextField`, so a widget two features now want doesn't get forked.

**Tests:** `drafts_list_viewmodel_test.dart` against `MockDraftService`/`MockTemplateRegistryService`/`MockDialogService`/`MockRouterService`, same outside-in shape as `vault_viewmodel_test.dart` — create (confirm/cancel)/open/edit/duplicate/delete(confirm/cancel), each asserting the right service call and the right post-action navigation. `studio_viewmodel_test.dart` gained coverage for `goToDrafts`, `editDraftDetails` (confirm/cancel), `draftName`/`draftNotes`, and the fresh-draft-selects-everything behavior now living on this ViewModel instead of `StartupViewModel`.

**Manually verified in a real browser** (not just unit tests): first-load migration of the pre-existing single draft into "My CV"; create → auto-navigates into a fully-populated Studio; rename/edit-notes dialog pre-fills and saves; duplicate clones selections and opens the copy; delete removes it; every draft's name, template, notes, and selections survive a hard page reload (IndexedDB round-trip, not just in-memory state).

### P2.3.1 — Nav rail cleanup: drop Studio as a tab, rename Drafts → CVs, real icons (2026-08-19)

Immediate follow-up to P2.3, prompted by the user questioning the nav rail's own design once Drafts existed: Studio isn't a peer of Vault/Drafts, it's a child of Drafts (you can't land there without a chosen draft), so presenting it as an equal-weight third tab was misleading — clicking it silently resumed "whichever draft was last active" with no way to predict that from the rail alone.

- **`AppChrome`'s `NavigationRail` now has 2 destinations, not 3.** `AppSection.studio` still exists as an enum value (`StudioView`'s three breakpoint files still pass `currentSection: AppSection.studio` unchanged) but renders no destination of its own — `AppChrome._visualSection` maps it onto `AppSection.drafts` for `selectedIndex`, so being in the editor highlights the "CVs" tab it was reached from. `_navigateTo`'s `case AppSection.studio` is unreachable dead code with a comment explaining why, kept only because the switch must stay exhaustive.
- **"Drafts" renamed to "CVs"** — user-facing label only (`NavigationRailDestination`'s `Text('CVs')`), not a rename of `DraftsListView`/`DraftService`/the `cvforge_drafts` Hive box/etc. Renaming the box name would need a migration path for real user data already under that name; the UI copy already used "CV" language everywhere else (empty state, "New CV" button), so the rail label was the one lagging surface. Considered "My CVs"/"Library"/"Applications" too; "CVs" won for matching the terse single-word style of "Vault".
- **Every icon in the app was swapped from Flutter's default Material Icons font to [Remix Icon](https://remixicon.com/)** (`remixicon` package, MIT, `RemixIcons.x_line`/`x_fill`), for one consistent icon language and — the actual trigger — because Material Icons has no bank-vault/safe glyph for the Vault nav icon.
  - **Getting here took two false starts, worth remembering before reaching for an icon font package again:** first tried `tabler_icons_plus` (Tabler Icons wrapper) since Tabler's core SVG repo does have a `vault.svg` — but the *published Flutter package* (and every other Tabler wrapper checked) is pinned to Tabler webfont v3.44–3.45, and `vault.svg` was only added in Tabler v3.46, so it silently doesn't exist in any currently-installable version. Checked Material Symbols next (Google's newer, 2500+-icon set) directly against its authoritative `.codepoints` file — no vault/safe icon there either. **`remixicon` was the first candidate actually verified against real installed package source** (not a package README's claims) to contain `safe_line`/`safe_fill` before being adopted — a lesson from the first two misses.
  - Vault's rail icon: `RemixIcons.safe_line` / `safe_fill` (a rounded safe door with a dial — confirmed by rendering it, not just trusting the name). Also replaces the Vault empty-state's icon, which used to be `Icons.folder_open`.
  - CVs' rail icon: `RemixIcons.file_text_line` / `file_text_fill`, also reused for each Drafts card's leading icon and the Drafts empty state (previously `Icons.description*`).
  - Every other icon in the app (delete, close, add, chevrons/expand carets, drag handle, error, edit, download, per-section leading icons — briefcase for work history, graduation cap for education, rocket for projects, star for skills, footprint for hobbies, user for basics) got a same-meaning Remix equivalent. Full mapping is in the diff; nothing was left on `Icons.*` — `grep -rn "Icons\." lib/` returns nothing.
- **Golden tests now need real regeneration, not just a re-confirm.** `vault_view_empty`/`vault_view_populated` diff against committed baselines jumped from the pre-existing Windows-vs-Linux drift (~0.5%/1.2%, R1) to ~0.96%/2.34% — a real content change (different glyphs), not platform noise. Needs `update-goldens.yml` dispatched on the Linux runner and the new PNGs committed before this merges; not done as part of this pass.

### P2.3.2 — Recovering from a stale local `main` that missed PR #13 (2026-08-19)

**Root cause, worth remembering:** all of P2.2/P2.3/P2.3.1 above was built directly on local `main`, without first checking it against `origin/main`. Local `main` had silently diverged after P1.7 — it carried an unrelated "ignore PLAN.md" commit and a no-op merge commit, but never picked up PR #13 (P2.1's actual tailoring UI: `tailorable_field.dart`, `studio_field_override_card.dart`, `studio_panel_heading.dart`, the `headlineOverride`/`referencesOverride`/`educationDetailsOverrides` fields, three new `DraftService` setters). The gap wasn't discovered until the user asked "why can't I edit bullets" and the answer turned out to be "the feature exists on `origin/main`, this checkout just never had it" — surfaced by running `git fetch && git status -sb`, which is now worth doing at the start of any session that's about to do non-trivial feature work, not just when something looks obviously wrong.

**Recovery, in order (safe because every step preserved the previous state rather than overwriting it):**
1. Committed the session's dirty working tree as-is to a new branch (`session-multidraft-navcleanup-icons`), so nothing was at risk regardless of what came next.
2. `git checkout main && git merge origin/main` — brought PR #13 in cleanly (no conflicts; local `main`'s only unique commit didn't touch any file PR #13 touched).
3. `git merge session-multidraft-navcleanup-icons` — let git's three-way merge auto-resolve everything it could (most of the 49 changed files merged with zero conflicts, including `CvDraft`, `StudioViewModel`, `VaultItemSelectorList`, and every Vault editor panel — the two features turned out to touch mostly disjoint code inside files that overlapped only superficially). Real conflicts were isolated to exactly 6 files: `draft_service.dart` and `draft_service_test.dart` (both sides added new methods/tests at the same insertion point — resolved by keeping both, reordering so P2.1's three override setters sit before this session's `_setDraft` doc comment), `studio_view.desktop.dart` (P2.1 added `LayoutBuilder`-based responsive panel width; this session added `StudioDraftHeader` wrapping the whole thing — combined, header outside the `LayoutBuilder`), `app_chrome.dart` and `vault_empty_state.dart` (both sides changed the same icon line — kept this session's `RemixIcons.safe_line`, since "replace every icon with RemixIcon, safe/vault glyph for Vault" is a strict superset of P2.1's earlier `Icons.lock` choice), and `cv_draft.freezed.dart` (generated — discarded both sides' conflicted version and regenerated via `stacked generate` from the already-merged source).
4. Ran the app-wide icon swap (already in progress this session) over `tailorable_field.dart` too, since it arrived via the merge with raw `Icons.undo`/`Icons.lock`/`Icons.check`/`Icons.edit_outlined` untouched — `RemixIcons.arrow_go_back_line`/`safe_line`/`check_line`/`edit_line` respectively. The `Icons.lock` → `RemixIcons.safe_line` swap here is deliberate, not just mechanical: the icon means "this value is still the Vault's, unedited," so it reads correctly only if it matches whatever glyph means "Vault" elsewhere (the nav rail).
5. Full loop (`dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test --exclude-tags golden`) green at every stage — after the initial merge-with-PR#13, and again after resolving this session's branch into it. **101 tests pass** (P2.1's ~29 + this session's ~72), no regressions either direction.
6. Manually re-verified in the browser, on the merged code: existing Vault/CV data survived the entire sequence untouched (real IndexedDB, not a fixture); the tailoring UI (headline/summary cards, per-bullet pencil-to-edit, "N tailored" counts) renders and is reachable from a multi-draft CV; nav rail is Vault/CVs only, using the new icon set throughout, including inside the tailoring editor.

**Not yet done:** the golden PNGs need a *second* regeneration pass — P2.1 already regenerated them once (for its own icon change) via `update-goldens.yml`, and this session's icon swap has invalidated them again. Same open item as noted just above, now compounding two icon changes instead of one.

---

## Phase 3 — Theming system & UI polish (2026-08-20)

Prompted by the user asking, ahead of further feature work, to bring the app chrome's theming up to "gold standard": minimal magic numbers, maximum consistency, and the ability to swap padding/theming later without a rewrite. Explicitly scoped to the app chrome (`lib/ui/**`, `lib/features/**`) only — `CvDesignTokens` (`lib/templates/design/`), the CV document's own token system, was already judged gold-standard on audit (framework-agnostic, single-source-of-truth, PDF-is-truth) and left untouched.

**Audit finding, before any code:** a real token vocabulary already existed (`app_constants.dart`'s `kdPadding*`, `app_text_styles.dart`'s `ktsX`, `ui_helpers.dart`'s `verticalSpace*`/`horizontalSpace*`) but was opt-in per call site — roughly half of `lib/features/**` routed around it with inline literals, and `buildAppTheme()` registered zero component themes, so every button/dialog/input fell through to Material's implicit defaults.

### Sub-phase sequence

| # | Name | PR |
|---|---|---|
| 3.1 | Token layer: `AppSpacing`/`AppRadius`/`AppTypography`/`AppMotion` as `ThemeExtension`s | [#16](https://github.com/IanHeinrich/cv-forge/pull/16) |
| 3.2 | Component themes (buttons, dialog, input) + the button-radius decision | [#17](https://github.com/IanHeinrich/cv-forge/pull/17) |
| 3.3 | Sweep: migrate every call site to the token layer; delete the dead constant files | [#18](https://github.com/IanHeinrich/cv-forge/pull/18) |
| 3.4 | Guardrail: document the convention in `CLAUDE.md` | [#19](https://github.com/IanHeinrich/cv-forge/pull/19) |
| 3.5 | Resolve the fontSize/EdgeInsets follow-ups flagged by 3.3's audit | [#20](https://github.com/IanHeinrich/cv-forge/pull/20) |
| 3.6 | Pin `ColorScheme.primary`/`error` to the real brand colors | [#21](https://github.com/IanHeinrich/cv-forge/pull/21) |
| 3.7 | UI polish: drop the summary-card chevron, more bullet spacing | [#22](https://github.com/IanHeinrich/cv-forge/pull/22) |
| 3.8 | Improve the Skills editor's "Link to bullets" picker | [#23](https://github.com/IanHeinrich/cv-forge/pull/23) |

### 3.1 — Token layer → [PR #16](https://github.com/IanHeinrich/cv-forge/pull/16)

Adopted [theme_tailor](https://pub.dev/packages/theme_tailor) (codegen for `ThemeExtension` boilerplate — copyWith/lerp/==/hashCode, plus a `context.appSpacing`-style `BuildContext` extension) rather than a hand-rolled `ThemeExtension` or a heavier package like `flex_color_scheme`. Fits this repo's existing codegen-heavy toolchain (freezed, json_serializable, stacked_generator all already run through `stacked generate`/`build_runner`); a `flex_color_scheme`-managed `TextTheme` risked reintroducing the exact Material-3-`TextTheme`-merge pixel shift `app_text_styles.dart`'s doc comment already warns about.

New `lib/ui/common/tokens/`: `AppSpacing` (the old `kdPadding*` scale plus `ui_helpers.dart`'s gap scale, unified under one `ThemeExtension`), `AppRadius` (the three distinct radii — 6/8/10 — found in use, newly named), `AppTypography` (wraps the existing `ktsX` values unchanged), `AppMotion` (the one hardcoded `AnimatedContainer` duration found). `ui_helpers.dart`'s old top-level `const Widget` gap constants (`verticalSpaceSmall` etc.) can't survive this — a `const Widget` bakes its value in at compile time, and the whole point is a value that can vary by theme — so they're replaced with `VGap`/`HGap`, small `StatelessWidget`s that resolve their size from `context.appSpacing` at build time instead.

**A real mistake, caught by CI, not assumed away:** the first cut also tried to intentionally pin `ColorScheme` (`fromSeed(...).copyWith(primary: kcPrimaryColor, ...)`) in this same "should be invisible" PR. It wasn't invisible — Material's seed algorithm derives `primary` as a *tone* of the seed hue for dark mode, not the literal seed color, and every Material-default-styled widget (this app registers zero component themes at this point) reads `colorScheme` directly. CI's Linux golden run caught the diff; reverted that piece back to the original `ColorScheme.fromSeed(..., surface: kcDarkGreyColor)` construction to restore exact pixel parity, keeping only the (inert, unconsumed) `ThemeExtension` registration. The lesson that stuck for the rest of Phase 3: don't assume a plumbing change is pixel-neutral — verify via CI's Linux golden run before claiming it, and if it isn't neutral, decide the visual question deliberately rather than let it ride through as a side effect. The `ColorScheme` pin itself came back deliberately in 3.6, once there was a component-theme layer built to consume it correctly.

### 3.2 — Component themes → [PR #17](https://github.com/IanHeinrich/cv-forge/pull/17)

Registered `FilledButtonThemeData`/`TextButtonThemeData`/`OutlinedButtonThemeData`, `DialogThemeData`, `InputDecorationTheme` on `buildAppTheme()`. One deliberate visual call, put to the user rather than assumed: Material 3's default button shape is a fully-rounded pill (`StadiumBorder`-equivalent), not the app's existing 6/8/10 radius scale used everywhere else (cards, dialogs, panels) — buttons were the one pill-shaped element in an otherwise squared-off UI, purely because nothing had ever themed them. Chose to square them off to `appRadius.medium` (8px), colors untouched. Verified via local golden diff images (not just the percentage) before pushing, then regenerated the two affected goldens (`vault_view_empty`/`drafts_list_view_empty` — the only screens rendering a button in their default state) via `update-goldens.yml`.

### 3.3 — Sweep → [PR #18](https://github.com/IanHeinrich/cv-forge/pull/18)

Migrated all 28 remaining consumers of `kdPadding*`/`ktsX`/`verticalSpace*`/`horizontalSpace*`/the three raw radii/the one raw duration to the token layer — purely value-preserving substitution, confirmed via local golden diff (the two "populated" goldens reproduced the exact known Windows-vs-Linux font-rasterization noise byte-for-byte; no CI regeneration needed). `app_constants.dart` and `app_text_styles.dart`, now fully dead, were deleted rather than left as an unused-but-present legacy layer.

**Deliberately not resolved in the sweep** (see 3.5): a cluster of `fontSize: 12/13/14` `TextStyle`s scattered across studio/vault widgets that aren't one consistent role — they vary in size, color, and weight per site — plus a handful of one-off `EdgeInsets` values (`2`, `4`, `14`) outside the padding/gap scale. Forcing either onto an existing token would have silently changed a value; flagged as a follow-up decision instead of resolved inline.

### 3.4 — Guardrail → [PR #19](https://github.com/IanHeinrich/cv-forge/pull/19)

Docs-only. Added a bullet to `CLAUDE.md`'s Code style section (which already lists real past mistakes, not hypotheticals) so new chrome UI code reaches for `context.appSpacing`/`appRadius`/`appTypography`/`appMotion` instead of quietly reintroducing what 3.3 just swept out.

### 3.5 — fontSize/EdgeInsets follow-ups → [PR #20](https://github.com/IanHeinrich/cv-forge/pull/20)

Resolved the two items 3.3 flagged. `AppTypography` gained `caption` (fontSize 12) — deliberately carrying **no** baked-in color, unlike `bodySmall`, since the ~11 call sites never agreed on one (`kcLightGrey`, `kcErrorColor`, or none — inheriting the ambient color); centralizing just the size via `.copyWith(color: ...)` at each site kept every existing color/weight/style choice byte-identical. Along the way, found two exact duplicates of the *already-named* `bodySmall` (fontSize 13, `kcLightGrey`) hiding as inline literals — missed by 3.3's sweep because they'd been lumped in with the genuinely-inconsistent cluster instead of recognized as exact matches. `AppSpacing` gained `paddingHairline` (4) — one tier below `paddingTight` — for three spots that had independently landed on 4 as "the smallest deliberate gap." The remaining one-offs (2, 6, 10, 14, 96) stayed as literals: no shared role to name, just numbers that happened to look right in one place each.

### 3.6 — `ColorScheme` pin → [PR #21](https://github.com/IanHeinrich/cv-forge/pull/21)

The deliberate version of what 3.1 had to revert. Investigated first, not assumed: wrote a throwaway test computing `ColorScheme.fromSeed(seedColor: kcPrimaryColor, brightness: dark, surface: kcDarkGreyColor)`'s actual derived values. `primary` came out `#DBB9F9` — a pale lavender — nowhere near the brand purple `kcPrimaryColor` (`#9600FF`) used directly by the nav rail indicator. Confirmed live in the browser dev server, not just via the numbers: buttons were visibly a different color family from the nav rail. Pinned `primary`/`onPrimary`/`error`/`onError` via `copyWith` to the real brand colors; every other `ColorScheme` slot stays seed-derived (nobody's designed a value for those yet). **One thing the pin doesn't reach, despite an initial assumption it would:** `FilterChip`/`ChoiceChip` selection color comes from `secondaryContainer`, not `primary` — checked live in the browser and chips stayed their muted seed-derived tone. Left as a flagged, not-yet-addressed follow-up (a `ChipThemeData`, or pinning `secondary` too) rather than silently expanding scope to fix. **Resolved 2026-08-20 — see [PR #25](https://github.com/IanHeinrich/cv-forge/pull/25)** (went with the `ChipThemeData` option, to leave every other not-yet-designed `secondary`-derived slot alone).

### 3.7 — UI polish: chevron + bullet spacing → [PR #22](https://github.com/IanHeinrich/cv-forge/pull/22)

Two small, user-requested tweaks bundled together. `AppSummaryCard` drops its trailing `arrow_right_s_line` chevron — every card is already fully tappable and the delete icon (or custom `actions`) was the only affordance actually doing something, so the chevron was pure decoration. `BulletListEditor`'s per-bullet bottom padding went from `paddingTight` (8) to `paddingDefault` (16) — each bullet is a multi-line block (label field, text field, skills line) and 8px read as cramped. Regenerated the two "populated" goldens for the chevron (the only visual change); had to rebase onto `main` first since 3.6 had merged in the meantime and the golden regeneration needs to run against the *combined* state, not stack a second divergent baseline on top.

### 3.8 — "Link to bullets" picker → [PR #23](https://github.com/IanHeinrich/cv-forge/pull/23)

User-requested clarity pass on `_SkillBulletLinkPicker` (Skills editor panel) — the widget that lets a skill be linked to the specific bullets that demonstrate it. Three changes: each role heading now reads "Role · Company" instead of just "Role" (several roles can trivially share a title across different companies with no way to tell them apart before this); more vertical space between each role's bullet group (same `paddingTight` → `paddingDefault` bump as 3.7, independently motivated); each bullet chip gets a `Tooltip` with its full, untruncated text (the visible chip label stays capped at 28 characters to keep the `Wrap` from ballooning, but the full text was previously unreachable past that cutoff). Verified live against the example Vault data in the browser dev server, not just by reading the diff. No golden impact — this widget doesn't render in either golden-tested view's default state.

## Follow-up fixes (2026-08-20) → [PR #25](https://github.com/IanHeinrich/cv-forge/pull/25)

Three previously-flagged, deliberately-deferred items, picked up together in one PR now that Phase 3 is done — small, independent, and none big enough to be its own phase. Each origin note above now points here.

**Chip selection color** (3.6's follow-up). `FilterChip`/`ChoiceChip` selection reads `ChipThemeData.selectedColor`, a slot `buildAppTheme()` had never set — pinning only `colorScheme.primary` (3.6) left selected chips on the seed-derived `secondaryContainer` tone. Fixed with a `chipTheme: ChipThemeData(selectedColor: kcPrimaryColor, checkmarkColor: kcWhite)` in `app_theme.dart`, the narrower of 3.6's two flagged options — every other not-yet-designed `secondary`-derived slot (nothing else currently reads it) is left alone rather than pinning `secondary` itself and risking a wider, unreviewed effect. Verified live in the browser: a selected skill-linking chip now matches the nav rail/button purple instead of the washed-out lavender.

**`/studio` deep-linkable to a specific draft** (P2.3's follow-up). Went with a `?draftId=…` **query param**, not the `/studio/:draftId` **path** segment the P2.3 note sketched — a second path-param `CustomRoute` for the same `StudioView` widget collides with the existing bare `/studio` registration during codegen: `stacked_generator` validates every `@PathParam()`-annotated constructor field against the *specific route's own* path, and the bare `/studio` route (which must keep working, since it's what the nav-rail-adjacent code path implicitly assumed) supplies no such param. This confirms the risk the original note anticipated, just resolved via query param instead of taking on a second route registration. `StudioView` gained an optional `@QueryParam() draftId`, threaded into `StudioViewModel(requestedDraftId:)`, which calls `DraftService.openDraft(id)` once on load (a no-op for `null`/unknown/already-active — same "dangling ids are normal" rule as everywhere else in this app). `DraftsListViewModel`'s open/create/duplicate actions now navigate with `StudioViewRoute(draftId: id)` instead of the bare route. Verified live: Open/New CV/Duplicate each produce the right URL; a hard reload on `/studio?draftId=<real id>` reopens that exact draft; an unknown id falls back cleanly to whatever's active rather than erroring.

**Export error copy classified by failure stage** (P1.7's G7). `PdfExportService.render`/`export` now wrap each of their three failure-prone stages — font/asset load, `pw.Document` build+save, and the browser save — in a `PdfExportException(PdfExportStage, cause)`, and `StudioViewModel.exportErrorMessage` switches on the stage for the `_ExportFab` error chip's copy, replacing the one generic message. Caught one real bug while wiring the render stage: the original `return document.save();` inside the render `try` block returned the un-awaited `Future` — a failure inside it would propagate *after* the enclosing `try/catch` had already exited, silently skipping the classification entirely (`unawaited_return_in_try_block` from `flutter analyze` is what caught it, not inspection). Fixed by `await`-ing before returning.

Also found and fixed while touching `FontService`, not originally in scope: `FontService.load()` had the exact same `_readyFuture ??=`-clobber bug P1.7's G2 fixed elsewhere in this codebase — a failed font load (e.g. an asset 404 under a bad `--base-href`) was cached forever, so the new "couldn't load fonts, try again" copy would have been a lie on retry. Fixed the same way G2 was: the reset lives in `load()` itself via `.catchError()`, not inside `_loadFonts()`.

## Verification

**Per sub-phase (CI enforces):** `dart format --output=none --set-exit-if-changed .`, `flutter analyze` (must be **zero** issues — info-level fails), `flutter test`.

**Local loop:**
```bash
stacked generate && dart format . && flutter analyze && flutter test
```

**Manual, at each version-bumped milestone** (via `flutter run -d web-server --web-port 8765` then browser):
- **P1.4** — enter a full CV, reload the page, confirm everything persists (IndexedDB behaves differently in a real browser than in any test). Delete an experience, confirm the confirm-dialog path.
- **P1.5** — toggle sections and experiences; confirm the preview updates live and the A4 proportion is right. Compare side-by-side against `Ian_Heinrich_CV.pdf` for fidelity.
- **P1.6 — the acceptance test for the whole MVP:** click export, then on the downloaded PDF:
  1. Open it and **Ctrl+A / Ctrl+C** → text must be selectable and paste as real text, not gibberish.
  2. Run `pdftotext` on it → every bullet, skill, and heading must appear in readable order.
  3. Paste a smart quote (`'`), an en-dash (`–`) and `€` into a bullet, re-export, confirm no crash and correct glyphs.
  4. Confirm the filename is `name_draft.pdf` — **not** `.pdf.pdf`.
- **P1.6 on the deployed Pages build specifically** — confirm `rootBundle.load('assets/fonts/…')` resolves under `--base-href /cv-forge/`. Asset-paths-under-base-href is exactly the bug class that only appears in the deployed build (we already hit its cousin with the bootstrap loader).

**Definition of done for Phase 1:** a first-time visitor to `https://ianheinrich.github.io/cv-forge/` can enter their career history, curate a draft, and download an ATS-parseable PDF — with nothing leaving the browser.

---

## Critical files

- `pubspec.yaml`, `build.yaml` — P1.0 groundwork (deps, assets/fonts, `explicit_to_json`)
- `lib/app/app.dart` — central `@StackedApp`; CLI-owned, marker-driven
- `test/helpers/test_helpers.dart` — mock registration conventions
- `lib/ui/views/startup/startup_viewmodel.dart` — becomes the init sequence
- `lib/ui/common/{app_colors,ui_helpers}.dart` — **reuse**, don't reinvent (`kc*` palette, `VGap`/`HGap`)
- `lib/ui/common/tokens/` — the theming token layer (Phase 3): `AppSpacing`/`AppRadius`/`AppTypography`/`AppMotion`, reachable via `context.appSpacing` etc. New chrome UI spacing/radius/typography/motion goes here, not a restated literal — see `CLAUDE.md`'s Code style section.
- `lib/templates/cv_template.dart` — the dual-renderer contract
- `lib/models/render/cv_composer.dart` — the only place Vault+Draft are joined
- `CLAUDE.md` — update in P1.7; updated again in Phase 3.4 for the token-layer convention
- `.github/workflows/` — add permanent `update-goldens.yml` in P1.3
