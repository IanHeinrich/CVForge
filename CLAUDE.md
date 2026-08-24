# CLAUDE.md

Guidance for Claude Code (and any AI assistant) working in this repository.

## Project

**cv-forge** is a Flutter Web application using the **Stacked** MVVM
architecture (`stacked` package from FilledStacks) for state management and
navigation, with **freezed** for immutable models/unions and
**json_serializable** for JSON (de)serialization.

Docs:
- Stacked CLI: https://stacked.filledstacks.com/docs/Tooling/stacked-cli
- Freezed: https://pub.dev/packages/freezed

## Hard rule: use the Stacked CLI, never hand-scaffold

Views, ViewModels, Services, Widgets, BottomSheets, and Dialogs **must** be
created with the `stacked` CLI, not written from scratch by hand. The CLI
keeps naming conventions consistent and automatically wires up route
registration, DI (locator) registration, and test scaffolding via the
`// @stacked-*` markers in `app.dart` / `test_helpers.dart`. Hand-writing
these files bypasses that wiring and will drift from the generated
conventions.

### Commands to use for each action

| Action | Command |
|---|---|
| New screen (View + ViewModel + route) | `stacked create view <name>` |
| New service (+ DI registration) | `stacked create service <name>` |
| New reusable widget (+ WidgetModel) | `stacked create widget <name>` |
| New bottom sheet (+ SheetModel) | `stacked create bottom_sheet <name>` |
| New dialog (+ DialogModel) | `stacked create dialog <name>` |
| Run all code generation (freezed, json_serializable, stacked locator/router, etc.) | `stacked generate` |
| Update the CLI itself | `stacked update` |

Useful flags:
- `--[no-]exclude-route` on `view` / `bottom_sheet` / `dialog` — skip
  auto-registering the route if you deliberately don't want one.
- `--[no-]exclude-dependency` on `service` — skip auto-registering in the
  locator.
- `--[no-]model` on `widget` / `bottom_sheet` / `dialog` — control whether a
  companion Model class is generated (default: on).
- `--path, -p` on `widget` — put the widget in a custom subfolder instead of
  `ui/widgets/common`.
- `--config-path, -c` on every `create` subcommand — points the CLI at an
  alternate `stacked.json`-shaped config file instead of the project-root
  one. This is how feature-scoped generation (see below) is done, since
  `view`/`service`/`bottom_sheet`/`dialog` have no `-p/--path` flag of their
  own.

Always run `stacked create ...` from the project root (where `stacked.json`
and `pubspec.yaml` live).

### After scaffolding or changing annotated code

Run code generation whenever you add/change a `@freezed`, `@JsonSerializable`,
or Stacked-annotated class, or after any `stacked create` command that
touches generated files:

```bash
stacked generate
```

This is the Stacked-aware replacement for running `build_runner` directly —
it drives freezed, json_serializable, mockito, and the Stacked
router/locator/logger generators in one pass. Do not hand-write or hand-edit
any `*.g.dart` or `*.freezed.dart` file — these are generated output and get
overwritten.

**Run `dart format .` immediately after every `stacked generate`, before
committing.** Generated output (freezed 3.x in particular) isn't always
CI-format-clean, and `dart format --set-exit-if-changed .` failing on
generated files is this repo's highest-frequency CI failure mode.

### `stacked.json`

Project-specific CLI configuration (paths, locator name, line length, etc.)
lives in `stacked.json` at the project root. Check it before assuming default
folder paths — if it has been customized, generated files will land in
whatever paths it specifies rather than the defaults below. This root config
is the fallback for anything that isn't owned by a single feature (see
below).

Default folder conventions (override via `stacked.json`):
- Views: `lib/ui/views/<name>/`
- Widgets: `lib/ui/widgets/common/`
- Bottom sheets: `lib/ui/bottom_sheets/`
- Dialogs: `lib/ui/dialogs/`
- Services: `lib/services/`
- App-level wiring (routes, DI): `lib/app/app.dart`
- Test helpers: `test/helpers/test_helpers.dart`

