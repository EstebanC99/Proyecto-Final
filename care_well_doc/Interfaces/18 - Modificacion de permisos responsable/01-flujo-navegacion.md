# US-18 — Flujo de navegación: Modificación de permisos de responsable

## Entrada
- Desde la pantalla de detalle del miembro en "Mi equipo" (al pulsar "Gestionar permisos" o similar en el perfil de un responsable).
- go_router: `/care-team/member/:memberId/permissions`
- Parámetros de ruta: `memberId` (ID del miembro cuyo permiso se edita), `dependentId` (ID de la persona a cargo, inferido del contexto de equipo activo).

## Flujo principal
```
Mi equipo (lista)
  └─> Detalle de miembro (Carlos Pérez)
        └─> [Gestionar permisos] ──> 01-permisos-responsable.html  (pantalla principal)
                                          │
                                    [Toggle ON/OFF × N]
                                          │
                                    [Guardar cambios]
                                          │
                                    Llamada API PATCH /permissions
                                          │
                                    02-cambio-guardado.html  (snackbar confirmación)
                                          │
                                    [auto-dismiss 3 s] ──> vuelve a la misma pantalla
```

## Flujo alternativo — error de red
```
[Guardar cambios]
  └─> API falla
        └─> Snackbar de error: "No se pudo guardar. Intentá de nuevo."
              (bg #D14343, texto blanco, sin acción)
```

## Navegación de salida
- ARROW_BACK → vuelve a detalle del miembro sin guardar (cambios descartados sin confirmación, dado que no hay datos sensibles persistidos).
- Snackbar auto-dismiss → permanece en la pantalla de permisos (permite seguir editando).

## Estados de pantalla
| Estado    | Descripción                                                              |
|-----------|--------------------------------------------------------------------------|
| Normal    | Permisos cargados, toggles interactivos                                  |
| Guardando | Botón muestra spinner, toggles deshabilitados, overlay sutil             |
| Exito     | Snackbar verde-negro confirma cambio, toggles vuelven a ser interactivos |
| Error     | Snackbar rojo-oscuro, toggles se mantienen en el estado editado          |

## Notas de navegación
- No se usa un dialog de confirmación: la acción es de bajo riesgo (reversible en cualquier momento).
- Los cambios no persisten localmente; si el usuario presiona BACK sin guardar, los toggles vuelven al estado del servidor en la próxima carga.
