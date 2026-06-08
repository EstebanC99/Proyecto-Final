# US-25 — Flujo de navegación: Modificación de evento

## Entrada
- Tap en tarjeta de evento futuro en US-23 → formulario editable
- Tap en tarjeta de evento pasado en US-23 → formulario readonly (vencido)

## Estados de la pantalla
1. **Editable** (`01-editar-evento.html`): evento futuro, campos habilitados
2. **Vencido / readonly** (`02-evento-vencido.html`): evento pasado, campos deshabilitados

## Salidas
| Acción                          | Destino                   |
|---------------------------------|---------------------------|
| ARROW_BACK (editable)           | US-23 agenda lista        |
| ARROW_BACK (vencido)            | US-23 agenda lista        |
| "Guardar cambios" (válido)      | US-23 con evento actualizado (sin pantalla de éxito separada) |
| "Guardar cambios" (inválido)    | misma pantalla con errores inline |
| "Guardar cambios" (disabled)    | sin efecto                |

## Reglas de negocio
- Un evento solo es editable si su fecha y hora son estrictamente mayores a ahora.
- La validación del estado (futuro/pasado) se hace en el submit y también al cargar la pantalla.
- Eventos pasados son completamente readonly: todos los campos y el botón quedan deshabilitados.
- No se puede cambiar la fecha de un evento futuro a una fecha pasada.
- Solo usuarios con permiso "Gestionar agenda" pueden acceder a este formulario.
