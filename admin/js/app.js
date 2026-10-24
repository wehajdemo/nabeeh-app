import { ConflictError, createDemoBackend, createFirebaseBackend, isConfigured } from './data.js';
import {
  CATEGORIES, CERTAINTIES, DEFAULT_PROGRAMS, KINDS, MONTHS, blankProgram, describeNext,
  diffSchedules, move, normalize, sameSchedule, validateProgram, validateSchedule,
} from './schedule.js';

const $ = (id) => document.getElementById(id);
const clone = (list) => list.map((p) => ({ ...p }));

// ── tiny DOM helper (text is always set as text, never as HTML) ───────────
function h(tag, props = {}, ...kids) {
  const el = document.createElement(tag);
  for (const [key, value] of Object.entries(props)) {
    if (key === 'class') el.className = value;
    else if (key.startsWith('on')) el.addEventListener(key.slice(2), value);
    else if (value === true) el.setAttribute(key, '');
    else if (value !== false && value != null) el.setAttribute(key, value);
  }
  el.append(...kids.flat().filter((k) => k != null && k !== false));
  return el;
}

const ICONS = {
  up: '<path d="M6 15l6-6 6 6"/>',
  down: '<path d="M6 9l6 6 6-6"/>',
  edit: '<path d="M4 20h4L19 9l-4-4L4 16v4z"/><path d="M13.5 6.5l4 4"/>',
  trash: '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
};
function icon(name) {
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('viewBox', '0 0 24 24');
  svg.setAttribute('aria-hidden', 'true');
  svg.innerHTML = ICONS[name]; // constant strings above, no user data
  return svg;
}
function iconButton(name, label, onclick, { disabled = false, danger = false } = {}) {
  return h('button', {
    class: `icon-btn${danger ? ' danger' : ''}`, type: 'button', title: label,
    'aria-label': label, disabled, onclick,
  }, icon(name));
}

// ── state ─────────────────────────────────────────────────────────────────
const params = new URLSearchParams(location.search);
const demoParam = params.get('demo');

const state = {
  backend: null,
  user: null,
  programs: [],
  baseline: [],
  baseUpdatedAt: null,
  publishedBy: null,
  exists: false,
  previewDate: new Date(),
  busy: false,
  editing: null, // {index: number | -1 for new, draft: object}
};
let authToken = 0;

