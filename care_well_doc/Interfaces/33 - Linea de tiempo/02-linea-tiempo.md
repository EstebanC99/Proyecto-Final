# 33 · Linea de tiempo [01]

> Vista cronologica de eventos de salud de una persona bajo cuidado.
> Tokens en `00-sistema-diseno.md`. HTML: `html/01-linea-tiempo.html`.

## Proposito
Ofrecer al equipo de cuidado una vision cronologica completa del historial de salud de la
persona bajo cuidado: citas, internaciones, cambios de medicacion, tratamientos y hitos de
bienestar. Funciona como punto de entrada para navegar al detalle de cada evento.

## Wireframe (ASCII)

```
┌────────────────────────────────────────────┐  ← background #F6F8F8
│ 9:41                               5G 100% │   status bar #16201F
│ [←]  Linea de tiempo  [Alicia Rodriguez]   │   AppBar + chip persona
│──────────────────────────────────────────  │
│                                             │
│  o───  [Cita medica]                        │   dot #E11D48
│  |     Jun 2026                             │   fecha discreta
│  |     Control cardiologico                 │   titulo bold
│  |     Dr. Martin Sosa · Hospital Italiano  │   descripcion
│  |                                          │
│  o───  [Medicacion]                         │   dot #2563EB
│  |     May 2026
│  |     Ajuste de dosis — Atenolol           │
│  |     Indicado por el cardiologo           │
│  |                                          │
│  o───  [Bienestar]                          │   dot #16A34A
│  |     Abr 2026                             │
│  |     Alta psicologica                     │
│  |     Finalizo ciclo de 12 sesiones        │
│  |                                          │
│  o───  [Hospitalizacion]                    │   dot #E11D48
│  |     Mar 2026                             │
│  |     Internacion 3 dias                   │
│  |     Clinica Santa Isabel · UCI           │
│  |                                          │
│  o     [Tratamiento]                        │   dot #7C3AED (ultimo, sin linea)
│        Feb 2026                             │
│        Inicio fisioterapia                  │
│        Sesiones martes y jueves             │
│                                             │
└────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | AppBar | Bg `surface #FFF`, height `56 dp`. ARROW_BACK 24 dp. Titulo "Linea de tiempo" `16 dp bold`. Chip "Alicia Rodriguez": bg `#FFF1F2`, texto `#E11D48`, `11 dp` peso 600, radio `999 dp`. |
| 2 | Contenedor timeline | Padding `8 dp 16 dp 24 dp`. Sin separadores de mes en MVP. |
| 3 | Fila de evento (tl-row) | `display:flex`, gap `12 dp`. Columna izquierda: dot + linea. Columna derecha: tarjeta. |
| 4 | Dot | `22 dp x 22 dp`, radio `50%`, color por categoria (ver tabla en `00-sistema-diseno.md`). |
| 5 | Linea conectora | `2 dp` ancho, color `#EDF1F1`, entre dot y siguiente dot. El ultimo evento no la tiene. |
| 6 | Tarjeta de evento (tl-card) | Bg `#FFF`, radius `12 dp`, padding `12 dp 14 dp`, sombra `0 1px 4px rgba(0,0,0,0.06)`, margin-bottom `12 dp`. Objetivo tactil: toda la superficie. |
| 7 | Chip categoria | `10 dp`, peso 600, radio `999 dp`, padding `2px 8px`, margin-bottom `6 dp`. Colores por tabla. |
| 8 | Fecha | `11 dp textDisabled`, margin-bottom `2 dp`. |
| 9 | Titulo evento | `14 dp bold textPrimary`. |
| 10 | Descripcion evento | `12 dp textSecondary`, margin-top `2 dp`, interlineado `1.4`. |

## Estados

| Estado | Descripcion | Diferencia visual |
|---|---|---|
| Con datos | Al menos 1 evento | Lista de filas tl-row |
| Vacio | Sin eventos registrados | Icono FAVORITE 48 dp `#C5CECE` + "Aun no hay eventos registrados." `14 dp textDisabled` centrado verticalmente |
| Cargando | Primera carga | 3 skeleton loaders de fila (dot placeholder + card gris claro) |
| Error | Fallo de red | Banner `InlineErrorBanner` en top del scroll + boton "Reintentar" |

## Interacciones y comportamiento

- **Tap en tarjeta de evento:** navega al detalle del evento (US-32 [01]), push slide-left.
- **Feedback pressed:** toda la tl-card oscurece 5% al presionar (ripple o shade).
- **Pull-to-refresh:** gesto desde el tope recarga la lista; indicador de color `#E11D48`.
- **Scroll:** la pantalla hace scroll vertical completo; el AppBar permanece fijo.
- **Accesibilidad:** cada fila tiene semanticLabel con "Evento: [titulo], [fecha], tipo [categoria]".

## Navegacion

- **Entrada:** desde Mi salud / seccion linea de tiempo o menu principal modulo salud.
- **Salida:** ARROW_BACK → Mi salud. Tap en tarjeta → Detalle del evento (US-32).
