# US-27 — Pantalla: Agenda con estado de notificaciones

## Objetivo
Mostrar la lista de eventos de la agenda con chips de estado que indican si cada evento
tiene un recordatorio programado. El usuario puede reconocer de un vistazo qué eventos
tienen notificación activa sin tener que abrir cada uno.

## Layout (jerarquía de componentes)

```
StatusBar (28px)
AppBar (56px)
  ├── ARROW_BACK (40px tap)
  ├── Titulo "Mi calendario"
  └── ADD circular (40px, bg #0284C7)
ChipContexto "Alicia Rodriguez" (margin 12px 16px)
ScrollContent
  ├── DateGroupLabel "HOY · 5 JUN"
  │   ├── EventCard — Toma de medicacion 09:00
  │   │     └── NotificationStatusChip ACTIVO
  │   │           [NOTIFICATIONS 14px #0284C7] "Recordatorio activo" (bg #E0F2FE)
  │   └── EventCard (pasado, opacity 0.5) — Fisioterapia 08:00
  │         (sin chip de notificacion — evento vencido)
  ├── DateGroupLabel "MAÑANA · 6 JUN"
  │   ├── EventCard — Control medico 15:30
  │   │     └── NotificationStatusChip ACTIVO
  │   │           [NOTIFICATIONS 14px #0284C7] "Recordatorio activo" (bg #E0F2FE)
  │   └── EventCard — Llamada familiar 18:00
  │         └── NotificationStatusChip INACTIVO
  │               [NOTIFICATIONS 14px #9AA5A5] "Sin recordatorio" (bg #EDF1F1)
  └── [padding bottom 88px para FAB]
FAB ADD (absolute bottom 24 right 16, bg #0284C7)
```

## Variantes del chip de notificacion

### Chip activo
```
bg: #E0F2FE
color: #0284C7
icono: NOTIFICATIONS 14px #0284C7
texto: "Recordatorio activo"
padding: 4px 10px
border-radius: 999px
font-size: 11px, font-weight: 500
```

### Chip inactivo
```
bg: #EDF1F1
color: #9AA5A5
icono: NOTIFICATIONS 14px #9AA5A5
texto: "Sin recordatorio"
padding: 4px 10px
border-radius: 999px
font-size: 11px, font-weight: 500
```

## Interacciones

- Tap en chip "Recordatorio activo" → US-25 Editar evento (sección recordatorio abierta,
  con opcion de desactivar)
- Tap en chip "Sin recordatorio" → US-25 Editar evento (sección recordatorio
  pre-seleccionada, con opcion de activar)
- Tap en el resto de la EventCard → US-25 Editar evento (comportamiento habitual de US-23)
- Los dos targets (chip vs. resto de la card) son independientes pero llevan al mismo lugar
  con diferente foco inicial

## Reglas de diseño

1. Los chips solo se muestran en eventos futuros. Los eventos vencidos (opacity 0.5)
   no tienen chip de notificacion.
2. Los chips diferencian claramente activo vs. inactivo por color y texto, no solo por
   el icono, para cumplir requisitos de accesibilidad.
3. El chip no oculta ni compite con el titulo del evento; se posiciona como metadato
   secundario debajo del titulo y la descripcion.
