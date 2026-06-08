# US-30 Registro de eventos de salud — Sistema de diseño

> Hereda el sistema de diseño global de CareWell. Este archivo documenta las decisiones
> específicas del sub-módulo Eventos de salud dentro de Mi salud.

---

## 1. Acento del sub-módulo

| Concepto              | Token / valor                                     |
|-----------------------|---------------------------------------------------|
| Acento eventos salud  | `eventsAccent #E11D48` / container `#FFF1F2`      |

El rojo rosado `#E11D48` corresponde al color del tile "Mi salud" en el home y en el hub,
manteniendo consistencia visual entre el punto de entrada y el sub-módulo de eventos.

## 2. Chips de tipo de evento

Cada tipo tiene su propio color semántico para diferenciar categorías de un vistazo:

| Tipo            | Bg chip    | Texto chip | Uso                           |
|-----------------|------------|------------|-------------------------------|
| Cita médica     | `#FFF1F2`  | `#E11D48`  | Consultas y controles         |
| Hospitalización | `#FFF7ED`  | `#EA580C`  | Internaciones                 |
| Medicación      | `#EFF6FF`  | `#2563EB`  | Cambios o inicios de medicación |
| Cirugía         | `#FDF4FF`  | `#9333EA`  | Procedimientos quirúrgicos    |
| Bienestar       | `#F0FDF4`  | `#16A34A`  | Altas, logros, estados positivos|

## 3. Componentes específicos

### 3.1 EventCard
- Bg `#FFFFFF`, radius 12 px, padding 16 px, sombra `0 2px 8px rgba(0,0,0,0.06)`.
- Chip de tipo (top-left), fecha (top-right, textSecondary, 12 px).
- Título (weight 700, 15 px).
- Cuerpo truncado a 1 línea (overflow ellipsis), 13 px, `textSecondary`.
- Mínimo 72 px de alto para objetivo táctil adecuado.

### 3.2 Selector de tipo (chips scrollables)
- Scroll horizontal sin barra visible.
- Chip activo: bg del tipo + borde 1.5 px del color del tipo.
- Chip inactivo: bg `#EDF1F1`, texto `#566060`.
- Altura 36 px, radius 18 px, padding 0 14 px, gap 8 px.

### 3.3 FAB
- Tamaño 56 px, radius 16 px, bg `#E11D48`, ícono ADD blanco 24 dp.
- Posición: bottom 24 px, right 20 px.
- Sombra `0 4px 12px rgba(225,29,72,0.35)`.

## 4. Notas
- La fecha se muestra siempre en formato "d MMM YYYY" (ej. "2 jun 2026").
- El campo Observaciones es opcional en el formulario.
- Los tipos de evento son los únicos campos obligatorios junto a descripción y fecha.
