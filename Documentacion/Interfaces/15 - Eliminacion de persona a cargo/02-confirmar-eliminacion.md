# US-15 Eliminacion de persona a cargo — Estado: Confirmar eliminacion

> Dialog de confirmacion de eliminacion. Se muestra sobre la pantalla de perfil
> de US-14 atenuada por un scrim. No hay pantalla nueva en la pila de navegacion.

---

## Objetivo

Comunicar de forma clara las consecuencias de eliminar a la persona a cargo y requerir
una confirmacion explicita del usuario antes de ejecutar la accion. Dar una salida
facil (Cancelar) para prevenir eliminaciones accidentales.

---

## Layout y jerarquia del dialog

```
┌────────────────────────────────────────────┐  ← pantalla US-14 atenuada
│                                            │    scrim rgba(0,0,0,0.4)
│    ┌──────────────────────────────────┐    │
│    │                                  │    │
│    │    [WARNING icon 24dp amber]     │    │  ← icono centrado
│    │                                  │    │
│    │    ¿Eliminar a Alicia?           │    │  ← 18px 700 centrado
│    │                                  │    │
│    │  Se eliminaran todos sus datos   │    │  ← cuerpo 14px 400 #566060
│    │  y el acceso al equipo de        │    │    line-height 1.5
│    │  cuidado de Alicia. Esta         │    │
│    │  accion no se puede deshacer.    │    │
│    │                                  │    │
│    │  ┌──────────────────────────┐    │    │  ← boton Eliminar
│    │  │       Eliminar           │    │    │    bg #D14343, texto blanco
│    │  └──────────────────────────┘    │    │    h: 44dp, radius: 12dp
│    │                                  │    │
│    │  ┌──────────────────────────┐    │    │  ← boton Cancelar
│    │  │       Cancelar           │    │    │    borde #C5CECE, texto #16201F
│    │  └──────────────────────────┘    │    │    h: 44dp, radius: 12dp
│    │                                  │    │
│    └──────────────────────────────────┘    │
│                                            │
└────────────────────────────────────────────┘
```

---

## Especificacion completa del dialog

### Scrim
- Background: `rgba(0, 0, 0, 0.4)`
- Cubre toda la pantalla (390x844)
- Tap en scrim (fuera del dialog): equivale a "Cancelar"

### Dialog container
- Background: `#FFFFFF`
- Border-radius: 28dp
- Margin horizontal: 24dp (ancho efectivo: 390 - 48 = 342dp)
- Padding: 24dp
- Sombra: `0 8px 24px rgba(0,0,0,0.15)`
- Posicion: centrado vertical

### Icono WARNING
- SVG Material, 24dp
- Color: `#E0A100`
- Centrado horizontalmente
- Margin-bottom: 16dp

### Titulo
- Texto: "¿Eliminar a Alicia?"
- Font: 18px, 700, `#16201F`
- Text-align: center
- Margin-bottom: 12dp

### Cuerpo
- Texto: "Se eliminaran todos sus datos y el acceso al equipo de cuidado de Alicia.
  Esta accion no se puede deshacer."
- Font: 14px, 400, `#566060`
- Text-align: left
- Line-height: 1.5
- Margin-bottom: 24dp

### Boton "Eliminar"
- Altura: 44dp
- Width: 100% del padding del dialog
- Background: `#D14343`
- Texto: "Eliminar", 15px 700, `#FFFFFF`
- Border-radius: 12dp
- Margin-bottom: 8dp

### Boton "Cancelar"
- Altura: 44dp
- Width: 100% del padding del dialog
- Background: transparente
- Borde: 1px solid `#C5CECE`
- Texto: "Cancelar", 15px 500, `#16201F`
- Border-radius: 12dp

---

## Interacciones

- **Tap "Eliminar":** ejecuta la eliminacion. Boton muestra spinner, "Cancelar" se deshabilita.
  Si exitoso: dialog se cierra, navega a US-13, snackbar "Alicia fue eliminada del sistema".
  Si error de red: mensaje de error inline, botones vuelven al estado inicial.
- **Tap "Cancelar":** cierra el dialog, vuelve a la pantalla de perfil normal (US-14).
- **Tap en scrim:** igual que "Cancelar".
- **Back del sistema (Android):** igual que "Cancelar".
