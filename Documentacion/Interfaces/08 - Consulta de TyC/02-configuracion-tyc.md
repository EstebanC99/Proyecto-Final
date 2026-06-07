# 02 · Configuración — ítem T&C activo

> Pantalla Configuración con el ítem "Términos y condiciones" resaltado.
> Tokens en `00-sistema-diseno.md`. HTML: `html/01-configuracion-tyc.html`.

## Propósito

Mostrar la pantalla principal del módulo Configuración como punto de entrada a la US-08.
El ítem "Términos y condiciones" aparece con el fondo `primaryContainer` como feedback
contextual: indica al usuario desde dónde navega hacia los T&C y refuerza la relación
entre las pantallas del flujo.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ←  Configuración                             │   AppBar surface, borde inferior outline
│                                              │
│  CUENTA                                      │   SectionHeader 13px 500 textSecondary
│ ┌────────────────────────────────────────┐   │
│ │  [PERSON]   Mi Perfil             [›]  │   │   SettingsItem 56dp
│ └────────────────────────────────────────┘   │
│                                              │
│  SEGURIDAD Y PRIVACIDAD                      │
│ ┌────────────────────────────────────────┐   │
│ │  [SECURITY]  Cambio contraseña    [›]  │   │   SettingsItem 56dp
│ └────────────────────────────────────────┘   │
│                                              │
│  LEGAL                                       │
│ ┌────────────────────────────────────────┐   │
│ │ [DESCRIPTION]  Términos y cond…   [›]  │   │   SettingsItem ACTIVO
│ │                                        │   │   bg #C9EDE8, borde izq 3dp primary
│ └────────────────────────────────────────┘   │   ícono, texto y chevron en #1A8C82
│                                              │
│  SESIÓN                                      │
│ ┌────────────────────────────────────────┐   │
│ │  [LOGOUT]     Cerrar sesión       [›]  │   │   SettingsItem destructivo #D14343
│ │  [DELETE]     Eliminar cuenta     [›]  │   │   SettingsItem destructivo #D14343
│ └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, fondo `#16201F`, texto blanco "9:41" / "5G 100%". |
| 2 | AppBar | Fondo `surface` (#FFF). Borde inferior 1 dp `outline`. Ícono ARROW_BACK 24 dp `textPrimary`. Título "Configuración" 18 px 700 `textPrimary`. Altura 56 dp. |
| 3 | SectionHeader "CUENTA" | Texto en mayúsculas, 13 px 500 `textSecondary`. Padding 8/24/4 dp. |
| 4 | Ítem "Mi Perfil" | Ícono PERSON 24 dp. Label 16 px. Chevron derecha. Estado neutro. |
| 5 | SectionHeader "SEGURIDAD Y PRIVACIDAD" | Igual al punto 3. |
| 6 | Ítem "Cambio de contraseña" | Ícono SECURITY 24 dp. Label 16 px. Estado neutro. |
| 7 | SectionHeader "LEGAL" | Igual al punto 3. |
| 8 | Ítem "Términos y condiciones" (ACTIVO) | Fondo `primaryContainer` (#C9EDE8). Borde izquierdo 3 dp `primary`. Ícono DESCRIPTION color `primary`. Label "Términos y condiciones" 16 px 600 `primary`. Chevron color `primary`. |
| 9 | SectionHeader "SESIÓN" | Igual al punto 3. |
| 10 | Ítem "Cerrar sesión" | Ícono LOGOUT, label y chevron color `error` (#D14343). Estado neutro destructivo. |
| 11 | Ítem "Eliminar cuenta" | Ícono DELETE_FOREVER, label y chevron color `error` (#D14343). Estado neutro destructivo. |

## Interacciones y comportamiento

- **Tap en "Términos y condiciones":** navega a `02-terminos-condiciones` (push, slide-up + fade 250 ms). El ítem aplica feedback pressed (ripple `primaryContainer` 60%) durante el tap.
- **Tap en ARROW_BACK:** regresa al menú principal (pop).
- **Tap en otros ítems:** navegan a sus respectivos flujos (fuera del alcance de esta US).
- **Resalte del ítem activo:** se muestra al llegar a esta pantalla desde el menú; desaparece al volver desde T&C (el ítem vuelve al estado neutro).

## Navegación

- **Entrada:** desde el menú principal (Home) o desde el botón Configuración de la shell.
- **Salida:** hacia `02-terminos-condiciones` (tap ítem T&C) o hacia atrás al menú principal.
