'use strict';
const $ = (selector) => document.querySelector(selector);
let tareas = [], filtro = 'pending', cargando = false;
const fecha = new Intl.DateTimeFormat('es-EC', { day:'numeric', month:'long', year:'numeric' });
$('#today').textContent = fecha.format(new Date());
async function request(path, options = {}) {
  const response = await fetch(`/v1/${path}`, { ...options, signal: AbortSignal.timeout(15000), headers: { 'Content-Type':'application/json', ...options.headers } });
  if (!response.ok) throw new Error(`El servidor respondió ${response.status}.`);
  return response.json();
}
function mensaje(selector, text, error = false) { const el = $(selector); el.textContent = text; el.classList.toggle('error', error); }
function render() {
  const query = $('#search').value.trim().toLocaleLowerCase('es');
  const visibles = tareas.filter(t => (filtro === 'all' || t.completada === (filtro === 'done')) && `${t.titulo} ${t.descripcion}`.toLocaleLowerCase('es').includes(query));
  const pendientes = tareas.filter(t => !t.completada).length;
  $('#summary').textContent = `${pendientes} pendientes · ${tareas.length - pendientes} completadas · ${visibles.length} en esta vista`;
  $('#tasks').replaceChildren();
  mensaje('#list-message', visibles.length ? '' : tareas.length ? 'No hay tareas en esta vista. Prueba otro filtro o cambia la búsqueda.' : 'Tu agenda está lista. Crea tu primera tarea con el formulario.');
  for (const t of visibles) {
    const li = document.createElement('li'); li.className = `task${t.completada ? ' done' : ''}`;
    const check = document.createElement('input'); check.type = 'checkbox'; check.checked = t.completada;
    check.setAttribute('aria-label', `${t.completada ? 'Marcar pendiente' : 'Completar'}: ${t.titulo}`);
    check.addEventListener('change', async () => {
      check.disabled = true;
      try {
        const updated = await request(`tareas/${t.id}`, { method:'PATCH', body:JSON.stringify({ completada:check.checked }) });
        tareas = tareas.map(x => x.id === t.id ? updated : x); render();
      } catch { check.checked = t.completada; mensaje('#list-message', 'No se pudo cambiar el estado. Comprueba la conexión y vuelve a intentarlo.', true); }
      finally { check.disabled = false; }
    });
    const body = document.createElement('div'); body.className = 'task-body';
    const title = document.createElement('h3'); title.textContent = t.titulo; body.append(title);
    if (t.descripcion) { const description = document.createElement('p'); description.textContent = t.descripcion; body.append(description); }
    const due = document.createElement(t.fechaEntrega ? 'time' : 'span');
    if (t.fechaEntrega) {
      const date = new Date(`${t.fechaEntrega}T00:00:00`); due.dateTime = t.fechaEntrega;
      const today = new Date(); today.setHours(0,0,0,0);
      const overdue = !t.completada && date < today; due.className = overdue ? 'late' : '';
      due.textContent = `${overdue ? 'Vencida · ' : 'Entrega: '}${fecha.format(date)}`;
    } else { due.className = 'no-date'; due.textContent = 'Sin fecha de entrega'; }
    body.append(due); li.append(check,body); $('#tasks').append(li);
  }
}
async function cargar() {
  if (cargando) return; cargando = true; $('#refresh').disabled = true;
  mensaje('#list-message', 'Actualizando tus tareas…');
  try { tareas = await request('tareas'); render(); }
  catch { mensaje('#list-message', 'No se pudo cargar la agenda. Comprueba que el servidor esté disponible y pulsa Actualizar.', true); }
  finally { cargando = false; $('#refresh').disabled = false; }
}
$('#create-form').addEventListener('submit', async (event) => {
  event.preventDefault(); const titulo = $('#title').value.trim();
  if (!titulo) { mensaje('#form-message', 'Escribe el título de la tarea.', true); $('#title').focus(); return; }
  $('#save').disabled = true; $('#save').textContent = 'Creando…'; mensaje('#form-message','');
  try {
    await request('tareas', {method:'POST',body:JSON.stringify({ titulo, descripcion:$('#description').value.trim(), fechaEntrega:$('#due').value || null })});
    $('#create-form').reset(); setFilter('pending'); $('#search').value = '';
    mensaje('#form-message','Tarea creada.'); await cargar(); $('#title').focus();
  } catch { mensaje('#form-message', 'No se confirmó la creación. Actualiza la lista antes de reintentar para evitar duplicados.', true); }
  finally { $('#save').disabled = false; $('#save').textContent = 'Crear tarea'; }
});
function setFilter(value) { filtro = value; document.querySelectorAll('[data-filter]').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.filter === value))); }
document.querySelectorAll('[data-filter]').forEach(b => b.addEventListener('click', () => { setFilter(b.dataset.filter); render(); }));
$('#search').addEventListener('input',render); $('#refresh').addEventListener('click',cargar); cargar();
