# 02 · Pantalla de entrada (Login) — acceso al registro

> Se especifica solo el segmento relevante a US-01: cómo se accede al registro desde el login.
> El login completo se especifica en su propia User Story. Tokens en `00-identidad-visual.md`.

## Propósito
Ofrecer un punto de acceso claro e inequívoco a "Crear cuenta" para quien todavía no tiene cuenta.

## Wireframe

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│                                                │
│                  ╭────────╮                    │   24 dp top-safe
│                  │  ◆◆◆   │  logo CareWell     │   logo 72x72, primary
│                  ╰────────╯                    │
│                  CareWell                      │   headlineMedium, textPrimary
│           Cuidar, en equipo.                   │   bodyMedium, textSecondary
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │ Email                                   │  │   AppTextField (label ext.)
│   │ ┌────────────────────────────────────┐ │  │
│   │ │ ✉  tucorreo@ejemplo.com            │ │  │
│   │ └────────────────────────────────────┘ │  │
│   └────────────────────────────────────────┘  │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │ Contraseña                              │  │
│   │ ┌────────────────────────────────────┐ │  │
│   │ │ 🔒 ••••••••                     👁  │ │  │
│   │ └────────────────────────────────────┘ │  │
│   └────────────────────────────────────────┘  │
│                                                │
│                      ¿Olvidaste tu contraseña? │   labelMedium, primary, right
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │            Iniciar sesión               │  │   PrimaryButton, full-width
│   └────────────────────────────────────────┘  │
│                                                │
│   ──────────────────────────────────────────  │
│                                                │   ↓ ZONA CLAVE US-01
│        ¿Aún no tenés cuenta?  Crear cuenta     │   bodyMedium + link primary
│                                                │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Logo + wordmark | Logo 72x72 dp color `primary` sobre `primaryContainer` circular; debajo "CareWell" en `headlineMedium`/`textPrimary` y tagline "Cuidar, en equipo." en `bodyMedium`/`textSecondary`. Centrado. |
| 2 | Campo Email | `AppTextField`, prefijo ✉, teclado `emailAddress`. (Spec completa en US Login.) |
| 3 | Campo Contraseña | `AppTextField` con toggle mostrar/ocultar (👁). |
| 4 | Link recuperar | `SecondaryTextButton` alineado a la derecha. |
| 5 | Botón "Iniciar sesión" | `PrimaryButton` full-width, 56 dp. |
| 6 | Divider | Línea `outline` 1 dp, margen vertical `xl (24)`. |
| 7 | **Bloque de acceso a registro** | Fila centrada: texto "¿Aún no tenés cuenta?" en `bodyMedium`/`textSecondary` + **"Crear cuenta"** en `labelMedium` **bold** color `primary`. El bloque completo (texto+link) es tappable con objetivo táctil >= 48 dp. |

## Interacciones y comportamiento
- **Tap en "Crear cuenta"** (o en toda la fila del bloque 7): navega a **Registro Paso 1 [03]**,
  con transición slide-right + fade 250 ms.
- El link "Crear cuenta" muestra feedback de pressed (opacidad 70%).
- En foco por teclado/lector de pantalla, el bloque se anuncia como botón: "Crear cuenta, botón".

## Estados alternativos
- No aplican estados de datos para este segmento (la carga/errores del login son de su propia US).
- En pantallas muy bajas (teclado abierto), el bloque de registro permanece accesible vía scroll;
  no se ancla al fondo para no chocar con el teclado.

## Navegación
- **Entrada:** arranque de la app / logout / desde pantalla de éxito o error de email.
- **Salida (US-01):** "Crear cuenta" → Registro Paso 1 [03].