// ── formatting ────────────────────────────────────────────────────────────
function pad(n) { return String(n).padStart(2, '0'); }
function formatDateTime(d) {
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}، ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}
function toInputDate(d) { return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`; }
function fromInputDate(value) {
  const [y, m, d] = value.split('-').map(Number);
  return y ? new Date(y, m - 1, d, 12) : new Date();
}

function scheduleLine(p) {
  return p.windowEndDay != null
    ? `من ${p.dayOfMonth} إلى ${p.windowEndDay} من كل شهر`
    : `يوم ${p.dayOfMonth} من كل شهر`;
}

function explain(error) {
  switch (error?.code) {
    case 'auth/invalid-credential':
    case 'auth/wrong-password':
    case 'auth/user-not-found':
    case 'auth/invalid-email':
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    case 'auth/too-many-requests': return 'محاولات كثيرة. حاول مرة أخرى بعد قليل.';
    case 'auth/network-request-failed':
    case 'unavailable': return 'تعذّر الاتصال بالشبكة. تحقق من الإنترنت وأعد المحاولة.';
    case 'permission-denied': return 'لا تملك صلاحية تنفيذ هذا الإجراء.';
    default: return 'حدث خطأ غير متوقع. أعد المحاولة.';
  }
}

// ── views / toast ─────────────────────────────────────────────────────────
const VIEWS = ['loading', 'setup', 'login', 'denied', 'main'];
function showView(name) {
  for (const v of VIEWS) $(`view-${v}`).hidden = v !== name;
}

let toastTimer;
function toast(message, { error = false } = {}) {
  const el = $('toast');
  el.textContent = message;
  el.className = `toast${error ? ' error' : ''}`;
  el.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { el.hidden = true; }, error ? 6000 : 3500);
}

/** Resolves true when the primary button is pressed. */
function confirmDialog({ title, body = [], okLabel = 'حسناً', cancel = true, danger = false }) {
  const dialog = $('confirm-dialog');
  $('confirm-title').textContent = title;
  $('confirm-body').replaceChildren(...body);
  const ok = $('confirm-ok');
  ok.textContent = okLabel;
  ok.className = `btn ${danger ? 'danger' : 'primary'}`;
  $('confirm-cancel').hidden = !cancel;
  return new Promise((resolve) => {
    dialog.addEventListener('close', () => resolve(dialog.returnValue === 'ok'), { once: true });
    dialog.returnValue = '';
    dialog.showModal();
    ok.focus();
  });
}

const list = (items) => h('ul', {}, items.map((t) => h('li', {}, t)));

// ── rendering ─────────────────────────────────────────────────────────────
const isDirty = () => !sameSchedule(state.programs, state.baseline);

function render() {
  $('user-email').textContent = state.user?.email ?? '';

  $('status-published').textContent = state.exists
    ? `آخر نشر: ${formatDateTime(state.baseUpdatedAt)}${state.publishedBy ? ` — ${state.publishedBy}` : ''}`
    : 'لم يُنشر جدول بعد — التطبيق يستخدم القائمة المدمجة فيه.';

  const dirty = isDirty();
  $('status-dirty').hidden = !dirty;
  $('btn-publish').disabled = !dirty || state.busy;
  $('btn-revert').disabled = !dirty || state.busy;
  $('btn-import').hidden = state.programs.length > 0;
  $('empty-state').hidden = state.programs.length > 0;

  const baselineById = new Map(state.baseline.map((p) => [p.id, JSON.stringify(normalize(p))]));
  $('program-list').replaceChildren(
    ...state.programs.map((p, i) => card(p, i, baselineById)),
  );
}

function card(p, index, baselineById) {
  const last = state.programs.length - 1;
  const edited = baselineById.get(p.id) !== JSON.stringify(normalize(p));
  return h('li', { class: `card${p.active ? '' : ' inactive'}${edited ? ' edited' : ''}`, 'data-id': p.id },
    h('div', { class: 'card-head' },
      h('span', { class: 'card-index', 'aria-hidden': 'true' }, String(index + 1)),
      h('div', { class: 'card-main' },
        h('p', { class: 'card-title' }, p.title),
        p.provider && h('p', { class: 'card-provider' }, p.provider),
      ),
    ),
    h('div', { class: 'card-main' },
      h('div', { class: 'chips' },
        h('span', { class: `chip ${p.certainty}` }, CERTAINTIES[p.certainty]),
        h('span', { class: 'chip' }, CATEGORIES[p.category] ?? p.category),
        h('span', { class: 'chip' }, KINDS[p.kind] ?? p.kind),
        !p.active && h('span', { class: 'chip hidden-chip' }, 'مخفي عن التطبيق'),
        edited && h('span', { class: 'chip' }, 'معدّل'),
      ),
      h('p', { class: 'schedule-line' }, scheduleLine(p)),
      h('p', { class: 'next-line' }, describeNext(p, state.previewDate)),
      p.note && h('p', { class: 'card-note' }, p.note),
    ),
    h('div', { class: 'card-actions' },
      h('label', { class: 'switch' },
        h('input', {
          type: 'checkbox', checked: p.active, 'aria-label': `إظهار ${p.title} في التطبيق`,
          onchange: (e) => { p.active = e.target.checked; render(); },
        }),
        'ظاهر',
      ),
      h('span', { class: 'spacer' }),
      iconButton('up', 'تحريك لأعلى', () => reorder(index, -1), { disabled: index === 0 }),
      iconButton('down', 'تحريك لأسفل', () => reorder(index, 1), { disabled: index === last }),
      iconButton('edit', 'تعديل', () => openEdit(index)),
      iconButton('trash', 'حذف', () => removeProgram(index), { danger: true }),
    ),
  );
}

function reorder(index, delta) {
  state.programs = move(state.programs, index, delta);
  render();
}

async function removeProgram(index) {
  const p = state.programs[index];
  const ok = await confirmDialog({
    title: 'حذف البرنامج؟',
    body: [h('p', {}, `سيُحذف «${p.title}» من المسودة، ويختفي من التطبيق عند النشر. للإخفاء المؤقت استخدم مفتاح «ظاهر» بدلاً من الحذف.`)],
    okLabel: 'حذف', danger: true,
  });
  if (!ok) return;
  state.programs = state.programs.filter((_, i) => i !== index);
  render();
}

// ── add / edit dialog ─────────────────────────────────────────────────────
function fillSelect(select, options) {
  select.replaceChildren(...Object.entries(options).map(([value, label]) => h('option', { value }, label)));
}

function writeForm(p, isNew) {
  $('f-title').value = p.title;
  $('f-provider').value = p.provider;
  $('f-category').value = p.category;
  $('f-kind').value = p.kind;
  document.querySelectorAll('input[name=certainty]').forEach((r) => { r.checked = r.value === p.certainty; });
  $('f-window').checked = p.windowEndDay != null;
  $('f-day').value = p.dayOfMonth ?? '';
  $('f-end').value = p.windowEndDay ?? '';
  $('f-note').value = p.note;
  $('f-wnote').value = p.windowNote;
  $('f-id').value = p.id;
  $('f-id').readOnly = !isNew;
  $('f-id-hint').hidden = isNew;
  $('f-active').checked = p.active;
  syncWindowFields();
}

function syncWindowFields() {
  const isWindow = $('f-window').checked;
  $('f-end-wrap').hidden = !isWindow;
  $('f-wnote-wrap').hidden = !isWindow;
  $('f-day-label').textContent = isWindow ? 'أول يوم في النافذة *' : 'يوم الصرف من الشهر *';
}

const numberOrNaN = (value) => (value.trim() === '' ? Number.NaN : Number(value));

function readForm() {
  const isWindow = $('f-window').checked;
  return {
    id: $('f-id').value.trim(),
    kind: $('f-kind').value,
    category: $('f-category').value,
    title: $('f-title').value,
    provider: $('f-provider').value,
    certainty: document.querySelector('input[name=certainty]:checked')?.value ?? '',
    dayOfMonth: numberOrNaN($('f-day').value),
    windowEndDay: isWindow ? numberOrNaN($('f-end').value) : null,
    note: $('f-note').value,
    windowNote: isWindow ? $('f-wnote').value : '',
    active: $('f-active').checked,
  };
}

const FIELD_INPUT = {
  title: 'f-title', provider: 'f-provider', category: 'f-category', kind: 'f-kind',
  dayOfMonth: 'f-day', windowEndDay: 'f-end', note: 'f-note', windowNote: 'f-wnote', id: 'f-id',
};

function showErrors(errors) {
  document.querySelectorAll('[data-err]').forEach((el) => { el.textContent = errors[el.dataset.err] ?? ''; });
  for (const [field, inputId] of Object.entries(FIELD_INPUT)) {
    $(inputId).setAttribute('aria-invalid', field in errors ? 'true' : 'false');
  }
}

function othersExcluding(index) {
  return state.programs.filter((_, i) => i !== index);
}

function updateFormPreview() {
  const p = readForm();
  const errors = validateProgram(p, othersExcluding(state.editing.index));
  if (state.editing.submitted) showErrors(errors); // keep messages in step once shown
  const ready = !errors.dayOfMonth && !errors.windowEndDay;
  $('f-preview').textContent = ready ? describeNext(normalize(p), state.previewDate) : '—';
  $('f-day-hint').hidden = !(p.dayOfMonth >= 29);
}

function openEdit(index) {
  const isNew = index < 0;
  const draft = isNew ? blankProgram() : { ...state.programs[index] };
  state.editing = { index, draft, submitted: false };
  $('edit-title').textContent = isNew ? 'إضافة برنامج' : 'تعديل البرنامج';
  showErrors({});
  writeForm(draft, isNew);
  updateFormPreview();
  $('edit-dialog').showModal();
  $('f-title').focus();
}

function submitEdit(event) {
  event.preventDefault();
  const { index } = state.editing;
  const p = normalize(readForm());
  const errors = validateProgram(readForm(), othersExcluding(index));
  state.editing.submitted = true;
  showErrors(errors);
  if (Object.keys(errors).length) {
    const first = Object.keys(FIELD_INPUT).find((f) => f in errors);
    $(FIELD_INPUT[first]).focus();
    return;
  }
  if (index < 0) state.programs = [...state.programs, p];
  else state.programs = state.programs.map((old, i) => (i === index ? p : old));
  $('edit-dialog').close('saved');
  render();
}

// ── publish / revert / import ─────────────────────────────────────────────
function setBusy(busy) {
  state.busy = busy;
  $('btn-publish').textContent = busy ? 'جارٍ النشر…' : 'نشر التغييرات';
  render();
}

async function publish() {
  const problems = validateSchedule(state.programs);
  if (problems.length) {
    await confirmDialog({
      title: 'لا يمكن النشر بعد', body: [list(problems)], okLabel: 'حسناً', cancel: false,
    });
    return;
  }

  const diff = diffSchedules(state.baseline, state.programs);
  const lines = [
    diff.added.length && `إضافة: ${diff.added.join('، ')}`,
    diff.removed.length && `حذف: ${diff.removed.join('، ')}`,
    diff.changed.length && `تعديل: ${diff.changed.join('، ')}`,
    diff.reordered && 'تغيير الترتيب',
  ].filter(Boolean);
  const active = state.programs.filter((p) => p.active).length;
  const ok = await confirmDialog({
    title: 'نشر الجدول للمستخدمين؟',
    body: [
      list(lines),
      h('p', { class: 'muted' }, `سيظهر ${active} برنامجاً في التطبيق${active < state.programs.length ? ` (و${state.programs.length - active} مخفي)` : ''}. يصل التحديث للمستخدمين خلال 24 ساعة أو عند سحب الشاشة للتحديث.`),
    ],
    okLabel: 'نشر الآن',
  });
  if (!ok) return;

  setBusy(true);
  try {
    const { updatedAt } = await state.backend.save(state.programs, state.user, state.baseUpdatedAt);
    state.baseline = clone(state.programs);
    state.baseUpdatedAt = updatedAt;
    state.publishedBy = state.user.email;
    state.exists = true;
    toast('تم نشر الجدول');
  } catch (error) {
    if (error instanceof ConflictError) {
      const reload = await confirmDialog({
        title: 'تم النشر من مشرف آخر',
        body: [h('p', {}, 'تغيّر الجدول على الخادم بعد فتحك للصفحة، ولن نكتب فوقه. أعد التحميل لرؤية آخر نسخة (ستُفقد تغييراتك غير المنشورة)، أو ألغِ وانسخ ما تحتاجه أولاً.')],
        okLabel: 'إعادة التحميل', danger: true,
      });
      if (reload) await loadSchedule();
    } else {
      toast(explain(error), { error: true });
    }
  } finally {
    setBusy(false);
  }
}

async function revert() {
  const ok = await confirmDialog({
    title: 'التراجع عن التغييرات؟',
    body: [h('p', {}, 'ستعود المسودة إلى آخر نسخة منشورة وتُفقد تعديلاتك.')],
    okLabel: 'تراجع', danger: true,
  });
  if (!ok) return;
  state.programs = clone(state.baseline);
  render();
}

function importDefaults() {
  state.programs = clone(DEFAULT_PROGRAMS);
  render();
  toast('تم استيراد القائمة المدمجة — راجعها ثم انشر');
}

// ── load / auth ───────────────────────────────────────────────────────────
async function loadSchedule() {
  showView('loading');
  try {
    const data = await state.backend.load();
    state.exists = data.exists;
    state.programs = clone(data.programs);
    state.baseline = clone(data.programs);
    state.baseUpdatedAt = data.updatedAt;
    state.publishedBy = data.updatedBy;
    showView('main');
    render();
  } catch (error) {
    showView('main');
    toast(explain(error), { error: true });
  }
}

async function onAuth(user) {
  const token = ++authToken;
  state.user = user;
  if (!user) {
    showView('login');
    $('login-submit').disabled = false;
    return;
  }
  showView('loading');
  const admin = await state.backend.isAdmin(user);
  if (token !== authToken) return;
  if (!admin) {
    $('denied-email').textContent = user.email;
    $('denied-uid').textContent = user.uid;
    showView('denied');
    return;
  }
  await loadSchedule();
}

async function login(event) {
  event.preventDefault();
  const email = $('login-email').value.trim();
  const password = $('login-password').value;
  const error = $('login-error');
  error.hidden = true;
  if (!email || !password) {
    error.textContent = 'أدخل البريد الإلكتروني وكلمة المرور.';
    error.hidden = false;
    return;
  }
  $('login-submit').disabled = true;
  try {
    await state.backend.signIn(email, password);
  } catch (e) {
    error.textContent = explain(e);
    error.hidden = false;
    $('login-submit').disabled = false;
  }
}

async function signOut() {
  if (isDirty() && !(await confirmDialog({
    title: 'تسجيل الخروج؟',
    body: [h('p', {}, 'لديك تغييرات غير منشورة ستُفقد.')],
    okLabel: 'خروج', danger: true,
  }))) return;
  state.programs = [];
  state.baseline = [];
  await state.backend.signOut();
}

// ── boot ──────────────────────────────────────────────────────────────────
async function boot() {
  fillSelect($('f-category'), CATEGORIES);
  fillSelect($('f-kind'), KINDS);
  $('preview-date').value = toInputDate(state.previewDate);

  $('login-form').addEventListener('submit', login);
  $('signout').addEventListener('click', signOut);
  $('denied-signout').addEventListener('click', () => state.backend.signOut());
  $('btn-add').addEventListener('click', () => openEdit(-1));
  $('btn-import').addEventListener('click', importDefaults);
  $('btn-publish').addEventListener('click', publish);
  $('btn-revert').addEventListener('click', revert);
  $('preview-date').addEventListener('change', (e) => {
    state.previewDate = fromInputDate(e.target.value);
    render();
  });

  $('edit-form').addEventListener('submit', submitEdit);
  $('edit-form').addEventListener('input', () => { if (state.editing) updateFormPreview(); });
  $('f-window').addEventListener('change', syncWindowFields);
  $('edit-cancel').addEventListener('click', () => $('edit-dialog').close('cancel'));

  window.addEventListener('beforeunload', (e) => {
    if (state.user && isDirty()) { e.preventDefault(); e.returnValue = ''; }
  });

  if (demoParam) {
    state.backend = createDemoBackend({ seed: demoParam === 'empty' ? 'empty' : 'defaults' });
    window.__demo = state.backend; // test hook
    $('demo-banner').hidden = false;
    $('login-hint').textContent = 'الوضع التجريبي: أي بريد وكلمة مرور تعمل.';
  } else {
    const { firebaseConfig } = await import('../firebase-config.js');
    if (!isConfigured(firebaseConfig)) {
      showView('setup');
      return;
    }
    try {
      state.backend = await createFirebaseBackend(firebaseConfig);
    } catch {
      showView('setup');
      $('view-setup').querySelector('p').textContent = 'تعذّر تحميل Firebase. تحقق من الاتصال ثم أعد تحميل الصفحة.';
      return;
    }
  }
  state.backend.onAuthChange(onAuth);
}

boot();