## Feature folder structure (vertical slices)

This project is organized **package-by-feature, not package-by-layer**.
Anything owned by a single feature — Views, Dialogs, BottomSheets, and
feature-specific Widgets — lives together under `lib/features/<feature>/`,
not scattered across the global `ui/views/`, `ui/dialogs/`,
`ui/bottom_sheets/` folders. Two things stay global regardless of feature,
because Stacked's routing/DI model is inherently centralized and because
they're meant to be reused:
- **Services** always live in `lib/services/` (per root `stacked.json`),
  whether they're used by one feature or many. Don't move a service into a
  feature folder even if only that feature currently uses it.
- **Genuinely shared UI** (colors, spacing helpers, a widget used by 2+
  features) stays in `lib/ui/common/` and `lib/ui/widgets/common/`. Only
  move something into a feature folder once it's actually feature-specific;
  don't pre-emptively shard shared code.
- **Routing and DI registration** (`lib/app/app.dart`, `app.router.dart`,
  `app.locator.dart`) and the test helpers file stay singular/central —
  vertical slicing here is about where source files live, not about
  splitting Stacked's `@StackedApp` wiring itself.

Two non-feature layers sit alongside these:
- `lib/models/` — pure Dart freezed models (`vault/`, `draft/`, `render/`).
  **Must never import `flutter` or `pdf`.** `render/cv_composer.dart` is the
  only place Vault and Draft data are joined.
- `lib/templates/` — the single-renderer boundary. `design/` holds
  framework-agnostic tokens plus one `pdf`-only adapter
  (`cv_design_tokens_pdf.dart`). `design/cv_pdf_renderer.dart`'s
  `CvPdfRenderer` owns the walk from `ResolvedCv` to a flat widget list;
  a template subclasses it and overrides presentation only — section
  heading, body alignment, and each entry type's header widget. A
  template must not reimplement that walk.
  Studio's live preview rasterizes that same PDF via `printing.PdfPreview`
  rather than maintaining a second, hand-built Flutter render tree
  alongside it — preview and export are the same bytes, so they can't
  drift on content *or* pixels. **A template's `buildDocument` must hand
  `pw.MultiPage.build` a flat `List<pw.Widget>`, never a single wrapping
  `pw.Column`** — a `pw.Column` root can't be split across pages, so
  everything silently overflows onto page 1 and reads like a package
  limitation rather than the actual cause.
  **A `pw.Column` nested *inside* another `pw.Column` doesn't reliably
  split further when the outer one spans, either** — confirmed against
  `package:pdf` 3.13.0's actual source, not assumed: `Flex.layout` hands
  every child an unbounded max-height regardless of remaining page space,
  and `Flex.hasMoreWidgets` is unconditionally `true`, so a single
  oversized nested child gets measured at its full natural size and
  either throws (`PdfException`) or drives `pw.MultiPage` past its
  20-page safety cap (`PdfTooBigPageException`) — empirically reproduced,
  not theoretical. **Bullets can only genuinely split across a page break
  when each one is its own top-level `pw.MultiPage` widget**, never
  grouped into a nested "remaining bullets" `pw.Column`, however tempting
  that looks. `lib/templates/design/section_pagination_pdf.dart`'s
  `assembleSectionWidgets` is the one place this is implemented — reused
  recursively (section→entries, entry→bullets, company→positions) via
  `pw.Inseparable` to glue a heading to just its first item so a page
  break can never strand a title without any of its body, while still
  letting later items split freely. `CvPdfRenderer` is what routes every
  heading+items group through that helper, which is why a template
  supplies widgets rather than structure — a renderer that builds its own
  nested `pw.Column` silently reintroduces both the stranded-title and
  mid-entry-split bugs this exists to prevent.

### How to scaffold into a feature slice

`stacked create view/dialog/bottom_sheet` don't have a `-p/--path` flag, so
feature-scoped generation is done with a **per-feature config file** passed
via `-c`:

