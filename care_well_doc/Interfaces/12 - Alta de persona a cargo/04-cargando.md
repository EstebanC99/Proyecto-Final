# 04 · Alta de persona a cargo — Estado de carga

> Estado mientras la petición POST está en vuelo. Tokens en `00-sistema-diseno.md`. HTML: `html/03-cargando.html`.

## Proposito
Bloquear la interaccion con el formulario mientras se procesa la solicitud, dando feedback
visual inmediato sin overlay oscuro (carga liviana, misma filosofia que US-02 §3.4).

## Especificaciones

| Elemento | Estado de carga |
|---|---|
| Todos los inputs | `disabled`: fondo `surfaceVariant #EDF1F1`, texto `textDisabled #9AA5A5`, no interactuables |
| Ícono prefijo | color `textDisabled #9AA5A5` |
| Bloque de foto | opacidad 0.5, no tappable |
| Checkbox T&C | disabled, no tappable |
| Botón | fondo `outline #C5CECE`, spinner 22 dp blanco (border-top animado), texto "Registrando..." |
| ARROW_BACK | disabled durante la carga (no se puede cancelar; la petición ya se envió) |

## Comportamiento

- No se muestra ningún overlay ni scrim. La pantalla mantiene su layout exacto con los
  campos rellenados; solo el fondo de los inputs cambia a `surfaceVariant`.
- El spinner CSS gira a 0.8 s linear.
- Si el servidor responde con 201 → transicion a [04] exito.
- Si el servidor responde con error → botón vuelve a estado activo, inputs se habilitan,
  aparece banner de error encima del formulario (fade + slide-down).
- Si no hay red → banner info "Sin conexion" + "Reintentar".
