# US-26 — Flujo de navegación: Eliminación de evento de agenda

## Entrada
- Long press sobre una EventCard futura en la lista de agenda (US-23)
- Tap en el ícono de menú contextual (tres puntos) de una EventCard futura → opción "Eliminar"
- Tap en "Eliminar evento" dentro de US-25 (Edición de evento), solo si el evento es futuro

## Estados de la pantalla

| Estado | Archivo | Descripción |
|--------|---------|-------------|
| Dialog de confirmación | `01-confirmar-eliminacion.html` | Overlay + dialog M3 sobre la agenda |

## Diagrama de flujo

```
  US-23 Lista agenda
       │
       │  long press / tap "Eliminar" en menú
       ▼
  ┌────────────────────────────────────────┐
  │   DIALOG CONFIRMAR ELIMINACIÓN  [01]   │
  │   Overlay rgba(0,0,0,0.4)              │
  │   Evento resaltado en fondo            │
  │   WARNING + título + descripción       │
  │   [Eliminar evento]  [Cancelar]        │
  └────────────┬───────────────────────────┘
               │
       ┌───────┴────────────┐
       │ tap "Eliminar"     │ tap "Cancelar" / back del sistema
       ▼                    ▼
  Eliminar +           Dialog se cierra
  SnackBar             (sin cambios)
  "Evento eliminado"
       │
       ▼
  US-23 Lista actualizada
  (o estado vacío si era el último)
```

## Transiciones

| Origen | Destino | Disparador | Animación |
|--------|---------|------------|-----------|
| US-23 lista | Dialog [01] | long press / tap menú | scrim fade-in 200 ms + dialog scale-in desde 95% 200 ms |
| Dialog [01] | US-23 actualizada | tap "Eliminar evento" | dialog fade-out 150 ms, scrim fade-out 150 ms, tarjeta eliminada fade+slide-up 200 ms |
| Dialog [01] | US-23 sin cambios | tap "Cancelar" o back | dialog slide-down 150 ms + scrim fade-out 150 ms |

## Reglas de gobierno del flujo

- **Solo eventos futuros son eliminables.** Los eventos vencidos no tienen opción "Eliminar"
  en ningún punto de la UI.
- **El dialog siempre confirma.** No hay eliminación directa sin paso de confirmación.
  Esto protege al usuario (cuidador apurado o mayor poco familiarizado con la app).
- **Sin "Deshacer" en MVP.** El SnackBar informa pero no ofrece reversión. Se añadirá
  en iteraciones posteriores.
- **Back del sistema (Android) en el dialog** actúa como "Cancelar": cierra el dialog
  sin eliminar nada.
- **Permisos:** Solo usuarios con permiso "Gestionar agenda" ven la opción eliminar.
  Los cuidadores sin ese permiso no ven el menú contextual ni el long press tiene efecto.
