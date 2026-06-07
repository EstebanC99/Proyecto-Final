# 02 · Mi Perfil — pantalla de visualización (con datos)

> Pantalla principal de US-06. Tokens en `00-sistema-diseno.md`. HTML: `html/01-mi-perfil.html`.

## Propósito

Permitir que el usuario consulte sus datos de perfil de forma clara y rápida. Es una pantalla
de solo lectura: sin acciones de edición inline, sin formularios. El foco está en la
legibilidad y en la jerarquía de la información.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
├──────────────────────────────────────────────┤
│  ←  Mi Perfil                                 │   AppBar surface (#FFF), shadow sutil
├──────────────────────────────────────────────┤
│                                               │
│              ┌───────────┐                    │   avatar círculo 80×80 dp
│              │     M     │                    │   bg primaryContainer (#C9EDE8)
│              └───────────┘                    │   inicial "M" 36px bold #0A3D38
│                                               │
│           María García                         │   nombre 20px bold textPrimary
│          [Responsable]                         │   chip rol: bg #C9EDE8 · text #0A3D38
│                                               │   12px 600 · radius 999 · pad 4×12
├──────────────────────────────────────────────┤   border-bottom #C5CECE
│                                               │
│  ✉  Email                                     │   ← fila de dato (64dp mín)
│     maria.garcia@ejemplo.com                  │   ícono 20dp #566060
│                                               │   label 13px #566060
├───────────────────────────────────────────────┤   valor 16px #16201F w500
│                                               │   divider 1dp #C5CECE
│  ☎  Teléfono                                  │
│     +54 9 11 1234-5678                        │
│                                               │
├───────────────────────────────────────────────┤
│                                               │
│  ID  DNI                                      │
│      12.345.678                               │
│                                               │
├───────────────────────────────────────────────┤
│                                               │
│  👤  Rol en el sistema                        │
│      Responsable                              │
│                                               │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, fondo `#16201F`, texto blanco. Hora a la izquierda, íconos de sistema a la derecha. |
| 2 | AppBar | 56 dp, fondo `surface #FFF`, sombra 2 dp sutil. Ícono ARROW_BACK 24 dp a la izquierda. Título "Mi Perfil" 18 px bold `textPrimary`. |
| 3 | Encabezado de perfil | Zona centrada, fondo `surface #FFF`, padding 24 dp, border-bottom 1 dp `outline`. Contiene avatar + nombre + chip de rol con 12 dp de gap entre elementos. |
| 4 | `ProfileAvatar` | Círculo 80×80 dp. Fondo `primaryContainer #C9EDE8`. Inicial "M" 36 px bold, color `#0A3D38`. Sin borde. |
| 5 | Nombre completo | "María García". 20 px bold, `textPrimary #16201F`. Margen top 12 dp desde avatar. |
| 6 | `RoleBadge` | Chip "Responsable". Fondo `#C9EDE8`, texto `#0A3D38` 12 px weight 600, radius 999, padding 4×12 px. Margen top 8 dp desde nombre. |
| 7 | Sección de datos | Fondo `background #F6F8F8`. Lista vertical de `ProfileDataRow`. Padding horizontal 0 (los 24 px están dentro de cada fila). |
| 8 | Fila Email | Ícono EMAIL 20 dp `#566060` · Label "Email" 13 px · Valor "maria.garcia@ejemplo.com" 16 px. |
| 9 | Fila Teléfono | Ícono PHONE 20 dp · Label "Teléfono" · Valor "+54 9 11 1234-5678". |
| 10 | Fila DNI | Ícono BADGE 20 dp · Label "DNI" · Valor "12.345.678". |
| 11 | Fila Rol | Ícono PERSON 20 dp · Label "Rol en el sistema" · Valor "Responsable". |

## Interacciones y comportamiento

- **Las filas de dato no responden a tap.** No hay ripple, no hay navegación. La edición
  es competencia exclusiva de US-07.
- **AppBar ARROW_BACK:** vuelve a la pantalla anterior (pop). Gesto de back de Android equivalente.
- **Scroll:** si el contenido supera la altura disponible (dispositivos pequeños o muchos datos
  futuros), la sección de datos hace scroll. El encabezado de perfil puede quedarse fijo
  (sticky) o scrollear con el contenido — decisión de implementación delegada a `dev-flutter`.

## Estados de la pantalla

| Estado | Descripción |
|---|---|
| Con datos | Estado documentado en este archivo y en `html/01-mi-perfil.html`. |
| Cargando | Skeleton de avatar (círculo gris) + skeleton de tres filas (barras grises animadas). |
| Error | Banner inline "No se pudieron cargar los datos. Reintentar." bajo la AppBar. |

## Navegación (de dónde viene / a dónde va)

- **Entrada:** Menú principal (US-04) vía bottom nav o drawer · Settings (sección Cuenta).
- **Salida:** Back al punto de entrada · US-07 Edición (si hay botón editar en AppBar).