1. If it doesn't exist yet, create `stacked_configs/<feature>.json` — a copy
   of the root `stacked.json` with only the path fields repointed under the
   feature, e.g. for a `vault` feature:
   ```json
   {
       "bottom_sheets_path": "features/vault/bottom_sheets",
       "dialogs_path": "features/vault/dialogs",
       "line_length": 80,
       "locator_name": "locator",
       "prefer_web": true,
       "register_mocks_function": "registerServices",
       "services_path": "services",
       "stacked_app_file_path": "app/app.dart",
       "test_helpers_file_path": "helpers/test_helpers.dart",
       "test_services_path": "services",
       "test_views_path": "features/vault/viewmodels",
       "test_widgets_path": "features/vault/widget_models",
       "v1": false,
       "views_path": "features/vault/views",
       "widgets_path": "features/vault/widgets"
   }
   ```
   Note `services_path`, `stacked_app_file_path`, and `test_helpers_file_path`
   are left pointing at the same global locations as root `stacked.json` —
   only the view/widget/dialog/bottom_sheet (and their matching test) paths
   move.
2. Pass that config on every `create` command for that feature:
   ```bash
   stacked create view login -c stacked_configs/vault.json
   stacked create dialog confirm_delete -c stacked_configs/vault.json
   ```
3. For a feature-specific reusable widget, either use the same `-c` config
   or the widget command's own `-p` flag pointed at
   `features/<feature>/widgets` — prefer `-c` for consistency so there's one
   mechanism to remember per feature rather than two.

This has been verified to work end-to-end: `stacked generate` still drives
the single central router/locator correctly, routes still register into the
one `app.dart`, and `--exclude-route`/other flags behave the same regardless
of which config is active.

## Freezed & json_serializable conventions

- Every data model (DTOs, request/response payloads, immutable app state)
  should be a `@freezed` class, not a hand-written class with manual
  `copyWith`/`==`/`hashCode`.
- File layout for a model `foo.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';

  part 'foo.freezed.dart';
  part 'foo.g.dart'; // only if it needs JSON (de)serialization

  @freezed
  abstract class Foo with _$Foo {
    const factory Foo({
      required String id,
      String? name,
    }) = _Foo;

    factory Foo.fromJson(Map<String, dynamic> json) => _$FooFromJson(json);
  }
  ```
- `fromJson`/`toJson` on a `@freezed` class are powered by `json_serializable`
  under the hood — adding the `part 'foo.g.dart'` line and the `fromJson`
  factory is enough; don't add a separate manual `@JsonSerializable()` class
  for something that's already `@freezed`.
- Reach for a plain `@JsonSerializable()` class (no freezed) only for things
  that are genuinely not domain models — e.g. a thin wrapper purely for
  parsing a third-party API response you immediately map into a `@freezed`
  domain type. Default to `@freezed` for anything that represents app state
  or data the rest of the app consumes directly.
- Use multiple factory constructors for union/sealed state (e.g. a
  `ViewState` with `.loading()`, `.data(...)`, `.error(...)` variants) instead
  of hand-rolled enums + nullable fields. Prefer Dart 3 `switch` expressions
  over the legacy `.when()`/`.map()` for handling variants in new code.
- Use `@unfreezed` only when a class genuinely needs mutable fields — default
  to `@freezed` (immutable).
- Never edit generated `*.freezed.dart` / `*.g.dart` files by hand; change the
  source class and re-run `stacked generate`.
- After adding/editing any freezed/json_serializable model, run
  `stacked generate` before writing code that depends on it (e.g.
  `copyWith`, `fromJson`), since that code won't compile/exist until
  generation has run.

## Localization (i18n)

Every user-facing string lives in `lib/l10n/app_en.arb`. A string literal in a
`Text(...)`, `label:`, `hintText:`, `tooltip:`, or a dialog
`title:`/`description:` under `lib/features/**` or `lib/ui/**` is a bug.

### The UI's language and the document's language are different axes

