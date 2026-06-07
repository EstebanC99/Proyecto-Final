# US-19 — Flujo de navegación: Baja de responsable del equipo

## Entrada
- Desde la pantalla de detalle del miembro o desde el menu de opciones (kebab) en la tarjeta del miembro en la lista "Mi equipo".
- La accion "Quitar del equipo" dispara el dialog de confirmacion sin navegacion (overlay in-place).
- No tiene ruta propia: es un dialog modal que se superpone a la pantalla actual (permisos o detalle del miembro).

## Flujo principal
```
Mi equipo (lista) o Detalle de miembro o Pantalla de permisos
  └─> [Quitar del equipo] ──> Dialog de confirmacion (overlay)
                                    │
                        ┌───────────┴───────────┐
                        │                       │
               [Quitar del equipo]          [Cancelar]
                        │                       │
               Llamada API DELETE           Dialog se cierra
               /care-team/member/:id            │
                        │                  vuelve a pantalla previa
               Loading en boton
                        │
               Respuesta 200 OK
                        │
               Navega a lista Mi equipo
               + Snackbar "Carlos fue quitado del equipo"
```

## Flujo alternativo — error de red
```
[Quitar del equipo] → API falla
  └─> Dialog se cierra
        └─> Snackbar de error: "No se pudo quitar a Carlos. Intentá de nuevo."
              (bg #D14343, texto blanco)
```

## Navegacion de salida
- "Cancelar" o tap en el scrim → cierra dialog, permanece en pantalla previa.
- Confirmacion exitosa → pop a la lista "Mi equipo" (se elimina el miembro de la lista localmente o se recarga).
- La pantalla de permisos de Carlos ya no es accesible tras la baja exitosa.

## Estados del dialog
| Estado    | Descripcion                                                               |
|-----------|---------------------------------------------------------------------------|
| Visible   | Dialog con dos botones activos                                            |
| Cargando  | Boton "Quitar del equipo" muestra spinner blanco, "Cancelar" deshabilitado|
| Error     | Dialog se cierra, snackbar rojo en pantalla previa                        |

## Notas
- El tap en el scrim no cierra el dialog durante el estado "Cargando" (evita cancelaciones accidentales).
- La accion DELETE debe revocar el token de sesion del miembro quitado en el backend.
