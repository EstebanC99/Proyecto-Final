# 04 · Cambio exitoso — pantalla de confirmación

> Pantalla de confirmación tras actualizar la contraseña con exito.
> Tokens en `00-sistema-diseno.md`. HTML: `html/03-cambio-exitoso.html`.

## Propósito

Confirmar al usuario que su contraseña fue cambiada correctamente. La pantalla usa el
patrón de pantalla de éxito completa (sin AppBar) para dar un cierre visual claro al flujo.
Un solo CTA devuelve al usuario a Configuración sin forzar re-login.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│                                              │
│                                              │
│                  ╭────────╮                  │   logo CareWell 64dp
│                  │  ◐ ●   │                  │   (mismo SVG que login)
│                  ╰────────╯                  │
│                  CareWell                    │   wordmark bicolor 22px
│                                              │
│                                              │
│             ╭─────────────────╮              │   círculo 112dp bg #D8F0E1
│             │                 │              │
│             │   CHECK_CIRCLE  │              │   ícono 80dp color #2E9E5B
│             │                 │              │
│             ╰─────────────────╯              │
│                                              │
│           Contrasena actualizada!            │   headlineMedium 24px 700
│                                              │   textPrimary, centrado
│    Tu nueva contrasena ya esta activa.       │   bodyLarge 16px textSecondary
│                                              │   centrado
│                                              │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │       Volver a Configuracion          │   │   PrimaryButton 56dp full-width
│  └──────────────────────────────────────┘   │   go('/settings')
│                                              │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, `#16201F`, texto blanco. |
| 2 | Logo CareWell | Ícono SVG 64 dp + wordmark bicolor "CareWell" 22 px 700. Centrado. Margen superior 52 dp. |
| 3 | Contenedor del ícono de check | Círculo 112 dp, fondo `successContainer` (#D8F0E1). Centrado. Margen superior 32 dp. |
| 4 | Ícono CHECK_CIRCLE | 80 dp, color `success` (#2E9E5B). Centrado dentro del círculo. |
| 5 | Título | "Contrasena actualizada!" (sin tilde para evitar problemas de encoding). 24 px 700 `textPrimary`. Centrado. Margen superior 24 dp. |
| 6 | Subtítulo | "Tu nueva contrasena ya esta activa." 16 px 400 `textSecondary`. Centrado. Margen superior 8 dp. |
| 7 | Botón "Volver a Configuracion" | `PrimaryButton` full-width 56 dp radio 16. Fondo `primary`. Margen superior 40 dp. Padding horizontal 24 dp. |

## Comportamiento de navegacion

- **CTA "Volver a Configuracion":** ejecuta `go('/settings')` (no `push`). Esto reemplaza
  el stack de navegacion de forma que el back del sistema en Configuracion no vuelve a la
  pantalla de exito ni al formulario de cambio.
- **Back del sistema (Android) desde esta pantalla:** idealmente deshabilitado o redirigido
  a `/settings` para evitar volver al formulario con datos ya enviados.
- **La sesion sigue activa.** El usuario no necesita volver a iniciar sesion.

## Diferencia clave con US-03 (recuperacion de contrasena)

| Aspecto | US-03 (recuperacion) | US-09 (cambio en sesion) |
|---|---|---|
| Autenticacion previa | No (usuario sin sesion) | Si (usuario autenticado) |
| Verifica identidad con | Codigo de email | Contrasena actual |
| Despues del exito | Crea nueva sesion, re-login | Sesion continua activa |
| Navegacion CTA | go('/home') o similar | go('/settings') |

## Navegacion

- **Entrada:** desde el formulario de cambio tras respuesta 200 del servidor.
- **Salida unica:** tap "Volver a Configuracion" → `go('/settings')`.
