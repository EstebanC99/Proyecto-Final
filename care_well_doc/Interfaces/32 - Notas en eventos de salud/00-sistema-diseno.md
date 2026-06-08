# US-32 Notas en eventos de salud — Sistema de diseño

> Este flujo hereda la paleta base y los tokens del sistema de diseño global de CareWell
> (`01 - Registro de usuario/00-identidad-visual.md`) y aplica el **color de módulo Mi salud**:
> rosa `#E11D48` / container `#FFF1F2`. Acá solo se documentan las decisiones específicas del flujo.

---

## 1. Tokens del módulo Mi salud

| Concepto | Token / valor |
|---|---|
| Acento módulo | `healthPrimary #E11D48` |
| Container módulo | `healthContainer #FFF1F2` |
| Primario global | `primary #1A8C82` |
| Background | `background #F6F8F8` |
| Surface | `surface #FFFFFF` |
| SurfaceVariant | `surfaceVariant #EDF1F1` |
| textPrimary | `#16201F` |
| textSecondary | `#566060` |
| textDisabled | `#9AA5A5` |
| outline | `#C5CECE` |
| Radios | card `12 dp` · nota `10 dp` · chip `999 dp` · input `12 dp` · botón `16 dp` |
| Objetivo táctil mín. | `48 dp` |
| FAB | `48 dp` · bg `#E11D48` · icono ADD blanco |

---

## 2. Componentes propios del flujo

### 2.1 Chip de categoría
- Fondo `#FFF1F2`, texto `#E11D48`, 11 px, peso 600, radio `999 dp`, padding `3px 10px`.
- Aparece en el AppBar junto al título del evento para identificar el tipo (Cita médica, Control, etc.).
- No es interactivo en esta pantalla.

### 2.2 Tarjeta de evento (resumen)
- Bg `surface #FFF`, radio `12 dp`, padding `16 dp`, sombra `0 2px 8px rgba(0,0,0,0.06)`.
- Jerarquía: fecha (13 px `textDisabled`) → cuerpo bold (15 px `textPrimary`) → observación (14 px `textSecondary`).

### 2.3 Tarjeta de nota
- Bg `surface #FFF`, radio `10 dp`, padding `14 dp`, sombra sutil.
- **Borde izquierdo 3 dp `#E11D48`** — identifica visualmente el módulo Mi salud y agrupa las notas.
- Fila de autoría: avatar circular `28 dp` (inicial + bg de color derivado del nombre) + nombre bold `13 dp` + separador "·" + timestamp `11 dp textDisabled`.
- Cuerpo de nota: `14 dp textPrimary`, interlineado `1.5`.

### 2.4 Avatar de autor
- Diámetro `28 dp`, letra inicial `12 dp bold`.
- Paleta de fondos (por nombre del autor, no configurable por el usuario):
  - María → bg `#C9EDE8` texto `#0A3D38`
  - Laura → bg `#FCE2DA` texto `#7A2E1A`
  - Colores adicionales a definir en el token `avatarPalette` (mapeo determinístico por índice de inicial).

### 2.5 Campo de nota (textarea)
- Label externo `13 dp` peso 500 `textSecondary` + asterisco `#E11D48`.
- Borde outline `1 dp #C5CECE`, radio `12 dp`, padding `12 dp 16 dp`.
- Alto mínimo `120 dp`, crece con el contenido.
- Focus: borde `2 dp #E11D48`.
- Placeholder `textDisabled`.

### 2.6 Botón primario módulo
- Igual a `PrimaryButton` global pero con `bg #E11D48` (acento módulo salud).
- Full-width, `56 dp`, radio `16 dp`.

---

## 3. Decisiones de diseño

1. **El autor de la nota es siempre el usuario autenticado.** No hay selector de autor.
   El nombre y el timestamp se resuelven en el servidor al guardar; el frontend solo envía el
   texto. Esto elimina fricción y evita suplantación.

2. **Borde izquierdo rosa como señalizador de módulo.** Dado que la pantalla de detalle de un
   evento puede recibir usuarios que lleguen desde la agenda o desde el menú principal, el borde
   izquierdo de color `healthPrimary` en cada nota ancla visualmente la sección al módulo Mi salud
   sin necesidad de subtítulos redundantes.

3. **FAB flotante para nueva nota.** El acceso a "Agregar nota" se expone como FAB (48 dp,
   esquina inferior derecha) en la pantalla de detalle del evento. No se usa un botón inline
   para mantener el área de lectura limpia cuando hay varias notas.

4. **Contexto del evento siempre visible al redactar.** La pantalla "Nueva nota" incluye una
   card de contexto (`#FFF1F2`) que muestra el nombre y fecha del evento al que pertenece la
   nota. Esto previene errores cuando el usuario abre la pantalla desde una notificación o
   desde la agenda.

5. **Sección "Notas del equipo" etiquetada.** El label `12 dp uppercase textSecondary` separa
   visualmente la ficha del evento de las notas colaborativas, dejando claro que las notas son
   aportadas por miembros del equipo de cuidado.

---

## 4. Mapa de estados

| Pantalla | Estado | Disparador |
|---|---|---|
| Detalle del evento | Con notas | evento tiene al menos 1 nota guardada |
| Detalle del evento | Sin notas (vacío) | evento nuevo o sin notas aún |
| Detalle del evento | Cargando | primera carga de notas |
| Nueva nota | Redactando | FAB pulsado |
| Nueva nota | Guardando | "Guardar nota" pulsado |
| Nueva nota | Error al guardar | fallo de red o servidor |
