# Pantalla 02 — Historial de estado de ánimo

## Objetivo
Mostrar el patrón de ánimo de la persona a cargo en los últimos 7 días y los registros recientes con sus observaciones.

## Ruta
`/health/mood/history`

## Layout (jerarquía de componentes)

```
StatusBar (28 px, dark)
AppBar (56 px)
  ← ARROW_BACK               "Historial de ánimo"
  Chip "Alicia" (bg #FFF1F2, text #E11D48, radius 20)
────────────────────────────────────────────────
ScrollView
  Card gráfico (bg #FFF, radius 16, margin 16, padding 20 16)
    Label "ÚLTIMOS 7 DÍAS" (12 px / 700 / #566060 / uppercase)
    Row MoodBar: 7 columnas
      [L] [M] [M] [J] [V] [S] [D]
      (barras altura variable, colores escala)

  Section "REGISTROS RECIENTES"
    Label (12 px / 700 / #566060 / uppercase, padding 24 16 8)
    Lista de MoodRecord items:
      Item (bg #FFF, radius 12, margin 0 16 8, padding 12 14)
        Row: ícono estado (36 px, color nivel) + Column(fecha, obs)
        Fecha: 11 px / #9AA5A5
        Observación: 13 px / #16201F (max 2 líneas, overflow ellipsis)
────────────────────────────────────────────────
BottomNavBar
```

## Estados de la pantalla

### Estado con datos (mostrado en el HTML)
- Gráfico con 7 barras (datos reales de la semana)
- Lista con 3 registros recientes

### Estado vacío
- Gráfico sin barras (alturas 0 o placeholder gris)
- Texto "Sin registros esta semana" centrado en la card del gráfico
- Lista: card con "Aún no hay registros. Registrá el primer estado de ánimo."

### Estado de carga
- Shimmer en la card del gráfico (skeleton 7 barras)
- Shimmer en los 3 ítems de lista

### Estado de error
- Banner error rojo top: "No se pudo cargar el historial · Reintentar"

## Interacciones
- Pull to refresh: recarga gráfico y lista
- Tap en ítem de lista: bottom sheet con detalle completo (observación completa, nivel exacto, fecha/hora)
- Scroll: carga más registros debajo de los 3 iniciales (paginación lazy)

## Notas de diseño
- El gráfico de barras es puramente CSS/Flutter, sin dependencias de charting
- Los colores de las barras mapean 1:1 a los colores del selector (consistencia visual)
- El chip "Alicia" permite cambiar de persona a cargo si hay varias (future-proof)
