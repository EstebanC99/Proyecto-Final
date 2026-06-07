# US-23 — Pantalla: Agenda con eventos

## Objetivo
Mostrar al usuario los eventos programados de la persona a cargo, agrupados por fecha,
con indicación clara de cuáles ya pasaron (readonly) y cuáles son editables.

## Layout (jerarquía de componentes)
```
StatusBar (28px)
AppBar (56px)
  ├── ARROW_BACK (40px tap)
  ├── Título "Mi calendario"
  └── ADD circular (40px, bg #0284C7)
ChipContexto "Alicia Rodríguez" (margin 12px 16px)
ScrollContent
  ├── DateGroupLabel "HOY · 5 JUN"
  │   ├── EventCard (futuro) — Toma de medicación 09:00
  │   └── EventCard (pasado, opacity 0.5) — Fisioterapia 08:00
  ├── DateGroupLabel "MAÑANA · 6 JUN"
  │   ├── EventCard (futuro) — Control médico 15:30
  │   └── EventCard (futuro) — Llamada familiar 18:00
  └── [padding bottom 88px para FAB]
FAB ADD (absolute bottom 24 right 16)
```

## Interacciones
- Tap EventCard futuro → US-25 edición
- Tap EventCard pasado → US-25 modo readonly (vencido)
- Tap FAB / ADD AppBar → US-24 nuevo evento
- Long press EventCard futuro → bottom sheet con opciones (editar / eliminar) — reservado post-MVP

## Anotaciones de diseño
1. Eventos vencidos: opacity 0.5 + LOCK icon — no editables (integridad del histórico)
2. ADD en AppBar y FAB son redundantes por convención Material: el FAB es el destino principal
3. El chip de contexto indica sobre qué persona se está viendo la agenda
4. DateGroupLabel usa "HOY" y "MAÑANA" para las primeras fechas, luego día abreviado