The app chrome is localized. **The CV this app produces is not** — it is
written in English regardless of what language the user reads the interface
in, because someone applying across borders routinely needs an English CV
while reading a German UI. Nothing the UI locale does may reach:

- `lib/models/render/cv_composer.dart` — section titles, and the `'Present'`
  marker (capitalized deliberately for ATS regex matching)
- all of `lib/templates/**`
- `YearMonth.monthName` and the Vault month pickers it feeds. The picker looks
  like an obvious localization target and is not: it selects a value that gets
  *printed*, in English, so showing "Mär" where the CV will say "Mar" would
  break the invariant that getter's doc exists to protect.

This is a separate future feature, not an oversight. Region is a third axis
again — see `RegionProfile`'s own note on region ≠ locale.

### Also deliberately not localized

Storage keys and any persisted enum `.name`; JSON/schema field names; route
paths; `Exception.toString()` bodies (localize the *ViewModel switch* that
maps a failure to user copy, not the exception — `SettingsViewModel.
connectionTestErrorMessage` is the pattern); every `promptLabel` and all LLM
prompt text, which is English because the model is instructed in English and
translating it changes model behaviour; backup filenames; and brand names
(`ksAppTitle`, `LlmProvider.displayName`, `RegionPreset.localName` — the
market's own word for the document, whose entire purpose is to not be
translated).

### Three access paths, and only three

| Where | How |
|---|---|
| Views / Widgets | `context.l10n.someKey` (`lib/ui/common/l10n_extensions.dart`) |
| ViewModels / Services | inject `LocalizationService`, read `.strings` |
| Enum labels | an extension *method* taking `AppLocalizations` |

Never cache a localized string in a ViewModel field — always a getter, so a
locale change is picked up on the next build with no `listenableServices`
plumbing.

**Enum label extensions live in `lib/ui/common/l10n/`, never on the model**,
because `AppLocalizations` imports Flutter and `lib/models/` must not. The
enum stays put; only its label moves.

### Key naming

`<area><Surface><Slug>` in lowerCamelCase — e.g. `settingsRegionCardTitle`,
`atsFindingNoTextLayerTitle`, `vaultHobbyCount`.

- **Name by location and role, never by English words.** When copy changes,
  edit the ARB *value*; never rename the key. A rename is a delete + add to
  every locale and every translation tool.
- **Never de-duplicate by English text.** Two identical English strings in two
  features get two keys — "Change" in Settings and "Change" in Studio can
  legitimately translate differently. Only strings whose owning *file* is in
  `lib/ui/common/` or `lib/ui/widgets/common/` share a `common*` key. Sharing
  follows code ownership, not string equality.
- **One key = one complete rendered phrase.** Never concatenate two keys into
  a sentence, and never interpolate a translated noun into a translated frame
  — a language with gender or case cannot inflect it. Use ICU `select` over
  the whole frame instead.
- **Keep the ARB alphabetically sorted.** Since keys are area-prefixed,
  alphabetical order *is* grouped-by-area order, which keeps merge conflicts
  local while several sweep PRs are in flight.
- `@description` is mandatory (the empty `@key` slot is build-enforced by
  `required-resource-attributes: true`). It must say *where the string
  appears* and any constraint on it — never restate the English.
- Every placeholder needs an explicit `type` and an `example`. An untyped
  placeholder silently becomes `Object` and breaks `plural`/`select`.

### Codegen

`flutter gen-l10n` is **not** part of `stacked generate`, and `flutter test`
does not run it either — which is why the generated output under
`lib/l10n/generated/` is committed like every other generated file here. The
full recipe:

```bash
flutter gen-l10n && stacked generate && dart format .
```

gen_l10n formats its own output, so the generated l10n cannot break
`dart format --set-exit-if-changed`; the trailing `dart format .` is for the
`stacked generate` output.

### Directional layout

Use `EdgeInsetsDirectional`/`AlignmentDirectional` in `lib/ui/**` and
`lib/features/**`. `CrossAxisAlignment.start` is already direction-aware and
needs no change. `lib/templates/**` is exempt — it renders the PDF, which is
always LTR, and `package:pdf` has no `Directionality` inheritance anyway.

