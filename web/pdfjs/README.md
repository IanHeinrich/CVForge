# Vendored `pdf.js` 5.7.284 (patched)

`pdf.min.mjs` and `pdf.worker.min.mjs` are the stock Mozilla `pdf.js`
5.7.284 build (see `web/index.html`'s `dartPdfJsBaseUrl` and
`third_party/printing/README.md` for why this is vendored locally instead
of loaded from `unpkg.com`), with one hand-applied patch on top.

## Patch: `Map.prototype.getOrInsertComputed` polyfill

Both files call the TC39 ["Upsert" proposal](https://github.com/tc39/proposal-upsert)
methods `Map.prototype.getOrInsert` / `Map.prototype.getOrInsertComputed`
(used by `pdf.js`'s internal `MessageHandler` to memoize per-id callback
maps). Chrome/V8 and Firefox ship these; Safari/JavaScriptCore does not
(as of the Safari versions available when this was diagnosed), so loading
either bundle in Safari throws immediately:

```
NoSuchMethodError: method not found: 'getOrInsertComputed'
(this.#pr.getOrInsertComputed is not a function)
```

— and PDF preview/rasterization never renders in Safari at all (Studio's
live preview, and PDF-import in the ATS analyzer, both go through this).

The fix is a small polyfill prepended to each file, right after the
license header and before any other code runs:

```js
if (!Map.prototype.getOrInsert) {
  Map.prototype.getOrInsert = function (key, value) {
    if (this.has(key)) return this.get(key);
    this.set(key, value);
    return value;
  };
}
if (!Map.prototype.getOrInsertComputed) {
  Map.prototype.getOrInsertComputed = function (key, callbackfn) {
    if (this.has(key)) return this.get(key);
    var value = callbackfn(key);
    this.set(key, value);
    return value;
  };
}
```

It's a no-op (guarded by `if (!Map.prototype...)`) once a browser ships
these methods natively, so it's safe to leave in place rather than
removing it the moment Safari catches up.

It has to live in *both* files, not just `pdf.min.mjs`: `pdf.worker.min.mjs`
runs in a Web Worker, a separate JS realm with its own `Map.prototype`, so
a polyfill applied only on the main thread (e.g. in `web/index.html`)
would not reach the worker.

## Re-vendoring

If `pdf.js` is ever bumped to a newer version, re-download the two
`.min.mjs` files and re-apply this same polyfill snippet at the top of
each (right after the `/** ... */` license/version header, before the
first real statement) — check first whether the newer version still needs
it, i.e. whether Safari has shipped the Map-upsert methods by then.
