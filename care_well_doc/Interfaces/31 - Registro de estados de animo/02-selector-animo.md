# Pantalla 01 — Selector de estado de ánimo (rediseño v2 — carrusel)

## Objetivo
Registrar el estado de ánimo diario de la persona a cargo con la menor fricción posible,
comunicando el nivel con un símbolo grande (emoji) y un color que se lee de un vistazo
(escala roja→ámbar→verde), pensado para cuidadores apurados y para colaboradores mayores
o poco familiarizados con la tecnología.

**Cambio respecto a v1:** se reemplaza el selector de fila de 5 círculos por un selector tipo
**carrusel** (flechas + un único emoji grande en el centro), con "Regular" como valor por
defecto. Decisión de producto: se conserva íntegramente el registro cuantitativo 1–5 del
dominio; **solo cambia la interacción**, no el modelo de datos.

## Ruta
`/health/mood/register`

## Layout (jerarquía de componentes)

```
StatusBar (28 px, dark)
AppBar (56 px) — "Estado de ánimo"
ContextSelector (persona a cargo) — sin cambios
────────────────────────────────────────────────
ScrollView
  Título centrado (ancho completo, texto centrado)
    "¿Cómo se siente " + NOMBRE (resaltado, color secondary #F2785C, bold) + " hoy?"
    (16 px / 600, resto en textPrimary #16201F)
    → NOMBRE proviene siempre de la persona de contexto seleccionada (ContextSelector).
      Si aún no hay persona resuelta, se muestra "la persona a cargo" SIN resaltar
      (no es un nombre propio).

  Card surface (bg #FFF, radius 16, margin 16, padding 24 16)
    Row centrada:
      [‹ flecha, 56×56]  [Blob circular 156×156 + emoji 64px]  [flecha ›, 56×56]
    Label del estado (centrado, debajo del blob)
      "Regular"  20 px / 700 / textPrimary
    Indicador de posición: 5 puntos (8 px, el activo 10 px y coloreado)

  Section: campo de texto (margin-top 24)
    Label "¿Hay algo que quieras contarme?" (13 px / 500 / #566060)
    Textarea (igual a v1: bg #FFF, borde 1px #C5CECE, radius 12, padding 14 16,
              min-height 88 px, placeholder "Ej. Estuvo tranquila, durmió bien")

  Botón "Registrar" (height 56, radius 16, margin 24 0)
    - Antes de la primera interacción con el picker: variante OUTLINED
      (borde 2px #7C3AED, texto #7C3AED, sin relleno) + caption debajo:
      "Tocá las flechas o deslizá para confirmar el estado" (12 px, textSecondary)
    - Después de la primera interacción: variante FILLED violeta (igual a v1)
────────────────────────────────────────────────
BottomNavBar
```

## Sistema de color — escala de ánimo

Nuevos tokens dedicados (no se reusan colores de otros módulos, para no acoplar semánticas):

| Nivel | Token | HEX |
|---|---|---|
| Muy mal | `moodScaleVeryBad` | `#D14343` |
| Mal | `moodScaleBad` | `#C85A2E` |
| Regular (default) | `moodScaleNeutral` | `#E0A100` |
| Bien | `moodScaleGood` | `#8CAA22` |
| Muy bien | `moodScaleVeryGood` | `#2E9E5B` |

- **Blob de fondo:** color del nivel actual al 16% de opacidad — logra el efecto "fondo
  transparente medio amarillento" en Regular, y se traduce a rojizo/verdoso en los extremos.
- **Anillo del blob:** borde 3 dp con el mismo color al 100%, para reforzar el mensaje aun con
  dificultad para distinguir tonos pastel.
- **Label de texto ("Regular", "Mal", etc.):** se mantiene en `textPrimary` (no se tiñe). El
  ámbar `#E0A100` sobre blanco da ~2.3:1 de contraste — no cumple ni el mínimo de 3:1 de WCAG
  para texto grande. El color vive en el blob/anillo (decorativo), el texto siempre es legible.
