import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import { DOCS, LANGS, fileName, renderHtml, resolveDocument } from '../legal/render.mjs';

const read = (rel) => readFileSync(new URL(rel, import.meta.url), 'utf8');
const legal = JSON.parse(read('../../assets/legal/legal.json'));
const withAds = (on) => ({ ...structuredClone(legal), features: { ads: on } });
const allText = (doc) =>
  [doc.title, doc.intro, ...doc.sections.flatMap((s) => [s.heading, ...s.blocks.flatMap((b) => b.bullets ?? [b.paragraph])])].join('\n');

test('the hosted pages are up to date with assets/legal/legal.json', () => {
  for (const name of DOCS) {
    for (const lang of LANGS) {
      assert.equal(
        read(`../legal/${fileName(name, lang)}`),
        renderHtml(legal, name, lang),
        `legal/${fileName(name, lang)} is stale — run: node scripts/build-legal.mjs`,
      );
    }
  }
});

test('every document exists in both languages with matching structure', () => {
  for (const name of DOCS) {
    const ar = resolveDocument(legal, name, 'ar');
    const en = resolveDocument(legal, name, 'en');
    assert.equal(ar.sections.length, en.sections.length, `${name}: section count differs`);
    ar.sections.forEach((s, i) => {
      assert.equal(s.blocks.length, en.sections[i].blocks.length, `${name} §${i + 1}: block count differs`);
    });
  }
});

test('no placeholder is left unresolved', () => {
  for (const name of DOCS) {
    for (const lang of LANGS) {
      for (const flag of [false, true]) {
        const text = allText(resolveDocument(withAds(flag), name, lang));
        assert.ok(!text.includes('{{'), `${name}.${lang} ads=${flag} has an unresolved placeholder`);
      }
    }
  }
});

test('without ads the policy does not mention an ad network', () => {
  for (const name of DOCS) {
    for (const lang of LANGS) {
      const text = allText(resolveDocument(withAds(false), name, lang));
      assert.ok(!/AdMob|إعلانات عبر|advertis/i.test(text), `${name}.${lang} mentions ads while features.ads is false`);
    }
  }
});

test('with ads switched on, the policy discloses the ad network', () => {
  const ar = allText(resolveDocument(withAds(true), 'privacy', 'ar'));
  const en = allText(resolveDocument(withAds(true), 'privacy', 'en'));
  assert.ok(ar.includes('AdMob') && ar.includes('معرّف الإعلانات'));
  assert.ok(en.includes('AdMob') && en.includes('advertising ID'));
  // The "no tracking" sentence must not survive unqualified.
  assert.ok(!resolveDocument(withAds(true), 'privacy', 'en').sections.some((s) =>
    s.blocks.some((b) => b.paragraph === 'We do not collect your name, email address, phone number, location or contacts, and we do not use behavioural analytics or tracking tools.')));
});

test('prices, trial and free limit match the app', () => {
  const plan = read('../../lib/features/upgrade/domain/plus_plan.dart');
  const gate = read('../../lib/features/upgrade/domain/plus_gate.dart');
  assert.equal(Number(plan.match(/monthlyPrice = Money\.fromRiyals\((\d+)\)/)[1]), legal.meta.monthlyPriceSar);
  assert.equal(Number(plan.match(/yearlyPrice = Money\.fromRiyals\((\d+)\)/)[1]), legal.meta.yearlyPriceSar);
  assert.equal(Number(plan.match(/trialDays = (\d+)/)[1]), legal.meta.trialDays);
  assert.equal(Number(gate.match(/freeGoalCount = (\d+)/)[1]), legal.meta.freeGoalCount);
});

test('the ads flag matches AppInfo.hasAds', () => {
  const info = read('../../lib/core/constants/app_info.dart');
  assert.equal(info.match(/hasAds = (true|false)/)[1] === 'true', legal.features.ads);
});

test('the support email is linked and HTML is escaped', () => {
  const html = renderHtml(legal, 'support', 'en');
  assert.ok(html.includes(`href="mailto:${legal.meta.supportEmail}"`));
  const evil = structuredClone(legal);
  evil.meta.developerName.en = '<script>alert(1)</script>';
  assert.ok(!renderHtml(evil, 'terms', 'en').includes('<script>'));
});

test('Arabic pages are right-to-left, English pages left-to-right', () => {
  assert.match(renderHtml(legal, 'privacy', 'ar'), /<html lang="ar" dir="rtl">/);
  assert.match(renderHtml(legal, 'privacy', 'en'), /<html lang="en" dir="ltr">/);
});

test('an unknown placeholder is an error, not silent text', () => {
  const broken = structuredClone(legal);
  broken.documents.privacy.en.intro = 'Hello {{nope}}';
  assert.throws(() => resolveDocument(broken, 'privacy', 'en'), /nope/);
});