### While extracting strings

**A sweep PR changes zero rendered characters.** The ARB's English value is a
character-for-character copy of the literal it replaces, so the 7 golden
baselines stay valid and the diff is provably behaviour-preserving. Copy
improvements are a separate PR.

**The app ships `en` and `es`.** Both `lib/l10n/app_en.arb` and
`lib/l10n/app_es.arb` must stay complete: `flutter gen-l10n` does *not* fail
on a missing key — it silently falls back to the English value — so
`lib/l10n/untranslated_messages.json` is the only signal, and it must stay
`{}`. It is committed for exactly that reason.

That also means a new string is now **two** edits, not one. While `en` was the
only locale a not-yet-extracted string was invisible; it isn't any more.

## Testing: outside-in only

This project follows Stacked's outside-in testing approach. Test through the
public behavior of a ViewModel or Service, not through hand-written unit
tests of private helpers or implementation details.

- **Do not write unit tests for individual functions/methods in isolation**
  unless the user explicitly asks for one. Default to no test coverage over
  writing a unit test that wasn't asked for.
- When a test is warranted, it should exercise a ViewModel (or Service)
  through its public API — call the methods a View would call, assert on the
  resulting state/properties — with its dependencies mocked via the
  generated test helpers (`stacked create service` and `stacked create view`
  both scaffold matching entries in `test/helpers/test_helpers.dart` and a
  stub test file). Use `mockito` mocks for services, not real
  implementations, so the test isolates the unit under test at the
  ViewModel/Service boundary rather than at the method boundary.
- Golden tests (already set up via `golden_toolkit` under `test/golden/`)
  follow the same philosophy at the View level — they verify rendered output
  for a given ViewModel state, not internal widget implementation details.
- If asked to "test" a change without further detail, default to an
  outside-in ViewModel/Service test (or a golden test for a View change),
  not a unit test.
- **Golden tests must call `registerServices()`**, not a hand-picked subset
  of `getAndRegister*` calls. A View pulls in every service its ViewModel's
  constructor resolves; a partial setup crashes at widget-build time rather
  than failing a pixel comparison, and `--update-goldens` does not catch it.
- **Golden tests are tagged `@Tags(['golden'])`** and baselined on
  `ubuntu-latest` (see `update-goldens.yml`) — font rasterization differs by
  platform, so they show a small pixel diff on a non-Linux dev machine even
  with no real change. Run `flutter test --exclude-tags=golden` locally for
  a signal that's actually green; `ci.yml`'s plain `flutter test` on Linux
  is what verifies them for real on every PR. Run `flutter test
  --tags=golden` to check just these before pushing a deliberate UI change,
  or trigger `update-goldens.yml` to regenerate the baselines afterward.
- **Carve-out: pure geometry/math helpers and paint-invalidation
  invariants may be unit-tested directly** — e.g.
  `test/models/ats/ats_matrix_math_test.dart` (matrix composition, box
  rotation) and `test/features/analyzer/widgets/ats_xray_painter_test.dart`
  (`shouldRepaint` identity checks). These have no ViewModel or Service
  above them to test through, and routing them through
  `AnalyzerViewModel` would exercise less of the actual logic while
  costing more per test. The outside-in rule still holds for anything one
  layer up from these — a ViewModel/Service method is never unit-tested
  in isolation just because it happens to call one of these helpers.

## Code style

Each of these was a real mistake in this repo, not hypothetical:

- **State a cross-cutting rationale once.** Document an invariant in the file
  that owns it and reference that file elsewhere. The same explanation
  restated in four files rots in four places.
- **No plan/phase numbers (`P1.6`) or schedule references in code comments.**
  They're stale as soon as the plan moves on. Describe the gap, not when it
  gets filled.
- **Comments explain why, not what.** `// --- experiences ---` style banners
  usually mean the file wants splitting instead.
