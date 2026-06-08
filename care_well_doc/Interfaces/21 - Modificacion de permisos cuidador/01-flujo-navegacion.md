# US-21 — Flujo de navegacion

## Objetivo
Permitir al Responsable ajustar los permisos granulares de un Cuidador sobre una persona
a cargo, con feedback inmediato al guardar.

## Entradas a esta pantalla
- Desde la pantalla de detalle del miembro (Mi equipo > tarjeta Cuidador > "Permisos")
- Desde un acceso rapido en la lista del equipo (icono de escudo o menu contextual)

## Estados de la pantalla

### Cargando
Skeleton loader en las filas de permisos (3 barras grises animadas).
El boton "Guardar cambios" aparece deshabilitado (opacity 0.4).

### Con datos (estado normal)
Lista completa de 6 permisos con sus toggles en el estado actual del miembro.
Boton "Guardar cambios" habilitado.

### Guardando
Boton muestra indicador de progreso circular (blanco, 20px) reemplazando el texto.
Toggles deshabilitados temporalmente para evitar doble envio.

### Guardado OK
Snackbar verde animado aparece desde abajo: "Permisos de Sandra actualizados".
Se mantiene la pantalla para que el responsable pueda seguir ajustando.

### Error al guardar
Snackbar rojo: "No se pudieron guardar los cambios. Intenta de nuevo."
Los toggles vuelven al estado anterior al intento.

### Vacio (sin permisos disponibles)
No aplica — los permisos son un conjunto fijo definido por el sistema.

## Salidas
- ARROW_BACK: vuelve a la pantalla anterior (detalle del miembro o lista del equipo)
- Guardar cambios: persiste y muestra snackbar de exito

## Navegacion relacionada
- US-22: desde esta pantalla se accede a la baja del cuidador (boton o menu overflow)
- US-18: mismo patron para Responsable (referencia visual)
