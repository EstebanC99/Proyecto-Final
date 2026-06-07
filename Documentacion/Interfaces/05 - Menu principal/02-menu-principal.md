# 05 · Menú principal — spec completa del Home

> Pantalla raíz post-login. Tokens en `00-sistema-diseno.md`. Flujo en `01-flujo-navegacion.md`.
> HTML: `html/01-menu-principal.html`.

---

## Propósito

Centralizar el acceso a todas las secciones del MVP en una pantalla orientadora clara,
con la acción de emergencia siempre a la vista. El usuario llega aquí tras cada login y
puede navegar a cualquier sección con un solo toque.

---

## Wireframe (ASCII)

```
┌─────────────────────────────────────────────────────┐  ← background #F6F8F8
│ 9:41                                        5G 100% │   status bar #16201F
├─────────────────────────────────────────────────────┤
│  ╭──╮ CareWell          ╭──╮ Hola, María  ▾         │   HomeHeader 64 dp · surface
│  └──┘                   └──┘                        │   logo 40dp · avatar 40dp
├─────────────────────────────────────────────────────┤
│  [ Mi Perfil ]   [ Configuración ]                   │   QuickAccessRow 56 dp
├─────────────────────────────────────────────────────┤
│                                                      │   padding 16 dp lateral
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │                      │  │                      │ │
│  │  [calendario 32dp]   │  │   [group 32dp]       │ │
│  │                      │  │                      │ │   NavTile ~130 dp
│  │   Mi calendario      │  │   Mi equipo          │ │   grid 2×2 · gap 12 dp
│  │                      │  │                      │ │
│  └──────────────────────┘  └──────────────────────┘ │
│                                                      │
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │                      │  │                      │ │
│  │  [elderly 32dp]      │  │  [favorite 32dp]     │ │
│  │                      │  │                      │ │
│  │  Personas a cargo    │  │  Mi salud            │ │
│  │                      │  │                      │ │
│  └──────────────────────┘  └──────────────────────┘ │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │   [warning 32dp]   Emergencia                │   │   EmergencyTile 72 dp · coral
│  └──────────────────────────────────────────────┘   │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | Altura 28 dp. Fondo `#16201F`. Texto blanco 12 px 600. Izq: hora "9:41". Der: "5G 100%". |
| 2 | `HomeHeader` | Altura 64 dp. Fondo `surface #FFF`. Padding horizontal 20 dp. Izq: ícono marca 40 dp SVG + wordmark "**Care**Well" 16 px bold bicolor (`Care #16201F`, `Well #1A8C82`). Der: avatar circular 40 dp (`primaryContainer` bg, inicial "M" color `#0A3D38` 18 px bold) + "Hola, **María**" 14 px + `▾` 12 px. Toda el área derecha (avatar + texto + flecha) es tappable, objetivo ≥48 dp → US-06. |
| 3 | `QuickAccessRow` | Altura 56 dp. Padding horizontal 20 dp. Dos botones: "Mi Perfil" y "Configuración". Cada botón: ícono SVG 20 dp + label 12 px 500. Fondo `surfaceVariant`. Radio 12 dp. Padding 8×14 dp. Gap entre botones 12 dp. Objetivo táctil ≥48 dp. |
| 4 | Grid de `NavTile` | Contenedor con `padding 16 dp` lateral, `gap 12 dp`. Grid 2 columnas, 2 filas. Cada tile: `surface` bg, radio 16 dp, sombra `0 2px 8px rgba(0,0,0,0.08)`, padding 20 dp, altura ~130 dp. Layout: ícono 32 dp centrado (color `primary`), gap 12 dp, label centrado `titleMedium` 15 px 600. |
| 4a | NavTile · Mi calendario | Ícono: CALENDAR SVG. Label: "Mi calendario". → `/agenda` (US-10). |
| 4b | NavTile · Mi equipo | Ícono: GROUP SVG. Label: "Mi equipo". → `/care-team` (US-11). |
| 4c | NavTile · Personas a cargo | Ícono: ELDERLY SVG. Label: "Personas a cargo". → `/dependents` (US-12). |
| 4d | NavTile · Mi salud | Ícono: FAVORITE SVG. Label: "Mi salud". → `/health` (US-13). |
| 5 | `EmergencyTile` | Ancho 100%. Altura 72 dp. Fondo `secondary #F2785C`. Radio 16 dp. Layout horizontal centrado: ícono WARNING SVG 32 dp blanco + gap 12 dp + texto "Emergencia" 18 px bold blanco. Margen superior 4 dp (del grid). → `/emergency` (US-09). |

---

## Estados

### Estado con datos (normal)
Descrito arriba. Header muestra el nombre real del usuario.

### Estado de carga (primera apertura post-login)
- Header y QuickAccessRow se muestran inmediatamente (sin skeleton).
- Los 4 `NavTile` muestran un skeleton: rectángulo redondeado gris `surfaceVariant`
  animado (shimmer izq→der 1.2 s). Mismas dimensiones que el tile normal.
- `EmergencyTile` se muestra inmediatamente, activo.

### Estado de error (fallo al cargar datos del usuario)
- Snackbar en la parte inferior: "No se pudo cargar la información. Intentá de nuevo." +
  acción "Reintentar". Duración 8 s. El snackbar no bloquea los tiles.
- Los tiles permanecen activos (navegación funciona aunque los datos sean parciales).

---

## Interacciones y comportamiento

- **Tap en NavTile:** ink ripple `primaryContainer` sobre el tile, 100 ms →
  push de la ruta correspondiente con slide-up + fade 250 ms.
- **Tap en EmergencyTile:** overlay oscuro 10% momentáneo → push `/emergency` con
  slide-up acelerada 180 ms. No hay confirmación en esta pantalla (está en US-09).
- **Tap en avatar / área derecha del header:** push `/profile` con slide-right + fade 250 ms.
- **Long press en cualquier tile (opcional UX):** sin acción definida en MVP. Reservado.
- **Scroll:** el contenido total entra en 844 dp sin scroll. No se requiere scroll en condiciones normales.
  Si el sistema aumenta el tamaño de fuente (accesibilidad), el contenido hace scroll sin truncar texto.
- **Back del sistema (Android):** diálogo "¿Salir de CareWell?" con opciones "Cancelar" / "Salir".

---

## Navegación (de dónde viene / a dónde va)

- **Entrada:** login exitoso (US-02) via `pushReplacement`; retorno de sección secundaria via `pop`.
- **Salida:** cualquiera de los accesos de la tabla en `01-flujo-navegacion.md §2`.
