# 05 · Menú principal — estado vacío (sin personas a cargo)

> Estado del Home cuando el usuario no tiene personas a cargo registradas.
> Tokens en `00-sistema-diseno.md`. HTML: `html/02-menu-estado-vacio.html`.

---

## Propósito

Comunicar al usuario que aún no cargó ninguna persona bajo cuidado, invitándolo a hacerlo
con una llamada a la acción clara y no intrusiva. El resto de la app permanece operativo:
el usuario puede configurar su equipo, registrar datos de salud propios o explorar la agenda
antes de tener una persona a cargo asignada.

---

## Diferencias respecto al estado normal

Solo el tile "Personas a cargo" cambia. Todos los demás elementos (header, fila de accesos
rápidos, otros tres tiles del grid, tile de emergencia) son idénticos al estado normal.

---

## Wireframe (ASCII) — solo tile afectado

```
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │                      │  │                      │ │
│  │  [elderly gris]      │  │  [favorite 32dp]     │ │
│  │                      │  │                      │ │   Fila 2 del grid
│  │  Aún no tenés        │  │  Mi salud            │ │
│  │  personas a cargo  + │  │                      │ │
│  │                      │  │                      │ │
│  └──────────────────────┘  └──────────────────────┘ │
```

---

## Especificación del tile vacío (`EmptyStateTile`)

| Atributo | Valor |
|---|---|
| Dimensiones | Igual a `NavTile`: ~130 dp alto, mitad del ancho del grid |
| Fondo | `surfaceVariant #EDF1F1` (diferencia del blanco normal) |
| Borde | `1 dp dashed #C5CECE` (sutil; indica que es un estado incompleto) |
| Radio | 16 dp |
| Sombra | Ninguna (el tile sin datos no tiene elevación) |
| Ícono | ELDERLY SVG 32 dp · color `textDisabled #9AA5A5` |
| Texto principal | "Aún no tenés personas a cargo" · 11 px · `textSecondary #566060` · centrado · máx. 2 líneas |
| Botón `+` | Posición absoluta: esquina superior derecha, margen 10 dp. Círculo 24 dp, fondo `primary #1A8C82`, ícono `+` blanco 16 dp. Objetivo táctil real: área de 40 dp centrada en el ícono. |

---

## Comportamiento e interacciones

- **Tap en el cuerpo del tile:** navega a `/dependents` (US-12 — listado de personas a cargo),
  donde también hay un acceso a "Agregar". Mismo destino que el tile normal.
- **Tap en el botón `+`:** navega directamente a `/dependents/new` (US-12 — formulario de alta),
  cortocircuitando la pantalla de listado (que estaría vacía de todas formas).
- **Feedback pressed:** el tile entero aplica el mismo ripple que el `NavTile` normal
  (`primaryContainer` overlay, 100 ms).

---

## Transición hacia el estado normal

Cuando el usuario agrega su primera persona a cargo (desde US-12) y vuelve al Home,
el tile cambia de `EmptyStateTile` a `NavTile` normal. El cambio se realiza via
`ref.invalidate` del provider correspondiente en Riverpod, lo que provoca una reconstrucción
del widget con una animación de `AnimatedSwitcher` (fade 300 ms entre ambos estados).

---

## Criterio de aceptación de este estado

- El tile vacío es visualmente diferente al tile normal (fondo, borde, ícono gris).
- El texto informativo no supera las 2 líneas dentro del tile.
- El botón `+` es visible y tiene objetivo táctil de al menos 40 dp.
- El tile de emergencia permanece completamente activo y visible.
- Los otros tres tiles del grid (Mi calendario, Mi equipo, Mi salud) son idénticos al estado normal.

---

## Navegación (de dónde viene / a dónde va)

- **Entrada:** igual que el estado normal (login exitoso, retorno de sección). Este estado se
  activa automáticamente si `dependents.length == 0`.
- **Salida:**
  - Tap cuerpo del tile → `/dependents` (US-12).
  - Tap `+` → `/dependents/new` (US-12 alta directa).
  - Demás accesos del Home: idénticos al estado normal.
