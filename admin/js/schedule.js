// Pure schedule logic: validation, weekend rule, next-payout preview and the
// document shape shared with the Flutter app. No DOM, no Firebase.
//
// KEEP IN SYNC with the app:
//   lib/features/payments/domain/payout_schedule_calculator.dart
//   lib/features/payments/domain/payout_schedule_codec.dart
// test/schedule.test.mjs checks the built-in list against payout_catalog.dart.

export const KINDS = {
  governmentSalary: 'رواتب حكومية',
  citizenAccount: 'حساب المواطن',
  socialSecurity: 'ضمان اجتماعي',
  pension: 'معاش تقاعد',
  studentStipend: 'مكافأة طلاب',
  other: 'أخرى',
};

export const CATEGORIES = {
  government: 'الرواتب الحكومية',
  support: 'برامج الدعم',
  retireesAndStudents: 'المتقاعدين والطلاب',
};

export const CERTAINTIES = {
  confirmed: 'مؤكد',
  expected: 'متوقع',
};

export const MAX_PROGRAMS = 50;

export const MONTHS = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];
export const WEEKDAYS = [
  'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
];

// The 5 programs shipped inside the app (ids must match PayoutCatalog so users'
// saved reminders keep working).
export const DEFAULT_PROGRAMS = [
  {
    id: 'gov-salaries', kind: 'governmentSalary', category: 'government',
    title: 'رواتب القطاع الحكومي', provider: 'الجهات المدنية والعسكرية',
    certainty: 'confirmed', dayOfMonth: 27, windowEndDay: null,
    note: 'يصرف في تمام 12:00 صباحاً', windowNote: '', active: true,
  },
  {
    id: 'citizen-account', kind: 'citizenAccount', category: 'support',
    title: 'حساب المواطن', provider: 'برنامج دعم الأسر المستحقة',
    certainty: 'confirmed', dayOfMonth: 10, windowEndDay: null,
    note: 'الدورة الشهرية المعتمدة (يوم 10)', windowNote: '', active: true,
  },
  {
    id: 'social-security', kind: 'socialSecurity', category: 'support',
    title: 'الضمان الاجتماعي المطور', provider: 'وزارة الموارد البشرية',
    certainty: 'confirmed', dayOfMonth: 1, windowEndDay: null,
    note: 'يصرف في بداية كل شهر ميلادي', windowNote: '', active: true,
  },
  {
    id: 'retirees', kind: 'pension', category: 'retireesAndStudents',
    title: 'رواتب المتقاعدين', provider: 'المؤسسة العامة للتأمينات الاجتماعية',
    certainty: 'expected', dayOfMonth: 1, windowEndDay: null,
    note: 'توحيد موعد الصرف ليوم 1 ميلادي', windowNote: '', active: true,
  },
  {
    id: 'student-stipends', kind: 'studentStipend', category: 'retireesAndStudents',
    title: 'مكافآت الطلاب والجامعات', provider: 'الجامعات السعودية الحكومية',
    certainty: 'expected', dayOfMonth: 25, windowEndDay: 28,
    note: 'تختلف بيوم أو يومين باختلاف الجامعة', windowNote: 'حسب اعتماد كل جامعة',
    active: true,
  },
];

// ── Dates (UTC-based so daylight saving can never shift a day) ────────────

/** Calendar date as a UTC midnight timestamp. */
export function dateOnly(d) {
  return Date.UTC(d.getFullYear(), d.getMonth(), d.getDate());
}

const DAY_MS = 86_400_000;
const FRIDAY = 5;
const SATURDAY = 6;
export const RECENTLY_PAID_DAYS = 14;

export function daysBetween(fromMs, toMs) {
  return Math.round((toMs - fromMs) / DAY_MS);
}

function daysInMonth(year, month0) {
  return new Date(Date.UTC(year, month0 + 1, 0)).getUTCDate();
}

/** Friday → Thursday, Saturday → Sunday (Saudi banking week). */
export function applyWeekendRule(ms) {
  const weekday = new Date(ms).getUTCDay();
  if (weekday === FRIDAY) return ms - DAY_MS;
  if (weekday === SATURDAY) return ms + DAY_MS;
  return ms;
}

function occurrence(year, month0, day) {
  const normalised = new Date(Date.UTC(year, month0, 1)); // handles -1 / 12
  const y = normalised.getUTCFullYear();
  const m = normalised.getUTCMonth();
  const nominal = Date.UTC(y, m, Math.min(day, daysInMonth(y, m)));
  return { nominal, date: applyWeekendRule(nominal) };
}

