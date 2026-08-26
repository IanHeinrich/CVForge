<!--
Thanks for the PR. Keep it to one coherent change where you can — the smaller
it is, the faster it lands.
-->

## What and why

<!-- The diff already says what changed. Say why it needed to. -->

## How it was verified

<!--
Tick what you ran. CI re-runs all of this on Linux against every PR, as three
parallel jobs: Format & analyze, Test, and Golden.
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
PNGs — dispatch the update-goldens.yml workflow against THIS branch and it
commits them for you; then pull. Sort them out in this PR, not a follow-up.

That bot push does NOT re-trigger CI (GitHub suppresses workflow runs for
pushes made with GITHUB_TOKEN), so the new commit lands with no checks against
it. Close and reopen this PR to run CI on the new baselines — re-running the
old CI run replays the old commit and will not work.

And review the image diff. `--update-goldens` rewrites baselines without
comparing, so it accepts a rendering regression exactly as readily as an
intended change; no human has looked at that PNG before you.

A new golden test must carry `@Tags(['golden'])`. The tag is the only selector
both CI and update-goldens use, so an untagged one can never be re-baselined
by the workflow.
-->

- [ ] No golden baselines affected
- [ ] Baselines regenerated via `update-goldens.yml`, pulled in, and the image
      diff reviewed

## Anything else

<!--
Trade-offs you made, alternatives you rejected, things you are unsure about,
follow-up work you deliberately left out.
-->
