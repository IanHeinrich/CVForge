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

> **Status (2026-08-20):** the above is stale as of P1.6 merging — kept verbatim rather than rewritten, matching this doc's existing drift-note convention. Actual state: **P1.0 through P2.3.2 are all shipped** (PR #3–#14; see each sub-phase's "✅ shipped" marker and shipped-note above for what actually landed vs. the original spec). One more PR landed with no corresponding sub-phase in this doc — **[PR #15](https://github.com/IanHeinrich/cv-forge/pull/15), "Code review cleanup"**: dead code, DRY, docs, and correctness fixes found in a review pass, not tied to a feature. Repo version is still `1.1.0` (P2.1's bump); nothing since has warranted another. **Phase 3 — Theming system & UI polish** (PR #16–#23) is also done; see its own section below, after the Phase 2 sketch. Three items flagged during Phase 2/Phase 3 as deliberately deferred (the chip selection color, `/studio` deep-linking, and export error classification) were picked up together afterward — see [PR #25](https://github.com/IanHeinrich/cv-forge/pull/25) ("Follow-up fixes" below, after Phase 3). **Nothing spec'd in this doc is unbuilt as of PR #25.** The next work is **Phase 4 — Portability, presets, templates, and the Copilot**, specified after "Follow-up fixes" below: the four features Phase 1's Context listed as "designed for but not built". It is a plan only — no sub-phase of it has started.

> **Status (2026-08-20, later the same day):** Phase 4 is no longer just a plan. **4.1 (Settings surface) and 4.2 (JSON export/import) shipped together** as [PR #27](https://github.com/IanHeinrich/cv-forge/pull/27) — see each sub-phase's "✅ shipped" marker and the "Actually shipped" note after 4.2 for what landed vs. spec. Repo version is now `1.2.0`. Remaining Phase 4 work, in decision 1's locked order: **4.3 (regional presets) next**, then 4.4/4.5 (Copilot plumbing + the tailoring pass), then 4.6 (second template). None of 4.3–4.6 has started.

> **Status (2026-08-21):** a lot landed without a doc update in between — this entry reconciles PR #28–#35 in one pass. **4.3 (regional presets) shipped** as [PR #28](https://github.com/IanHeinrich/cv-forge/pull/28). **Phase 5 — ATS format analyzer**, a user-requested feature outside the original roadmap (its own section below, after Phase 4), shipped its core pipeline as [PR #29](https://github.com/IanHeinrich/cv-forge/pull/29), a false-positive fix in the garbled-text check as [PR #30](https://github.com/IanHeinrich/cv-forge/pull/30), and — reversing Phase 5's own "deferred, not shipped in this phase" note — the X-Ray bounding-box overlay with evidence-linked findings and camera pan/zoom as [PR #31](https://github.com/IanHeinrich/cv-forge/pull/31) (version bump in [#32](https://github.com/IanHeinrich/cv-forge/pull/32)). [PR #34](https://github.com/IanHeinrich/cv-forge/pull/34) fixed a stale Pages `--base-href` after the GitHub repo was renamed `cv-forge` → `CVForge`. **4.6 (second template + picker) also shipped**, as [PR #35](https://github.com/IanHeinrich/cv-forge/pull/35) — ahead of 4.4/4.5, out of decision 1's locked order (harmless: nothing about the picker depended on the Copilot shipping first) — plus a first-class Publications section and per-template section ordering that weren't in the original spec. See each sub-phase's own "✅ shipped"/"Actually shipped" note for detail. Repo version is now `1.4.2`. **The only unbuilt piece of Phase 4 — and the only unbuilt thing in this entire doc — is the Copilot: 4.4 (plumbing) then 4.5 (the tailoring pass).** 4.4 now has a full implementation spec (below); 4.5 is still the shorter form it's always been, unblocked once 4.4 lands.

> **Status (2026-08-21, later the same day):** **4.4 (Copilot plumbing) shipped** — `LlmService`/`LlmProvider`/`AnthropicProvider`/`LlmProviderRegistry`, `SettingsService`'s first mutators plus per-provider API-key storage, and a `CopilotSettingsCard` on the Settings page (key entry, model choice, test-connection). See 4.4's own "Actually shipped" note for the implementation-time deviations (`LlmException`'s file location, the registry not being locator-registered, `LlmService`'s injectable `Dio`) and — importantly — that the live browser-CORS proof the doc calls "blocking, before any code" could not actually be run in this session (no API key, no way to drive an authenticated browser request) and is still outstanding before this is relied on in production or 4.5 begins. Verified via `flutter analyze` (0 issues), the full test suite (196 tests, including goldens), and a visual check of the regenerated `settings_view_default` golden. **4.5 (the tailoring pass) is next and is the only unbuilt sub-phase of Phase 4 remaining** — start there only after Step 0's live check has actually run.

> **Status (2026-08-21, evening):** Step 0 has since actually run — both providers pass browser-CORS from a real browser, with a negative control proving Anthropic's header is load-bearing. **4.4b (Gemini provider) shipped** on top of that: `GeminiProvider`, wired into `LlmProviderRegistry`, `SettingsViewModel` reworked so nothing hardcodes a single provider anymore, and a real provider dropdown in `CopilotSettingsCard`. Every wire-shape detail in the adapter (type casing, string `enum` support, response/usage shape, the error-body-based auth-failure mapping) was confirmed against real `generateContent` requests, not recalled — including a genuine surprise: the model this section's shortlist named (`gemini-2.5-flash-lite`) was already retired for new keys, caught only by actually calling it. See 4.4b's "Actually shipped" note for the full list, and its one open item: whether Gemini's `responseSchema` recognises `additionalProperties` at all, currently omitted rather than guessed. Verified via `flutter analyze` (0 issues) and 203 tests including goldens. **Phase 4's only remaining unbuilt piece is 4.5 (the tailoring pass)** — resolve the `additionalProperties` question first, since it decides how strong the anti-hallucination guarantee actually is for the provider being added.

> **Status (2026-08-21, night):** `additionalProperties` resolved — Gemini rejects it outright (`400 INVALID_ARGUMENT`), meaning it has no schema-level object-key-closure mechanism at all, not merely a weaker one than Anthropic's. **4.5 (the tailoring pass) has since shipped**, in two PRs: [#44](https://github.com/IanHeinrich/CVForge/pull/44) (data layer — payload builder, per-request response schema, response validation, `CopilotService`, `DraftService` apply/undo, all outside-in tested against a mocked `LlmService`) and [#45](https://github.com/IanHeinrich/CVForge/pull/45) (the Studio surface — persistent job-description card, the run dialog, the permanent hallucination warning, and an honest rewrite of the README's privacy claim). See 4.5's own "Actually shipped" note for what deviated from spec (two PRs instead of one, a real defensive-typing bug the test suite itself caught, `CopilotConfigCard` built fresh rather than reusing `StudioFieldOverrideCard`) and what's explicitly not built yet (a last-run timestamp, true request cancellation, a real end-to-end Anthropic generation call). Repo version is now `2.0.0`. **Every sub-phase of Phase 4 is now shipped — nothing spec'd in this document is unbuilt.** The two-pass Copilot idea recorded further down remains deliberately unscheduled; open questions 2–5 are the only genuinely open items left.

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

---

## Phase 4 — Portability, presets, templates, and the Copilot (planned 2026-08-20)

The four features Phase 1's Context named as "designed *for* but not built" — BYOK LLM Copilot, more templates, regional presets, JSON backup — specified properly for the first time. **Nothing in this section is built yet**; every sub-phase below is a spec, not a shipped note, and should grow an "Actually shipped" annotation the way P1.5/P1.6 did once it lands.

The Phase-1 "Phase 2 corners avoided" table claimed most of this was nearly free because the seams exist. That claim is *half* right, and the same way P2's sketch had to correct the "Multi-draft: free" row: the seams are real, but each one is a signature, not a feature.

| Feature | Seam that genuinely exists | What is actually missing |
|---|---|---|
| JSON export/import | Every aggregate is already a JSON string under a named key, with in-model `schemaVersion` and a migrate-or-quarantine read path. `StorageBoxes`' own doc comment says it was named for this. | A bundle envelope spanning *all* the keys, a file-picking dependency (there's a `FileDownloadService`, no counterpart for reading), replace-vs-merge semantics, and a UI surface to put it on. |
| Regional presets | `RegionProfile` enum + `CvComposer._formatDateRange`'s single-case `switch`; `PdfPageFormat` is a parameter on `CvTemplate.buildDocument` and `PdfExportService.render`. | Region isn't persisted anywhere, and `StudioViewModel.pageFormat` hardcodes `PdfPageFormat.a4`, so the format parameter is a seam nothing can currently push a different value through. |
| More templates | `CvTemplate` + `TemplateRegistryService` + `ResolvedSection` union + per-template `CvDesignTokens`. `DraftService.setTemplate` already exists. | `FontService` hardcodes Roboto's four TTFs and `CvTemplate` can't declare a family, so every template is a sans-serif Roboto template. And `setTemplate` has **zero production call sites** — today it is exactly the "no production API that only tests call" violation `CLAUDE.md` names; a picker is what redeems it, and a picker needs a second template to be worth showing. |
| BYOK Copilot | `bulletOverrides`/`tailoredSummary`/`headlineOverride`/`educationDetailsOverrides` + the composer's override-aware read path — the model can tailor a draft without ever touching the Vault. `StorageBoxes.settings` is opened but never read. | Everything else: an HTTP client, a key, a provider, a response contract, a place to put the job description, and an honest answer to the fact that this feature sends the user's career history off-device. |

### Decisions locked

| # | Decision | Rationale |
|---|---|---|
| 1 | **Sequence: settings surface → backup → region → Copilot → templates.** | Backup lands before anything that bulk-mutates a draft (the Copilot does), so there is an escape hatch before the risky feature exists rather than after. Templates go last because their *identity* is still undecided (see 4.6) and nothing else depends on them. |
| 2 | **A real `/settings` route, not a menu tucked into Drafts.** | Three separate features need a home for a persisted preference — export/import, the default region, and the API key. A fourth nav destination is cheaper than three ad-hoc affordances, and it gives `StorageBoxes.settings` its first reader. |
| 3 | **Import is replace-the-world, never merge.** | Merging two Vaults means reconciling ids that were generated on two machines with no shared clock — a whole conflict-resolution model for a feature whose actual use is "restore my backup" and "move to a new browser". Replace is one confirm dialog and no new failure modes. |
| 4 | **An import auto-exports the current state first, and offers it as a download before overwriting.** | Import is the one destructive operation in the app. The confirm dialog is easy to click through; a file already in your downloads folder is what actually saves you. Same "no silent data loss" rule that quarantines corrupt payloads instead of dropping them. |
| 5 | **Region is a field on `CvDraft`, not an app-wide setting.** | A draft is per-application, and applying to a US and a UK employer from one Vault is a real workflow. Same shape as `templateId`, which is already per-draft for the same reason. An app-wide *default for new drafts* lives in settings; the draft's own value is what renders. |
| 6 | **Region never rewrites the user's prose.** | It sets page format, date format, and label vocabulary. It does not normalise `organised` → `organized`. Silently exporting words the user didn't type — with the Vault still showing the originals — is the same class of defect as `unawaited()` on a persistence call: invisible until it has already happened. A reviewable spelling pass is a legitimate *later* feature; it is not part of a region preset. |
| 7 | **Every call is direct from the browser, no proxy, ever.** | A proxy would mean a backend, which is the one thing this product doesn't have. This is also a hard filter on which providers CVForge can ever support: one that refuses browser-origin requests is not addable here, no matter how good it is. |
| 7a | **One provider *implementation* (Anthropic) in Phase 4, behind a seam sized for the next one.** | Building two providers before either has a user is speculative; building the first one with its request shape, auth header, schema dialect, and error mapping welded into `LlmService` guarantees the second is a rewrite. The seam is a `LlmProvider` interface plus a registry — the same shape `TemplateRegistryService` already uses for templates — and it costs almost nothing to put in on day one. See 4.4. |
| 8 | **The key is session-only by default, with an opt-in "remember on this device".** | Persisted means plaintext IndexedDB, readable by any XSS on the origin — the Phase-1 sketch already committed to being honest about this rather than claiming secure storage. Opt-in makes the tradeoff the user's, and the warning ships either way. |
| 9 | **The Copilot's output is a strict JSON schema, and every id in it is an `enum` of ids that actually exist.** | Structured outputs (`output_config.format`) constrain the *shape*; enumerating the real ids constrains the *content*, making a hallucinated experience id structurally impossible rather than something we validate after the fact. Free-text rewrites are still free text — see decision 10. |
| 10 | **The Copilot applies its pass directly to the draft, and every change it makes is individually revertible plus undoable as a whole.** | The asked-for flow is "new draft → paste the job ad → it's done", not a twelve-item accept/reject queue. That's the right call *because* the review surface already exists: a Copilot rewrite lands in `bulletOverrides` exactly where a manual one does, so `TailorableField`'s existing per-field revert-to-Vault control and "N tailored" count are already the diff view. A single draft-level "Undo Copilot pass" covers the rest. **Flagged for revisit — see "Two-pass Copilot" below.** |
| 11 | **The hallucination warning is permanent UI, not a one-time dialog.** | The failure mode is a plausible, well-written bullet claiming something the user never did, applied automatically, on the document that gets sent to employers. A dismissed-once modal doesn't survive the moment it matters. |
| 12 | **The Copilot request never contains contact details.** Name, email, phone, location, and profile links are stripped from the payload; the model sees career *content* and ids only. | They contribute nothing to selecting or rewriting a bullet, and they're the most sensitive thing in the Vault. It also makes the pre-send disclosure short enough to be read and true enough to stand. |
| 13 | **Settings are absent from the backup bundle, and API keys live in their own storage rows — one per provider — rather than inside the settings model.** | Two independent structural guarantees that a secret can't reach a file, instead of one `forExport()` call that has to stay correct forever. Settings are device-scoped anyway. **Keyed per provider from the start**: a user with both an Anthropic and a Google key shouldn't have to retype one to use the other, and retrofitting `apiKey` → `apiKeyFor(providerId)` after a key is persisted means a storage migration for one function signature's worth of foresight. |
| 14 | **`schemaVersion` on `CvVault`/`CvDraft` stays at 1 for every additive field in this phase.** | Precedent: `bulletOverrides`, `headlineOverride`, `referencesOverride`, `educationDetailsOverrides` all landed as new optional/defaulted fields without a bump, and `requireSchemaVersion` treats an unrecognised version as corruption. The *bundle* envelope gets its own independent version (4.2) — that one does need to be strict, since it crosses machines and app versions. |

### Sub-phase sequence

| # | Name | Bump | Depends on |
|---|---|---|---|
| 4.1 | Settings surface + `SettingsService` | — | Phase 3 |
| 4.2 | JSON export / import (full backup + restore) | **1.2.0** | 4.1 |
| 4.3 | Regional presets (per-draft) | **1.3.0** | 4.1 |
| 4.4 | Copilot plumbing: `LlmService`, key entry, model choice | — | 4.1 |
| 4.5 | Copilot: the tailoring pass | **2.0.0** | 4.2, 4.4 |
| 4.6 | Second template + family-aware `FontService` + picker | **2.1.0** | 4.3 |

