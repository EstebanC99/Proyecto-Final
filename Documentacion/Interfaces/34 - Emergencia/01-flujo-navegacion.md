# US-34 Emergencia — Flujo de navegación

## 1. Objetivo de la user story

Permitir que un usuario (responsable o cuidador con permiso) envíe una alerta de emergencia
a todos los miembros del equipo de cuidado de la persona a cargo, con confirmación anti-accidental
en dos pasos y retroalimentación clara del resultado.

---

## 2. Diagrama de flujo

```
[Menú principal]
       |
       | tap "Emergencia"
       v
[01 - Pantalla de emergencia]  ←── estado normal (botón disponible)
       |
       | tap botón circular EMERGENCIA
       v
[02 - Dialog de confirmación]  ←── overlay sobre pantalla de emergencia
       |
       |─── tap "Cancelar" ────────────────────────────────→ [01 - Pantalla de emergencia]
       |
       | tap "Sí, enviar alerta"
       v
[Estado: Enviando...]           ←── spinner en el botón del dialog / pantalla bloqueada
       |
       | respuesta OK del servidor
       v
[03 - Pantalla de alerta enviada]
       |
       | tap "Volver al inicio"
       v
[Menú principal]
```

---

## 3. Pantallas del flujo

| N.° | Archivo HTML | Descripción |
|---|---|---|
| 01 | `01-pantalla-emergencia.html` | Pantalla principal con botón pulsante |
| 02 | `02-confirmacion-dialog.html` | Dialog M3 de confirmación (overlay) |
| 03 | `03-alerta-enviada.html` | Confirmación post-envío con lista de notificados |

> El estado "Enviando..." se representa como variante de `02`: el botón del dialog pasa a
> loading (spinner) y ambos botones quedan deshabilitados. No se genera un HTML aparte.

---

## 4. Entradas a este flujo

| Origen | Acción | Destino |
|---|---|---|
| Menú principal | tap ítem "Emergencia" | `01 - Pantalla de emergencia` |

---

## 5. Salidas de este flujo

| Pantalla | Acción | Destino |
|---|---|---|
| `01 - Pantalla de emergencia` | ARROW_BACK / gesto back | Menú principal |
| `02 - Dialog confirmación` | tap "Cancelar" | `01 - Pantalla de emergencia` (dialog se cierra) |
| `03 - Alerta enviada` | tap "Volver al inicio" | Menú principal |

---

## 6. Permisos requeridos

- Solo usuarios con rol **Responsable** o **Cuidador con permiso de emergencia** pueden acceder
  a esta pantalla.
- Si el usuario no tiene permiso, el ítem del menú principal aparece deshabilitado (no oculto).

---

## 7. Consideraciones de navegación

- La pantalla de emergencia (`01`) usa `go_router` con ruta `/emergency`.
- La pantalla de éxito (`03`) reemplaza el stack de navegación: no permite volver con BACK
  a la pantalla de emergencia (evita reenvíos accidentales por gesto de back).
- El dialog de confirmación (`02`) es un `showDialog` nativo de Flutter, no una ruta separada.
- Al llegar a `03`, el botón de back del sistema no navega a `02` ni a `01`; va directamente
  al menú principal (comportamiento de `go_router` con `go()` en lugar de `push()`).
