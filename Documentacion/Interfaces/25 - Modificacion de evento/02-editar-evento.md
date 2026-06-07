# US-25 — Pantalla: Editar evento (futuro)

## Objetivo
Permitir al usuario modificar los datos de un evento futuro. Los campos se pre-cargan
con los valores actuales y un banner azul refuerza que solo se pueden editar eventos futuros.

## Layout (jerarquía de componentes)
```
StatusBar (28px)
AppBar (56px)
  ├── ARROW_BACK
  └── Título "Editar evento"
ScrollContent (padding 16px 24px 32px)
  ├── Banner info (bg #E0F2FE, color #0284C7)
  │   [CALENDAR 16px] "Solo podés modificar eventos futuros."
  ├── Field: Fecha * (pre-cargado "10/06/2026")
  ├── Field: Hora * (pre-cargado "15:30")
  ├── Field: Descripción * (pre-cargado "Control médico mensual")
  ├── Fila de notificación (toggle ON)
  └── Botón "Guardar cambios" (bg #0284C7)
```

## Interacciones
- Campos editables: tap abre picker nativo del SO (fecha/hora) o teclado (descripción)
- Toggle notificación: tap alterna
- "Guardar cambios": valida → si OK guarda y vuelve a US-23 con feedback snackbar
- ARROW_BACK: confirma si hay cambios no guardados (bottom sheet "Descartar cambios")

## Anotaciones de diseño
1. Solo editable si fecha > ahora — validado en submit
2. Banner azul es informativo, no de error: orienta sin asustar
3. Pre-carga de valores: reduce reingreso de datos, menor fricción
