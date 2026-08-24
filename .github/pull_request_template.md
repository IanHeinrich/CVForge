<!--
Thanks for the PR. Keep it to one coherent change where you can — the smaller
it is, the faster it lands.
-->

## What and why

<!-- The diff already says what changed. Say why it needed to. -->

## How it was verified

<!--
Tick what you ran. CI runs format, analyze and test on Linux against every PR.
-->

- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `flutter analyze`
- [ ] `flutter test --exclude-tags=golden`
- [ ] Checked in the browser (required for anything under
      `lib/features/studio/widgets/`, which has no golden coverage)

## Goldens

<!--
Delete this section if the change is not visual.

Baselines are generated on ubuntu-latest. Do not commit locally-generated
PNGs — run the update-goldens.yml workflow, download the artifact, and commit
those in THIS PR rather than a follow-up.
-->

- [ ] No golden baselines affected
- [ ] Baselines regenerated via `update-goldens.yml` and committed here

## Anything else

<!--
Trade-offs you made, alternatives you rejected, things you are unsure about,
follow-up work you deliberately left out.
-->
