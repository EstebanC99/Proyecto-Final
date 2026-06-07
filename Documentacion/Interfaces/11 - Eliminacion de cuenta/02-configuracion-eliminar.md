# 02 · Configuracion — item Eliminar cuenta activo

> Pantalla Configuracion con el item "Eliminar cuenta" resaltado en errorContainer.
> Tokens en `00-sistema-diseno.md`. HTML: `html/01-configuracion-eliminar.html`.

## Proposito

Punto de entrada al flujo de eliminacion de cuenta (US-11). El item "Eliminar cuenta"
aparece con fondo `errorContainer` (#FBE3E3) y borde izquierdo 3 dp `error` (#D14343)
como feedback contextual del flujo activo. Comunica al usuario que esta a punto de
iniciar una accion destructiva antes de que abra el dialog.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  <- background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ <-  Configuracion                            │   AppBar surface
│                                              │
│  CUENTA                                      │
│ ┌────────────────────────────────────────┐   │
│ │  [PERSON]   Mi Perfil             [›]  │   │   neutro
│ └────────────────────────────────────────┘   │
│                                              │
│  SEGURIDAD Y PRIVACIDAD                      │
│ ┌────────────────────────────────────────┐   │
│ │ [SECURITY]  Cambio de contrasena  [›]  │   │   neutro
│ │ [DELETE] !! Eliminar cuenta       [›]  │   │   ACTIVO: bg #FBE3E3, borde izq #D14343
│ └────────────────────────────────────────┘   │   icono, texto, chevron en #D14343, bold
│                                              │
│  LEGAL                                       │
│ ┌────────────────────────────────────────┐   │
│ │ [DESCRIPTION]  Terminos y cond…   [›]  │   │   neutro
│ └────────────────────────────────────────┘   │
│                                              │
│  SESION                                      │
│ ┌────────────────────────────────────────┐   │
│ │  [LOGOUT]     Cerrar sesion       [›]  │   │   destructivo #D14343
│ └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, `#16201F`, texto blanco. |
| 2 | AppBar | Fondo `surface`. Borde inferior 1 dp `outline`. ARROW_BACK 24 dp. Titulo "Configuracion" 18 px 700. |
| 3 | Item "Eliminar cuenta" (ACTIVO ERROR) | Fondo `errorContainer` (#FBE3E3). Borde izquierdo 3 dp `error` (#D14343). Icono DELETE_FOREVER color `error`. Label 16 px 600 `error`. Chevron color `error`. |
| 4 | Item "Cambio de contrasena" | Estado neutro (icono y texto en textSecondary/textPrimary). |
| 5 | Item "Cerrar sesion" | Estado destructivo neutro (sin fondo resaltado): icono, texto y chevron en `error` (#D14343). |
| 6 | Resto de items | Estado neutro estandar. |

## Diferencias con otras US de Configuracion

La variante "activo error" difiere del "activo primario" (usado en US-08 y US-09):
- US-08/09: fondo `primaryContainer` (#C9EDE8), borde y texto `primary` (#1A8C82).
- US-11: fondo `errorContainer` (#FBE3E3), borde y texto `error` (#D14343).

El cambio de color comunica la naturaleza destructiva del flujo que se va a iniciar.
El usuario recibe feedback visual de "zona de peligro" antes de ver el dialog.

## Navegacion

- **Entrada:** desde Configuracion (menu principal o ARROW_BACK desde otra pantalla del modulo).
- **Salida:** showDialog de confirmacion (tap item "Eliminar cuenta").
