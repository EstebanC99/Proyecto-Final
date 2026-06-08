# 06 · Cambio exitoso — contraseña actualizada

> Pantalla final del flujo US-03. Reutilizada en US-09 (cambio de contraseña desde Configuracion).
> Tokens en `00-sistema-diseno.md`. HTML: `html/05-cambio-exitoso.html`.

## Propósito

Confirmar al usuario que su contraseña fue actualizada correctamente y guiarlo al inicio de
sesión. Es una pantalla de cierre del flujo: celebratoria, clara, sin opciones superfluas.
El foco está en el feedback positivo y en la acción única disponible.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│                                                │   sin AppBar
│                                                │
│                  ╭────────╮                    │   logo 64×64 dp
│                  │  ◐ ●   │                    │
│                  ╰────────╯                    │
│                  CareWell                      │   wordmark bicolor
│                                                │
│                                                │   espacio vertical ~40 dp
│                                                │
│                  ╔════════╗                    │   contenedor circular 112 dp
│                  ║  [✓]   ║                    │   fondo successContainer (#D8F0E1)
│                  ╚════════╝                    │   CHECK_CIRCLE 80 dp (success #2E9E5B)
│                                                │
│          ¡Contraseña actualizada!              │   displaySmall · textPrimary · centrado
│                                                │
│   Tu nueva contraseña está activa.            │
│   Ya podés iniciar sesión.                    │   bodyMedium · textSecondary · centrado
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │         Ir al inicio de sesión          │  │   PrimaryButton full-width 56 dp
│   └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Logo + wordmark | Ícono 64×64 dp centrado. Wordmark "CareWell" ("Care" `textPrimary`, "Well" `primary`). Sin tagline. Margen superior 52 dp. |
| 2 | Ícono de exito | Contenedor circular 112 dp, fondo `successContainer` (#D8F0E1). CHECK_CIRCLE 80 dp, color `success` (#2E9E5B). Centrado horizontalmente. Margen superior 40 dp. |
| 3 | Título | `displaySmall` (28 sp bold) "¡Contraseña actualizada!". Centrado. `textPrimary`. Margen superior 24 dp. |
| 4 | Cuerpo | `bodyMedium` (16 sp regular) `textSecondary`. "Tu nueva contraseña está activa. Ya podés iniciar sesión." Centrado. Margen superior 8 dp. |
| 5 | Botón "Ir al inicio de sesión" | `PrimaryButton` full-width, 56 dp, radio 16, fondo `primary`. Margen superior 36 dp. |

## Interacciones y comportamiento

- **"Ir al inicio de sesión":** `pushReplacement /login`. Limpia el stack completo de recuperación
  (pantallas `03-nueva-contrasena` y esta). El usuario no puede volver atrás con el back del sistema.
- **Back del sistema (Android):** bloqueado o redirige a Login (misma lógica que `pushReplacement`).
  El link del email ya fue consumido; no tiene sentido permitir navegar atrás.
- **Sin AppBar:** la pantalla es un punto final del flujo. No hay navegación interna.
- **Animacion de entrada:** el ícono CHECK_CIRCLE puede tener una animacion de escala (scale-in,
  300 ms, curva `easeOutBack`) al aparecer para reforzar el feedback positivo.

## Reutilizacion en US-09

Cuando esta pantalla se usa desde Configuración (US-09), la acción del botón cambia:
en lugar de ir a Login, hace `pop` de vuelta a Configuración. El texto del botón puede
cambiar a "Listo" o mantenerse genérico ("Volver"). El widget recibe el destino como
parámetro de configuración.

## Navegacion (de donde viene / a donde va)

- **Entrada en US-03:** `03-nueva-contrasena` → servidor confirma cambio → `pushReplacement /recover/success`.
- **Entrada en US-09:** pantalla de cambio de contraseña → servidor confirma → `pushReplacement`.
- **Salida:** Login (US-03) o Configuración (US-09) → `pushReplacement`.
