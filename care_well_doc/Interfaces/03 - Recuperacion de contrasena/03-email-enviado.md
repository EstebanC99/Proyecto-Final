# 03 · Email enviado — confirmacion de envio del link

> Segunda pantalla del happy path de US-03. Tokens en `00-sistema-diseno.md`. HTML: `html/02-email-enviado.html`.

## Propósito

Confirmar al usuario que el link fue enviado y a qué dirección, para que sepa exactamente adónde
ir a buscarlo. También ofrece la opción de reenviar si el email no llega. La pantalla es informativa
y de bajo esfuerzo cognitivo: no requiere accion inmediata del usuario dentro de la app.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ← Email enviado                               │   AppBar surface (#FFFFFF)
│                                                │
│                                                │
│                  ┌────────┐                    │   contenedor circular 96 dp
│                  │   📧✓  │                    │   fondo primaryContainer (#C9EDE8)
│                  └────────┘                    │   ícono MARK_EMAIL_READ 48 dp (primary)
│                                                │
│              Revisá tu email                   │   headlineMedium · textPrimary · centrado
│                                                │
│   Enviamos un link a                           │
│   maria@ejemplo.com                            │   bodyMedium · email en negrita
│   Seguí las instrucciones para                 │   textSecondary · centrado
│   restablecer tu contraseña.                   │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │        Volver al inicio de sesión       │  │   PrimaryButton full-width 56 dp
│   └────────────────────────────────────────┘  │
│                                                │
│        ¿No recibiste el email? Reenviar         │   SecondaryTextButton · centrado
│                                                │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | AppBar | Surface #FFFFFF. Ícono ARROW_BACK 24 dp. Sin título en AppBar (el contenido tiene su propia jerarquía). |
| 2 | Ícono ilustrativo | Contenedor circular 96 dp, fondo `primaryContainer` (#C9EDE8). Ícono MARK_EMAIL_READ 48 dp, color `primary` (#1A8C82). Centrado horizontalmente, margen superior 48 dp desde AppBar. |
| 3 | Título | `headlineMedium` (24 sp bold) "Revisá tu email". Centrado. Margen superior 24 dp. |
| 4 | Cuerpo | `bodyMedium` (16 sp regular) `textSecondary`. Centrado. El email se muestra en `bold` `textPrimary` en la misma línea o línea siguiente. Texto: "Enviamos un link a [email]. Seguí las instrucciones para restablecer tu contraseña." |
| 5 | Botón "Volver" | `PrimaryButton` full-width "Volver al inicio de sesión", 56 dp, radio 16. Margen superior 36 dp. |
| 6 | Link "Reenviar" | `SecondaryTextButton` centrado "¿No recibiste el email? Reenviar". "Reenviar" en bold/`primary`. Margen superior 16 dp. Objetivo táctil mín. 48 dp. |

## Interacciones y comportamiento

- **"Volver al inicio de sesión":** `pop` hasta `/login`, limpia el stack de recuperación. El usuario
  puede iniciar sesión con la nueva contraseña una vez que la haya establecido.
- **"Reenviar":** reenvía la petición al servidor con el mismo email. Durante el reenvío, el link
  muestra "Reenviando…" (disabled, color `textDisabled`) por ~1 s. Tras el reenvío, vuelve al
  estado normal con un feedback sutil (snackbar "Email reenviado" o el link vuelve a estar activo).
  Límite recomendado: máximo 3 reenvíos (lógica del backend).
- **ARROW_BACK:** vuelve a `01-solicitar-email` por si el usuario quiere corregir el email.
- **No hay timeout ni polling.** La pantalla es estática; el usuario gestiona el proceso desde su
  cliente de email.

## Estados alternativos

- **Reenviando:** link "Reenviar" en estado disabled con texto "Reenviando…".
- **Reenvio exitoso:** feedback sutil (snackbar no intrusivo, 2 s).

## Navegacion (de donde viene / a donde va)

- **Entrada:** `01-solicitar-email` tras confirmación del servidor → `push /recover/sent`.
- **Salida principal:** Login → `pop` hasta `/login`.
- **Salida alternativa:** volver a `01-solicitar-email` por ARROW_BACK → `pop`.