function dayIn(todayMs, monthOffset, day) {
  const t = new Date(todayMs);
  const first = new Date(Date.UTC(t.getUTCFullYear(), t.getUTCMonth() + monthOffset, 1));
  const y = first.getUTCFullYear();
  const m = first.getUTCMonth();
  return Date.UTC(y, m, Math.min(day, daysInMonth(y, m)));
}

export function isWindow(program) {
  return program.windowEndDay != null;
}

/**
 * Same rules as PayoutScheduleCalculator.evaluate. [now] is a Date; the
 * result carries UTC-midnight timestamps.
 */
export function evaluate(program, now) {
  const today = dateOnly(now);
  return isWindow(program) ? evaluateWindow(program, today) : evaluateFixed(program, today);
}

function evaluateFixed(program, today) {
  const t = new Date(today);
  const occurrences = [-1, 0, 1].map((o) =>
    occurrence(t.getUTCFullYear(), t.getUTCMonth() + o, program.dayOfMonth));
  const next = occurrences.find((o) => o.date >= today);
  const last = [...occurrences].reverse().find((o) => o.date < today);
  const sinceLast = daysBetween(last.date, today);
  const recentlyPaid = sinceLast <= RECENTLY_PAID_DAYS && next.date !== today;
  return {
    kind: 'fixed',
    status: recentlyPaid ? 'paid' : program.certainty === 'confirmed' ? 'confirmed' : 'expected',
    next: next.date,
    last: last.date,
    daysUntil: daysBetween(today, next.date),
    shiftedForWeekend: next.nominal !== next.date,
  };
}

function evaluateWindow(program, today) {
  const offset = today > dayIn(today, 0, program.windowEndDay) ? 1 : 0;
  const start = dayIn(today, offset, program.dayOfMonth);
  const end = dayIn(today, offset, program.windowEndDay);
  return {
    kind: 'window',
    status: 'expected',
    next: start,
    windowEnd: end,
    daysUntil: Math.max(0, daysBetween(today, start)),
    daysUntilWindowEnd: daysBetween(today, end),
    shiftedForWeekend: false,
  };
}

export function formatDate(ms) {
  const d = new Date(ms);
  return `${d.getUTCDate()} ${MONTHS[d.getUTCMonth()]} ${d.getUTCFullYear()}`;
}

export function formatDateWithWeekday(ms) {
  return `${WEEKDAYS[new Date(ms).getUTCDay()]}، ${formatDate(ms)}`;
}

/** One-line Arabic description of the next payout for the preview. */
export function describeNext(program, now) {
  const info = evaluate(program, now);
  if (info.kind === 'window') {
    const range = `${new Date(info.next).getUTCDate()} - ${formatDate(info.windowEnd)}`;
    return info.daysUntil === 0 && info.daysUntilWindowEnd >= 0
      ? `النافذة مفتوحة الآن: ${range}`
      : `النافذة القادمة: ${range}`;
  }
  const when = info.daysUntil === 0 ? 'اليوم' : `بعد ${arabicDays(info.daysUntil)}`;
  const shifted = info.shiftedForWeekend ? ' — عُدّل بسبب العطلة' : '';
  return `${formatDateWithWeekday(info.next)} (${when})${shifted}`;
}

function arabicDays(n) {
  if (n === 1) return 'يوم';
  if (n === 2) return 'يومين';
  return `${n} ${n >= 3 && n <= 10 ? 'أيام' : 'يوماً'}`;
}

// ── Validation ────────────────────────────────────────────────────────────

const isDay = (v) => Number.isInteger(v) && v >= 1 && v <= 31;

/**
 * Returns `{field: message}`; empty object means valid. [others] are the
 * other programs (for the duplicate-id check).
 */
