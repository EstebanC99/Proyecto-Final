# 03 · Confirmar cierre de sesion — dialog de confirmacion

> Dialog de confirmacion sobre la pantalla de Configuracion atenuada.
> Tokens en `00-sistema-diseno.md`. HTML: `html/02-confirmar-cierre.html`.

## Proposito

Requerir confirmacion explicita antes de cerrar la sesion. El dialog sigue el patron M3
de confirmacion destructiva: boton principal en rojo a la derecha, accion secundaria
(cancelar) a la izquierda, mensaje claro y sin alarmismo.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8) con overlay
│ 9:41                                  5G 100% │   rgba(0,0,0,0.4) sobre toda la pantalla
│▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│
│▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│   fondo de Configuracion atenuado 40%
│▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│
│▒▒▒ ┌──────────────────────────────────┐ ▒▒▒│
│▒▒▒ │                                  │ ▒▒▒│
│▒▒▒ │  [WARNING]                       │ ▒▒▒│   icono warning 20dp color #E0A100
│▒▒▒ │  Cerrar sesion?                  │ ▒▒▒│   18px 700 textPrimary
│▒▒▒ │                                  │ ▒▒▒│
│▒▒▒ │  Vas a salir de tu cuenta.       │ ▒▒▒│   14px 400 textSecondary
│▒▒▒ │  Podes volver a ingresar         │ ▒▒▒│
│▒▒▒ │  cuando quieras.                 │ ▒▒▒│
│▒▒▒ │                                  │ ▒▒▒│
│▒▒▒ │  ┌───────────┐ ┌───────────────┐ │ ▒▒▒│
│▒▒▒ │  │  Cancelar │ │ Cerrar sesion │ │ ▒▒▒│   botones 44dp, gap 12dp
│▒▒▒ │  └───────────┘ └───────────────┘ │ ▒▒▒│   cancelar: neutro · confirmar: rojo
│▒▒▒ └──────────────────────────────────┘ ▒▒▒│
│▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Overlay | `position: absolute; inset: 0; background: rgba(0,0,0,0.4)`. Tappable para cancelar. Z-index 50. |
| 2 | Contenedor del dialog | Fondo `surface` (#FFF). Radio 28 dp. Padding 24 dp. Margen horizontal 24 dp. `max-width: calc(100% - 48px)`. Centrado vertical y horizontalmente. |
| 3 | Icono WARNING | 20 dp, color `warning` (#E0A100). Margen inferior 12 dp. |
| 4 | Titulo | "Cerrar sesion?" 18 px 700 `textPrimary`. Margen inferior 8 dp. |
| 5 | Cuerpo | "Vas a salir de tu cuenta. Podes volver a ingresar cuando quieras." 14 px 400 `textSecondary`. Margen inferior 20 dp. |
| 6 | Boton "Cancelar" | Flex 1. Alto 44 dp. Radio 12 dp. Borde 1 dp `outline` (#C5CECE). Fondo `surface`. Texto "Cancelar" 14 px 700 `textPrimary`. |
| 7 | Boton "Cerrar sesion" | Flex 1. Alto 44 dp. Radio 12 dp. Sin borde. Fondo `error` (#D14343). Texto "Cerrar sesion" 14 px 700 blanco (#FFFFFF). |

## Interacciones y comportamiento

- **Tap "Cancelar":** cierra el dialog (fade-out 150 ms). La pantalla de Configuracion
  vuelve a su estado normal sin overlay.
- **Tap fuera del dialog (en el overlay):** igual que "Cancelar".
- **Back del sistema (Android):** igual que "Cancelar".
- **Tap "Cerrar sesion" (confirmar):** el boton muestra un spinner breve (~500 ms) mientras
  se invalida el token y se limpia el almacenamiento local. Luego `go('/login')` con fade 250 ms.
- **Pressed state en botones:** el boton "Cerrar sesion" aplica un oscurecimiento del 15%
  sobre el fondo rojo. El boton "Cancelar" aplica fondo `surfaceVariant` (#EDF1F1).

## Detalles de implementacion

- El dialog es un `AlertDialog` de Flutter (M3), configurado con `shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(28))`.
- Se invoca con `showDialog()` desde el tap del item "Cerrar sesion".
- El `barrierDismissible: true` permite cerrar tocando el overlay.
- El `barrierColor: Colors.black.withOpacity(0.4)` provee el scrim oscuro.

## Navegacion

- **Entrada:** desde Configuracion [01], tap item "Cerrar sesion".
- **Salida cancelar:** dialog se cierra, permanece en Configuracion [01].
- **Salida confirmar:** `go('/login')`, stack de navegacion limpiado.
