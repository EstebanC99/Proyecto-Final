# US-15 Eliminacion de persona a cargo — Flujo de navegacion

> Mapa de navegacion del flujo de eliminacion de una persona a cargo.
> No es una pantalla nueva: es un dialog modal que se muestra sobre la pantalla
> de perfil de US-14. No genera una ruta nueva en `go_router`.

---

## 1. Vista general

```
   US-14 (perfil persona) ──► tap MORE_VERT ──► menu contextual
                                                        │
                                              tap "Eliminar persona"
                                                        │
                                                        ▼
                             ┌──────────────────────────────────────┐
                             │  US-14 (perfil) ATENUADO             │
                             │  ┌────────────────────────────────┐  │
                             │  │  [WARNING]                     │  │
                             │  │  ¿Eliminar a Alicia?           │  │
                             │  │                                │  │
                             │  │  Se eliminaran todos sus datos │  │
                             │  │  y el acceso al equipo de      │  │
                             │  │  cuidado de Alicia. Esta       │  │
                             │  │  accion no se puede deshacer.  │  │
                             │  │                                │  │
                             │  │  [      Eliminar      ]        │  │
                             │  │  [      Cancelar      ]        │  │
                             │  └────────────────────────────────┘  │
                             └──────────┬───────────────────────────┘
                                        │
                        ┌───────────────┼───────────────────┐
                        │ tap Cancelar  │                   │ tap Eliminar
                        ▼               │                   ▼
               Dialog se cierra         │         ┌──────────────────────┐
               Vuelve a US-14           │         │  Estado: Eliminando   │
               (perfil normal)          │         │  Spinner en boton    │
                                        │         │  Cancelar disabled   │
                                        │         └───────┬──────────────┘
                                        │                 │
                                        │       ┌─────────┴──────────┐
                                        │       │ exito              │ error de red
                                        │       ▼                    ▼
                                        │  US-13 (listado)      Error inline
                                        │  Snackbar:            en dialog
                                        │  "Alicia fue          + reintentar
                                        │  eliminada"
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| US-14 MORE_VERT | Menu contextual | tap MORE_VERT | fade-in 150 ms |
| Menu contextual | Dialog US-15 | tap "Eliminar persona" | fade-in scrim + scale-in dialog 200 ms |
| Dialog | US-14 perfil normal | tap "Cancelar" | fade-out scrim + scale-out 150 ms |
| Dialog | Estado eliminando | tap "Eliminar" | boton → spinner in-place 150 ms |
| Estado eliminando | US-13 listado | respuesta exitosa | dialog fade-out + pop a US-13, snackbar slide-up |
| Estado eliminando | Dialog con error | fallo de red | spinner → error message fade-in |

---

## 3. Reglas de gobierno del flujo

- **El dialog NO genera ruta nueva.** Se implementa como `showDialog` en Flutter sobre
  la pantalla actual de US-14. El ARROW_BACK del sistema cuando el dialog esta visible
  es equivalente a "Cancelar": cierra el dialog y vuelve al perfil.

- **Solo Responsable con permiso de eliminacion accede a este dialog.** El menu
  contextual MORE_VERT filtra las opciones segun el rol y los permisos del usuario
  autenticado. Si no tiene permiso, la opcion "Eliminar persona" no aparece en el menu.

- **Tras la eliminacion exitosa, no es posible volver a US-14.** La persona ya no existe;
  se navega directamente a US-13 (listado) usando `go_router` con `pop` o `go`.
  Si el listado queda vacio, se muestra el estado vacio de US-13.

- **El snackbar de confirmacion se muestra en US-13, no en el dialog.** Esto refuerza
  que la accion fue completada y el usuario esta en un estado estable (la lista).

---

## 4. Relacion con otras US

| US relacionada | Relacion |
|---|---|
| US-14 Modificacion de persona a cargo | Pantalla host del dialog · acceso via MORE_VERT |
| US-13 Listado de personas a cargo | Destino tras eliminacion exitosa |
