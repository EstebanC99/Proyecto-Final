# US-27 — Flujo de navegación: Notificaciones de la agenda

## Entrada
- Tap en tile "Mi calendario" del home (US-05) → se muestra la agenda con chips de estado
- Tap en notificación del sistema → abre la app y navega al evento correspondiente

## Estados / pantallas

| Estado | Archivo | Descripción |
|--------|---------|-------------|
| Lock screen con notificaciones | `01-notificacion-sistema.html` | Pantalla de bloqueo documentando cómo se ven las notificaciones locales |
| Agenda con chips de notificación | `02-agenda-con-notificaciones.html` | Lista de eventos con indicadores de estado de recordatorio |

## Diagrama de flujo

```
  Home (US-05)
       │ tap "Mi calendario"
       ▼
  US-23/27 Agenda con chips de notificación [02]
       │
       ├── Tap chip "Recordatorio activo"
       │       └──► US-25 Editar evento (sección recordatorio activa)
       │
       ├── Tap chip "Sin recordatorio"
       │       └──► US-25 Editar evento (sección recordatorio pre-seleccionada)
       │
       └── [Al momento programado]
               │ flutter_local_notifications dispara
               ▼
           Lock screen / notification tray [01]
               │ tap en notificación
               ▼
           App abre → navega al evento correspondiente
```

## Transiciones

| Origen | Destino | Disparador | Animación |
|--------|---------|------------|-----------|
| Agenda lista | US-25 edición | tap chip | push slide-right + fade 250 ms |
| Notificación del sistema | Evento en la app | tap notificación | app abre (si cerrada) o push, fade 250 ms |

## Reglas de gobierno del flujo

- **Las notificaciones son locales.** Se programan desde el dispositivo con
  `flutter_local_notifications`. No dependen de push/servidor para el MVP.
- **Alcance de la notificación:** se dispara en todos los dispositivos de los miembros
  del equipo con permisos sobre la persona a cargo.
- **Sincronización entre dispositivos:** queda para iteraciones post-MVP (requiere backend).
  En MVP, cada dispositivo programa sus propias notificaciones.
- **Cancelación automática:** al eliminar un evento (US-26) o al desactivar el recordatorio,
  la notificación programada se cancela por su ID (`evento_id`).
- **Permisos del sistema:** al primer uso de la agenda, se solicita permiso de
  notificaciones al sistema operativo. Si se deniega, los chips muestran estado "Sin permiso"
  (fuera del alcance de las pantallas aquí documentadas; se incluirá en US futuras).
- **Eventos vencidos:** no muestran chip de notificación. El recordatorio de un evento pasado
  ya fue disparado o cancelado.
