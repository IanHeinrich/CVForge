// Dev-only: serves `build/web` with the SPA fallback GitHub Pages gets from
// 404.html, so a refresh on a deep path (/vault, /studio) loads the app
// instead of 404ing. Not part of the app or the test suite.
//
//   flutter build web --release && node tool/serve_web.mjs
import http from 'http';
import fs from 'fs';
import path from 'path';

const ROOT = path.resolve('build/web');
const PORT = Number(process.env.PORT ?? 8088);

const TYPES = {
  // .mjs matters: the preview pane's PDF rasterizer is pdfjs/pdf.min.mjs, and
  // a module script served as octet-stream is rejected outright by strict MIME
  // checking, so the preview spins for ever with no error in the app itself.
  '.html': 'text/html', '.js': 'application/javascript', '.json': 'application/json',
  '.mjs': 'application/javascript',
  '.wasm': 'application/wasm', '.png': 'image/png', '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml', '.ttf': 'font/ttf', '.otf': 'font/otf',
  '.ico': 'image/x-icon', '.map': 'application/json', '.symbols': 'text/plain',
};

if (!fs.existsSync(path.join(ROOT, 'index.html'))) {
  console.error(`No build at ${ROOT} — run: flutter build web --release`);
  process.exit(1);
}

http.createServer((req, res) => {
  const urlPath = decodeURIComponent((req.url ?? '/').split('?')[0]);
  let file = path.join(ROOT, urlPath);
  // Keep the resolved path inside ROOT, then fall back to index.html for
  // anything that is not a real file — that is what makes client-side
  // routing survive a refresh, exactly as web/404.html does on Pages.
  if (!file.startsWith(ROOT) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    file = path.join(ROOT, 'index.html');
  }
  res.writeHead(200, { 'Content-Type': TYPES[path.extname(file)] ?? 'application/octet-stream' });
  fs.createReadStream(file).pipe(res);
}).listen(PORT, () => console.log(`CVForge on http://localhost:${PORT}`));
