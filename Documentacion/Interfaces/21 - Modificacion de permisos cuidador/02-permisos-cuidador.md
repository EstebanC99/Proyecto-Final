# US-21 — Especificacion: Pantalla de permisos de cuidador

## Objetivo de pantalla
Mostrar y permitir modificar los 6 permisos granulares asignados al Cuidador sobre
la persona a cargo seleccionada.

## Layout (jerarquia de componentes)

```
StatusBar (28px, #16201F)
AppBar (56px, #FFF, borde inferior)
  - IconButton ARROW_BACK 48x48dp
  - Title "Permisos de Sandra" centrado, 16px/700
MemberHeader (padding 20px 16px, #FFF, borde inferior)
  - Avatar 52px circular, bg #FCE2DA, inicial "S" bold #7A2E1A
  - Column
      - "Sandra Ruiz" 16px/700 #16201F
      - Badge "Cuidadora" bg #FCE2DA, text #7A2E1A, 12px/600, radius 100px
      - "sandra@ejemplo.com" 13px #566060
SectionTitle (margin 16px, 14px/700)
  - "Permisos sobre " + "Alicia Rodriguez" en #1A8C82
PermissionsList (bg #FFF, borde superior e inferior exterior)
  - PermissionRow x6 (min-height 56px, padding 0 16px, borde entre filas)
      - Label 15px/500 #16201F
      - Toggle ON o OFF
PrimaryButton fijo (bottom 24px, left/right 16px)
  - height 56px, bg #1A8C82, "Guardar cambios" 16px/700 #FFF, radius 16px
```

## Permisos y estado por defecto (Cuidador)

| # | Permiso                        | Estado por defecto |
|---|--------------------------------|--------------------|
| 1 | Ver datos personales           | ON                 |
| 2 | Ver agenda                     | ON                 |
| 3 | Editar agenda                  | OFF                |
| 4 | Ver historial de salud         | OFF                |
| 5 | Enviar alertas de emergencia   | OFF                |
| 6 | Gestionar equipo               | OFF                |

Razon: el Cuidador tiene permisos de lectura minimos por defecto. El acceso
de escritura y funciones sensibles requieren habilitacion explicita del Responsable.

## Interacciones
- Tap toggle: cambia estado inmediatamente en UI (optimistic update), se persiste al guardar
- Tap "Guardar cambios": envia cambios al backend, muestra loading en boton
- Swipe hacia atras / ARROW_BACK: si hay cambios no guardados, muestra dialog de confirmacion

## Diferencia visual clave vs US-18 (Responsable)
- Avatar: bg #FCE2DA vs #C9EDE8
- Badge: "Cuidadora" salmon vs "Responsable" teal
- Estado inicial de toggles: 2 ON vs 4+ ON
- Esta diferencia visual refuerza la jerarquia de roles sin texto adicional
