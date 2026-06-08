# 02 · Configuración — ítem Cambio de contraseña activo

> Pantalla Configuración con el ítem "Cambio de contraseña" resaltado.
> Tokens en `00-sistema-diseno.md`. HTML: `html/01-configuracion-seguridad.html`.

## Propósito

Punto de entrada al flujo de cambio de contraseña (US-09). El ítem "Cambio de contraseña"
aparece con fondo `primaryContainer` como feedback contextual del flujo activo.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ←  Configuración                             │   AppBar surface
│                                              │
│  CUENTA                                      │
│ ┌────────────────────────────────────────┐   │
│ │  [PERSON]   Mi Perfil             [›]  │   │   neutro
│ └────────────────────────────────────────┘   │
│                                              │
│  SEGURIDAD Y PRIVACIDAD                      │
│ ┌────────────────────────────────────────┐   │
│ │ [SECURITY]  Cambio de contraseña  [›]  │   │   ACTIVO: bg #C9EDE8, borde izq primary
│ └────────────────────────────────────────┘   │   ícono, texto, chevron en #1A8C82
│                                              │
│  LEGAL                                       │
│ ┌────────────────────────────────────────┐   │
│ │ [DESCRIPTION]  Términos y cond…   [›]  │   │   neutro
│ └────────────────────────────────────────┘   │
│                                              │
│  SESIÓN                                      │
│ ┌────────────────────────────────────────┐   │
│ │  [LOGOUT]     Cerrar sesión       [›]  │   │   destructivo #D14343
│ │  [DELETE]     Eliminar cuenta     [›]  │   │   destructivo #D14343
│ └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, `#16201F`, texto blanco. |
| 2 | AppBar | Fondo `surface`. Borde inferior 1 dp `outline`. ARROW_BACK 24 dp. Título "Configuración" 18 px 700. |
| 3 | Ítem "Cambio de contraseña" (ACTIVO) | Fondo `primaryContainer` (#C9EDE8). Borde izquierdo 3 dp `primary`. Ícono SECURITY color `primary`. Label 16 px 600 `primary`. Chevron color `primary`. |
| 4 | Resto de ítems | Estado neutro o destructivo según corresponda (ver `00-sistema-diseno.md`). |

## Navegación

- **Entrada:** desde Configuración (menú principal).
- **Salida:** hacia `02-cambiar-contrasena` (tap ítem "Cambio de contraseña").
