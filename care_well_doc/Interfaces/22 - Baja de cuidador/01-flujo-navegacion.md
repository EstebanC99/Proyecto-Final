# US-22 — Flujo de navegacion

## Objetivo
Permitir al Responsable quitar a un Cuidador del equipo de cuidado, con confirmacion
explicita antes de ejecutar la accion.

## Entradas a esta pantalla (trigger del dialog)
- Desde la pantalla de permisos del cuidador (US-21): boton o menu overflow "Quitar del equipo"
- Desde la tarjeta del cuidador en la lista de Mi equipo: accion rapida deslizando o via menu

## Estados

### Dialog de confirmacion (estado inicial de esta pantalla)
La pantalla de permisos del cuidador queda visible y atenuada bajo el scrim.
El dialog se centra verticalmente en la pantalla.

### Procesando
Boton "Quitar del equipo" muestra CircularProgressIndicator blanco 20px.
Ambos botones se deshabilitan para evitar doble accion.

### Exito
Dialog se cierra, navegacion automatica hacia la lista de Mi equipo.
Snackbar de confirmacion: "Sandra fue quitada del equipo" (bg #323232, CHECK verde).

### Error
Dialog permanece abierto. Texto de error debajo del boton destructivo:
"No se pudo completar. Intentalo de nuevo." en #D14343, 13px.

### Cancelar
Tap en "Cancelar" o en el scrim: dialog se cierra, vuelve a la pantalla de permisos
sin cambios.

## Salidas
- Quitar del equipo (confirmar): accion ejecutada, navegacion a lista de Mi equipo
- Cancelar: cierre del dialog, regreso a permisos de Sandra (US-21)
- Tap en scrim: identico a cancelar

## Navegacion relacionada
- US-21: pantalla de origen de esta accion
- US-19: patron identico para baja de Responsable (referencia visual)

## Consideraciones UX
- Accion reversible: el texto del dialog lo informa explicitamente
- Sin campo de confirmacion de texto (no se exige tipear el nombre): la poblacion objetivo
  incluye personas mayores o con poca experiencia tecnologica — la friccion debe ser
  minima y clara, no punitiva
- El scrim sobre la pantalla de fondo contextualiza la accion sin abandonar el flujo