export function validateProgram(p, others = []) {
  const errors = {};
  if (!String(p.id ?? '').trim()) errors.id = 'المعرّف مطلوب';
  else if (!/^[a-z0-9][a-z0-9-]{1,39}$/.test(p.id)) {
    errors.id = 'المعرّف أحرف إنجليزية صغيرة وأرقام وشرطة فقط (2–40)';
  } else if (others.some((o) => o.id === p.id)) errors.id = 'المعرّف مستخدم مسبقاً';

  if (!String(p.title ?? '').trim()) errors.title = 'اسم البرنامج مطلوب';
  else if (p.title.trim().length > 80) errors.title = 'الاسم طويل (80 حرفاً كحد أقصى)';

  if (!(p.category in CATEGORIES)) errors.category = 'اختر التصنيف';
  if (!(p.kind in KINDS)) errors.kind = 'اختر النوع';
  if (!(p.certainty in CERTAINTIES)) errors.certainty = 'اختر درجة التأكيد';

  if (!isDay(p.dayOfMonth)) errors.dayOfMonth = 'أدخل يوماً من 1 إلى 31';
  if (p.windowEndDay != null) {
    if (!isDay(p.windowEndDay)) errors.windowEndDay = 'أدخل يوماً من 1 إلى 31';
    else if (isDay(p.dayOfMonth) && p.windowEndDay <= p.dayOfMonth) {
      errors.windowEndDay = 'نهاية النافذة يجب أن تكون بعد بدايتها';
    }
  }
  for (const f of ['provider', 'note', 'windowNote']) {
    if (String(p[f] ?? '').length > 160) errors[f] = 'النص طويل (160 حرفاً كحد أقصى)';
  }
  return errors;
}

/** Problems that block publishing the whole list. */
export function validateSchedule(programs) {
  const problems = [];
  if (programs.length > MAX_PROGRAMS) problems.push(`الحد الأقصى ${MAX_PROGRAMS} برنامجاً`);
  if (!programs.some((p) => p.active)) {
    problems.push('فعّل برنامجاً واحداً على الأقل — القائمة الفارغة لا تُعرض في التطبيق');
  }
  programs.forEach((p, i) => {
    const errors = validateProgram(p, programs.filter((_, j) => j !== i));
    if (Object.keys(errors).length) problems.push(`«${p.title || p.id || 'بدون اسم'}»: ${Object.values(errors)[0]}`);
  });
  return problems;
}

// ── Document shape ────────────────────────────────────────────────────────

export function normalize(p) {
  const text = (v) => String(v ?? '').trim();
  return {
    id: text(p.id),
    kind: p.kind in KINDS ? p.kind : 'other',
    category: p.category,
    title: text(p.title),
    provider: text(p.provider),
    certainty: p.certainty in CERTAINTIES ? p.certainty : 'expected',
    dayOfMonth: Number(p.dayOfMonth),
    windowEndDay: p.windowEndDay == null || p.windowEndDay === '' ? null : Number(p.windowEndDay),
    note: text(p.note),
    windowNote: text(p.windowNote),
    active: p.active !== false,
  };
}

/** The `programs` array written to config/payout_schedule. */
export function toDocumentPrograms(programs) {
  return programs.map(normalize);
}

/** Reads the stored document back, dropping anything unusable. */
export function fromDocumentPrograms(data) {
  const raw = Array.isArray(data?.programs) ? data.programs : [];
  const seen = new Set();
  const out = [];
  for (const item of raw) {
    if (!item || typeof item !== 'object') continue;
    const p = normalize(item);
    if (Object.keys(validateProgram(p)).length || seen.has(p.id)) continue;
    seen.add(p.id);
    out.push(p);
  }
  return out;
}

export function newId() {
  const rand = Math.random().toString(36).slice(2, 8).padEnd(6, '0');
  return `prog-${rand}`;
}

export function blankProgram() {
  return {
    id: newId(), kind: 'other', category: 'government', title: '', provider: '',
    certainty: 'expected', dayOfMonth: 25, windowEndDay: null,
    note: '', windowNote: '', active: true,
  };
}

/** Returns a new array with the item moved by [delta] places (clamped). */
export function move(list, index, delta) {
  const target = index + delta;
  if (index < 0 || index >= list.length || target < 0 || target >= list.length) return list;
  const copy = [...list];
  const [item] = copy.splice(index, 1);
  copy.splice(target, 0, item);
  return copy;
}

export function sameSchedule(a, b) {
  return JSON.stringify(toDocumentPrograms(a)) === JSON.stringify(toDocumentPrograms(b));
}

/** Human-readable difference between the published list and the draft. */
export function diffSchedules(before, after) {
  const prev = new Map(before.map((p) => [p.id, JSON.stringify(normalize(p))]));
  const next = new Map(after.map((p) => [p.id, p]));
  const added = after.filter((p) => !prev.has(p.id)).map((p) => p.title);
  const removed = before.filter((p) => !next.has(p.id)).map((p) => p.title);
  const changed = after
    .filter((p) => prev.has(p.id) && prev.get(p.id) !== JSON.stringify(normalize(p)))
    .map((p) => p.title);
  const kept = (list, other) => list.filter((p) => other.has(p.id)).map((p) => p.id);
  const reordered = JSON.stringify(kept(before, next)) !== JSON.stringify(kept(after, prev));
  return { added, removed, changed, reordered };
}
