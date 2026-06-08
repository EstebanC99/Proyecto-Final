# US-10 Cierre de sesion — Flujo de navegacion

> Mapa de navegacion del flujo de cierre de sesion dentro del modulo Configuracion.
> El cierre de sesion no tiene ruta propia: es un dialog sobre `/settings`.

---

## 1. Vista general (happy path + cancelacion)

```
                    ┌──────────────────────────────────────┐
   Configuracion ───►    CONFIGURACION  [01]                │
                    │   ── SESION ───────────────────────   │
                    │   [LOGOUT]  Cerrar sesion  ● [›]      │  ← item activo (errorContainer)
                    │   [DELETE]  Eliminar cuenta    [›]    │
                    └─────────────────┬────────────────────┘
                           tap "Cerrar sesion"
                                      ▼
                    ┌──────────────────────────────────────┐
                    │  CONFIGURACION  [01] (fondo atenuado) │
                    │  ┌────────────────────────────────┐  │
                    │  │  [WARNING]                      │  │
                    │  │  Cerrar sesion?                 │  │  ← ConfirmationDialog [02]
                    │  │  "Vas a salir de tu cuenta.    │  │
                    │  │   Podes volver a ingresar      │  │
                    │  │   cuando quieras."              │  │
                    │  │  [Cancelar]  [Cerrar sesion]   │  │
                    │  └────────────────────────────────┘  │
                    └─────────────────┬────────────────────┘
                             │                │
                       Cancelar          Confirmar
                             │                │
                             ▼                ▼
                    ┌──────────────┐  ┌──────────────────────┐
                    │ CONFIGURACION │  │  LOGIN  [03]          │
                    │  [01]        │  │  go('/login')         │
                    │  (sin dialog) │  │  stack limpiado       │
                    └──────────────┘  └──────────────────────┘
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| Configuracion [01] | Dialog [02] | tap "Cerrar sesion" | dialog slide-up + fade overlay 200 ms |
| Dialog [02] | Configuracion [01] | tap "Cancelar" o tap fuera del dialog | dialog fade-out 150 ms, overlay desaparece |
| Dialog [02] | Login [03] | tap "Cerrar sesion" (confirmar) | dialog cierra, luego `go('/login')` fade 250 ms |

---

## 3. Reglas de gobierno del flujo

- **No hay pantalla intermedia.** El cierre de sesion no requiere una pantalla propia.
  El dialog provee suficiente espacio para el mensaje y los dos botones.

- **Tap fuera del dialog cancela.** El scrim es interactivo. El tap en cualquier punto
  fuera del dialog descarta la accion sin cerrar sesion.

- **El back del sistema (Android) durante el dialog cancela.** Equivale a "Cancelar":
  cierra el dialog sin cerrar sesion.

- **Al confirmar, el stack se limpia.** Se usa `go('/login')` (no `push`) para reemplazar
  todo el stack de navegacion. El usuario no puede volver atras con el gesto de back desde
  el Login.

- **Los datos locales se limpian antes de navegar.** Token de sesion, cache y preferencias
  sensibles se borran del almacenamiento local antes de ejecutar la navegacion a Login.

- **El item "Cerrar sesion" vuelve al estado neutro destructivo al cancelar.** Solo tiene
  fondo `errorContainer` mientras el dialog esta abierto (indicador de que ese item disparo
  la accion).

- **Sin estado de carga prolongado.** El cierre de sesion es rapido (invalidar token + limpiar
  local storage). No hay pantalla de "Cerrando..." salvo un spinner breve en el boton del dialog
  durante ~500 ms antes de navegar a Login.