- **Never fire-and-forget a write of user data.** `unawaited(...)` on a
  persistence call silently loses data; surface the failure.
- **No production API that only tests call.** If a method exists solely so a
  test can force something, wire it into a real call site or delete it.
- **Responsive variants (`*.desktop/.tablet/.mobile.dart`) that differ only
  in constants share one widget** parameterised by those constants, rather
  than three copies of the same tree.
- **One naming convention per widget shape.** A summary card and its editor
  panel are `foo_editor_card.dart` + `foo_editor_panel.dart` — don't mix
  "card"/"section"/"list_section" for the same concept, and don't put a
  150-line panel in a file named `..._card.dart`.
- **An import that reaches outside its own directory (`../`) uses
  `package:cv_forge/...`, not a relative path.** A same-directory sibling
  import (`import 'foo.dart';`) is fine either way — this is specifically
  about not mixing `../../models/...` and `package:cv_forge/models/...`
  for the same import in different files. Not enforced by a lint
  (`always_use_package_imports` would also flag same-directory imports,
  which are idiomatic and common here) — this is a convention to follow by
  hand, not a rule `flutter analyze` checks.
- **Chrome UI spacing, radius, typography, and motion go through
  `lib/ui/common/tokens/`, never a restated literal.** `AppSpacing`/
  `AppRadius`/`AppTypography`/`AppMotion` are `ThemeExtension`s registered
  on `buildAppTheme()`, reachable as `context.appSpacing`/
  `context.appRadius`/`context.appTypography`/`context.appMotion`;
  `ui_helpers.dart`'s `VGap`/`HGap` cover sibling-spacing gaps the same
  way. A new `fontSize:`, `BorderRadius.circular(<n>)`, or
  `EdgeInsets.only(<n>)` in `lib/ui/**` or `lib/features/**` should reuse
  one of these, not restate the number. If a value genuinely doesn't fit
  the existing scale, that's a sign a new named field belongs in
  `tokens/`, not a reason to inline it — the CV document's own type/rule
  scale (`lib/templates/design/CvDesignTokens`) is the precedent for that:
  a deliberately separate system, but never raw numbers scattered through
  renderer code. This convention is what a `stacked create widget`
  scaffold won't set up for you, since the CLI has no way to know a given
  double is meant to be a spacing/radius value rather than an arbitrary
  layout constant.

## General AI-development practices for this repo

- Always run `stacked generate` after generation-affecting edits, before
  compiling, testing, or declaring a change complete.
- Prefer editing the Stacked-generated files in place (View, ViewModel,
  Service, etc.) over restructuring the generated scaffolding.
- Keep business/UI logic in the ViewModel, not the View — Views should stay
  declarative and delegate actions to the bound ViewModel.
- When adding a new dependency between a View and a Service, add the Service
  via `stacked create service` first so it's registered in the locator before
  you reference it in a ViewModel.
- Don't manually add `// @stacked-*` marker comments or route/DI wiring by
  hand — those are inserted and maintained by the CLI. If wiring looks wrong,
  fix it via the CLI (e.g. regenerate) rather than editing the markers
  directly.
- **If a Dart MCP server (`dart mcp-server`) is connected, prefer its native
  tools** — `hot_reload`/`hot_restart`, `run_tests`, `analyze_files`,
  `dart_format`, `dtd` — over shelling out to `flutter`/`dart` directly.
  It's faster (no cold-start per invocation, real hot reload against a
  running app instead of killing/restarting a dev server) and avoids a
  Windows-specific gotcha in some sandboxed shells: `dart` internally shells
  out to `WHERE` and `PowerShell.exe` (both in `C:\Windows\System32`), which
  some Bash tool environments strip from `PATH` by default, silently
  breaking `dart`/`flutter`/`stacked` invocations. A project-scoped
  `.mcp.json` configuring this server (not checked in — it's inherently
  machine-specific: absolute SDK path, `PATH` env fixup) is a reasonable
  one-time local setup step if it isn't already present.
