# 03 · Cambiar contraseña — formulario

> Pantalla con el formulario de cambio de contraseña.
> Tokens en `00-sistema-diseno.md`. HTML: `html/02-cambiar-contrasena.html`.

## Propósito

Permitir al usuario autenticado establecer una nueva contraseña, verificando primero la
contraseña actual para confirmar su identidad. El formulario es corto (3 campos) y guía
visualmente la fortaleza de la nueva contraseña con el `PasswordStrengthMeter`.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ←  Cambiar contraseña                        │   AppBar surface
│                                              │
│  Nueva contraseña                            │   headlineMedium 24px 700 textPrimary
│  Tu nueva contraseña reemplazará la actual.  │   bodyMedium 14px textSecondary, mt 4dp
│                                              │
│  Contraseña actual                           │   field-label 13px 500 textSecondary
│  ┌──────────────────────────────────────┐   │
│  │ [🔒]  ●●●●●●●●                  [👁] │   │   AppTextField 56dp, estado con datos
│  └──────────────────────────────────────┘   │
│  (helper reservado 18dp)                     │
│                                              │
│  Nueva contraseña                            │
│  ┌──────────────────────────────────────┐   │
│  │ [🔒]  ●●●●●●●●●●●●             [👁] │   │   AppTextField 56dp, estado con datos
│  └──────────────────────────────────────┘   │
│  [███████████████]  Fuerte               │   │   PasswordStrengthMeter 3/3 success
│  (helper reservado 18dp)                     │
│                                              │
│  Confirmar nueva contraseña                  │
│  ┌──────────────────────────────────────┐   │
│  │ [🔒]  ●●●●●●●●●●●●                 │   │   AppTextField 56dp, sin toggle
│  └──────────────────────────────────────┘   │
│  (helper reservado 18dp)                     │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │           Guardar cambios             │   │   PrimaryButton 56dp, primary
│  └──────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, `#16201F`, texto blanco. |
| 2 | AppBar | Fondo `surface`. Borde inferior 1 dp `outline`. ARROW_BACK 24 dp. Título "Cambiar contraseña" 18 px 700. |
| 3 | Título de sección | "Nueva contraseña". 24 px 700 `textPrimary`. Margen superior 24 dp. |
| 4 | Subtítulo | "Tu nueva contraseña reemplazará la actual." 14 px 400 `textSecondary`. Margen superior 4 dp, inferior 20 dp. |
| 5 | Campo "Contraseña actual" | `AppTextField` 56 dp. Prefijo LOCK 20 dp. Sufijo VISIBILITY 20 dp (toggle ver/ocultar). Tipo password. Helper reservado 18 dp. Label externo "Contraseña actual". |
| 6 | Campo "Nueva contraseña" | `AppTextField` 56 dp. Prefijo LOCK 20 dp. Sufijo VISIBILITY 20 dp. Tipo password. Helper reservado 18 dp. Label externo "Nueva contraseña". |
| 7 | PasswordStrengthMeter | Debajo del campo "Nueva contraseña". 3 segmentos, estado "Fuerte" (3/3, color `success` #2E9E5B). Etiqueta "Fuerte" 12 px `success`. Visible solo cuando el campo tiene contenido. |
| 8 | Campo "Confirmar nueva contraseña" | `AppTextField` 56 dp. Prefijo LOCK 20 dp. Sin sufijo toggle. Tipo password. Helper reservado 18 dp. Label externo "Confirmar nueva contraseña". |
| 9 | Botón "Guardar cambios" | `PrimaryButton` full-width 56 dp radio 16. Fondo `primary` (#1A8C82). Texto blanco 16 px 700. Siempre habilitado. |

## Estado del formulario mostrado en el HTML

El mockup muestra el estado "con datos / listo para enviar":
- "Contraseña actual": valor ingresado (puntos).
- "Nueva contraseña": valor ingresado (puntos), medidor en "Fuerte" (3/3).
- "Confirmar nueva contraseña": valor ingresado (puntos).
- Botón "Guardar cambios" habilitado.

## Interacciones y comportamiento

- **Tap en campos:** foco → borde 2 dp `primary`, abre teclado. Tipo `TextInputType.visiblePassword`.
- **Toggle VISIBILITY en "Contraseña actual":** alterna puntos/texto plano. Independiente de los demás.
- **Toggle VISIBILITY en "Nueva contraseña":** ídem, independiente.
- **Escribir en "Nueva contraseña":** el `PasswordStrengthMeter` aparece y actualiza en tiempo real.
- **"Guardar cambios":** dispara validación en cascada; si todo OK, envía petición y muestra loading.
- **ARROW_BACK:** descarta el formulario y regresa a Configuración.

## Estados de error inline

| Campo | Condición | Mensaje helper |
|---|---|---|
| Contraseña actual | campo vacío | "Ingresá tu contraseña actual" |
| Contraseña actual | respuesta 401 del servidor | "Contraseña incorrecta" |
| Nueva contraseña | campo vacío | "Ingresá una nueva contraseña" |
| Nueva contraseña | fortaleza insuficiente | "La contraseña debe tener al menos 8 caracteres" |
| Confirmar nueva contraseña | campo vacío | "Confirmá la nueva contraseña" |
| Confirmar nueva contraseña | no coincide | "Las contraseñas no coinciden" |

## Navegación

- **Entrada:** desde Configuración [01], tap "Cambio de contraseña".
- **Salida exitosa:** pantalla `04-cambio-exitoso` (push reemplazante).
- **Salida manual:** ARROW_BACK → regresa a Configuración.
