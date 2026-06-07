# 03 · Alta de persona a cargo — Formulario con errores de validación

> Estado de error del formulario. Tokens en `00-sistema-diseno.md`. HTML: `html/02-formulario-error.html`.

## Proposito
Indicar al Responsable cuales campos tienen datos inválidos o faltantes antes de enviar la
solicitud al servidor, con mensajes claros y localizados en cada campo.

## Campos en error en este estado

- **Nombre:** campo vacío (requerido). Borde error + helper "Ingresá el nombre."
- **DNI:** formato inválido (letras o longitud incorrecta). Borde error + helper
  "Ingresá un DNI válido (solo números, 7-8 dígitos)."

## Componentes y especificaciones de los campos en error

| Elemento | Especificacion |
|---|---|
| Borde del input | 2 dp solid `error #D14343` |
| Ícono prefijo | cambia a color `error #D14343` |
| Helper text | fila 18 dp bajo el input: ícono ERROR 16 dp `error` + texto 12 px `error` font-weight 500 |
| Ícono ERROR 16 dp | `<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>` |

## Comportamiento

- Los campos válidos (Apellido, Fecha, Email) mantienen su estado normal sin helper.
- El helper de error se limpia on-change: en cuanto el usuario empieza a escribir en el
  campo con error, el borde vuelve a `outline` y el helper desaparece.
- El scroll hace foco en el primer campo con error al pulsar el botón.
- El botón "Registrar persona" permanece activo (T&C ya marcado); el usuario puede reintentar.

## Navegacion

- Mismo estado que [01] pero con errores visibles. Al corregir todos los campos → estado [01]
  con campos válidos. Al volver a pulsar "Registrar persona" → [03] cargando.