One PR each, same as every phase before it. 4.5 takes the major bump: it's the first time this app talks to a network at all, and the README's privacy stance changes with it.

### 4.1 — Settings surface + `SettingsService` ✅ shipped

```bash
stacked create service settings
stacked create view settings -c stacked_configs/settings.json
```

New feature slice `lib/features/settings/`, new `stacked_configs/settings.json` (copy of root `stacked.json` with the view/widget/test paths repointed, per the feature-folder recipe above). `AppChrome` gains a third `NavigationRail` destination — and this time it *is* a peer of Vault and CVs, unlike Studio (see P2.3.1); pin it to the rail's bottom via `trailing` rather than adding it to the main destination list, since it's a utility surface, not a workspace.

`SettingsService` mixes in `PersistedStoreMixin<AppSettings>` against `StorageBoxes.settings` — the same debounced-write, surfaced-`persistError`, idempotent-`ready()` shape `VaultService`/`DraftService` already use, so there's one persistence pattern in this codebase rather than two. `AppSettings` is a `@freezed` model: `schemaVersion`, `defaultRegion`, `copilotProviderId`, `copilotModelId`, `rememberApiKey`. Provider and model are **two fields, not one string** — a model id is only meaningful relative to its provider, and collapsing them means parsing a compound key later.

**API keys are deliberately NOT fields on `AppSettings`.** Each lives under its own storage row in the same box (`StorageKeys.apiKeyFor(providerId)` — one per provider, see decision 13), read and written directly rather than as part of the settings blob. Two reasons, both structural rather than stylistic: forgetting the key becomes a `storage.delete` of one row instead of a rewrite of a model that still has a `String?` slot for it, and no future code path that serialises `AppSettings` — logging it, exporting it, putting it in an error report — can carry the secret along by accident. See 4.2 and 4.4.

Ships with the region default (4.3's dependency) and the export/import buttons (4.2's) as its actual content — a settings page with nothing on it isn't a shippable PR on its own, so 4.1 is really "the surface plus whichever of 4.2/4.3 merges first". Sequence them in whichever order, but 4.1 doesn't merge alone.

**`SettingsViewModel` follows P1.7-G1's rule:** `implements Initialisable`, loads its own service in `initialise()` via a keyed `runBusyFuture`, and renders `StorageUnavailableCard` on failure. Deep-linking to `/settings` and refreshing there must work exactly like `/vault` does.

**This PR regenerates every golden, and that is not optional.** All three golden tests (`vault_view_empty`, `vault_view_populated`, `drafts_list_view_empty`) pump their View directly, and every View wraps itself in `AppChrome` — so a third nav rail destination changes all three baselines. Dispatch `update-goldens.yml` on the Linux runner and commit the PNGs *in this PR*, not after. This repo has already shipped an icon change twice without doing it (P2.3.1, then P2.3.2 compounding on top), and both times the note ended with "not done as part of this pass".

### 4.2 — JSON export / import → **bump 1.2.0** ✅ shipped

**The bundle.** One file, one envelope, everything in it:

```jsonc
{
  "app": "cv-forge",
  "bundleVersion": 1,        // independent of the per-model schemaVersions inside
  "exportedAt": "2026-08-20T14:31:00.000Z",
  "appVersion": "1.2.0",     // provenance only, never branched on
  "vault": { /* CvVault.toJson() */ },
  "drafts": [ /* CvDraft.toJson() each */ ],
  "activeDraftId": "…"
}
```

Filename `cvforge_backup_<yyyy-mm-dd>.json`, through the existing `FileDownloadService` (which already handles the `.pdf.pdf` class of filename bug — pass `extension: 'json'`, `MimeType.json`, no extension in the name).

