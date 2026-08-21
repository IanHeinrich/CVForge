# Phase 7 — Interface work

Eight workstreams from the August 2026 UI/UX review, one file each.
They are ordered so that each one makes the next cheaper, but most are
independent and can land in any order or in parallel.

| # | Workstream | Bump | Depends on |
|---|---|---|---|
| [7.1](7.1-elevation-ramp.md) | Surface elevation ramp | patch | — |
| [7.2](7.2-skills-chips.md) | Grouped chip skill selection | minor | — |
| [7.3](7.3-preview-fit-and-page-count.md) | Preview fit + page count | minor | — |
| [7.4](7.4-studio-restructure.md) | Studio document bar + master–detail | minor | 7.1, 7.2, 7.3 |
| [7.5](7.5-template-region-scaling.md) | Template gallery + region data | minor | 7.4 |
| [7.6](7.6-logo.md) | Logo, favicon, splash | patch | — |
| [7.7](7.7-settings.md) | Settings page + backup state | minor | 7.1 (soft) |
| [7.8](7.8-vault.md) | Vault date correctness + placement | **patch, urgent** | — |

## Two of these are not cosmetic

Most of this phase is interface work that can wait. Two items are not:

- **7.8's date fields** silently discard invalid input, leaving the UI
  showing one value while the model holds another, and can persist a
  wrong month mid-edit. That is a data-correctness bug in the app's
  master record, found by reading the source rather than using the
  screen.
- **7.6's `manifest.json`** is invalid JSON and has been shipping that
  way. Browsers ignore an unparseable manifest wholesale, so every PWA
  affordance is currently off. One line.

Both are small, both are independent of everything else here, and
neither should queue behind a layout change.

**7.7's backup state** is the third one worth reading early — not a bug,
but the app keeps everything in browser storage with no record of
whether a backup was ever taken. That combination is only comfortable
while the data is disposable.

## Why these are separate files, not a `plan.md` phase

`plan.md` is the shipped-history document — each sub-phase there is a
spec that grows an "Actually shipped" annotation once it lands. These
eight are pre-spec: they carry the review's findings, the decisions
taken in response, and enough detail to execute. When one ships,
summarise it into `plan.md` as a `### 7.N` entry with its PR link, the
way every earlier phase records itself, and leave the file here as the
long-form rationale.

## Conventions these files follow

Same as `plan.md` — `##`/`###` only, identifiers in backticks, decisions
recorded as a table with rationale, prose hard-wrapped at ~72 columns,
and a `## Verification` section naming the actual commands rather than
describing testing in the abstract.

Two claims are kept deliberately distinct throughout, because the review
that produced these files got value from the distinction: **confirmed**
means read in the source or observed in the running app, **inferred**
means reasoned from surrounding code and not yet checked. Anything
marked inferred is a spike, not a step.

## The one cross-cutting hazard

Golden baselines. There are five, in `test/golden/goldens/`, and all
five pump their View wrapped in `AppChrome` — so **any** change to
`app_colors.dart`, `buildAppTheme()` or the token layer re-baselines all
of them. `update-goldens.yml` is `workflow_dispatch` only, uploads the
PNGs as an artifact, and does not commit them; download and commit them
in the same PR as the change, never after. This is exactly the trap
Phase 4.1 recorded, and 7.1 walks straight into it.

There is no golden coverage for `StudioView` or for any widget under
`lib/features/studio/widgets/` — so 7.2, 7.3 and 7.4, the largest
visual changes here, have **zero** pixel coverage and must be verified
in the browser. Each file says how. 7.7 and 7.8, by contrast, both
touch golden-covered Views (`SettingsView`, `VaultView`) — expect real
baseline diffs there, not just a browser check.
