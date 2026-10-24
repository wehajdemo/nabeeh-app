// Regenerates admin/legal/*.html from assets/legal/legal.json.
//   node scripts/build-legal.mjs            write the pages
//   node scripts/build-legal.mjs --check    fail if a page is out of date
//   node scripts/build-legal.mjs --release  also fail if placeholders remain
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { DOCS, LANGS, fileName, releaseBlockers, renderHtml } from '../legal/render.mjs';

const source = new URL('../../assets/legal/legal.json', import.meta.url);
const outDir = new URL('../legal/', import.meta.url);
const legal = JSON.parse(readFileSync(source, 'utf8'));
const args = new Set(process.argv.slice(2));

let stale = 0;
for (const name of DOCS) {
  for (const lang of LANGS) {
    const file = new URL(fileName(name, lang), outDir);
    const html = renderHtml(legal, name, lang);
    if (args.has('--check')) {
      let current = '';
      try { current = readFileSync(file, 'utf8'); } catch { /* missing */ }
      if (current !== html) {
        stale++;
        console.error(`out of date: legal/${fileName(name, lang)}`);
      }
    } else {
      mkdirSync(outDir, { recursive: true });
      writeFileSync(file, html);
      console.log(`wrote legal/${fileName(name, lang)}`);
    }
  }
}

const blockers = releaseBlockers(legal);
if (args.has('--release') && blockers.length > 0) {
  for (const problem of blockers) console.error(`release blocker: ${problem}`);
  process.exit(1);
}
if (stale > 0) process.exit(1);
if (blockers.length > 0 && !args.has('--check')) {
  console.warn('\nBefore publishing, fill in:');
  for (const problem of blockers) console.warn(`  - ${problem}`);
}
