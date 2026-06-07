# US-25 — Pantalla: Evento vencido (readonly)

## Objetivo
Mostrar los datos de un evento ya ocurrido en modo solo-lectura. El usuario puede ver
el histórico pero no puede modificar nada. Un banner rojo contextualiza el estado.

## Layout (jerarquía de componentes)
```
StatusBar (28px)
AppBar (56px)
  ├── ARROW_BACK
  └── Título "Editar evento"
ScrollContent (padding 16px 24px 32px)
  ├── Banner error (bg #FBE3E3, color #D14343)
  │   [LOCK 16px] "Este evento ya ocurrió y no puede modificarse."
  ├── Field: Fecha (disabled, bg #EDF1F1)
  ├── Field: Hora (disabled)
  ├── Field: Descripción (disabled)
  ├── Fila de notificación (toggle disabled / OFF)
  └── Botón "Guardar cambios" (disabled, bg #C5CECE)
```

## Interacciones
- Ningún campo responde a tap (pointer-events: none en implementación)
- Toggle no responde a tap
- Botón no ejecuta acción
- ARROW_BACK funciona normalmente: vuelve a US-23

## Anotaciones de diseño
1. Readonly total para eventos pasados: integridad del histórico
2. Banner rojo bien visible: anticipa la limitación antes de que el usuario intente interactuar
3. Título "Editar evento" se mantiene: el usuario llegó con esa intención; el banner explica
4. Campos grises comunican estado disabled sin necesidad de texto adicional
