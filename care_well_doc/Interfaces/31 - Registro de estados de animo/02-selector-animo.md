# Pantalla 01 — Selector de estado de ánimo

## Objetivo
Permitir al cuidador registrar el estado de ánimo diario de la persona a cargo con la menor fricción posible. Una acción, un tap.

## Ruta
`/health/mood/register`

## Layout (jerarquía de componentes)

```
StatusBar (28 px, dark)
AppBar (56 px)
  ← ARROW_BACK                "Estado de ánimo"
────────────────────────────────────────────────
ScrollView
  Section: subtítulo
    "¿Cómo se siente Alicia hoy?"   (16 px / 600 / #16201F, padding 24 16)

  Card surface (bg #FFF, radius 16, margin 16, padding 20 16)
    Row: 5 opciones MoodPicker (space-around)
      [Muy bien] [Bien*] [Regular] [Mal] [Muy mal]
      (* = seleccionado)

  Section: campo opcional (margin-top 24)
    Label "Observación" (13 px / 500 / #566060)
    Textarea (bg #FFF, border 1px #C5CECE, radius 12, padding 14 16,
              min-height 88 px, placeholder "Ej. Estuvo tranquila, durmió bien")
      Prefijo DESCRIPTION 20 px / #9AA5A5 (posición top-left)

  Botón primario "Registrar" (height 56, bg #7C3AED, radius 16, margin 24 0)
────────────────────────────────────────────────
BottomNavBar
```

## Estados de la pantalla

### Estado vacío (sin selección)
- Los 5 círculos en gris `#EDF1F1`
- Botón "Registrar" visible pero muestra error inline al pulsarlo

### Estado con selección (mostrado en el HTML)
- "Bien" seleccionado: fondo `#F0FDF4`, borde 3 px `#65A30D`, scale 1.1
- Resto: gris `#EDF1F1`
- Botón "Registrar" habilitado

### Estado de carga (post-tap en Registrar)
- Botón muestra CircularProgressIndicator blanco 20 px
- Campos deshabilitados

### Estado de error
- Snackbar rojo bottom si falla el guardado
- Si ningún estado seleccionado: texto de error rojo 12 px bajo el picker

## Interacciones
- Tap en círculo: transición spring 200 ms (scale + borde)
- Campo textarea: scroll up al enfocar (keyboard avoidance)
- Botón: ripple + loading state

## Especificación de accesibilidad
- Cada círculo tiene `semanticsLabel`: "Estado Muy bien", "Estado Bien", etc.
- Contraste borde seleccionado sobre fondo claro: cumple AA (3:1 mínimo para componentes)
- Área táctil 64 px (supera mínimo 48 px)
