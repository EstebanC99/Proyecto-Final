# US-11 Eliminacion de cuenta — Flujo de navegacion

> Mapa de navegacion del flujo de eliminacion de cuenta dentro del modulo Configuracion.
> La confirmacion es un dialog modal; no hay ruta separada en go_router para el dialog.
> Ruta de configuracion: `/settings`.

---

## 1. Vista general (happy path + ramas de error)

```
                   ┌──────────────────────────────────────────┐
  Configuracion ──►│   CONFIGURACION  [01]                    │
                   │   [DELETE]  Eliminar cuenta ●[›]         │  <- item activo (errorContainer)
                   └────────────────┬─────────────────────────┘
                          tap "Eliminar cuenta"
                                    │
                          showDialog (modal)
                                    ▼
                   ┌──────────────────────────────────────────┐
                   │   DIALOG: ¿Eliminar tu cuenta?  [02]     │
                   │   [WARNING] Icono advertencia            │
                   │   "Esta accion es irreversible..."       │
                   │   [Campo: escribi DELETE               ] │
                   │   [  Eliminar mi cuenta  ] (disabled)    │
                   │   [        Cancelar       ]              │
                   └────────────────┬─────────────────────────┘
                                    │
                    ┌───────────────┴────────────────┐
                    │ campo == "DELETE" exacto?       │
                    └──────┬─────────────────┬────────┘
                        no │                 │ si
                           ▼                 ▼
                  [boton disabled]   [boton activo #D14343]
                                              │
                                   tap "Eliminar mi cuenta"
                                              ▼
                   ┌──────────────────────────────────────────┐
                   │   ENVIANDO...  [02b]                      │
                   │   Boton: spinner, controles disabled      │
                   └────────────────┬─────────────────────────┘
                                    │
                          ┌─────────┴──────────┐
                          │ 200 OK             │ Error de red
                          ▼                    ▼
               ┌─────────────────┐   ┌──────────────────────────┐
               │  EXITO  [03]    │   │  ERROR RED  [02c]         │
               │  go('/login')   │   │  Boton vuelve activo      │
               │  SnackBar       │   │  Toast: "No se pudo       │
               │  confirmacion   │   │  eliminar. Intentalo      │
               └─────────────────┘   │  de nuevo."              │
                                     │  Campo conserva "DELETE"  │
                                     └──────────────────────────┘
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| Configuracion [01] | Dialog [02] | tap "Eliminar cuenta" | showDialog, fade + scale 200 ms |
| Dialog [02] | Cancelado | tap "Cancelar" o tap scrim | dismiss, fade 150 ms, vuelve a [01] |
| Dialog [02] | Enviando [02b] | tap "Eliminar mi cuenta" (DELETE correcto) | boton → spinner, controles fade-disable 150 ms |
| Enviando [02b] | Login | respuesta 200 | dismiss dialog, go('/login'), fade 300 ms, SnackBar |
| Enviando [02b] | Error [02c] | error de red / 5xx | boton vuelve activo, toast slide-up 150 ms |
| Dialog [02] | Configuracion [01] | ARROW_BACK del sistema | dismiss dialog, sin cambio de ruta |

---

## 3. Reglas de gobierno del flujo

- **El dialog es modal; el scrim no es tappable para descartar.**
  El usuario debe usar el boton "Cancelar" explicitamente. Razon: evitar cierres
  accidentales del dialog en una accion tan critica.
  Excepcion: el back del sistema (gesto o boton fisico) si descarta el dialog.

- **El campo DELETE es case-sensitive y no admite espacios.**
  Trim al comparar: "DELETE " (con espacio) no habilita el boton.

- **Al cancelar, el campo se resetea.**
  Si el usuario reabre el dialog, el campo vuelve a estar vacio. No se persiste
  el estado del dialog entre aperturas.

- **El estado loading no tiene timeout en el front.**
  Si el servidor no responde, el loading persiste hasta que la conexion falla
  (el OS reporta el error). Luego se muestra el toast de error.

- **Tras el exito no hay vuelta atras en la pila.**
  `go('/login')` reemplaza toda la pila de navegacion. El usuario no puede
  presionar "atras" para volver a una sesion que ya no existe.

- **La sesion se cierra localmente antes de llamar al servidor.**
  Se invalida el token local y se limpia el almacenamiento seguro. Si la llamada
  al servidor falla, el usuario igual queda deslogueado localmente (la cuenta
  persiste en el servidor hasta que se reintente, pero no puede acceder con esas
  credenciales).

---

## 4. Rutas go_router

| Pantalla | Ruta | Tipo |
|---|---|---|
| Configuracion | `/settings` | GoRoute |
| Dialog confirmacion | sin ruta propia | showDialog() desde la pantalla |
| Login (tras exito) | `/login` | go() reemplazando pila |
