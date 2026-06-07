# US-18 — Pantalla: Permisos de responsable (estado normal)

## Objetivo
Mostrar la lista completa de permisos configurables del responsable sobre la persona a cargo, con sus estados actuales, y permitir modificarlos antes de guardar.

## Layout (jerarquía de componentes)
```
StatusBar (28px, dark)
AppBar
  ├─ ARROW_BACK 24px (tappable 48x48)
  └─ Título "Permisos de Carlos" (16px bold, centrado)

MemberHeader (bg #FFF, padding 20px, border-bottom 1px #EDF1F1)
  ├─ Avatar 52px (bg #C9EDE8, inicial "C", 20px bold #1A8C82)
  ├─ Columna texto
  │   ├─ Nombre "Carlos Pérez" (16px bold #16201F)
  │   ├─ Badge "Responsable" (chip teal: bg #C9EDE8, texto #1A8C82, 12px 600, radius 100px, padding 2px 10px)
  │   └─ Email "carlos@ejemplo.com" (13px #566060)
  └─ (sin acciones)

SectionTitle "Permisos sobre Alicia Rodríguez" (14px bold, margin 16px 16px 8px 16px)
  └─ "Alicia Rodríguez" resaltado en #1A8C82

PermissionList (scroll, bg #FFF)
  ├─ PermissionRow [ON]  "Editar datos personales"
  ├─ PermissionRow [ON]  "Gestionar agenda"
  ├─ PermissionRow [ON]  "Gestionar equipo de cuidado"
  ├─ PermissionRow [ON]  "Ver historial de salud"
  ├─ PermissionRow [OFF] "Enviar alertas de emergencia al equipo"
  └─ PermissionRow [OFF] "Eliminar personas a cargo"

PrimaryButton "Guardar cambios" (fijo al fondo, margin 16px, height 56px)
```

## Especificación de PermissionRow
- Alto: 56px mínimo
- Padding: 0 16px
- Layout: `display:flex; align-items:center; justify-content:space-between`
- Etiqueta: 15px, weight 500, color #16201F
- Separador: border-bottom 1px #EDF1F1 (excepto última fila)
- Toggle: alineado a la derecha, 40x22px
- Interacción: tap en toda la fila invierte el toggle

## Estados
- **Normal**: todos los toggles interactivos, botón habilitado.
- **Sin cambios pendientes**: el botón "Guardar cambios" aparece habilitado igualmente (no detecta dirty state en este prototipo, pero en la implementación podría deshabilitarse).
- **Cargando permisos** (estado inicial): skeleton de filas (ver spec separada si aplica).

## Interacciones
- Tap en PermissionRow: toggle cambia de estado instantáneamente (sin llamada a API todavía).
- Tap en "Guardar cambios": inicia PATCH a la API, botón pasa a estado loading.
- Tap en ARROW_BACK: pop sin guardar.
