---
name: run-app
description: Launch CVForge in a browser and drive it, on Linux/headless (CI containers, Claude Code sessions). Use when asked to run the app, screenshot a screen, or verify a UI change in the real app rather than in tests — in particular for anything under lib/features/studio/widgets/, which has no golden coverage and which the PR template requires be checked in a browser.
---

# Running CVForge

Flutter Web, CanvasKit renderer. `flutter test` does not cover
`lib/features/studio/widgets/**` — the PR template asks for a browser
check there, and this is how to do it without a display.

## The short version

```bash
flutter build web --release          # ~75s
node tool/serve_web.mjs              # http://localhost:8088
```

Then drive it with Playwright (globally installed; see the driver below).
**Do not** use `python3 -m http.server` — see *SPA fallback*.

## Four things that will bite you

Two are fixed in the app now and are here so nobody re-diagnoses them.
Two are live.

### 1. CanvasKit and Roboto — fixed, don't re-break

The app used to fetch CanvasKit and Roboto from `gstatic.com`, which most
locked-down containers block. Both are local now:

- `web/index.html` sets `canvasKitBaseUrl: 'canvaskit/'` in the loader
  config. `flutter build web` already copies those bytes into `build/web`.
- `pubspec.yaml` registers the bundled Roboto under `fonts:`, so CanvasKit
  finds it in the asset manifest.

If the app hangs on the anvil splash and the console shows
`ERR_TUNNEL_CONNECTION_FAILED` for `gstatic.com`, one of those two
regressed. Fix the config; do not re-add a proxy workaround.

### 2. Emoji still reaches the network — live

`RegionPreset.flags` is emoji, and CanvasKit downloads Noto Color Emoji
for any glyph no embedded font covers. So a screen showing a region flag
(Vault list, CV-defaults panel, region gallery, drafts cards) still hits
`fonts.gstatic.com`. Flags render as tofu boxes when that is blocked;
everything else is unaffected. Closing it means bundling a ~10MB emoji
font or drawing the flags as assets — neither has been done.

**Do not assert "no third-party requests" without excluding this one.**

### 3. Locale — live, and it white-screens

Headless Chromium with no explicit locale reports
`navigator.language = "en-US@posix"`. Flutter's engine feeds that to the
JS `Intl.Locale` constructor, which throws `RangeError: Incorrect locale
information provided` before `main()` finishes. You get a splash that
never resolves and one `pageerror`.

This is upstream in the engine, not app code —
`LocalizationService._resolve` already uses `basicLocaleListResolution`,
which never throws. Real browsers always send a valid BCP-47 tag, so it
is not worth coding around; just **always pass a locale**:

```js
await browser.newContext({ locale: 'en-GB', timezoneId: 'Europe/London' })
```

`"C"` fails the same way. `"en-US"` is fine.

### 4. SPA fallback — live

`main.dart` calls `usePathUrlStrategy()`, so after boot the URL is
`/vault`, not `/`. A plain static server 404s that on refresh. On Pages,
`web/404.html` handles it; locally, `tool/serve_web.mjs` does the same by
falling back to `index.html`.

You will hit this on the reload in step 3 of the driver, not on first
load — which makes it look like the app broke rather than the server.

## Driving it

Playwright is installed globally, not in the repo. From a scratch dir:

```bash
mkdir -p /tmp/drv && cd /tmp/drv
ln -sfn "$(npm root -g)" node_modules
```

```js
import { chromium } from 'playwright';

const b = await chromium.launch({
  args: ['--no-sandbox', '--enable-unsafe-swiftshader'],  // no GPU in a container
});
const ctx = await b.newContext({
  viewport: { width: 1500, height: 1000 },
  locale: 'en-GB',            // required — see gotcha 3
});
const p = await ctx.newPage();
p.on('pageerror', e => console.log('PAGEERROR', String(e).slice(0, 200)));

await p.goto('http://localhost:8088/', { waitUntil: 'load' });
await p.waitForTimeout(4000);
await p.reload({ waitUntil: 'load' });   // first launch usually needs one refresh
await p.waitForTimeout(13000);           // CanvasKit + first frame is slow here
await p.screenshot({ path: 'shot.png' });
```

**Look at the screenshot.** A splash with the anvil on it is a failure to
boot, not a slow frame.

### Clicking things

Flutter paints to a canvas, so there is no DOM to select by default.
Switch on the semantics tree first:

```js
await p.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
await p.waitForTimeout(2500);
```

After that `p.getByText('Load example CV').click()` works. Two caveats:

- Labels land in `textContent`, not always `aria-label`, and nav items
  carry a suffix — the rail reads `"CVs\nTab 2 of 3"`, so `getByText('CVs',
  {exact: true})` finds nothing.
- When a selector will not resolve, click coordinates instead. At
  1500x1000 the rail is Vault `(41, 29)`, CVs `(41, 85)`, ATS `(41, 141)`.

### A route to the Studio editors

The surface the PR template actually cares about:

```js
await p.getByText('Load example CV').click();   // Vault empty state
await p.waitForTimeout(4000);
await p.mouse.click(41, 85);                    // CVs
await p.waitForTimeout(4000);
await p.mouse.click(207, 226);                  // the first CV card
await p.waitForTimeout(12000);                  // Studio + PDF preview
```

Studio's preview pane rasterizes the real exported PDF, so if it renders,
export does too.

## Checking the PDF instead

For a template or renderer change, skip the browser —
`tool/render_photo_samples.dart` writes real PDFs to `build/photo_samples`:

```bash
flutter test tool/render_photo_samples.dart
pip install pymupdf   # then rasterize a page to look at it
```

That is the faster loop for anything under `lib/templates/**`.
