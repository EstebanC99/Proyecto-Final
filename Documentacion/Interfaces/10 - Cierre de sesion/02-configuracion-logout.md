# 02 · Configuracion — item Cerrar sesion activo

> Pantalla Configuracion con el item "Cerrar sesion" resaltado con fondo errorContainer.
> Tokens en `00-sistema-diseno.md`. HTML: `html/01-configuracion-logout.html`.

## Proposito

Punto de entrada al flujo de cierre de sesion (US-10). El item "Cerrar sesion" aparece
con fondo `errorContainer` (#FBE3E3) y borde izquierdo `error` (#D14343) como feedback
contextual de que el flujo destructivo esta activo.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ←  Configuracion                             │   AppBar surface
│                                              │
│  CUENTA                                      │
│ ┌────────────────────────────────────────┐   │
│ │  [PERSON]   Mi Perfil             [›]  │   │   neutro
│ └────────────────────────────────────────┘   │
│                                              │
│  SEGURIDAD Y PRIVACIDAD                      │
│ ┌────────────────────────────────────────┐   │
│ │ [SECURITY]  Cambio de contrasena  [›]  │   │   neutro
│ └────────────────────────────────────────┘   │
│                                              │
│  LEGAL                                       │
│ ┌────────────────────────────────────────┐   │
│ │ [DESCRIPTION]  Terminos y cond…   [›]  │   │   neutro
│ └────────────────────────────────────────┘   │
│                                              │
│  SESION                                      │
│ ┌────────────────────────────────────────┐   │
│ │ [LOGOUT]    Cerrar sesion         [›]  │   │   ACTIVO: bg #FBE3E3, borde izq error
│ └────────────────────────────────────────┘   │   icono, texto y chevron en #D14343
│ ┌────────────────────────────────────────┐   │
│ │ [DELETE]    Eliminar cuenta       [›]  │   │   destructivo neutro #D14343
│ └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, `#16201F`, texto blanco. |
| 2 | AppBar | Fondo `surface`. Borde inferior 1 dp `outline`. ARROW_BACK 24 dp. Titulo "Configuracion" 18 px 700. |
| 3 | Item "Cerrar sesion" (ACTIVO) | Fondo `errorContainer` (#FBE3E3). Borde izquierdo 3 dp `error` (#D14343). Icono LOGOUT color `error`. Label "Cerrar sesion" 16 px 600 `error`. Chevron color `error`. |
| 4 | Item "Eliminar cuenta" | Estado neutro destructivo: icono, label y chevron en `error` (#D14343), fondo `surface` sin resalte. |
| 5 | Resto de items | Estado neutro. |

## Navegacion

- **Entrada:** desde Configuracion (menu principal), tap "Cerrar sesion".
- **Salida:** abre `ConfirmationDialog` sobre esta misma pantalla.
