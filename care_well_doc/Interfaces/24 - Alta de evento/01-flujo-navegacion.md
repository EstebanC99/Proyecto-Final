# US-24 — Flujo de navegación: Alta de evento

## Entrada
- Tap FAB ADD en US-23 (agenda lista o vacía)
- Tap ADD circular en AppBar de US-23
- Tap "Crear evento" en empty state de US-23

## Estados de la pantalla
1. **Formulario** (`01-nuevo-evento.html`): campos vacíos listos para completar
2. **Éxito** (`02-exito.html`): confirmación visual del evento creado

## Salidas
| Acción                    | Destino                   |
|---------------------------|---------------------------|
| ARROW_BACK                | US-23 agenda lista        |
| "Guardar evento" (válido) | 02-exito.html             |
| "Guardar evento" (inválido) | misma pantalla con errores inline |
| "Ver agenda" (desde éxito) | US-23 agenda lista       |

## Validaciones
- Fecha: requerida, no puede ser en el pasado
- Hora: requerida
- Descripción: requerida, mínimo 3 caracteres, máximo 200
- Toggle notificación: opcional, por defecto ON

## Reglas de negocio
- Solo usuarios con permiso "Gestionar agenda" pueden acceder.
- Notificaciones locales en MVP: no requiere integración Google Calendar.
- El evento se asocia automáticamente a la persona a cargo en contexto (chip).