**Settings are not in the bundle at all** — not stripped from it, absent from it. A backup is career data; settings are device-scoped (which model this machine uses, whether this machine remembers a key, this machine's default region), and restoring them onto a different browser is at best meaningless and at worst destructive. Leaving them out also means the API key can never reach a backup file *by construction* rather than by remembering to strip it — and a backup is exactly the artifact that ends up in cloud storage, an email attachment, or a support ticket. The alternative (export settings, null the key on the way out) was considered and rejected: it makes safety depend on one `forExport()` call being correct forever.

**Quarantined payloads are left where they are.** Import doesn't clear the `*_corrupt_<timestamp>` keys — preserving an unparseable payload rather than discarding it is the whole point of quarantining it, and "the user just restored a backup" is not evidence that the thing that failed to parse last month is now worthless. They're inert and unenumerated.

**Reading a file** needs a dependency this project doesn't have. Prefer **`file_selector`** (1.1.0, Nov 2025 — `flutter/packages`, i.e. flutter.dev-owned and federated, with `file_selector_web` as the official web implementation) over the more popular community **`file_picker`** (12.0.0, Aug 2026 — more actively released, single-maintainer). Same reasoning as Phase 1's `hive_ce` decision, inverted: there, the official-looking option was the abandoned one and release activity was the deciding evidence; here both are alive, so ownership breaks the tie on a platform-interop boundary. Check both again at implementation time rather than trusting these numbers — that's the P2.3.1 icon-package lesson (verify against the real package, not a README or a stale note). Wrapped in a `FileUploadService` mirroring `FileDownloadService`, so the ViewModel never sees the package and the test suite mocks one narrow interface.

**Import flow**, in order, with no step skippable:
1. Pick file → parse → validate envelope (`app`, `bundleVersion`, presence of `vault`).
2. **Reject a `bundleVersion` newer than this build understands**, with copy that says so plainly ("this backup was made by a newer version of CVForge") rather than a parse error. This is the one place strict version checking earns its keep — unlike the in-app `schemaVersion`, a bundle genuinely crosses app versions.
3. Validate every inner model by round-tripping it through `fromJson` **before writing anything**. A bundle that fails halfway must leave storage untouched; parse-all-then-write-all is what guarantees that.
4. Auto-export the current state and hand it to the user as a download (decision 4).
5. Confirm dialog naming exactly what's about to be replaced ("This will replace your Vault and all 4 CVs with the 6 CVs in this file").
6. Write vault, every draft, and the index; force `VaultService`/`DraftService` to reload rather than trusting in-memory state.

**Also worth exporting: a single draft.** A per-CV "Export as JSON" on the Drafts list, producing a bundle with `vault: null` and one draft, importable as "add this CV to my existing Vault" — the one *non*-destructive import, and the only merge-shaped operation in the phase (it appends a draft with a fresh id; it never reconciles Vault ids). Ships in this PR if it fits, otherwise a follow-up — it's genuinely optional, the full bundle is the feature.

**Tests:** round-trip the backup service through mocked storage — export a known state, import the bytes back, assert every draft, override map, and the active-draft pointer survive. Explicit cases for: a truncated/invalid JSON file, a future `bundleVersion`, and a bundle whose `vault` parses but whose third draft doesn't (must write nothing at all). No "the key isn't in the export" test is needed, because there is no code path that could put it there — which is the point of leaving settings out entirely.

> **Actually shipped (2026-08-20, [PR #27](https://github.com/IanHeinrich/cv-forge/pull/27)):** 4.1 and 4.2 landed together in one PR, per 4.1's own "doesn't merge alone" note — decision 1's locked order picked backup over region as the pairing. A few specifics the spec above left open:
> - `AppSettings` shipped with the full `defaultRegion`/`copilotProviderId`/`copilotModelId`/`rememberApiKey` field set as planned, but `SettingsService` itself grew **zero mutators** — not even for `defaultRegion` — since nothing in this PR has a real call site for one yet; only `load()` and the `settings` getter exist. Same "no production API that only tests call" reasoning the plan already applies to `setTemplate` elsewhere.
> - The bundle's `appVersion` field is a hardcoded `const` inside `BackupService`, not read from `pubspec.yaml` via `package_info_plus` — the field is provenance-only and never branched on, so a new dependency to keep one string in sync felt disproportionate. Real cost: it needs a manual bump alongside every `pubspec.yaml` version bump, or it drifts. Flagging in case that tradeoff should be revisited once a second consumer of "the app's own version string" shows up.
> - Import's step 6 ("force `VaultService`/`DraftService` to reload") became two new methods, `VaultService.replaceAll`/`DraftService.replaceAll`, rather than a literal storage-reload — they write through and update in-memory state directly (the write already happened; there's nothing a reload would learn that isn't already known). Both flush (`persistNow`) any write still sitting in the 300ms debounce timer *before* overwriting — a correctness detail the original spec didn't call out: without it, a normal edit made just before import can fire after import and silently clobber the restored data. `DraftService.replaceAll` also deletes the storage entry for every draft that fell out of the imported set, so replace-the-world (decision 3) holds at the storage layer, not just the in-memory index.
> - The confirm dialog reused `ConfirmDeleteDialog`/`DialogType.confirmDelete` as-is — no new dialog was built for step 5.
> - `AppChrome`'s `NavigationRail.selectedIndex` had to become nullable (`null` when Settings is the active section) since Settings sits in `trailing`, outside the indexed `destinations` list the spec didn't fully resolve this mechanism for.
> - **Not shipped:** the optional per-draft "Export as single CV" — still a legitimate follow-up, per the spec's own "otherwise a follow-up" allowance.
> - All 5 golden baselines (4 existing views + the new `settings_view_default`) regenerated via `update-goldens.yml` on `ubuntu-latest` and committed in the same PR, per the "not optional" instruction above.

### 4.3 — Regional presets → **bump 1.3.0**

`RegionProfile` grows from `{ uk }` to `{ uk, us }` — and stays an **enum**, not a freezed struct. The enum name is what gets persisted and JSON round-tripped; the values it maps to are a `const` lookup table (`RegionPreset`) that can change between app versions without invalidating a single stored draft.

```dart
// lib/models/render/region_profile.dart
enum RegionProfile { uk, us }

class RegionPreset {   // const table, keyed by RegionProfile
  final String displayName;      // "United Kingdom", "United States"
  final PdfPageFormatToken page; // a4 | letter — token, not PdfPageFormat: this file must not import `pdf`
}
```

**Two fields, and that's on purpose.** The obvious richer preset — `documentNoun` ("CV" vs "Resume"), `phoneLabel` ("Mobile" vs "Cell"), a `dateStyle` token — was written out and then cut, because **nothing in this app would read any of it**. The PDF's contact line is unlabelled by construction (`location | phone | email | links`, joined by pipes in `ats_minimal_pdf_renderer.dart`), so there is no phone label to regionalise. The app's own UI says "CV" everywhere as a deliberate P2.3.1 decision, not an unexamined default. And date formatting doesn't need a token at all: `CvComposer._formatDateRange` **already takes `RegionProfile` and already switches on it** — the switch *is* the seam, so a `dateStyle` field would be a second, redundant one. Adding all three would have been three fields no production code reads, which is the same `CLAUDE.md` rule (`setTemplate` is currently violating it) applied before the violation exists rather than after.

`page` is a token, not a `PdfPageFormat`: `lib/models/` must never import `pdf` (the same rule `cv_design_tokens.dart` states for itself), so the enum→`PdfPageFormat` mapping lives with the other pdf adapters and `StudioViewModel.pageFormat` resolves through it. **That hardcoded `PdfPageFormat.a4` getter is the actual code change** — the rest of the format plumbing is already parameterised end to end.

`CvDraft` gains `@Default(RegionProfile.uk) RegionProfile region` (no schema bump, decision 14). `DraftService.setRegion` mirrors `setTemplate` — and unlike `setTemplate`, it gets its call site in the same PR: a region selector in `StudioConfigPanel`, next to the template picker's eventual home. New drafts take `AppSettings.defaultRegion`.

`CvComposer.compose`'s `region:` parameter finally does something for a second value. Whether `_formatDateRange` actually diverges is a real question to answer with evidence, not an assumption: `Mon YYYY` is ATS-safe and widely used on both sides of the Atlantic, and inventing a US convention we can't defend is worse than shipping one date format. **The substantive difference is page size**, and that alone justifies the feature — someone applying to a US employer wants Letter. If the `us` case ends up formatting dates identically to `uk`, leave the branch out and let the shared path handle both. **`Present` stays capitalized and un-localised regardless** — it's the ATS-recognized keyword token, per its existing comment, not a piece of regional vocabulary.

**Considered and rejected: region-driven section defaults.** US resumes conventionally omit hobbies/interests, so a `us` preset could pre-hide that section on new drafts. Rejected for the same reason as spelling normalisation (decision 6): the user put those items in their Vault and selected them, and a preset quietly removing content from the exported document is a change they didn't make and won't see. A hint in the UI would be legitimate; a silent default isn't.

**Verification note:** the whole point is a different `PdfPageFormat`, so the manual check is exporting the same draft under both presets and confirming the Letter version is 8.5×11in with the margins still in the right place — the design tokens are in points and don't scale with the page, which is correct (margins shouldn't grow because the page did) but should be *looked at* once rather than assumed.

**Whichever of 4.3 / 4.5 / 4.6 lands first owns a `StudioConfigPanel` grouping pass.** Each of them adds a control to that panel — region selector, Copilot card, template picker — and the panel is already carrying section checkboxes, three override cards, and the whole selector list. Three more bolt-ons at the top of one `ListView` is how it becomes unnavigable. The grouping that falls out of what's there: **Document** (template, region), **Tailoring** (the Copilot card, the three override cards), **Content** (sections + item selection). One pass, in the first PR that touches it, not a fourth cleanup sub-phase afterwards.

### 4.4 — Copilot plumbing: `LlmService`, key, model ✅ shipped

**Step 0, blocking, before any code:** send one real `POST
https://api.anthropic.com/v1/messages` request from an actual browser tab
(`flutter run -d web-server`, or a bare `fetch()` in the browser devtools
console) with `anthropic-dangerous-direct-browser-access: true` and a real
key. This is the doc's own P1 risk ("verify it end-to-end from a real
browser tab as the first thing in this sub-phase") — if CORS rejects it,
this sub-phase and 4.5 both stop here, full stop, and the plan needs to go
back to the user rather than continuing on a false assumption. Nothing
below this line should be built before that request succeeds.

```bash
stacked create service llm
```

Registers into `app.locator.dart` and `test/helpers/test_helpers.dart`
automatically via the CLI's `// @stacked-*` markers — same mechanism every
other service in this project already uses, nothing to hand-wire.

No UI-visible feature of its own — it merges with 4.5, or ships behind the Settings page as "enter your key, test the connection". Split out here because the failure modes are entirely different from 4.5's, and debugging "why is my API key rejected" is a much smaller problem when it isn't tangled with "why did it select the wrong bullets". **This sub-phase's actual deliverable is that Settings page surface** — a working "enter your key, pick a model, test the connection" flow — not just the service in isolation.

**The provider seam, in one paragraph.** `LlmService` owns *policy* — the key, the retry stance, the timeout, error surfacing — and knows nothing about any vendor's wire format. A `LlmProvider` implementation owns *dialect*: building the request, sending it, and returning a parsed `Map<String, dynamic>` plus a `LlmUsage`. `LlmProviderRegistry` is a `const` list with a `byId` that falls back gracefully, copied wholesale from `TemplateRegistryService` — same problem, same shape, no reflection so unregistered providers tree-shake out. Anthropic is the only entry in Phase 4.

```dart
abstract interface class LlmProvider {
  String get id;                       // 'anthropic' — persisted, so never rename
  String get displayName;
  List<LlmModelOption> get models;     // id, label, input/output $ per MTok
  Uri get keySignupUrl;                // where a user goes to get a key

  Future<LlmJsonResponse> completeJson({
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userContent,
    required JsonSchema schema,        // provider-agnostic; the adapter emits its dialect
  });

  Future<void> validateKey(String apiKey);
}
```

**Four things vary between providers, and all four are inside that interface** — this is the whole reason the seam pays for itself rather than being ceremony:

| Varies | Anthropic | What a second provider does differently |
|---|---|---|
| Auth | `x-api-key` header | Google sends `x-goog-api-key`; OpenAI sends `Authorization: Bearer`. Not a base-URL swap. |
| Browser access | `anthropic-dangerous-direct-browser-access: true` | Every provider has its own answer, and **"no" is a valid one** — see decision 7. Each adapter proves this itself. |
| Structured output | `output_config.format` + JSON Schema | Google uses `responseMimeType: 'application/json'` + `responseSchema` (an OpenAPI subset); OpenAI uses `response_format: {type: 'json_schema', strict: true}`. Same *idea*, three dialects and three sets of restrictions. |
| Response shape + failure vocabulary | JSON in a text content block; `stop_reason: "refusal"` | Google returns `candidates[].content.parts[].text` with `finishReason`; OpenAI returns `choices[].message.content`. Each adapter maps into the shared `LlmFailure` cases rather than leaking its own. |

**The schema is authored provider-agnostically and translated per adapter**, not written in Anthropic's dialect and patched later. In practice that means staying inside the intersection: object/array/string/number/boolean, `required`, `additionalProperties: false`, and **string `enum`** — which every candidate supports, so 4.5's enum-of-real-ids anti-hallucination trick survives translation intact. Avoid anything past that intersection even where Anthropic allows it.

**Not in scope, deliberately:** streaming, tool use, multi-turn, and per-provider prompt tuning. The interface above has exactly one method because the Copilot makes exactly one kind of call. Widening it is the second provider's problem, informed by a real second provider — not a guess made now.

**Transport: raw HTTP via `dio`.** Flutter/Dart has no official SDK for any of these, so the Anthropic adapter is `POST https://api.anthropic.com/v1/messages` by hand. `dio` (new dependency — confirmed no HTTP client package exists in this project yet) over `package:http`: interceptors plus built-in timeout/cancellation-token support cover 4.5's cancel-a-long-running-pass need (Risk P6) without hand-rolling it. `LlmService` owns a single shared `Dio` instance and passes it into each stateless `const` provider call, the same way `TemplateRegistryService` hands a template no per-call state of its own. Headers:

| Header | Value |
|---|---|
| `x-api-key` | the user's key |
| `anthropic-version` | `2023-06-01` |
| `content-type` | `application/json` |
| `anthropic-dangerous-direct-browser-access` | `true` |

That last header is what makes the API answer a browser's CORS preflight — the same thing the TypeScript SDK sends behind `dangerouslyAllowBrowser`. **Verify it end-to-end from a real browser tab as the first thing in this sub-phase, before building anything on top of it**: if direct browser access doesn't work, the entire feature needs a backend and Phase 4 stops here. **This check is per provider, forever** — it's the first thing any future adapter has to earn, and the reason `LlmProvider` is a seam rather than a config table. This is the P1.6 `rootBundle`-under-`--base-href` lesson repeated — prove the platform assumption early, in the environment that actually runs it, not at the end.

**Validating a key costs nothing.** `LlmProvider.validateKey` exists precisely so each adapter can pick its own cheapest proof; Anthropic's calls **`GET /v1/models`**, not a hello-world message — it authenticates the key, proves CORS works, and returns the live model list, all without spending a token of the user's money. Burning real inference on a connection test is a bad look on a feature the user pays for directly.

**Model choice** is a Settings dropdown driven by `LlmProviderRegistry` — provider first, then that provider's `models`. With one provider registered, render the provider row only when there's more than one to choose from, so Phase 4's UI stays a single dropdown without the widget needing to change when a second arrives. Default **`claude-opus-5`**, with `claude-sonnet-5` and `claude-haiku-4-5` as cheaper options and per-model input/output rates shown, and display actual spend after each run from the response's `usage` block — a BYOK feature bills the user directly, so the cost has to be visible, not inferred. Rates are a `const` table in the app; label it with the date it was checked, since it will drift.

**Request defaults:** `thinking: {type: "adaptive"}`, `max_tokens: 16000`, non-streaming with a generous client timeout. Non-streaming because the response is a single JSON object that's useless until complete — there's nothing to progressively render. If real-world latency turns out to trip HTTP timeouts, switching to streaming and accumulating is the fix, and it changes only this service.

**Error classification follows `PdfExportService`'s precedent exactly** — a `LlmException(LlmFailure, cause)` with cases for `noKey`, `unauthorized` (401), `rateLimited` (429), `overloaded` (5xx), `network`/CORS, `timeout`, `refusal` (a 200 with `stop_reason: "refusal"`, which is not an error at the HTTP layer and will otherwise fall through as a malformed response), and `malformedResponse`. P1.7's G7 established that one generic message for every failure is a real defect; don't rebuild it here.

**Do not auto-retry a 429.** The SDKs retry rate limits by default and that's right for a server; here the user is watching a spinner and paying per attempt, so a rate limit is a thing to *report* ("your API account is rate limited, try again in a moment"), not to silently multiply. Same for 5xx: one clear failure beats three invisible ones.

**Key handling:** held in memory on `SettingsService`, keyed by provider id; written to `StorageKeys.apiKeyFor(providerId)` (its own row, not part of the `AppSettings` blob — see 4.1) only when `rememberApiKey` is on. Turning the toggle off deletes that row immediately, not on the next write. The key is masked in the UI after entry, and is never logged, never put in an exception message, and — by construction, since settings aren't exported at all — never in a backup bundle.

**Confirmed `SettingsService` currently has zero mutators** — its own doc
comment says so deliberately ("No mutators yet ... this PR's whole
surface"). This sub-phase is what finally gives it some, in the exact
mutator idiom `DraftService` already uses (`await ready(); _setDraft((d) =>
d.copyWith(...));` → here, `await ready(); _settings.value = _settings
.value.copyWith(...); scheduleWrite(_settings.value);`):

- `setCopilotProvider(String? providerId)`, `setCopilotModel(String?
  modelId)`, `setRememberApiKey(bool value)` — all three persist through
  `AppSettings` exactly as already shaped; all three fields
  (`copilotProviderId`, `copilotModelId`, `rememberApiKey`) already exist
  on the model from 4.1, this sub-phase is their first writer.
- API keys stay off `AppSettings` (decision 13, already correctly
  anticipated in 4.1). Add to `SettingsService`: an in-memory
  `Map<String, String> _sessionApiKeys` field (not reactive — a key never
  needs to trigger a rebuild by itself); `String? apiKeyFor(String
  providerId)` reading that map first, lazily populated from
  `StorageKeys.apiKeyFor(providerId)` on first access for a remembered key;
  `Future<void> setApiKey(String providerId, String key)` writing to the
  memory map unconditionally and to storage only when
  `settings.rememberApiKey` is true; `Future<void> clearApiKey(String
  providerId)` removing from memory and deleting the storage row
  immediately.
- Add `static String apiKeyFor(String providerId) => 'api_key_$providerId';`
  to `StorageKeys` (`lib/services/storage_keys.dart`), matching its
  existing `draftEntry(String draftId)` method-key convention exactly.
- Update `SettingsService`'s class doc comment once this lands — "no
  mutators yet" stops being true.

**File layout:**

- `lib/models/llm/` — pure Dart, no `flutter`/`pdf` imports, no
  persistence (the `lib/models/ats/` precedent: `@freezed`, no
  `fromJson`/`toJson`/`schemaVersion` since nothing here is written to
  storage). `llm_model_option.dart` (`id`, `label`,
  `inputPricePerMTok`/`outputPricePerMTok`), `llm_usage.dart`
  (`inputTokens`, `outputTokens` — feeds 4.5's per-run spend display),
  `llm_json_response.dart` (`Map<String, dynamic> data` + `LlmUsage
  usage` — what `completeJson` returns), `json_schema.dart` (a small
  freezed union — `.object(...)`, `.array(...)`, `.string(...)`,
  `.number()`, `.boolean()`, `.stringEnum(values)` — expressing exactly
  the intersection scoped above, no more; 4.4 defines the type and the
  Anthropic adapter's walker, 4.5 is what authors a real schema instance
  against it). `LlmFailure`/`LlmException` are **not** under
  `lib/models/` — they live in `lib/services/llm_service.dart` itself,
  mirroring exactly where `PdfExportException`/`PdfExportStage` sit
  relative to `PdfExportService`.
- `lib/services/llm/llm_provider.dart` — the interface above, unchanged.
  `lib/services/llm/anthropic_provider.dart` — `const`-constructible
  `AnthropicProvider implements LlmProvider`, stateless (the shared `Dio`
  is passed in per call, not held). `lib/services/llm/
  llm_provider_registry.dart` — `class LlmProviderRegistry` copying
  `TemplateRegistryService`'s exact shape (confirmed via
  `lib/services/template_registry_service.dart`): `static const
  List<LlmProvider> _providers = [AnthropicProvider()];`, `available`,
  `byId` (falls back to `_providers.first`, never throws),
  `defaultProvider`.
- `lib/features/settings/widgets/copilot_settings_card.dart` — new sibling
  to `backup_settings_card.dart`, reusing its exact card frame (confirmed:
  `SingleChildScrollView` → padded `Container` with `kcDarkGreyColor`,
  `context.appRadius.medium`, a `titleMedium` heading, `VGap`/`HGap`
  spacing) rather than inventing new chrome. Contents: a masked API-key
  `TextField`, a "remember on this device" toggle bound to
  `setRememberApiKey`, a model dropdown from `LlmProviderRegistry
  .defaultProvider.models` (provider selector itself hidden while
  `available.length == 1`, per the doc), and a "Test connection" button.
  Inline result text below it reuses `BackupSettingsCard`'s
  `importErrorMessage` pattern (`kcErrorColor`, `bodySmall`) rather than a
  dialog. `settings_view.dart`'s single-widget `content: () =>
  BackupSettingsCard(...)` becomes a `Column` of both cards.
  `SettingsViewModel` gains `isTestingConnection` state and
  `testCopilotConnection()`, mapping any `LlmException` to
  `LlmFailure`-specific copy — same "no single generic failure message"
  rule the doc already cites from P1.7-G7 for `PdfExportService`.

**Tests:** `LlmService` against a mocked `Dio` transport (a fake
`HttpClientAdapter`, or a mockito-generated mock — pick whichever fits this
repo's existing mockito-first convention at implementation time) — one test
per `LlmFailure` case (401 → `unauthorized`, 429 → `rateLimited`, 500 →
`overloaded`, a `DioExceptionType.connectionError` → `network`, a
`DioExceptionType.connectionTimeout`/`receiveTimeout` → `timeout`, a 200
with `stop_reason: "refusal"` → `refusal`, unparseable body →
`malformedResponse`), plus a happy path asserting the request body carries
the schema and the right model id. No test ever hits the real API.
`test/services/settings_service_test.dart` (extend if 4.1 already has one,
else create) additionally covers: `setApiKey` with `rememberApiKey: false`
doesn't touch storage; with it `true`, it does; `clearApiKey` deletes the
row immediately; `apiKeyFor` lazily reloads a remembered key from storage on
first access after a fresh service instance (simulating a page reload).
`test/services/llm_provider_registry_test.dart` mirrors
`template_registry_service_test.dart`: an unknown id falls back to
`defaultProvider` rather than throwing. No golden test is needed — no new
View, only a new widget inside the existing `settings_view` golden; if the
new card changes that View's rendered height, regenerate the baseline via
`update-goldens.yml` on the Linux runner per the doc's standing rule.

> **Actually shipped:** matches the spec above with a few implementation-
> time deviations, all forced by details the plan hadn't hit yet:
> - **`LlmFailure`/`LlmException` moved to `lib/services/llm/llm_exception.dart`**,
>   not `llm_service.dart` as originally planned to mirror
>   `PdfExportException`'s placement. `llm_service.dart` importing
>   `llm_provider_registry.dart` which imports `anthropic_provider.dart`
>   which would import back into `llm_service.dart` for this type is a real
>   import cycle, not a hypothetical one — `PdfExportService` never hit this
>   because it has no separate provider layer. `LlmException`'s own doc
>   comment records why.
> - **`LlmProviderRegistry` is not locator-registered** — a plain field on
>   `LlmService`/`SettingsViewModel`, not a `stacked create service`. It's
>   stateless and deterministic like `CvComposer`, and nothing needed it
>   mockable independently; `TemplateRegistryService`'s *shape* (const list,
>   `byId` with a never-throwing fallback) was still copied exactly.
> - **`LlmService`'s `Dio` is constructor-injectable** (`LlmService({Dio?
>   client})`, defaulting to a real `Dio()`), since it owns the client
>   directly rather than receiving one per call — the plumbing-level
>   equivalent of the doc's own "mocked `Dio` transport" test requirement.
>   `test/services/llm_service_test.dart` uses a ~40-line hand-rolled
>   `HttpClientAdapter` fake (`Dio`'s own extension point) rather than
>   pulling in a mocking package for one test file.
> - **Step 0 could not be run in the session that built 4.4** (no API key,
>   no way to drive an authenticated browser request) — **but it has since
>   been run for real, from a real browser, and passed.** See 4.4b's
>   "Actually verified" note for the result and how to reproduce it.
> - **`SettingsViewModel.selectCopilotModel` always writes both
>   `copilotProviderId` and `copilotModelId` together** (not left as two
>   independent setters), since Phase 4 has exactly one provider and there
>   was no UI moment where they'd legitimately be set separately yet.
> - `BackupSettingsCard` lost its own `SingleChildScrollView`/page-padding
>   wrapper (moved up to `SettingsView`, now wrapping both cards in one
>   `Column`) so two cards can share one scroll region — an unplanned but
>   necessary consequence of Settings going from one card to two.
> - `settings_view_default.png` regenerated locally on this Linux sandbox
>   (not via `update-goldens.yml`) — the same deviation and reasoning PR
>   #35 already recorded for `drafts_list_view_default.png`: the workflow's
>   artifact lands on Azure Blob Storage, which this session's egress
>   policy blocks. Sandbox OS is Linux, matching the `ubuntu-latest` CI
>   runner this doc requires baselines be generated on.

> **Code-review follow-up (2026-08-21), shipped as 4.4b below.** A review
> pass over the merged 4.4 code found defects worth recording, because two
> of them are lessons rather than typos:
> - **The hardcoded Opus 5 rate was wrong (`15/75`; actual `5/25`) and the
>   comment beside it claimed a check that never happened.** Root cause is
>   structural, not clerical: `plan.md` required per-model rates be *shown*
>   in Settings, that was never built, and an unrendered constant can be
>   wrong indefinitely because nothing displays it. Fixed by rendering the
>   rate under the model dropdown — which is the only reason to keep a
>   hardcoded price table at all. **Rule going in: never write a pricing or
>   model-id constant from memory, and never stamp a "checked" date on one
>   without having checked.**
> - **Any 4xx that wasn't 401/429 was classified `network`**, so a
>   malformed request rendered "check your connection". 4.5 sends a large
>   generated schema and is exactly where 400s will appear. Added
>   `LlmFailure.invalidRequest`; 403 now joins 401 as `unauthorized`.
> - **`LlmFailure.timeout` was unreachable** — `Dio` applies no timeouts by
>   default and none were configured, despite the spec calling for "a
>   generous client timeout" and `dio` having been chosen partly for them.
> - **`LlmService`'s empty-key guards threw synchronously** from
>   non-`async` methods, escaping any caller's `runBusyFuture`. Same bug
>   class already documented on `VaultViewModel._load`; it recurs because
>   the failing shape looks correct.
> - **A stored `copilotModelId` no longer in the model list would crash
>   `DropdownButton`** at build time. Now falls back to the first model.
> - Dead API surface removed (`showCopilotProviderSelector`,
>   `keySignupUrl` — the latter needs `url_launcher` to be worth having,
>   which isn't a dependency); `_ButtonSpinner` deduplicated into
>   `ui/widgets/common/button_spinner/`; `setApiKey` now awaits `ready()`
>   like its three sibling mutators.

### 4.4b — Gemini provider + 4.4 review fixes ✅ shipped

The review fixes above, plus the second provider. **Anthropic stays** — this
adds Gemini alongside it rather than replacing it, which is what the
`LlmProvider` seam was built for and what decision 13's per-provider key
storage already assumed.

Gemini is a genuinely good first exercise of the seam, because it differs
from Anthropic in all four ways the "four things vary" table predicts —
including one the current code would get wrong: **`JsonSchema`'s walker
emits `additionalProperties: false` on every object, which Anthropic
requires and Gemini's OpenAPI-subset `responseSchema` rejects.** That the
walker lives in the adapter rather than the shared model is what makes this
a per-adapter detail instead of a rewrite; it is the clearest evidence so
far that the seam earns its keep.

> **Actually verified (2026-08-21).** Step 0 has now genuinely run — real
> browser (`fetch`, not `curl`), real deliberately-invalid keys (a CORS
> proof needs no real one — a 401/400 *reaching JavaScript at all* is the
> passing result), origin `https://www.google.com` (arbitrary, not even
> this app's own — meaning neither API is origin-allowlisted, it's general
> CORS support):
> - `POST api.anthropic.com/v1/messages` **with**
>   `anthropic-dangerous-direct-browser-access: true` → CORS passed, HTTP
>   401 reached JS.
> - Same request **without** that header → CORS **blocked** (`Access to
>   fetch ... has been blocked by CORS policy`). This is the negative
>   control that matters: it proves the header is load-bearing, not
>   decorative — a probe that only ran the first case couldn't distinguish
>   "the header worked" from "Anthropic allows browsers regardless."
> - `POST generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`
>   with just `x-goog-api-key` (no special browser-access header exists or
>   is needed) → CORS passed, HTTP 400 reached JS.
>
> **Both providers clear Step 0.** Neither has had a real successful
> generation yet (both probes used invalid keys on purpose) — that's a
> smaller, non-blocking follow-up once real keys are in hand, not a gate
> on writing the adapter.
>
> **Gemini's real model catalog was also pulled** (`GET
> generativelanguage.googleapis.com/v1beta/models` with a real key,
> outside this session — `ai.google.dev`/`cloud.google.com` are blocked
> here, see below). It's large and includes plenty of preview/experimental
> entries (image, video, audio, embedding, robotics models) that aren't
> relevant here. The stable, non-preview text-generation models — the ones
> worth offering, mirroring `AnthropicProvider`'s three-tier flagship/mid/
> cheap shape — are **`gemini-2.5-pro`**, **`gemini-2.5-flash`**, and
> **`gemini-2.5-flash-lite`**. (The catalog also has `gemini-pro-latest`/
> `gemini-flash-latest`-style rolling aliases; pin to the dated ids above
> for the same reproducibility reason `AnthropicProvider` doesn't use a
> `-latest` alias either.)

> **Pricing supplied by hand (2026-08-21)** — read off Google's pricing
> page directly, since neither Anthropic's nor Google's Models API returns
> cost data (Anthropic's `GET /v1/models` response has `id`/`display_name`/
> `created_at`/`max_input_tokens`/`max_tokens`/`capabilities`, no price
> field; same absence on Gemini). That's structural, not an oversight —
> it's exactly why an unrendered hardcoded rate can go stale silently, per
> the Opus-pricing lesson, and why 4.4 renders the number rather than only
> storing it.
>
> | Model | Input $/MTok | Output $/MTok |
> |---|---|---|
> | `gemini-2.5-pro` | **1.25** | **10.00** |
> | `gemini-2.5-flash` | 0.30 | 2.50 |
> | `gemini-2.5-flash-lite` | 0.10 | 0.40 |
>
> **`gemini-2.5-pro`'s real pricing is two-tier** — 1.25/10.00 up to 200k
> context tokens, 2.50/15.00 above it — which `LlmModelOption` can't
> represent (one flat in/out rate per model, matching Anthropic's actual
> shape). Use the base tier above; a full Vault-plus-job-ad payload is
> nowhere near 200k tokens (plan.md's own 4.5 sizing note: "a full career
> Vault is a few thousand tokens"), so the tier boundary is not a live risk
> here, but the simplification is real and worth a one-line code comment
> pointing at this note if `LlmModelOption` is ever asked to handle a
> provider where it isn't safe to ignore. Batch API (50% off) and
> non-text-token rates (audio, context caching) don't apply to this
> integration and aren't modeled.

**Still to verify before writing the adapter — do not fill these in from
memory, per the Opus-pricing lesson above:**
- The exact `generationConfig.responseSchema` dialect: type-name casing
  (`STRING` vs `string`), whether `enum` on a string is supported (the
  anti-hallucination trick depends on it), and how required/optional
  properties are expressed.
- Response and usage shape (`candidates[].content.parts[].text`,
  `finishReason`, `usageMetadata`) and how a safety block surfaces — the
  Gemini equivalent of `stop_reason: "refusal"`.

With two providers registered, the Settings provider selector (currently
suppressed while `available.length == 1`) becomes live for the first time.

> **Actually shipped (2026-08-21).** `GeminiProvider` built against the
> real request/response captured above, plus two more empirical checks
> made during implementation rather than assumed:
> - **`gemini-2.5-flash-lite` — the id this section's model shortlist
>   named — turned out to already be retired for new API keys**, confirmed
>   by a real 404 redirecting to `gemini-3.5-flash-lite`. This is the
>   sharpest version yet of the lesson underlying all of 4.4b: a model list
>   pulled once from `ListModels` (or copied from a pricing page) is not
>   the same as a model that's actually been exercised against
>   `generateContent`. `GeminiProvider.models` now offers only
>   `gemini-3.5-flash-lite`, and only because it was the one id a real
>   request actually succeeded against. Its pricing is carried forward
>   from 2.5 Flash-Lite's confirmed rate as a provisional stand-in — the
>   3.5 generation's own rate hasn't been checked — flagged in the code
>   comment beside it, not silently assumed correct.
> - **Gemini's error envelope needed reading, not just its status code.**
>   An invalid key returns HTTP `400` with `error.status:
>   "INVALID_ARGUMENT"` and `error.details[].reason: "API_KEY_INVALID"` —
>   confirmed by a real request — not `401`/`403`. Status-code-only mapping
>   (Anthropic's approach, which works because Anthropic actually returns
>   `401`) would have silently misclassified every Gemini auth failure as
>   `invalidRequest`. `GeminiProvider._mapDioException` reads the response
>   body's `error.details[].reason` for this one confirmed case before
>   falling back to status-code mapping for everything else.
> - **`additionalProperties` on Gemini's `responseSchema` — resolved
>   (2026-08-21, later still): rejected outright.** A real request with
>   `"additionalProperties": false` on an object node returned HTTP 400,
>   `"status": "INVALID_ARGUMENT"`, `"message": "Invalid JSON payload
>   received. Unknown name \"additionalProperties\" at
>   'generation_config.response_schema': Cannot find field."` — not a
>   silent ignore, a hard rejection of the field as unrecognized.
>   `GeminiProvider._walkSchema` omitting the key entirely (its existing
>   behavior) is therefore correct and needed no code change.
>
>   **But this closes off the "accepted-and-enforced" outcome, which is
>   the one 4.5's schema design actually needs.** Gemini's schema language
>   has no mechanism at all for closing an object to a known key set —
>   not a weaker version of Anthropic's guarantee, an absent one. This
>   matters concretely for 4.5's corrected response shape below:
>   `experiences`/`projects` are objects keyed by real Vault ids precisely
>   so an out-of-range key is schema-impossible on Anthropic. On Gemini,
>   nothing stops the model from adding an extra key under `experiences`
>   that isn't one of the enumerated ids — the schema will accept it
>   silently. **4.5 must validate response object keys against the known
>   id set in application code before folding them into the draft, on
>   every provider, not just as defense-in-depth for Anthropic** — for
>   Gemini specifically it is the *only* enforcement that exists. This is
>   also the concrete case for why decision 9's "structural impossibility"
>   framing was always Anthropic-specific and needs restating as a
>   per-provider property, not a property of the schema seam itself.
> - The Settings UI now shows a real provider dropdown (`Anthropic` /
>   `Google Gemini`) above the model dropdown, `SettingsViewModel` no
>   longer hardcodes `defaultProvider` anywhere (every Copilot getter/
>   method now reads through `selectedCopilotProvider`, sourced from
>   `AppSettings.copilotProviderId`), and switching providers clears the
>   typed-but-unsubmitted key field and resets the stored model to the new
>   provider's first option — a model id from the old provider left
>   sitting in settings would otherwise point at nothing meaningful.
>
> **Update (2026-08-21, after 4.5 shipped): `gemini-3.5-flash` added,
> and a real usage-accounting bug fixed alongside it.** Added because a
> real-world comparison against Anthropic wasn't a fair one — Flash-*Lite*
> is the cheapest possible Gemini tier, not a peer of Anthropic's default
> models. Confirmed working the same way Flash-Lite was: a real
> `generateContent` request, real `finishReason: "STOP"`, real
> `modelVersion: "gemini-3.5-flash"`. That same real response exposed a
> genuine bug: `GeminiProvider.completeJson` was reading `outputTokens`
> from `candidatesTokenCount` alone, but a trivial "reply OK" prompt came
> back with `candidatesTokenCount: 1` and a *separate* `thoughtsTokenCount:
> 86`, additive into `totalTokenCount` (7 + 86 + 1 = 94) — a thinking-
> capable model bills its reasoning as output tokens, and the old code
> silently dropped 86 of every 87 real output tokens from the cost shown
> in Settings. Fixed by summing both fields. `gemini-3.5-flash-lite`'s own
> captured response never carried `thoughtsTokenCount` at all, so the
> `?? 0` fallback is a confirmed real case, not a guess covering an
> untested one. `gemini-3.5-flash`'s pricing is the same "carried forward
> from the 2.5 tier, not yet re-checked for 3.5" caveat as Flash-Lite's.

**Verification:** `stacked generate && dart format . && flutter analyze &&
flutter test --exclude-tags=golden`; Step 0 no longer blocks (done above)
but a real-key manual pass is still worth doing once the adapter exists:
enter a real key on the deployed/dev-server Settings page for each
provider, click "Test connection", confirm success; enter a deliberately
invalid key, confirm the right per-`LlmFailure` copy renders; toggle
"remember on this device" on, reload the page, confirm the key survives
without re-entry; toggle it off, reload, confirm it's gone.

### 4.5 — Copilot: the tailoring pass → **bump 2.0.0** ✅ shipped

The feature: on a draft, press **Tailor with AI**, paste the job description, and get back a draft with the relevant experiences, bullets, and skills selected and the prose rewritten for that role.

**The job description becomes a first-class draft field.** `CvDraft` gains `String? targetJobDescription` — distinct from `notes` (which is the user's own application tracking and is never rendered or sent). Making it a persisted field, not a modal's transient text, is what lets the pass be re-run, refined, and re-run again against the same ad, and it's the input a future keyword-gap or cover-letter feature reads too.

**What actually gets sent, and what deliberately doesn't.** The pass needs the job description plus the Vault's *content*: headline, summary, experiences (role, company, dates, bullets), projects, skills, education, hobbies — each carrying the id the response has to refer back to. It does **not** need `ContactBasics`' identifying fields: full name, email, phone, location, and profile links are stripped before the request is built. They contribute nothing to selecting or rewriting a bullet, they're the most sensitive thing in the Vault, and leaving them out makes the pre-send confirm's claim smaller and completely true. Strip them at the point the payload is built, not by hoping every call site remembers — one `CopilotVaultPayload.from(vault)` with no PII fields on it at all.

**Size is a non-issue; don't build for it.** The current models carry a 1M-token context window and a full career Vault is a few thousand tokens. No chunking, no summarisation, no "send only the selected items" optimisation — send the whole Vault content in one request and keep the code that does it boring.

**The request.** System prompt states the rules: select from what exists, never invent an employer, a date, a qualification, or a metric; rewrite only for emphasis and phrasing; preserve every factual claim in the source bullet. **Write the prompt for the state the draft is actually in:** P1.6's `isFreshDraft` auto-selects everything from the Vault on a new draft, so the realistic flow ("create a CV, press Tailor") hands the model a draft with *everything* already included. Its selection job is therefore mostly **de**selection — cutting what the ad doesn't call for — not building a set up from empty. A prompt written for the empty case will systematically under-select.

**System prompt, drafted 2026-08-21 (aggressive on selection, timid on rewriting — the two jobs get opposite defaults because they carry opposite risk, per Risk P2):**

```
You are a CV tailoring assistant. You will be given a candidate's full
career history (the "Vault") and a target job description. Your job is to
select which parts of the Vault belong on a CV for this specific role, and
lightly rewrite the selected bullets for emphasis — never to invent.

## Selection: be aggressive

The Vault you're given typically already has everything switched on. Your
main job is cutting, not adding. For each experience, project, skill,
education entry, hobby, and publication, decide whether it belongs on a CV
for THIS job:
- Keep what's directly relevant, or provides evidence of a claim the job
  description cares about (a skill, a level of seniority, a domain).
- Cut what isn't relevant, even if it's impressive — an unrelated hobby, a
  skill the role doesn't touch, an experience with nothing worth surfacing
  for this ad. A shorter, targeted CV beats a complete one.
- Within a kept experience, select only the bullets that support this
  application. Do not keep a bullet just because it exists.
- If, after selecting, a section would be empty or provide no signal, add
  its CvSectionType name to hiddenSections.

Being too inclusive is the default failure mode. When in doubt, cut.

## Calibrate to how much you were given

The instruction above assumes a well-stocked Vault, where cutting still
leaves a substantial CV behind. That assumption breaks for a candidate
with limited documented experience — if you cut with the same aggression
regardless of how much you started with, a thin Vault comes out the other
side looking sparse or empty, which is a worse outcome than including
something only tangentially relevant.

Before cutting a bullet, project, or whole experience, look at what the
CV would contain overall if you did. If the total is already small, keep
tangentially-relevant-but-real items rather than pruning to only the
handful that map perfectly onto the job description — a real person
writing this CV by hand, with limited material to draw from, would
include them too. Reserve aggressive cutting for cases where the Vault
actually has enough directly-relevant content that trimming the rest
doesn't leave the CV thin. This does not relax the rule against
inventing anything — it only changes when a genuinely tangential-but-true
item should stay in rather than be cut.

## Rewriting: be conservative

You may rewrite the TEXT of a selected bullet, and nothing else about it.
A rewrite may:
- Reorder or rephrase for emphasis (lead with the outcome, not the task).
- Tighten wording, cut filler, match the job description's terminology
  where the underlying fact is the same thing under a different name.

A rewrite must NEVER:
- Add an employer, title, date, qualification, credential, tool, or
  technology that is not already present in that bullet or its parent
  experience.
- Add or change a number, metric, percentage, or scale that is not
  already stated.
- State a responsibility, outcome, or scope larger than what the source
  bullet actually claims.
- Imply seniority, team size, or ownership beyond the original.

Every claim in a rewritten bullet must be verifiable by re-reading the
original bullet and finding the same fact stated in it. If you are not
certain a rewrite is strictly a rephrasing, leave the bullet unrewritten
and select it as-is instead. An honest, plain bullet is always the safe
default; a fabricated one is not.

## Output

Respond only via the provided JSON schema. Every experience/project/
skill/education/hobby/publication id you reference must be one of the ids
given to you — the schema enforces this, but treat it as a hard rule
regardless of what the schema happens to allow for the provider you're
running on.

In `rationale`, briefly explain your selection choices — what you
prioritized and what you cut, and why. In `keywordGaps`, list requirements
or qualifications the job description asks for that nothing in the Vault
actually covers. This is not a place to paper over a gap with a
rewrite — if the Vault doesn't support a requirement, say so here instead
of stretching a bullet to imply it.
```

This is the first draft of the actual prompt text — 4.5's implementation should treat it as a starting point to iterate against real model output, not a frozen spec. The two structural rules it encodes (aggressive deselection, conservative rewriting with "leave it unrewritten if unsure") are the ones that matter and shouldn't drift even if the wording around them changes.

> **Revised (2026-08-21, after real usage feedback):** added the "Calibrate to how much you were given" section above. Real runs against a thin Vault (a candidate without "loads of points") showed the original "when in doubt, cut" instruction being followed too literally — it stripped tangentially relevant content that a person writing their own CV by hand would keep, leaving the result sparse rather than merely focused. The fix is prompt-level, not a code-enforced floor: the model already sees the whole Vault and can judge "is this thin" for itself; a hardcoded numeric minimum (N bullets, X% of the Vault kept) would just trade one blunt heuristic for another, and it's not obvious what number would actually be right. If prompt calibration alone proves insufficient after more real usage, a code-side floor is the fallback, not the first move.

**The response is a strict JSON schema** via `output_config: {format: {type: "json_schema", schema: …}}` (no beta header). Two constraints the schema must respect, both learned from the docs rather than discovered at runtime:

- **`additionalProperties` may only be `false`**, so a map keyed by *arbitrary* bullet ids is not expressible. **But keys known at schema-build time are** — and every id is, because the schema is generated per request from this Vault. So an id-keyed object *is* available and is the better shape; see the corrected response shape below.
- **`enum` on a string is supported**, so every id field is an enum of the ids actually present in this Vault. A hallucinated experience id becomes structurally impossible rather than something to validate away afterwards. String enums are also common to every provider dialect (4.4), so this stays true when a second one is added — the trick is portable, which is partly why it's worth building the whole response around.

Shape — **corrected 2026-08-21; the earlier array-of-objects version had a bug**, see the note below it:

```jsonc
{
  "headline": "string | null",
  "summary": "string | null",
  // One fixed property per experience id. Legal despite
  // additionalProperties:false because we generate this schema from this
  // Vault, so every key is known when the schema is built.
  "experiences": {
    "<vault experience id>": {
      "bulletIds": ["<enum of THIS experience's bullet ids>"],
      "rewrites":  [{ "id": "<enum of THIS experience's bullet ids>",
                      "text": "string" }]
    }
  },
  "projects":    { /* same shape, keyed by project id */ },
  "skillIds":    ["<enum>"],
  "educationIds":["<enum>"],
  "hobbyIds":    ["<enum>"],
  "publicationIds": ["<enum>"],
  "hiddenSections": ["<enum of CvSectionType names>"],
  "rationale": "string",
  "keywordGaps": ["string"]
}
```

> **Why this changed.** The original shape asked for `bulletIds` to be "an enum of *that* experience's bullet ids" inside an array of `{id, bulletIds}` objects. **JSON Schema cannot express that** — an array item's `items.enum` can't be conditioned on a sibling `id` field. Implemented literally it degrades to one global enum of every bullet id in the Vault, which lets the model attach experience B's bullet to experience A: exactly the class of error the enum trick exists to make structurally impossible. Keying the object by experience id restores the per-experience constraint, because each property gets its own independently-scoped enum. Cost: a slightly larger schema, and `required` should list nothing (an omitted experience simply isn't selected) while `additionalProperties` stays `false`. Note the shape also gained `publicationIds`, which the original predates (Publications became a first-class section in PR #35).
>
> **Provider caveat, confirmed in 4.4b: `additionalProperties: false` is Anthropic-only.** Gemini's schema dialect rejects the field outright (`400 INVALID_ARGUMENT`), so this shape's "closed to known ids" guarantee holds on Anthropic by construction and does not hold on Gemini at all — nothing stops a Gemini response from adding a key under `experiences`/`projects` that isn't a real id. The implementation must validate every returned object key against the known id set in application code before folding it into the draft, unconditionally (not just as Anthropic defense-in-depth) — for Gemini it's the only enforcement that exists. See `GeminiProvider._walkSchema`'s doc comment.

`keywordGaps` — requirements in the ad that nothing in the Vault covers — is the honest counterweight to the rest of the response: it's the model reporting what it *couldn't* find, and it's the thing that tells the user to go add something real to their Vault rather than trusting a rewrite to have covered it.

**Where the UI lives.** Two pieces, because the interaction and the state have different lifetimes:
- A **persistent card in `StudioConfigPanel`** — the job description (collapsed to a preview once set, reusing `StudioFieldOverrideCard`'s established pencil-to-edit pattern rather than inventing a third editing affordance), the "Tailor with AI" action, when the last pass ran, and the "Undo AI changes" action while an undo snapshot exists.
- A **dialog** for the run itself (`stacked create dialog copilot_run -c stacked_configs/studio.json`, following `EditDraftDialog`'s precedent): paste-or-confirm the job description, see exactly what will be sent and to whom, run, watch progress, read the rationale and `keywordGaps` on completion.

**Applying the result:** one `DraftService.applyCopilotResult(...)` that writes the whole pass as a single draft update and a single persisted write — not N calls through the existing per-item setters. P2.1's "Select all only selected one bullet" bug is exactly what a loop of read-modify-write setters produces here, at ten times the scale.

**The wait is the UX risk nobody plans for.** A full pass on `claude-opus-5` with adaptive thinking is a single opaque request that can run well past what a spinner covers comfortably, and there is no partial output worth rendering (the response is one JSON object, useless until complete). Three knobs, in order of preference: tune `output_config.effort` down from its `high` default if quality holds at `medium`; show elapsed time and a cancel control rather than an indeterminate spinner; and if it still feels dead, switch the request to streaming purely to surface `thinking: {display: "summarized"}` blocks as progress narration — a change confined to `LlmService`. Decide this against a real measured request in 4.4, not in advance.

**Undo, at two levels:**
- *Per field* — free, and already built. A Copilot rewrite lands in `bulletOverrides`/`tailoredSummary`/`headlineOverride`, the same place a manual override lands, so `TailorableField`'s existing revert-to-Vault control and "N tailored" counts already work on it unmodified. This is the diff review; there is no second review UI.
- *Whole pass* — the pre-pass `CvDraft` JSON is written to `copilot_undo_<draftId>` in the drafts box before the new one is saved (a distinct prefix, not `draft_`, so nothing enumerating drafts ever sees it), and an "Undo AI changes" action restores it. Superseded by the next pass; cleared when the draft is deleted.

**The hallucination warning is permanent UI** (decision 11): a persistent line in the Copilot panel while a pass is applied — *"AI-written. Check every rewritten bullet against what you actually did."* — not a modal that gets dismissed once and never seen again on the run that actually invents something. The pre-send confirm separately names what leaves the browser, accurately: the job description plus the Vault's career content — **not** name, email, phone, location, or links, which are stripped (decision 12) — sent to Anthropic, on the user's own key, from this browser with no CVForge server in the path.

**Privacy stance, updated honestly.** README currently says nothing leaves your browser, flatly. That stops being true the moment this ships and has to be rewritten, not quietly qualified: nothing leaves the browser *unless you turn on the Copilot and supply your own key*, and when you do, your CV content goes from your browser directly to Anthropic — never through a CVForge server, because there isn't one. The Copilot is **off until a key is entered**; a user who never opens Settings has the same zero-network app they have today. Same treatment for the in-app copy and the settings page.

**Tests:** `StudioViewModel`/copilot ViewModel against a mocked `LlmService` — a fixture response applies to the expected selections and overrides; a response containing an id not in the Vault is dropped rather than crashing (belt-and-braces behind the enum constraint, matching the codebase-wide "dangling ids are normal" rule); each `LlmFailure` surfaces its own message; undo restores the pre-pass draft exactly. **A golden test is not the right tool here** and shouldn't be added — the output is model-dependent by definition.

> **Actually shipped ([PR #44](https://github.com/IanHeinrich/CVForge/pull/44) data layer, [PR #45](https://github.com/IanHeinrich/CVForge/pull/45) UI):** landed in two PRs rather than one — the data layer
> (`CopilotVaultPayload`, `buildCopilotResponseSchema`, `CopilotResult
> .fromLlmResponse`, `CopilotService`, `DraftService.applyCopilotResult`/
> `undoCopilotPass`) first, fully outside-in tested against a mocked
> `LlmService` with no UI to exercise yet, then the Studio surface on top.
> Splitting it this way (rather than the doc's original single-PR framing)
> cost nothing and kept each PR's diff reviewable.
>
> One real defensive-typing gap was caught by the test suite itself before
> either PR shipped: `CopilotResult.fromLlmResponse`'s id-validation loops
> used `raw as List?` casts that threw a `CastError` on a wrong-typed
> field (a string where a list was expected) instead of treating it as
> absent — the "never crash" guarantee this factory's own doc comment
> promises didn't actually hold for that case. Fixed by routing every list
> read through one `_asList` helper that checks `is List` rather than
> casting blindly.
>
> The persistent Studio card does **not** reuse `StudioFieldOverrideCard`
> as originally suggested — that card's `TailorIconButtons` hardcodes
> "From your Vault"/"Revert to Vault" copy, which is simply false for the
> job description field (it has no Vault source at all, it's draft-only
> free text). `CopilotConfigCard` is built from the same lower-level
> pieces (`TailorableField`, `InlineTextOverrideEditor`) instead, with a
> plain pencil/clear pair. `AppDialogScaffold`'s `onConfirm`/`onCancel`
> were widened from `VoidCallback` to `VoidCallback?` to let the
> multi-phase run dialog disable a button while a request is in flight,
> rather than inventing a second dialog chrome for that one case.
>
> The run dialog applies the result **inside its own confirm step** —
> there is no separate "review, then apply" phase. This matches the
> doc's own "there is no second review UI" line for undo, just extended to
> the whole pass: `TailorableField`'s existing per-field revert controls
> are the review surface, and the whole-pass undo snapshot is the
> insurance policy, so a second staging step before applying would be a
> third mechanism doing a job the other two already cover.
>
> **Not built in this pass, and worth being explicit about the gap:** the
> persistent card doesn't show *when* the last pass ran (only *whether*
> one is currently applied, via the undo button's presence) — the doc's
> spec mentioned a timestamp, but adding one meant a new `CvDraft` field
> beyond `targetJobDescription`, and `hasCopilotUndo` already answers the
> question that actually matters ("is there something to review/undo").
> True request cancellation (Risk P6's "cancel control") also isn't
> built — the run dialog blocks both buttons while a request is in
> flight rather than offering to abort it, since Dio cancellation tokens
> plus a ViewModel that might be disposed mid-flight was judged more
> complexity than a first cut needed. Anthropic's actual generation
> (not just CORS/`validateKey`) still hasn't been exercised with a real
> key in this session — both provider adapters are unit-tested against
> mocked transports only; a real end-to-end run is the natural next
> manual verification step once a key is available.

### 4.6 — Second template + family-aware `FontService` + picker → **bump 2.1.0** ✅ shipped

**Which templates ship is deliberately still open** — see the open questions below. What's *not* open is the structural work, which is the same regardless of what gets built:

- **`CvTemplate` declares its font family**; `FontService` caches a `CvFontSet` **per family** instead of one hardcoded Roboto set (`Map<String, Future<CvFontSet>>`, keyed by family, each entry keeping the `catchError`-reset that P1.7-G2's pattern requires — the bug fixed in PR #25 must not be reintroduced once there are N cached futures instead of one). Any new family means four more TTFs plus its licence file in `assets/fonts/`, and a glyph-coverage check against the Unicode regression set (smart quotes, en/em dash, ellipsis, €, £, •) *before* adopting it — P1.6 already learned that Roboto's coverage doesn't transfer by assumption.
- **A template picker in `StudioConfigPanel`**, wired to the long-orphaned `DraftService.setTemplate`. Live preview re-renders on change for free, since the preview *is* the exported PDF.
- **Picker presentation:** a labelled list using each template's existing `displayName`/`description` first. Thumbnails are the obvious want, but static PNGs drift from the renderers silently — if thumbnails happen, render them from the real template at small scale via the existing raster path, so they cannot lie.
- **A per-template byte-marker test** matching `pdf_export_service_test.dart`'s: `%PDF-`, `/Identity-H`, `/ToUnicode`, plus the Unicode regression case. Those markers *are* the ATS-extractability guarantee, and they're per-template, not per-app.
- **Single-column only.** A two-column/sidebar layout is the most requested-looking CV format and the one this product exists to argue against — multi-column is the classic ATS parse failure. If one is ever built, it needs its own decision and its own honest warning in the picker, not a quiet addition to the list.

> **Actually shipped ([PR #35](https://github.com/IanHeinrich/cv-forge/pull/35)):**
> landed ahead of 4.4/4.5 rather than after them — deviates from decision 1's
> locked order (`settings → backup → region → Copilot → templates`), but
> nothing about the picker or the second template actually depended on the
> Copilot shipping first, so sequencing it earlier cost nothing.
>
> Open question 1 resolved in favor of the traditional-serif-styled
> candidate, cloned from a reference CV: centered rule-less section
> headings, a justified summary paragraph, and a bold/italic two-row entry
> header (`compact` uses one combined row). It ships as `classic_centered`
> (`displayName` "Classic Centered") — `ats_minimal` was also renamed, to
> `compact` ("Compact") — both renamed by *visual style* rather than
> font/ATS-claim, since every template in this product is ATS-friendly by
> design and naming only one that implied the others weren't. **Both
> templates render in Roboto** — `classic_centered` is not the Liberation
> Serif font evaluated back in P1.0 (still unused: TTFs, licence file, and
> glyph-coverage research all sitting idle). That means **the family-aware
> `FontService` structural work above was not built** — `CvTemplate` has no
> `fontFamily` getter, and `FontService` is still the single hardcoded
> Roboto-only cache it was in P1.6. This is real, not deferred-and-noted
> debt: the first template that actually needs a different family (Liberation
> Serif or otherwise) will need to build the per-family `Map<String,
> Future<CvFontSet>>` caching this section originally specced, including the
> `catchError`-reset-per-entry requirement (Risk P7).
>
> What did ship as specced: the template picker in `StudioConfigPanel`,
> finally giving `DraftService.setTemplate` its first production call site;
> a per-template byte-marker test (`test/services/pdf_export_service_test.dart`,
> `%PDF-`/`/Identity-H`/`/ToUnicode` asserted for both `compact` and
> `classic_centered` independently); and single-column-only, no sidebar
> layout.
>
> Beyond the original spec: a first-class **Publications** `CvSectionType`
> (`Publication` model — `id`, `title`, optional `citation`/`link` kept as
> separate fields so a long DOI never gets spliced into prose — Vault
> CRUD/editor panel, draft selection, and a `ResolvedPublicationsSection`
> case in both templates). This forced **`CvTemplate.sectionOrder`**, a new
> per-template `List<CvSectionType>` — `classic_centered`'s reference CV
> puts Skills near the bottom rather than near the top like `compact` does,
> so print order is no longer one global `CvSectionType.values` order,
> though `CvComposer` still does all the joining. Both are real additions to
> the `CvTemplate` interface and the Vault model list documented earlier in
> this doc (§"Domain models", §"`CvTemplate` Strategy interface") that
> those sections don't mention. The bullet-glyph ink-center scaling math
> (P1.6's `_bulletGlyphAlignmentY`) was also factored out of `compact` into
> a shared `templates/design` helper so `classic_centered` didn't re-derive
> it.
>
> One process deviation: the `drafts_list` golden (invalidated by the
> template rename) was regenerated locally on Linux rather than via
> `update-goldens.yml`, because that workflow's artifact lands on Azure Blob
> Storage and the session's egress policy blocked it — noted since the doc
> otherwise treats the Linux-CI-runner route as non-optional (P1.3, 4.1).

### Two-pass Copilot — a revisit of decision 10 (proposed 2026-08-21, not scheduled)

**Not for 4.5's first cut; recorded so the option isn't lost.** Split the
Copilot into two passes with different risk profiles rather than one pass
that does both jobs:

1. **Pass 1 — selection.** Choose experiences, bullets, skills, sections;
   produce the core CV. Applies directly, exactly as decision 10 describes.
2. **Pass 2 — wording.** Propose rewrites *for the user to review and
   accept*, one at a time, rather than applying them and relying on the
   user to notice and revert.

**Why it's attractive.** The two jobs have opposite risk profiles, and
decision 10 currently treats them identically. Selection is
enum-constrained, so it *cannot* fabricate — the worst case is a poorly
curated CV, which is obvious on sight and trivially reversible. Rewriting
is where a plausible, well-written, invented claim reaches an employer
(Risk P2), and it is exactly the case where auto-apply is weakest: a
fabricated bullet reads *better* than the honest one, so "revert if you
disagree" asks the user to catch the failure mode hardest to catch.
Accept-per-rewrite inverts the default from opt-out to opt-in for the only
step that can state something untrue.

**What decision 10 got right, and would still hold.** Its objection to a
"twelve-item accept/reject queue" was about the *selection* pass, where a
queue would be pure friction over a safe, reversible operation — and that
reasoning survives intact under this split. Its second argument (the
review surface already exists via `TailorableField`) is weaker than it
looks for rewrites specifically: a per-field revert control shows *that* a
field was tailored, not what the original said next to it, so it isn't
really a diff view.

**Costs to weigh before committing.** A second pass is a second billed
request on the user's own key (and 4.5's Risk P6 — the wait — doubles);
the accept/reject UI is genuinely new surface rather than reuse; and the
"paste the ad and it's done" flow the plan's Context sells becomes two
steps. A cheaper middle option worth pricing first: keep one request, but
land rewrites in a *pending* state that the Studio surfaces as
accept/dismiss per bullet, instead of writing them straight into
`bulletOverrides`. That gets the opt-in default without a second API call.

### Open questions, carried into implementation

1. ~~**Which templates** (4.6). Deferred deliberately. The two candidates on the table are a traditional serif single-column (Liberation Serif — evaluated in P1.0, licence and glyph coverage already researched, TTFs not currently in `assets/fonts/`) and a density variant of `ats_minimal` tuned to fit a long history on one page (Roboto, so no font work). They're not mutually exclusive and they cost very different amounts; pick at the start of 4.6.~~ **Resolved in PR #35** — a traditionally-styled candidate shipped as `classic_centered`, but rendered in Roboto rather than Liberation Serif (see 4.6's "Actually shipped" note) — the serif/font-family question is still genuinely open for whichever template needs a different family next.
2. **Does the Copilot get a "refine" turn?** The spec above is one-shot: paste, apply, undo, re-run. A follow-up instruction ("keep it to one page", "emphasise the leadership work") is a conversation, which means keeping message history — a materially bigger feature. Re-running the whole pass with an amended job description gets most of the value for none of that cost, so start there and see whether it's actually insufficient.
3. **Which provider goes second, and when.** Google (Gemini) and OpenAI are the obvious candidates; both are structured-output-capable and both need their browser-origin story checked before anything else. Nothing about the Phase 4 seam presumes either. The honest trigger for building one is a user who has that key and not an Anthropic one — not a desire for the list to look longer.
4. **Per-CV JSON export** (4.2) — ships with the bundle if it fits, otherwise separately.
5. **Where the deployed build's Copilot key entry warns about shared machines.** The threat model differs between a personal laptop and a library computer, and the app can't tell which it's on.

### Risks (Phase 4)

| | Risk | Mitigation |
|---|---|---|
| P1 | **Direct browser access to the API doesn't work as expected**, and the Copilot needs a backend this product refuses to have. | Prove it with a real request from a real browser tab as step one of 4.4, before any UI exists. Everything else in the phase is independent of it. The check is permanent and per provider — a provider that won't answer a browser origin can't be added here at all, whatever else it offers. |
| P2 | **A confident hallucination reaches a real employer.** | The model can't invent ids (enum-constrained schema); it can invent prose. Permanent warning copy, per-field revert already built, whole-pass undo, and `keywordGaps` explicitly surfacing what the Vault doesn't cover instead of papering over it. |
| P3 | **Import destroys real data.** | Parse-everything-before-writing-anything, an auto-exported backup handed over first, and a confirm dialog that names the actual counts. |
| P4 | **The API key leaks** — into a log line, an exception message, or a shared browser profile. | It can't reach a backup file at all: settings aren't exported, and the key isn't part of the settings model in the first place (decision 13). Beyond that: never logged, never attached to an exception, session-only unless explicitly persisted, and the stored row deleted the moment the toggle goes off. |
| P5 | **The privacy claim quietly becomes false.** | README, settings copy, and the pre-send confirm all get rewritten in the same PR that ships the network call — treated as part of the feature, not documentation to catch up on later. |
| P6 | **The Copilot's wait is long, opaque, and cancel-less**, and reads as a hang on the app's flagship feature. | Measure a real pass in 4.4 before designing the UI around it; tune `output_config.effort`; show elapsed time and a cancel rather than an indeterminate spinner; stream thinking summaries as a last resort. |
| P7 | **Per-family font caching reintroduces the `_readyFuture` clobber bug** that P1.7-G2 and PR #25 each fixed once. | The `catchError`-based reset pattern is documented in `PersistedStoreMixin.ready`'s doc comment; the map-of-futures version needs the same treatment per entry, and a test that stubs a failing load and retries it — the test shape that caught it both previous times. |

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

## Phase 5 — ATS format analyzer (2026-08-20)

A user-requested feature outside the original roadmap: upload a PDF resume
and surface format problems an ATS text extractor would choke on — no
extractable text layer, a multi-column layout that a position-sorting
parser would interleave, garbled/unmapped characters, missing canonical
section headings, unrecoverable contact info. Spiked first, since the
premise (does `pdf.js`'s reading order approximate a real ATS parser's,
and can extracted-text coordinates be trusted) was cheap to falsify and
expensive to build around if wrong.

### Decisions locked

1. **Spike before committing to the full spec** (X-Ray overlay, Bézier
   flow lines, upload entry point, own nav section) — evidence-gated via
   documented exit criteria, not a fixed schedule.
2. **`pdf.js` 5.7.284 is already vendored and loaded** (`web/pdfjs/`, via
   the patched `printing` package) — no new dependency, no CDN. Reused
   directly rather than re-vendored.
3. **`PdfExtractionService` (the `dart:js_interop` marshalling layer) is
   split into an abstract interface + a `*Web` implementation, registered
   manually in `main.dart` instead of through `@StackedApp`'s
   `dependencies:` list.** `package:web` does not compile under the Dart
   VM at all — not "untested there," a genuine compile failure — and
   every other service's registration bakes its concrete class straight
   into the centrally-generated `app.locator.dart`, which nearly every
   test file imports. Discovered by hitting it: the first `flutter test`
   run after adding the service broke 19 unrelated test files project-
   wide. `AtsAnalyzerService` (pure Dart, the actual check logic) has no
   such problem and is registered normally.
4. **Two of the four originally-proposed checks were cut**: typographic-
   hierarchy and orphaned-date checks are resume-design critiques, not
   ATS-parsing-failure signals, and shipping them at the same confidence
   as a real parsing failure would erode trust in the findings that do
   matter.
5. **The X-Ray bounding-box overlay and Bézier reading-order flow lines
   are deferred, not shipped in this phase** — see "What's deferred"
   below.

### 5.1 — Spike → GREEN, with two scope corrections

Full findings: throwaway probe + corpus lived in the session scratchpad
(never the repo — corpus PDFs are treated as potentially sensitive), not
checked in. Headline results, condensed:

- `pdf.js`'s `getTextContent()` item order is real content-stream order
  (no internal sorting) and matches a second, independent extractor
  (`pdftotext`) on every corpus file, including a synthetic two-column
  file — the load-bearing assumption for the whole spatial-check family
  held.
- Item granularity is run-level (not glyph/word/line), producer-
  dependent, and well within a UI-tractable range.
- `page.commonObjs` (bold/italic/embedded-font) only populates after
  `page.getOperatorList()` has run for that page — confirmed necessary
  against the real bundle.
- **Column crush needed reframing, not abandoning**: a two-column layout
  does *not* interleave in either extractor's default order (both group
  by column, since most layout engines draw one column's content stream
  fully before the next) — but two runs sharing a baseline at disjoint
  x-ranges is directly detectable in the coordinate data. The check
  simulates a *position-sorting* parser (e.g. PDFBox with
  `setSortByPosition(true)`) via `AtsAnalyzerService`'s own y/x
  clustering over the extracted coordinates, not a claim about `pdf.js`'s
  own order.
- **A non-embedded-font PUA bullet can extract as a silently vanished
  glyph** (a nonzero advance width, zero surviving characters) rather
  than a visible PUA/replacement codepoint — worse than the original
  design assumed. `AtsAnalyzerService._checkGarbledText` adds a
  width-without-characters ("phantom glyph") heuristic alongside the
  codepoint-class histogram; documented as catching only an isolated
  short run, not a dropped glyph merged into a longer sentence run (the
  shape the spike's own real capture happened to produce).
  > **Actually shipped ([PR #30](https://github.com/IanHeinrich/cv-forge/pull/30)):**
  > the original heuristic gated on `trimmed.length <= 3`, which let a
  > *pure*-whitespace run (trimmed length 0) through as a false positive —
  > cv-forge's own PDF export pads justified/right-aligned lines to width
  > with exactly one wide single-space run, so every cv-forge-generated PDF
  > with a right-aligned date range tripped this. Fixed by also requiring
  > `trimmed.isNotEmpty`, since a pure-whitespace run never had a character
  > to drop in the first place.

### 5.2 — Core pipeline: models, extraction, analysis, UI → **bump 1.4.0**

- **Models** (`lib/models/ats/`) — `AtsTextNode`/`AtsTextMatrix` (the raw
  `pdf.js` transform, not a derived axis-aligned box — a rotated run has
  no meaningful width/height, so `fontSize`/`rotationRadians`/baseline
  are getters on the matrix instead), `AtsFontInfo`, `AtsLinkAnnotation`,
  `AtsDocumentInfo`, `AtsExtractedDocument` (the wire shape between the
  two services below), `AtsFinding`/`AtsFindingCategory`/
  `AtsFindingSeverity`, `AtsAnalysisResult`. None import `flutter` or
  `pdf`, per the `lib/models/` rule; none are persisted, so none carry
  `fromJson`/`toJson`/`schemaVersion` (the `ResolvedCv` precedent).
- **`PdfExtractionService`** (`lib/services/pdf_extraction_service.dart`,
  abstract) + **`PdfExtractionServiceWeb`**
  (`pdf_extraction_service_web.dart`, the real `dart:js_interop`
  implementation) — see Decision 3. Marshals `pdf.js` output into an
  `AtsExtractedDocument`, deliberately free of analysis logic. A fresh
  `Uint8List` copy is passed to `getDocument()` on every call, since it
  transfers (detaches) the underlying buffer and the same source bytes
  may be raster'd elsewhere. Coexists with `printing`'s own `pdf.js`
  init via `importModule`'s import-map memoization — whichever runs
  first "wins."
- **`pdfjs_bindings.dart`** — the `@JS('pdfjsLib')` binding file, modeled
  on but never importing `third_party/printing/lib/src/pdfjs.dart` (that
  package is vendored, patched, and slated for deletion). Extended with
  `getTextContent`/`getMetadata`/`getAnnotations`/`getStructTree`/
  `getOperatorList`/`commonObjs`, none of which `printing`'s own binding
  needs.
- **`AtsAnalyzerService`** (`lib/services/ats_analyzer_service.dart`) —
  pure Dart, the reduced v1 check set: no-text-layer (document- and
  per-page-level), column-crush, garbled-text (replacement chars +
  embedded PUA + phantom glyphs + non-embedded-font corroboration),
  missing-headings, contact-info (regex over extracted text *and*
  `mailto:`/`tel:` Link annotations — the latter confirmed in the spike
  to be materially more reliable). Fully VM-testable; its tests use node
  fixtures built from real `pdf.js` output captured during the spike,
  not invented numbers.
- **`FileUploadService.pickPdfFile()`** — the existing `pickJsonFile()`
  was generalized to share one `_pickFile(XTypeGroup)` helper rather than
  duplicating the picker logic.
- **`lib/features/analyzer/`** — `AnalyzerView`/`AnalyzerViewModel`
  (`BaseViewModel`, not `ReactiveViewModel`/`Initialisable`: there is no
  persisted state to load, only a user-triggered pick-and-analyze flow),
  `AnalyzerUploadPrompt`/`AnalyzerResultsPanel`/`AtsFindingCard`. One
  layout for every breakpoint (no `.desktop`/`.mobile` split) — nothing
  here actually varies by screen size, unlike Vault/Studio.
- **Nav integration** — `AppSection.analyzer` inserted into the enum
  right after `drafts` (before `studio`), a third `NavigationRailDestination`
  ("ATS Check", `file_search_line`/`_fill`), route `/analyzer`. See
  `app_chrome.dart`'s updated doc comment for why the *position* in the
  enum matters (every section with a real indexed destination must keep
  its enum position in lockstep with `destinations`' order).

**What's deferred, and why:** the X-Ray bounding-box overlay
(`CustomPainter` + `InteractiveViewer`, reconciling extracted-text
coordinates against a `Printing.raster()` backdrop) and the Bézier
reading-order flow lines from the original 3-part design. This would be
the first `CustomPainter` in the codebase, the coordinate reconciliation
between page-space (PDF points, y-up) and raster-pixel-space (DPI-scaled,
y-down) was flagged in planning as the single biggest correctness trap
for exactly this feature, and shipping it half-verified under time
pressure was judged worse than shipping the findings list alone and
following up. The findings-list feature (this phase) already delivers the
core value; the overlay is additive polish, not load-bearing.

> **Actually shipped ([PR #31](https://github.com/IanHeinrich/cv-forge/pull/31)):**
> the deferral above didn't stick — the overlay was built in a follow-up
> session, tracked in flight via a handover doc
> (`docs/ats-xray-overlay-handover.md`, deleted once the work landed) rather
> than as a planned sub-phase. `AtsFinding` gained `evidence: List<AtsFindingEvidence>`
> (`{pageIndex, nodeIndex}`, populated by `_checkColumnCrush`/`_checkGarbledText`)
> and `AtsEvidenceShape` (`scattered` vs `span` — whether evidence nodes are
> independent instances or the endpoints of a gap the overlay should connect
> and frame as a union). Coordinate reconciliation uses `pdf.js`'s own
> `getViewport()` transform (composed with the extracted text matrix in the
> new `ats_matrix_math.dart`, unit-tested against hand-computed matrix
> products) rather than hand-deriving rotation/CropBox math — the approach
> the handover doc recommended over the originally-planned derivation.
>
> Mid-build, the design pivoted: instead of a separate Findings tab with a
> "Show in X-Ray" jump action, findings are merged directly onto the X-Ray
> page as severity-coloured evidence boxes. `AnalyzerResultsPanel` ended up
> two tabs (X-Ray, Machine Ingestion), not three — `AnalyzerXrayRail` lists
> findings beside the raster page instead of on their own tab, and
> `AtsXrayPainter`/`XrayCameraController`/`XrayPageLoader` split the
> painting, camera-animation, and page-loading concerns that grew too large
> for one widget. Reading-order flow lines (also shipped, behind a toggle,
> mutually exclusive with finding selection) moved up from "cosmetic, do
> last" once it became clear a `columnCrush` box alone can't convey reading
> order, only position.
>
> Three bugs worth knowing before touching this code again, all from the
> same underlying cause: a `setState` scoped too broadly, rebuilding the
> whole panel (rail + camera + `InteractiveViewer` subtree) on every hover
> or drag event instead of just the one widget that needed it. Fixed each
> time by narrowing to a `ValueNotifier` + `ValueListenableBuilder` around
> just the affected value (hover peek text, then cursor state). Separately,
> the camera controller was being recreated and disposed per animation call
> without clearing the field pointing at it, so only the *first* finding
> click ever animated the camera — fixed by reusing one persistent
> controller for the widget's lifetime. And the flow lines/selection
> highlight were originally drawn in low-alpha white sized for the app's
> dark chrome, invisible against the light PDF-page backdrop they actually
> render over — fixed with a halo-stroke technique (a wide pale pass under a
> narrow dark pass) that stays legible over arbitrary page content.
>
> Known gaps carried forward from the handover doc: the per-node
> garbled-text split and rotated/CropBox fixtures are still deferred and
> unverified.

**Known follow-ups, not blockers:**
- **Golden baselines are now stale** — adding a third nav-rail destination
  changed `AppChrome`'s layout, invalidating all 5 existing golden PNGs
  (`vault_view_*`, `drafts_list_view_*`, `settings_view_*`). Confirmed via
  `flutter test --tags=golden` (all 5 fail, as expected). Per the
  established process, these must be regenerated via `update-goldens.yml`
  on `ubuntu-latest`, not locally — do this before merging.
- **Corpus/producer diversity gap** — the spike corpus was one real
  cv-forge-generated PDF plus five synthetic `package:pdf`-generated
  fixtures; no genuine Word/Google Docs/Canva/LaTeX/Apple Pages/scanned/
  LinkedIn-export sample was available in the environment. The mechanism
  is verified; cross-producer calibration of thresholds (the
  `_columnGapThreshold` constant especially) is not. Collect real-world
  samples opportunistically and revisit.
- **No golden test added for `AnalyzerView`** — deferred alongside the
  baseline regeneration above, to land both in the same reviewable PR
  rather than adding a 6th stale baseline to an already-stale set.

### Verification

`stacked generate && dart format . && flutter analyze && flutter test
--exclude-tags=golden` — all clean (0 analyze issues, 142 tests passing).
Manually verified against the real running app (`flutter run -d
web-server`): every new interop file compiles and loads via the real dev
server with no console errors; `window.dartPdfJsBaseUrl` resolution,
`importModule`, and the full `pdf.js` call sequence
(`getDocument`/`getTextContent`/`getOperatorList`/`commonObjs`/
`getStructTree`/`getAnnotations`) were exercised against a real corpus PDF
through the app's own already-loaded module instance, reproducing the
same results captured during the spike.

---

## Phase 6 — Section management, Publication bullets, PDF pagination guards (2026-08-21)

Built directly through a live working session (Studio feature requests
plus a live-CV feasibility question that turned into an implementation),
not pre-planned in this document — appended after the fact for the same
reason every other phase is recorded here: a durable account of what
shipped and why.

### 6.1 — Reorderable sections → **bump 2.1.0** ✅ shipped

`CvDraft` gained `sectionOrder: List<CvSectionType>` (an explicit
per-draft field, defaulting to declaration order) plus an
`effectiveSectionOrder` getter that appends any `CvSectionType` case
missing from the stored list — a defensive guard against a future new
section type shipping after a draft was last saved. `CvTemplate.sectionOrder`
is now only a *seed suggestion* for a brand-new draft
(`DraftService._seedSectionOrder`), never re-read for an existing draft —
switching a draft's template never reorders its sections.

Decision (asked directly, not assumed): per-CV order with an explicit
"save as my default" action, not a live global default with per-CV
overrides. A live global needs a resolution rule for whether editing it
retroactively changes existing CVs — the only sane answer is "no, it just
seeds new ones," which collapses to the same thing as storing order on
the draft and using a settings value purely as a seed, minus the
ambiguity. `AppSettings` already had this exact seed-not-live-fallback
shape (`defaultRegion`).

Studio's "Sections" list became a `ReorderableListView` (drag handles,
`bullet_list_editor.dart`'s existing pattern) combining reorder with the
existing visibility checkbox — replacing two separate, duplicated
show/hide controls (the flat list, and a second toggle on the
Summary/References override cards) with one source of truth.

**Two real regressions found by testing the shipped feature, both fixed
same-session:** `StudioPreviewPane`'s repaint gate compared only
`ResolvedCv` content equality, so switching template or region — neither
of which touches `ResolvedCv` now that order lives on the draft, not the
template — silently stopped triggering a repaint. Fixed by also tracking
`viewModel.template.id` and `viewModel.pageFormat` (A4 vs Letter) in the
settled/rendered comparison.

### 6.2 — Publication bullets ✅ shipped

Full parity with `Project`: `Publication.bullets`, `CvDraft.publicationBulletIds`,
`VaultService` bullet CRUD, `VaultViewModel`/`vault_editor_panel_router.dart`
wiring, `PublicationEditorPanel`'s `BulletListEditor`, Studio's
`isPublicationBulletIncluded`/`togglePublicationBullet`/
`addAllPublicationBullets`, both PDF templates' bullet rendering — and,
per explicit confirmation rather than assumption, full Copilot pipeline
parity too: the LLM response schema's flat `publicationIds` array became
an id-keyed `publications` object (`bulletIds` + `rewrites`, exactly
`projects`' shape), `CopilotVaultPayload` sends each publication's
bullets, and `CopilotResult.fromLlmResponse` parses/validates them the
same way as project bullets.

### 6.3 — Example CV rewrite + Clear Vault ✅ shipped

`buildExampleVault()` rewritten as a fully fictional persona modeled on
the app author's real career shape (domain, skill stack, seniority arc)
but with every employer, exact metric, and client engagement invented —
raised proactively before writing it, since the fixture's own prior doc
comment already flagged "this repo is public, permanent git history" as
the reason it must stay fictional, and a name-only swap of the real CV
supplied for reference would have stayed trivially re-identifiable via
distinctive real employer/project names. One deliberate exception, per
explicit instruction: the Projects section links the author's own real,
public portfolio repos (this project among them), with descriptions
pulled from each repo's actual README — real and attributed by choice,
not fictionalized.

Added a confirmed "Clear Vault" action (`VaultService.clearVault`,
`VaultViewModel.clearVault` reusing the existing `confirmDelete` dialog
with a `confirmLabel` override) that resets to `CvVault.empty()` and
un-dismisses the empty state, so "Load example CV" / build-from-scratch
is offered again exactly as on first launch.

Follow-up mid-session: "Save as my default" was extended to also
remember which sections are hidden, not just their order —
`AppSettings.defaultHiddenSections` alongside `defaultSectionOrder`, both
set/reset together in one call (`SettingsService.setDefaultSectionSettings`,
`DraftService.resetSectionSettings`) so the pair can never drift apart or
end up half-reset.

### 6.4 — PDF pagination guards (orphan/split prevention) → **bump 2.1.0** ✅ shipped

Requested as a feasibility question first, then implemented once
confirmed. Two rules: a section/entry heading is never left stranded
without at least its first item below it, and a single bullet's text
never splits mid-sentence across a page break — while still allowing a
section or entry's remaining items to spread freely across as many pages
as needed.

**The feasibility investigation found the real mechanism is narrower than
it first looked**, confirmed empirically against the actual `package:pdf`
3.13.0 source and real rendered output, not just documentation:
`pw.Inseparable` (`canSpan: false`) is the correct primitive for gluing a
heading to its first item, but a `pw.Column` *nested inside* another
`pw.Column` does **not** reliably split across pages when the outer one
spans — `Flex.layout` hands every child an unbounded max-height
regardless of remaining page space, and `Flex.hasMoreWidgets` is
unconditionally `true`, so a single oversized nested child either
overflows silently or drives `pw.MultiPage` past its own 20-page safety
cap (`PdfTooBigPageException` — reproduced directly, not inferred). The
only way bullets genuinely split between each other across a page break
is for each bullet to be its own top-level `pw.MultiPage` widget, never
grouped into a nested "remaining bullets" `pw.Column`.

Implemented as `lib/templates/design/section_pagination_pdf.dart`'s
`assembleSectionWidgets`, reused recursively at every heading+items level
in both templates (section→entries, entry→bullets, promotion
group→positions→bullets) — the same helper, not a duplicated rule per
template. `PdfExportService.render` catches the one remaining legitimate
failure (`PdfException` for a single bullet whose own text is too long to
fit on any page — confirmed a genuine, unavoidable content limit in
either mode, not a bug) and retries once with the guard off, surfacing a
clean `PdfExportException` rather than an uncaught crash if even that
fails. A note was added to `CLAUDE.md` (not just this file) so a future
template renderer routes through `assembleSectionWidgets` instead of
silently reintroducing the nested-Column bug.

### Verification

`stacked generate && dart format . && flutter analyze && flutter test
--exclude-tags=golden` — all clean (0 analyze issues, 250 tests passing,
up from 239 at the start of the session). Golden baselines regenerated on
`ubuntu-latest` via `update-goldens.yml`: only `vault_view_populated`
changed (the example-CV rewrite), the other four came back byte-identical
and were left untouched. Manually verified against the running app for
every sub-phase above: section drag-reorder, save/reset default (order +
hidden sections), template switch, region switch, publication bullets in
Vault/Studio/both PDF exports, and the Clear Vault confirm-and-reset flow.

## Phase 7 — Interface work (2026-08-22)

The eight-workstream UI/UX review recorded in `docs/ux/` — see that
folder's `README.md` for the full review findings, the decision table
per workstream, and why these are pre-spec files rather than sections of
this document. Each summarised here once shipped, per that file's own
stated convention; the `docs/ux/7.N-*.md` file remains the long-form
rationale.

### 7.1 — Surface elevation ramp → [PR #51](https://github.com/IanHeinrich/CVForge/pull/51) ✅ shipped

`app_colors.dart` gained a four-tier surface ramp (`kcSurfaceSunken` →
`kcSurface` → `kcSurfaceRaised` → `kcSurfaceOverlay`) plus
`kcBorderColor`/`kcBorderStrong`, replacing the single flat
`kcBackgroundColor`/`kcDarkGreyColor` pair every panel and card used to
share. Pinned onto `buildAppTheme()`'s `ColorScheme` container slots
(`surface`, `surfaceContainerLowest/Low/High/Highest`,
`outlineVariant`/`outline`) rather than read directly by widgets — so
`Card`, `NavigationRail`, and `Divider` pick up the right tier from
Material's own defaults, and roughly a dozen call sites (every top-level
`Scaffold`'s `backgroundColor`, `AppChrome`'s `NavigationRail`, every
plain `VerticalDivider`/`Divider`) could have their explicit color
argument **deleted** entirely rather than repointed, since it now matches
the theme default. The remaining call sites — block-card `Container`
decorations, `Material` list-item fills, hairline borders — read
`Theme.of(context).colorScheme.*` rather than a raw `kc*` const, so no
widget outside `app_theme.dart` needs to know the ramp's actual values.
`kcMediumGrey`'s three previously-conflated roles (border/divider colour,
placeholder/disabled text, the preview pane's backdrop) split into their
correct tiers — border and backdrop moved to the ramp, placeholder/
disabled text is `kcMediumGrey`'s one remaining job. `AppSummaryCard`'s
selected state moved from a full `kcPrimaryColorDark` fill to a
`kcSurfaceOverlay` fill plus a 2px `kcPrimaryColor` left edge, per the
doc's "also worth fixing while here" note, now that a real ramp exists
underneath it to read against.

Re-baselined all five golden snapshots (every one pumps its View inside
`AppChrome`).

### 7.2 — Grouped chip skill selection ✅ shipped

Extracted `AppChipGroupSelector` (`lib/ui/widgets/common/`) from the
`Wrap`-of-`FilterChip`s pattern the Vault's `_SkillBulletLinkPicker`
(`skills_editor_panel.dart`) already used — a group has a label plus
items, each item an id/label/selected/`onToggle`, with an optional
per-group `onSelectAll`/`onSelectNone` computing its own "Add all (N)" /
"Remove all (N)" count from the items it's given. The Vault's own bullet
picker was switched onto it too (decision: prove the extraction by
making the widget it was pulled from use it), so the two consumers can't
drift.

Studio's skill selector (`studio_skill_selector/studio_skill_selector.dart`)
replaces `VaultItemSelectorList`'s flattened one-`CheckboxListTile`-per-
skill rendering, which discarded the category grouping `CvComposer` and
both templates reinstate when they print a skills section. Filtering is
**category-level**: a category renders in full (every skill, unfiltered)
once its name or any one skill's label matches the query, so a
category's "Add all (N)" always matches what tapping it actually adds —
never a partial-category count that would silently include hidden
skills. `StudioViewModel` gained `addAllSkillsInCategory`/
`removeAllSkillsInCategory` (same sequential-await shape every other bulk
selection in this codebase already needs) and `selectEvidencedSkills` —
adds every skill linked to a bullet actually included in the draft,
add-only, wired to a "Select N evidenced skills" button that disables
rather than hides at zero. `Skill.linkedBulletIds` had sat unused since
Phase 1 (its own doc comment said so); this is the first thing that
reads it.

No golden coverage exists for either surface touched (`StudioView` has
none at all; Phase 3.8 already recorded the Vault skills panel doesn't
render in either golden-tested View's default state) — verified in the
browser instead: chips wrap without scrolling, category headings appear
once each, a filtered-out selection survives the filter clearing, and
the evidenced-skills button's count matches what it selects.

### 7.3 — Preview fit and page count ✅ shipped

`StudioPreviewPane` swapped `printing.PdfPreview` for the same package's
`PdfPreviewCustom` — confirmed by reading `third_party/printing`'s actual
source that this is a drop-in replacement for every argument already in
use, and deletes three arguments (`useActions`/`canChangePageFormat`/
`canChangeOrientation`) whose only job was disabling `PdfPreview`'s own
action bar. The page is now capped at its true printed width
(`format.width / PdfPageFormat.inch * 96`, derived from `PdfPageFormat`
rather than a literal so a US Letter draft sizes correctly too) instead
of stretching to fill the pane — previously the page rendered at roughly
130% of print size on a 1728px viewport. Page count is read from
`pagesBuilder`'s own page list (free — the rasterisation already
happened) and surfaced via `StudioViewModel.pageCount`/`setPageCount`,
set from a post-frame callback guarded on the value changing, since
`pagesBuilder` runs mid-build and a direct `notifyListeners()` from there
would assert. Two-up rendering is gated on the pane's own available width
(`LayoutBuilder`, not a user toggle), and — confirmed against the
vendored source, not assumed — `PdfPreviewCustom` wraps its *entire*
content (including a custom `pagesBuilder`'s output) in one
`BoxConstraints(maxWidth: maxPageWidth)`, so the cap itself has to widen
to two-pages-plus-gutter whenever two-up applies, or the two-up row would
get clipped down to one page's width by the same constraint meant to cap
a single page.

**Not verified pixel-for-pixel in this session's browser check**: the
sandbox's bundled Chromium build hits a `pdf.js`/CanvasKit compatibility
error (`getOrInsertComputed` unimplemented) rasterising *any* PDF
preview, old widget or new — confirmed unrelated to this change since
both `PdfPreview` and `PdfPreviewCustom` share the same underlying
`PdfPreviewRaster` mixin. The width-cap and two-up-widening logic above
is verified against the real vendored source and the full test suite
(`pdf_export_service_test.dart` is untouched and still passing, per the
doc's own note that it exercises `PdfExportService.render` directly, not
the preview widget) rather than a live screenshot — worth a real-browser
check before relying on the exact pixel sizing.

### Verification

`flutter analyze` (0 issues) and `flutter test --exclude-tags=golden`
(253/253, up from 250 — three new `StudioViewModel` tests covering
`addAllSkillsInCategory`/`removeAllSkillsInCategory`/
`selectEvidencedSkills`, including the sequential-await assertion every
bulk-selection method in this codebase needs). Goldens regenerated
locally (`flutter test --tags=golden --update-goldens`, same Linux OS
family as `ubuntu-latest`) and separately confirmed green by dispatching
`update-goldens.yml` on the branch — its artifact wasn't downloaded into
this session (outside the sandbox's allowed egress), so the committed
PNGs are the local render, not that run's artifact; a diff between the
two is still worth doing. Browser-verified 7.1 and 7.2 against the
running app (elevation ramp, chip grouping in both Vault and Studio); 7.3
per its own note above. Shipped as one PR covering all three sub-phases;
CI (`Analyze & test`, `update-goldens`) green before merge.

### 7.4 — Studio document bar and master–detail restructure → [PR #53](https://github.com/IanHeinrich/CVForge/pull/53) ✅ shipped

Replaced the single 13-concern `studio_config_panel.dart` scroll with a
document bar / section nav / section editor / preview four-zone layout
on desktop, and a nav→editor drill-down under the existing Configure tab
on compact. `StudioDocumentBar` absorbed `studio_draft_header.dart`
(draft name/back/edit) plus the template/region pickers, page count
(7.3), and Export — moved off the preview pane's floating button so it
reads as document-level, not preview-level. `StudioSectionNav` is the
existing reorderable section list, now also selecting which section the
editor pane shows (checkbox = include/exclude, drag handle = order, row
body = select). `StudioSectionEditorRouter` plus eight small editors
under `lib/features/studio/widgets/sections/` replace the old panel's
inline per-section blocks, one per `CvSectionType`, each independently
scroll-position-keyed via `PageStorageKey`. `StudioViewModel` gained
`openSection`/`selectSection`, with hiding the currently-open section
clearing the selection so the editor can never show a section the nav no
longer lists. Deleted `studio_config_panel.dart` and
`studio_draft_header.dart`.

**Actually shipped:** a genuine `RenderFlex` overflow in
`CopilotConfigCard`'s button row, exposed only once the card moved into
the new ~220px nav column, caught during the doc's own mandated browser
pass rather than `flutter analyze`/tests — fixed by switching that `Row`
to a `Wrap`. Per the doc's own reasoning, no golden test was added for
`StudioView` — the preview pane rasterises a real PDF, so a golden here
would be reliably flaky, not reliably correct. Verified via `flutter
analyze` (0 issues), `flutter test --exclude-tags=golden` (257/257, +4
for `openSection`/`selectSection`), and a Playwright pass at 1728/1100/
tablet-800/mobile-500px confirming the three-column desktop layout,
section switching, and the tablet/mobile drill-down with its back
affordance — zero `RenderFlex` overflows after the `CopilotConfigCard`
fix.

### 7.5 — Template gallery and region data → [PR #54](https://github.com/IanHeinrich/CVForge/pull/54) ✅ shipped

Sized each picker to how it actually grows, per the doc's own framing:
templates (10–15 expected) got a thumbnail gallery dialog, regions (5–6,
but too many for one row of chips once 7.4's document bar is a single
row) got a plain `DropdownMenu`. New `TemplateThumbnailService` renders a
template's first page for the user's *own* current CV via
`PdfExportService.render` + `Printing.raster`, cached per
`(templateId, ResolvedCv)` using `ResolvedCv`'s value equality so an edit
invalidates automatically. `TemplateGalleryDialog` groups its grid under
tag headings rather than filtering (15 templates in 3–4 scannable groups
beats a filter control over 15 items); a failed or still-loading
thumbnail degrades to a name-and-description card rather than breaking
the grid. `CvTemplate` gained `tags` (`TemplateTag`: atsSafe/academic/
twoColumn/compact/traditional/modern), added now while there are only
two templates to retrofit. `RegionPreset` gained `documentNoun` (fixes
ATS Check saying "resume" for a UK user — read via
`AnalyzerViewModel.documentNoun` from `SettingsService.settings
.defaultRegion`, since Analyzer has no draft of its own) and `dateStyle`
(`CvComposer._formatDateRange`'s pre-existing seam, finally switched on
instead of on `RegionProfile` directly — both regions still resolve to
`RegionDateStyle.monYyyy` today, so this is wiring, not a behaviour
change).

Verified via `flutter analyze` (0 issues), `flutter test
--exclude-tags=golden` (268/268, new coverage for the thumbnail cache's
hit/miss/error-propagation contract, the gallery's tag-grouping and
selection state, and a UK/US `resolvedCv` date-range test covering the
`dateStyle` seam), and a Playwright pass confirming the gallery's
grouping and current-template marker, a template switch reflected in the
document bar, and the region dropdown updating UK → US. Thumbnails
degrade to their error-card state in this sandboxed Chromium (no PDF
rasterisation available — the same `Printing.raster`/pdf.js limitation
7.3 and 7.4 already hit, not a regression), which is exactly the
degrade-gracefully path the doc calls for.

### 7.7 — Settings: backup state and form-control consistency → [PR #55](https://github.com/IanHeinrich/CVForge/pull/55) ✅ shipped

The substantive change, per the doc's own framing: Backup went from a
bare pair of buttons to real state. `AppSettings.lastBackupAt` (set by
`SettingsViewModel.exportBackup` only on success) plus a
`hasChangesSinceBackup` getter derived from `CvVault.updatedAt`/
`CvDraft.updatedAt` — not a separate persisted dirty flag, since those
timestamps already exist and a reactive comparison can't drift from them
the way a flag maintained on every write path could. `BackupSettingsCard`
now reads "Never backed up" / "Last backed up 3 days ago" / a
warning-coloured "…you have changes since then". Everything else was
tidying, still real: `AppTextField` gained `errorText` (no field
anywhere could show a validation error before this — 7.8 is the bigger
consumer); Copilot's provider/model `DropdownButton`s became labelled
`DropdownButtonFormField`s matching the outlined API-key field's visual
language; the key field capped at 360px; "Remember on this device" now
names the storage and the risk; the connection result got a styled
success/error banner (new `kcSuccessColor` token) that clears itself via
`clearConnectionTestResult` whenever the provider, model, or key field
changes; the price label now reads "Provider's own rate — not billed by
CVForge". `SettingsView` gained a page header and a 720px content cap,
left-aligned.

**Not implemented:** the doc's "prompt after a first PDF export" idea —
outside its own "What changes" file list (no Studio file is named
there), so treated as context/rationale rather than a required change.
Verified via `flutter analyze` (0 issues), `flutter test
--exclude-tags=golden` (276/276), `settings_view_default.png`
regenerated (expected — the page header alone moves it) and committed,
and a Playwright pass confirming the header/cap/card-styling, the
"Never backed up" state, and a full provider-switch round trip (model
reset, price relabelled, key field cleared, styled result banner).

### 7.8 — Vault date entry correctness fix, Clear Vault relocation → [PR #56](https://github.com/IanHeinrich/CVForge/pull/56) ✅ shipped

The one workstream in this phase marked **patch, urgent** rather than
cosmetic, and shipped as a correctness fix rather than polish per the
doc's own decision 1. Free-text month entry (`AppTextField` +
`int.tryParse`) silently discarded invalid or partial input while
`AppTextField`'s debounce and resync-only-when-unfocused behaviour let
the displayed field diverge from the model indefinitely, or let a
transient invalid keystroke get committed if the user paused mid-edit.
Fixed by replacing month entry with a closed-set
`DropdownButtonFormField` (`ExperienceEditorPanel`'s start/end month) —
a closed set has no invalid state to reject and no partial keystroke to
write, so both failure modes are structurally impossible now, not just
handled better. `YearMonth` gained a public `monthName(int)`, the single
owner behind both `toMonYyyy()` and the new dropdowns. Year fields stay
free text but now use 7.7's `errorText` for out-of-range (1900–2100) or
non-numeric input instead of silently discarding it, validated on
`VaultViewModel` (not the stateless panels) per CLAUDE.md's "logic in
the ViewModel" rule. The doc's "Failure 3" — an entry with no end date
silently adopting the *start's* year the moment only the end month got
set — is fixed by seeding a null end date's year from the current year
instead.

Clear Vault moved from the Vault screen's first interactive element
(above the user's own name, styled the same as "Add experience") into a
"Danger zone" section on `BackupSettingsCard`, beside the export-first
framing 7.7 just gave Backup. `SettingsViewModel` gained `clearVault()`;
`VaultViewModel.clearVault()` was deleted — its UI-state resets (closing
the open editor, un-dismissing the empty state) were only needed because
the trigger lived on the same page, and moving away naturally
reconstructs a fresh `VaultViewModel` now. The card list also picked up
a 720px content-width cap (a row was a ~1,500px bar with its delete icon
a screen-width from the label it deletes) and the Hobbies card's
subtitle became a count, matching Skills, instead of a comma-joined list
that degrades into a truncated fragment past about four hobbies.

Verified via `flutter analyze` (0 issues), `flutter test
--exclude-tags=golden` (282/282 — new year-field validation coverage
for out-of-range/non-numeric rejection, valid-commit-and-clear-error,
the Failure-3 end-year seed, and Education's empty-is-valid case),
`vault_view_populated.png`/`settings_view_default.png` regenerated
(expected) and committed, and a Playwright pass exercising the actual
bug: typed an out-of-range year, confirmed a red error border with the
message exposed via the field's accessible description and the model
left unchanged; corrected it and confirmed the commit; changed the start
month via the dropdown; closed and reopened the panel and confirmed both
fields showed exactly what was saved — the round trip the pre-fix
implementation failed.

### Phase 7 status

7.1, 7.2, 7.3, 7.4, 7.5, 7.7, and 7.8 are shipped. **7.6 (logo, favicon,
splash, plus the `manifest.json` bug) is the only sub-phase left** —
deliberately deferred this round; it touches no Dart and is independent
of everything else here. Repo version bumped to `2.3.0` covering
7.4/7.5/7.7/7.8 (`BackupService._appVersion` — see its own doc comment —
was found drifted at `1.4.0`, stale since well before this phase, and
corrected to match in the same pass).
