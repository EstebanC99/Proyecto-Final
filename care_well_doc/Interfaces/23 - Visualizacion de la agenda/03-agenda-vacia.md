# US-23 — Pantalla: Agenda vacía

## Objetivo
Estado vacío de la agenda: orienta al usuario hacia la acción principal (crear un evento)
con un mensaje claro y no angustiante.

## Layout
```
StatusBar (28px)
AppBar (56px) — igual al estado con datos
ChipContexto "Alicia Rodríguez"
EmptyState (centrado verticalmente en el espacio restante)
  ├── Círculo 88px bg #E0F2FE
  │   └── CALENDAR 48px color #0284C7
  ├── Título "Agenda vacía" (20px bold)
  ├── Body "No hay eventos programados..." (14px #566060, max-width 280px)
  └── Botón primario "Crear evento" (bg #0284C7, max-width 240px)
```

## Interacciones
- Botón "Crear evento" → US-24 nuevo evento
- FAB ADD (si el usuario tiene permisos) → US-24 nuevo evento

## Anotaciones de diseño
1. Ícono en círculo de color módulo: coherencia visual con el tile del home
2. Botón en el empty state evita que el usuario tenga que buscar el FAB
3. Copy positivo: "Creá un recordatorio" en lugar de "No tenés eventos"
