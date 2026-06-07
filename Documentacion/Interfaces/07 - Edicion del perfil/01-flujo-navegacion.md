# US-07 Edicion del perfil — Flujo de navegacion

> Mapa de navegacion del flujo de edicion de perfil. Referencia los tokens de
> `00-sistema-diseno.md`. Ruta sugerida en `go_router`: `/profile/edit` (push sobre
> `/profile` de US-06).

---

## 1. Vista general

```
  US-06 Mi Perfil
  (boton editar en AppBar o FAB)
          |
          | push slide-right + fade 250ms
          v
  +-----------------------------------------------+
  |   PERFIL EDITABLE  [01]                        |
  |   AppBar: <- Mi Perfil                          |
  |   Cada fila con boton EDIT (lapiz) a derecha   |
  +-----------------------------------------------+
          |
          | tap EDIT en fila "Telefono"
          v
  +-----------------------------------------------+
  |   CAMPO EN EDICION  [02]                       |
  |   Fila Telefono: [ input ] [X] [v]             |
  |   Resto de filas: solo lectura con lapiz       |
  +-----------------------------------------------+
          |
    ------+------
    |            |
    | tap CLOSE  | tap CHECK
    v            v
  [01]     +-----------------------------------------------+
  (cancel) |   GUARDANDO  [03]                             |
           |   Fila Telefono: [ input disabled ] [spinner] |
           +-----------------------------------------------+
                    |
              ------+------
              |            |
           200 OK       error servidor
              |            |
              v            v
  +------------------+   Fila vuelve a modo edicion
  |  CAMBIO GUARDADO |   + mensaje de error inline bajo
  |  [04]             |   el input
  |  Snackbar 3s     |   -> [02] para corregir y reintentar
  |  Nuevo valor     |
  |  visible en fila |
  +------------------+
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| US-06 Mi Perfil | Perfil editable [01] | tap boton editar en AppBar de US-06 | push slide-right + fade 250ms |
| Perfil editable [01] | Campo en edicion [02] | tap EDIT (lapiz) de una fila | expansion inline de la fila, fade 150ms, sin cambio de ruta |
| Campo en edicion [02] | Perfil editable [01] | tap CLOSE o back del sistema | colapso inline, fade 150ms; descarta cambios no guardados |
| Campo en edicion [02] | Guardando [03] | tap CHECK | input disabled + spinner reemplaza botones, fade 100ms |
| Guardando [03] | Cambio guardado [04] | respuesta 200 | input colapsa, fila vuelve a reposo con nuevo valor, snackbar fade-in |
| Guardando [03] | Campo en edicion [02] | respuesta de error | spinner retira, botones reaparecen, mensaje de error bajo input |
| Cambio guardado [04] | Perfil editable [01] | snackbar auto-dismiss (3s) | snackbar fade-out 200ms; pantalla queda en reposo |
| Perfil editable [01] | US-06 Mi Perfil | tap ARROW_BACK | pop con datos actualizados, slide-left + fade 250ms |

---

## 3. Reglas de gobierno del flujo

- **Un solo campo en edicion a la vez.** Si el usuario toca el lapiz de otra fila
  mientras hay un campo activo, ese campo se cancela automaticamente (como CLOSE)
  y el nuevo campo entra en modo edicion. No se pierden datos guardados; solo se
  descarta el cambio no confirmado del campo que estaba activo.

- **CHECK siempre habilitado en modo edicion.** La validacion ocurre al pulsar CHECK.
  Si el valor no es valido, el campo permanece en modo edicion con un mensaje de error
  inline (no se hace el request). Si el valor es identico al original, CHECK puede
  comportarse como CLOSE (sin request, colapso silencioso).

- **Back del sistema durante edicion.** Si hay un campo activo, el back descarta el
  cambio en curso y colapsa el campo (equivalente a CLOSE). Si no hay campo activo,
  el back sale de la pantalla hacia US-06. No se muestra dialogo de confirmacion
  (el usuario solo pierde el cambio del campo que estaba editando, no datos guardados).

- **El rol nunca es editable.** La fila de Rol no tiene boton EDIT. Si el usuario
  no entiende por que, puede consultar la seccion de ayuda en Settings (fuera del
  alcance de este flujo).

- **Actualizacion optimista (opcional).** El valor nuevo puede mostrarse inmediatamente
  en la fila al confirmar (antes de la respuesta del servidor) y revertirse si hay error.
  Esto es una decision de implementacion delegada a `dev-flutter` segun la latencia
  esperada del backend.

---

## 4. Puntos de entrada y salida

| Punto | Tipo | Descripcion |
|---|---|---|
| US-06 Mi Perfil | Entrada | Boton editar en AppBar de la pantalla de visualizacion |
| US-06 Mi Perfil | Salida (back) | ARROW_BACK o gesto de back del sistema |
| US-06 Mi Perfil | Salida (guardado) | Tras cambio guardado, el back lleva a US-06 con datos actualizados |