- **Botón "Registrar":** permanece violeta (`moodAccent #7C3AED`) fijo, nunca se tiñe con el
  color del estado — evita que un botón rojo (por "Muy mal") se lea como alerta/error.

## Estados de la pantalla

### Con datos (default al entrar)
- Nivel = Regular (3/5) preseleccionado. Blob ámbar pastel. Ambas flechas activas.
- Botón "Registrar" en variante **outlined** (deshabilitado, `onPressed: null`, pero con
  color de marca — no gris — para no leerse como "roto"). Caption de ayuda visible debajo.

### Extremos del rango
- **Muy mal** (posición 1/5): flecha `‹` deshabilitada (ícono en `textDisabled`, sin ripple).
  Blob rojo pastel.
- **Muy bien** (posición 5/5): flecha `›` deshabilitada. Blob verde pastel.

### Tras la primera interacción
- Botón "Registrar" pasa a variante **filled** violeta, totalmente habilitado.
- El caption de ayuda desaparece.
- Esto aplica apenas se dispara `onChanged` una vez (tap de flecha o swipe), **incluso si el
  valor resultante vuelve a ser Regular** — lo que se exige es una interacción consciente, no
  necesariamente un cambio de valor.

### Estado de carga (post-tap en Registrar)
- Botón muestra `CircularProgressIndicator` blanco 20 px.
- Flechas y campo de texto deshabilitados (opacity 0.5, no interactivos).

### Estado de error
- Snackbar rojo si falla el guardado. Ya no existe un estado de "error de selección
  faltante": siempre hay un nivel válido (Regular por defecto).

### Estado de éxito
- `pop()` + Snackbar con acción "Ver historial" (sin cambios respecto a v1).

## Interacciones
- **Tap en flecha:** avanza/retrocede un nivel. Transición combinada (250 ms): slide horizontal
  + fade del emoji, interpolación de color del blob, fade del label.
- **Swipe horizontal sobre el blob:** gesto alternativo equivalente a tocar la flecha (mayor
  superficie táctil). Redundante a propósito: quien no descubre el swipe igual tiene las
  flechas grandes y explícitas.
- **Feedback táctil:** `HapticFeedback.selectionClick()` en cada cambio de nivel.
- **Campo de texto:** sin cambios de comportamiento.

## Accesibilidad
- `Semantics` en el selector anuncia el valor completo: "Estado de ánimo: Regular. Deslizá o
  usá las flechas para cambiar." (no depende de que el lector de pantalla interprete el emoji).
- Cada flecha con `semanticsLabel` explícito ("Estado de ánimo peor" / "Estado de ánimo
  mejor"); la flecha deshabilitada se excluye de semántica.
- Áreas táctiles de 56×56 dp (superan el mínimo de 48 dp) — importante para usuarios mayores.
- El color nunca es el único portador de información: siempre hay texto + emoji + anillo.

## Notas de implementación (para dev-flutter)
- Reutilizar `EstadosAnimoConst` (dominio) sin cambios: `muyBien=1, bien=2, regular=3, mal=4,
  muyMal=5`. El orden visual izquierda→derecha (peor→mejor) es
  `[muyMal, mal, regular, bien, muyBien]`; mapear por índice de esa lista, no por el id crudo.
- El componente que reemplaza a `MoodPicker` (fila de 5) se llama `MoodDialSelector`. Se
  mantiene el mismo archivo (`mood_picker.dart`) y las funciones helper `moodLevelColor`,
  `moodLevel`, `moodEmoji` (mismo contrato, sin romper `mood_bar_chart.dart`,
  `mood_history_screen.dart` ni `home_screen.dart`, que ya las consumen).
- Sugerido (no bloqueante): renombrar el archivo a `mood_dial_selector.dart` en una pasada de
  limpieza posterior, dado que ya no aloja una fila de "picker" sino un carrusel.
