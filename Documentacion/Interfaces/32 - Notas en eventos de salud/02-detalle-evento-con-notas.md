# 32 · Detalle de evento con notas [01]

> Pantalla que muestra la ficha de un evento de salud y la lista de notas del equipo.
> Tokens en `00-sistema-diseno.md`. HTML: `html/01-detalle-evento.html`.

## Propósito
Permitir a los miembros del equipo de cuidado consultar los detalles de un evento de salud
(fecha, profesional, observaciones) y leer o agregar notas colaborativas sobre ese evento.

## Wireframe (ASCII)

```
┌────────────────────────────────────────────┐  ← background #F6F8F8
│ 9:41                               5G 100% │   status bar #16201F
│ [←]  Control cardiológico  [Cita médica]   │   AppBar surface + chip rosa
│──────────────────────────────────────────  │
│ ┌──────────────────────────────────────┐   │
│ │ 2 de junio de 2026                   │   │   fecha · 13 dp textDisabled
│ │ Dr. Martín Sosa · Hospital Italiano  │   │   body 15 dp bold textPrimary
│ │ Resultados dentro de los parámetros  │   │   observación 14 dp textSecondary
│ │ normales. Repetir análisis en 3 meses│   │
│ └──────────────────────────────────────┘   │   card evento radius 12
│                                             │
│  NOTAS DEL EQUIPO                           │   label 12 dp uppercase textSecondary
│                                             │
│ ┌──────────────────────────────────────┐   │
│ │ [M] María García · 2 jun · 14:32     │   │   avatar 28dp + autoría
│ │ El médico indicó repetir análisis    │   │   cuerpo nota 14dp
│ │ en 3 meses. Solicitar turno a fin    │   │
│ │ de mes.                              │   │   border-left 3dp #E11D48
│ └──────────────────────────────────────┘   │   card nota radius 10
│                                             │
│ ┌──────────────────────────────────────┐   │
│ │ [L] Laura Méndez · 3 jun · 09:15    │   │
│ │ Acordado con Alicia hacer los        │   │
│ │ análisis en Fleni.                   │   │
│ └──────────────────────────────────────┘   │
│                                             │
│                              ┌───────┐     │
│                              │  [+]  │     │   FAB 48dp bg #E11D48
│                              └───────┘     │   bottom 24 right 16
└────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | AppBar | Bg `surface #FFF`, height 56 dp. Ícono ARROW_BACK 24 dp izquierda. Título "Control cardiológico" `16 dp bold textPrimary`. Chip "Cita médica" a la derecha del título: bg `#FFF1F2`, texto `#E11D48` `11 dp` peso 600, radio `999 dp`, padding `3px 10px`. |
| 2 | Card del evento | Bg `#FFF`, radius `12 dp`, padding `16 dp`, margin `16 dp`, sombra `0 2px 8px rgba(0,0,0,0.06)`. Fecha `13 dp textDisabled`. Cuerpo `15 dp bold textPrimary`. Observación `14 dp textSecondary` interlineado `1.5`. |
| 3 | Label sección | "NOTAS DEL EQUIPO" `12 dp uppercase` peso 600 `textSecondary`. Padding `12dp 16dp 8dp`. |
| 4 | Tarjeta de nota | Bg `#FFF`, radius `10 dp`, padding `14 dp`, margin `0 16dp 8dp`, border-left `3 dp #E11D48`, sombra `0 1px 4px rgba(0,0,0,0.05)`. |
| 5 | Autoría de nota | Fila: avatar `28 dp` + nombre `13 dp bold textPrimary` + "·" + timestamp `11 dp textDisabled`. |
| 6 | Avatar | Círculo `28 dp`, letra inicial `12 dp bold`. María: bg `#C9EDE8` texto `#0A3D38`. Laura: bg `#FCE2DA` texto `#7A2E1A`. |
| 7 | Cuerpo de nota | `14 dp textPrimary`, interlineado `1.5`, margin-top `8 dp`. |
| 8 | FAB | Círculo `48 dp`, bg `#E11D48`, ícono ADD blanco `24 dp`. Posición absoluta `bottom 24 right 16`. Sombra `0 4px 12px rgba(225,29,72,0.35)`. |

## Estados

| Estado | Descripción | Diferencia visual |
|---|---|---|
| Con notas | Al menos 1 nota cargada | Lista de tarjetas de nota |
| Sin notas (vacío) | Evento sin notas | Área de notas muestra mensaje "Aun no hay notas. Agregá la primera." en `14 dp textDisabled` centrado, con ícono DESCRIPTION 32 dp `#C5CECE` |
| Cargando | Primera carga | Skeleton loaders: card evento (3 líneas grises) + 2 skeleton de tarjetas de nota |
| Error de carga | Fallo de red | Banner `InlineErrorBanner` bajo la card del evento + botón "Reintentar" |

## Interacciones y comportamiento

- **ARROW_BACK:** pop hacia la pantalla anterior de Mi salud.
- **FAB "+":** push hacia Nueva nota [02], animación slide-up.
- **Tap en tarjeta de nota:** sin acción en MVP (reservado para editar/eliminar en iteración siguiente).
- **Scroll:** la pantalla es scrollable verticalmente. El FAB permanece fijo sobre el contenido.
- **Lista de notas:** orden cronológico ascendente (la más antigua arriba, la más reciente abajo).

## Navegación

- **Entrada:** desde Mi salud / lista de eventos (tap en evento). También desde notificación push
  (deep link a `/health/events/:eventId`).
- **Salida:** ARROW_BACK → Mi salud. FAB → Nueva nota [02].
