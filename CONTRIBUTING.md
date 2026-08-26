# Contributing to CVForge

Thanks for taking a look. This document covers how to get set up, the
conventions this codebase actually enforces, and what CI will check.

Most of the rules below exist because something went wrong once. Where that is
true, the reasoning is recorded rather than just the rule — if a convention
looks arbitrary, the "why" is usually one line away in
[CLAUDE.md](CLAUDE.md), which is the exhaustive version of this file.

---

## Table of contents

- [Getting set up](#getting-set-up)
- [The one hard rule: use the Stacked CLI](#the-one-hard-rule-use-the-stacked-cli)
- [Where code goes](#where-code-goes)
- [Models: freezed and codegen](#models-freezed-and-codegen)
- [Testing](#testing)
- [Golden tests, and the trap in them](#golden-tests-and-the-trap-in-them)
- [Code style](#code-style)
- [Before you open a PR](#before-you-open-a-pr)
- [Commits and pull requests](#commits-and-pull-requests)
- [Reporting bugs](#reporting-bugs)

---

## Getting set up

```bash
git clone https://github.com/IanHeinrich/CVForge.git
cd CVForge
flutter pub get
flutter run -d chrome
```

You will also want the Stacked CLI, which is not optional here:

```bash
dart pub global activate stacked_cli
```

No environment variables or API keys are needed. The two optional
integrations (AI tailoring, Google Drive sync) stay off until configured in
Settings, and everything else works without them.

---

## The one hard rule: use the Stacked CLI

**Views, ViewModels, Services, Widgets, BottomSheets and Dialogs must be
created with the `stacked` CLI, never written by hand.**

The CLI maintains route registration, locator (DI) registration and test
scaffolding through `// @stacked-*` marker comments in `lib/app/app.dart` and
`test/helpers/test_helpers.dart`. Hand-writing these files skips that wiring
and drifts from the generated conventions.

| What you want | Command |
|---|---|
| A screen (View + ViewModel + route) | `stacked create view <name>` |
| A service (+ DI registration) | `stacked create service <name>` |
| A reusable widget | `stacked create widget <name>` |
| A bottom sheet | `stacked create bottom_sheet <name>` |
| A dialog | `stacked create dialog <name>` |
| Run all code generation | `stacked generate` |

Useful flags: `--no-model` on `widget`/`dialog`/`bottom_sheet` skips the
companion model class; `--exclude-route` skips route registration;
`--exclude-dependency` skips locator registration.

Run every command from the repo root, where `stacked.json` lives.

Do **not** hand-edit the `// @stacked-*` markers, or any `*.g.dart` /
`*.freezed.dart` file. Those are generated output and will be overwritten.

### Scaffolding into a feature folder

`stacked create view/dialog/bottom_sheet` have no `--path` flag, so
feature-scoped generation uses a per-feature config passed with `-c`:

```bash
stacked create view login -c stacked_configs/vault.json
```

`stacked_configs/<feature>.json` is a copy of the root `stacked.json` with
only the view/widget/dialog/bottom_sheet paths repointed under that feature.
Services, routing and test helpers stay pointed at their global locations.
Copy an existing one when adding a feature.

---

## Where code goes

This project is organised **package-by-feature, not package-by-layer**.

```
lib/features/<feature>/     Views, dialogs, feature-specific widgets
lib/services/               ALWAYS global, even if only one feature uses it
lib/models/                 Pure Dart. Must never import flutter or pdf.
lib/templates/              One pdf renderer per template + design tokens
lib/ui/common/              Genuinely shared: theme, tokens, helpers
lib/ui/widgets/common/      Widgets used by 2+ features
lib/app/                    Routing and DI. Centralised by Stacked's design.
```

Two things stay global no matter what:

- **Services**, per the root `stacked.json`. Do not move a service into a
  feature folder even if only that feature currently uses it.
- **Routing and DI wiring.** Vertical slicing here is about where source files
  live, not about splitting Stacked's `@StackedApp` wiring.

Only move something into a feature folder once it is genuinely
feature-specific. Do not pre-emptively shard shared code.

### Two boundaries that matter

**`lib/models/` must never import `flutter` or `pdf`.** It is pure Dart.
`render/cv_composer.dart` is the only place Vault and Draft data are joined.

**`lib/templates/` is the single-renderer boundary.** A template owns exactly
one `pdf` renderer, and Studio's live preview rasterises that same PDF rather
than maintaining a second Flutter render tree — so preview and export cannot
drift on content *or* pixels.

If you write a template, read the pagination section of
[CLAUDE.md](CLAUDE.md) first. Splitting a CV across pages in `package:pdf` has
several traps that look like package limitations and are not:

- `buildDocument` must hand `pw.MultiPage.build` a **flat `List<pw.Widget>`**,
  never a single wrapping `pw.Column` — a `pw.Column` root cannot split across
  pages, so everything silently overflows onto page 1.
- A `pw.Column` nested inside another does not reliably split either.
- Bullets only genuinely split across a page break when each is its own
  top-level `pw.MultiPage` widget.

`templates/design/section_pagination_pdf.dart` is the one place this is solved
correctly. Route every heading-plus-items group through `assembleSectionWidgets`
rather than building your own nested `pw.Column`.

---

## Models: freezed and codegen

Every data model — DTOs, payloads, immutable app state — should be a
`@freezed` class, not a hand-written class with manual
`copyWith`/`==`/`hashCode`.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'foo.freezed.dart';
part 'foo.g.dart'; // only if it needs JSON

@freezed
abstract class Foo with _$Foo {
  const factory Foo({
    required String id,
    String? name,
  }) = _Foo;

  factory Foo.fromJson(Map<String, dynamic> json) => _$FooFromJson(json);
}
```

- Use multiple factory constructors for union/sealed state rather than enums
  plus nullable fields. Prefer Dart 3 `switch` expressions over
  `.when()`/`.map()` in new code.
- Use `@unfreezed` only when a class genuinely needs mutable fields.
- Reach for plain `@JsonSerializable()` only for things that are not domain
  models — e.g. a thin wrapper for parsing a third-party response you map
  straight into a `@freezed` type.

**After adding or editing any annotated class, run `stacked generate` before
writing code that depends on it** — `copyWith` and `fromJson` do not exist
until generation has run.

```bash
stacked generate
dart format .
```

**Always run `dart format .` immediately after `stacked generate`.** Generated
output (freezed 3.x especially) is not always format-clean, and
`dart format --set-exit-if-changed .` failing on generated files is this
repo's single most common CI failure.

---

## Testing

This project follows Stacked's **outside-in** testing approach. Test through
the public behaviour of a ViewModel or Service, not through implementation
details.

- **Do not write unit tests for individual functions or private helpers**
  unless there is a specific reason. Default to no coverage over a unit test
  nobody asked for.
- When a test is warranted, exercise a ViewModel or Service through its public
  API — call what a View would call, assert on the resulting state — with
  dependencies mocked via the generated helpers in
  `test/helpers/test_helpers.dart`. Use `mockito` mocks, not real
  implementations.
- Golden tests apply the same philosophy at the View level: they verify
  rendered output for a given ViewModel state.

**Carve-out:** pure geometry/maths helpers and paint-invalidation invariants
may be unit-tested directly — see `test/models/ats/ats_matrix_math_test.dart`
and `test/features/analyzer/widgets/ats_xray_painter_test.dart`. These have no
ViewModel above them, and routing them through one would exercise less logic
for more cost. The outside-in rule still holds one layer up.

```bash
flutter test --exclude-tags=golden
```

---

## Golden tests, and the trap in them

Golden baselines live in `test/golden/goldens/` and are **baselined on
`ubuntu-latest`**. Font rasterisation differs by platform, so they show a
small pixel diff on a macOS or Windows dev machine *even with no real change*.

- `flutter test --exclude-tags=golden` is the signal that is actually green
  locally.
- `flutter test --tags=golden` checks just these, before pushing a deliberate
  UI change.
- CI's plain `flutter test` on Linux is what verifies them for real.

**Do not commit locally-generated baselines.** Dispatch the
[`update-goldens.yml`](.github/workflows/update-goldens.yml) workflow against
your branch; it regenerates the PNGs on Linux and commits them back to that
branch itself. Then `git pull`. They belong **in the same PR as the change that
caused them** — never a follow-up.

Two wrinkles, both worth knowing before you rely on this:

- **The bot's push does not re-run CI.** GitHub suppresses workflow runs for
  pushes made with the default `GITHUB_TOKEN`, so the new head commit arrives
  with no checks against it at all. **Close and reopen the PR** — that fires
  `reopened` and runs CI fresh. Re-running the previous CI run does not work;
  it replays the old commit. (This is a genuine cost of the automation: the
  push you used to make by hand *did* trigger CI. It buys you never touching a
  PNG, at the price of one extra click.)
- **`--update-goldens` never fails.** It rewrites baselines instead of
  comparing them, so it will bless a rendering regression exactly as happily as
  an intended change, and the next CI run then compares against that new,
  wrong baseline and passes. Nothing catches this but your eyes: review the
  image diff on the PR. GitHub gives you a swipe/onion-skin view, and
  `*.png binary` in `.gitattributes` keeps the bytes exact.

A new golden test must carry `@Tags(['golden'])`. That tag is now the only
selector both the `Golden` job and `update-goldens.yml` use, so an untagged
golden still runs in CI but can never be re-baselined by the workflow.

Two more things worth knowing:

- **Golden tests must call `registerServices()`**, not a hand-picked subset of
  `getAndRegister*` calls. A View pulls in every service its ViewModel's
  constructor resolves, and a partial setup crashes at widget-build time
  rather than failing a pixel comparison — which `--update-goldens` will not
  catch.
- Any change to `app_colors.dart`, `buildAppTheme()` or the token layer
  re-baselines **all** of them, because every golden pumps its View wrapped in
  `AppChrome`.

There is no golden coverage for `StudioView` or anything under
`lib/features/studio/widgets/`. Changes there must be verified in the browser.

---

## Code style

Each of these was a real mistake in this repo, not a hypothetical.

- **State a cross-cutting rationale once.** Document an invariant in the file
  that owns it and reference that file elsewhere. The same explanation
  restated in four files rots in four places.
- **No plan or phase numbers in code comments.** They are stale as soon as the
  plan moves. Describe the gap, not when it gets filled.
- **Comments explain why, not what.** `// --- experiences ---` banners usually
  mean the file wants splitting.
- **Never fire-and-forget a write of user data.** `unawaited(...)` on a
  persistence call silently loses data. Surface the failure.
- **No production API that only tests call.** If a method exists solely so a
  test can force something, wire it into a real call site or delete it.
- **Responsive variants that differ only in constants share one widget**,
  parameterised by those constants — not three copies of the same tree.
- **One naming convention per widget shape.** A summary card and its editor
  panel are `foo_editor_card.dart` and `foo_editor_panel.dart`. Do not mix
  "card"/"section"/"list_section" for the same concept.
- **Imports that reach outside their own directory use
  `package:cv_forge/...`, not `../`.** Same-directory sibling imports are fine
  either way. This is a convention, not a lint.
- **Spacing, radius, typography and motion go through
  `lib/ui/common/tokens/`.** `AppSpacing`, `AppRadius`, `AppTypography` and
  `AppMotion` are `ThemeExtension`s reachable as `context.appSpacing` and so
  on; `ui_helpers.dart`'s `VGap`/`HGap` cover sibling spacing. A new
  `fontSize:`, `BorderRadius.circular(<n>)` or `EdgeInsets.only(<n>)` in
  `lib/ui/**` or `lib/features/**` should reuse one of these.

  If a value genuinely does not fit the scale, that is a sign a new named
  field belongs in `tokens/` — not a reason to inline the number. The CV
  document's own scale (`lib/templates/design/CvDesignTokens`) is the
  precedent: a deliberately separate system, but never raw numbers scattered
  through renderer code.

Keep business and UI logic in the ViewModel. Views stay declarative and
delegate to the bound ViewModel.

---

## Before you open a PR

CI runs exactly these, on `ubuntu-latest`, against every PR to `main` — as
three parallel jobs rather than one serial one, so a golden failure is
immediately distinguishable from a logic failure:

```bash
# job: Format & analyze
dart format --output=none --set-exit-if-changed .
flutter analyze

# job: Test
flutter test --exclude-tags=golden

# job: Golden
flutter test --tags=golden
```

Run them locally first. The golden baselines are still verified on every PR, so
if you changed anything visual, sort them out first (see above). When the
`Golden` job fails it attaches a `golden-failures` artifact with the diff
images, which is usually faster than reasoning about what moved.

One thing CI does not check: `web/manifest.json` is not validated by any of
the three, which is how a malformed one shipped once. If you touch it:

```bash
python -c "import json;json.load(open('web/manifest.json'));print('ok')"
```

---

## Commits and pull requests

- Branch off `main`.
- Keep a PR to one coherent change. A logo redraw and a routing refactor are
  two PRs.
- Write a description that says **why**, not just what. The diff already says
  what.
- If the change is visual and has no golden coverage, say how you verified it
  in the browser.
- Bump `version:` in `pubspec.yaml` if the change should deploy —
  `deploy.yml` looks for a version bump to decide whether to publish and tag.
  That one edit is the whole release: `lib/app/app_version.dart` is
  generated from it by `build_version`, so run `stacked generate` after
  bumping and commit the result. It used to be two literals kept in step by
  a test, and a merge that missed the second shipped a bundle stamped with
  the previous version.

---

## Reporting bugs

Open an issue with:

- What you expected, and what happened instead
- Steps to reproduce
- Browser and OS
- Anything from the browser console

Because everything is stored locally, a bug report will rarely contain data
that is useful to anyone else — **please do not paste your Vault contents into
an issue.** A redacted screenshot or a JSON export with the personal details
removed is plenty.

For anything that looks like a security or privacy issue — particularly around
the AI or Drive integrations — please raise it privately via GitHub's security
advisories rather than a public issue.
