import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import {
  DEFAULT_PROGRAMS, applyWeekendRule, blankProgram, dateOnly, describeNext, diffSchedules, evaluate,
  formatDate, fromDocumentPrograms, move, normalize, sameSchedule, toDocumentPrograms,
  validateProgram, validateSchedule,
} from '../js/schedule.js';

const utc = (y, m, d) => Date.UTC(y, m - 1, d);
const now = new Date(2026, 9, 22, 17); // Thu 22 Oct 2026, 17:00 (same as the app tests)
const byId = (id) => DEFAULT_PROGRAMS.find((p) => p.id === id);

test('weekend rule: Friday → Thursday, Saturday → Sunday', () => {
  assert.equal(applyWeekendRule(utc(2026, 11, 27)), utc(2026, 11, 26)); // Fri
  assert.equal(applyWeekendRule(utc(2026, 11, 28)), utc(2026, 11, 29)); // Sat
  assert.equal(applyWeekendRule(utc(2026, 10, 22)), utc(2026, 10, 22)); // Thu
});

// Same expectations as test/features/payments/payout_schedule_calculator_test.dart
test('government salary on Thu 22 Oct: next is Tue 27 Oct, in 5 days', () => {
  const info = evaluate(byId('gov-salaries'), now);
  assert.equal(info.next, utc(2026, 10, 27));
  assert.equal(info.daysUntil, 5);
  assert.equal(info.status, 'confirmed');
  assert.equal(info.shiftedForWeekend, false);
});

test('government salary after 27 Oct: next is 26 Nov (27 Nov is a Friday)', () => {
  const info = evaluate(byId('gov-salaries'), new Date(2026, 9, 28));
  assert.equal(info.next, utc(2026, 11, 26));
  assert.equal(info.shiftedForWeekend, true);
});

test('citizen account paid on Sat 10 Oct → Sun 11 Oct counts as recently paid', () => {
  const info = evaluate(byId('citizen-account'), now);
  assert.equal(info.status, 'paid');
  assert.equal(info.last, utc(2026, 10, 11));
});

test('social security: 1 Jan 2027 is a Friday → Thursday 31 Dec 2026', () => {
  const info = evaluate(byId('social-security'), new Date(2026, 11, 20));
  assert.equal(info.next, utc(2026, 12, 31));
});

test('window program stays current until the window has passed', () => {
  const stipend = byId('student-stipends');
  const during = evaluate(stipend, now);
  assert.equal(during.kind, 'window');
  assert.equal(during.next, utc(2026, 10, 25));
  assert.equal(during.daysUntil, 3);
  const inside = evaluate(stipend, new Date(2026, 9, 26));
  assert.equal(inside.daysUntil, 0);
  assert.equal(inside.daysUntilWindowEnd, 2);
  const after = evaluate(stipend, new Date(2026, 9, 29));
  assert.equal(after.next, utc(2026, 11, 25));
});

test('day 31 falls back to the last day of shorter months', () => {
  const p = { ...blankProgram(), dayOfMonth: 31, certainty: 'confirmed' };
  // 30 Apr 2027 is a Friday → Thursday 29 Apr
  const info = evaluate(p, new Date(2027, 3, 10));
  assert.equal(info.next, utc(2027, 4, 29));
});

test('year rollover', () => {
  const info = evaluate(byId('social-security'), new Date(2027, 0, 5));
  assert.equal(info.next, utc(2027, 2, 1));
  assert.equal(info.last, utc(2026, 12, 31));
});

test('describeNext reads naturally', () => {
  assert.equal(
    describeNext(byId('gov-salaries'), now),
    'الثلاثاء، 27 أكتوبر 2026 (بعد 5 أيام)',
  );
  assert.match(describeNext(byId('gov-salaries'), new Date(2026, 9, 28)), /عُدّل بسبب العطلة/);
  assert.match(describeNext(byId('student-stipends'), now), /النافذة القادمة/);
});

test('dateOnly ignores the time of day', () => {
  assert.equal(dateOnly(new Date(2026, 9, 22, 23, 59)), utc(2026, 10, 22));
  assert.equal(formatDate(utc(2026, 10, 22)), '22 أكتوبر 2026');
});

// ── validation ────────────────────────────────────────────────────────────

const valid = () => ({ ...blankProgram(), title: 'برنامج تجريبي' });

test('a filled blank program is valid', () => {
  assert.deepEqual(validateProgram(valid()), {});
});

