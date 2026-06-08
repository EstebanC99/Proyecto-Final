# Flujo de navegación — US-31 Registro de estados de ánimo

## Entrada
- Desde el módulo "Mi salud" → card o botón "Estado de ánimo"
- Ruta go_router: `/health/mood`

## Pantallas del flujo

```
Mi salud (hub)
    │
    ├─► [01] Selector de estado de ánimo   /health/mood/register
    │         │
    │         └─► Botón "Registrar" ──► Snackbar "Registro guardado" → vuelve a Mi salud
    │
    └─► [02] Historial de ánimo            /health/mood/history
              │
              └─► AppBar back → Mi salud
```

## Interacciones principales

### Pantalla 01 — Selector
| Interacción | Resultado |
|---|---|
| Tap en círculo de estado | Selección animada (scale 1.0 → 1.1, borde aparece) |
| Tap en otro estado ya seleccionado | Deselecciona el anterior, selecciona el nuevo |
| Campo Observación (opcional) | Teclado sube, pantalla hace scroll |
| Botón "Registrar" (siempre visible) | Si ningún estado seleccionado → shake + mensaje "Seleccioná un estado" |
| Botón "Registrar" con estado seleccionado | Loading 400 ms → Snackbar éxito → pop |

### Pantalla 02 — Historial
| Interacción | Resultado |
|---|---|
| Tap en registro de lista | Abre bottom sheet con detalle completo |
| Pull to refresh | Recarga el historial |
| Scroll vertical | Carga más registros (paginación) |

## Navegación de salida
- Éxito en registro → `pop()` hacia Mi salud con resultado `registered: true`
- AppBar back → `pop()` sin resultado
- Historial back → `pop()` hacia Mi salud