test('rejects bad days, windows, ids and titles', () => {
  assert.ok(validateProgram({ ...valid(), dayOfMonth: 0 }).dayOfMonth);
  assert.ok(validateProgram({ ...valid(), dayOfMonth: 32 }).dayOfMonth);
  assert.ok(validateProgram({ ...valid(), dayOfMonth: 12.5 }).dayOfMonth);
  assert.ok(validateProgram({ ...valid(), dayOfMonth: 10, windowEndDay: 10 }).windowEndDay);
  assert.ok(validateProgram({ ...valid(), dayOfMonth: 10, windowEndDay: 9 }).windowEndDay);
  assert.deepEqual(validateProgram({ ...valid(), dayOfMonth: 10, windowEndDay: 12 }), {});
  assert.ok(validateProgram({ ...valid(), title: '  ' }).title);
  assert.ok(validateProgram({ ...valid(), id: 'Bad ID' }).id);
  assert.ok(validateProgram({ ...valid(), id: '' }).id);
  assert.ok(validateProgram({ ...valid(), category: 'x' }).category);
  const one = valid();
  assert.ok(validateProgram(one, [{ id: one.id }]).id);
});

test('schedule needs at least one active program', () => {
  const hidden = DEFAULT_PROGRAMS.map((p) => ({ ...p, active: false }));
  assert.equal(validateSchedule(hidden).length, 1);
  assert.deepEqual(validateSchedule(DEFAULT_PROGRAMS), []);
});

test('the built-in list passes its own validation', () => {
  for (const p of DEFAULT_PROGRAMS) assert.deepEqual(validateProgram(p), {}, p.id);
});

// ── document shape ────────────────────────────────────────────────────────

test('document round trip keeps everything and drops junk', () => {
  const programs = toDocumentPrograms(DEFAULT_PROGRAMS);
  const back = fromDocumentPrograms({ programs: [...programs, null, { id: 'x' }, programs[0]] });
  assert.deepEqual(back, programs);
});

test('normalize trims text and converts empty window to null', () => {
  const p = normalize({ ...valid(), title: '  عنوان  ', windowEndDay: '', dayOfMonth: '15' });
  assert.equal(p.title, 'عنوان');
  assert.equal(p.windowEndDay, null);
  assert.equal(p.dayOfMonth, 15);
});

test('move reorders and clamps at the edges', () => {
  assert.deepEqual(move([1, 2, 3], 0, 1), [2, 1, 3]);
  assert.deepEqual(move([1, 2, 3], 2, -1), [1, 3, 2]);
  const same = [1, 2, 3];
  assert.equal(move(same, 0, -1), same);
  assert.equal(move(same, 2, 1), same);
});

test('sameSchedule detects edits', () => {
  const a = DEFAULT_PROGRAMS.map((p) => ({ ...p }));
  assert.ok(sameSchedule(a, DEFAULT_PROGRAMS));
  a[0].dayOfMonth = 26;
  assert.ok(!sameSchedule(a, DEFAULT_PROGRAMS));
});

test('diffSchedules lists added, removed, changed and reordering', () => {
  const [a, b, c] = DEFAULT_PROGRAMS;
  const d = { ...valid(), id: 'new-one', title: 'جديد' };
  assert.deepEqual(diffSchedules([a, b, c], [a, b, c]),
    { added: [], removed: [], changed: [], reordered: false });
  const diff = diffSchedules([a, b, c], [{ ...c, dayOfMonth: 2 }, a, d]);
  assert.deepEqual(diff.added, ['جديد']);
  assert.deepEqual(diff.removed, [b.title]);
  assert.deepEqual(diff.changed, [c.title]);
  assert.equal(diff.reordered, true);
  assert.equal(diffSchedules([a, b], [b, a]).reordered, true);
});

// ── parity with the Flutter app ───────────────────────────────────────────

test('DEFAULT_PROGRAMS matches lib/.../payout_catalog.dart', () => {
  const dart = readFileSync(new URL('../../lib/features/payments/domain/payout_catalog.dart', import.meta.url), 'utf8');
  const blocks = dart.split('PayoutProgram(').slice(1);
  assert.equal(blocks.length, DEFAULT_PROGRAMS.length);
  const str = (b, k) => b.match(new RegExp(`${k}: '([^']*)'`))?.[1] ?? '';
  const num = (b, k) => { const m = b.match(new RegExp(`${k}: (\\d+)`)); return m ? Number(m[1]) : null; };
  const enm = (b, k) => b.match(new RegExp(`${k}: \\w+\\.(\\w+)`))[1];
  blocks.forEach((b, i) => {
    const p = DEFAULT_PROGRAMS[i];
    assert.equal(str(b, 'id'), p.id);
    assert.equal(enm(b, 'kind'), p.kind, p.id);
    assert.equal(enm(b, 'category'), p.category, p.id);
    assert.equal(enm(b, 'certainty'), p.certainty, p.id);
    assert.equal(str(b, 'title'), p.title, p.id);
    assert.equal(str(b, 'provider'), p.provider, p.id);
    assert.equal(num(b, 'dayOfMonth'), p.dayOfMonth, p.id);
    assert.equal(num(b, 'windowEndDay'), p.windowEndDay, p.id);
    assert.equal(str(b, 'note'), p.note, p.id);
    assert.equal(str(b, 'windowNote'), p.windowNote, p.id);
  });
});
