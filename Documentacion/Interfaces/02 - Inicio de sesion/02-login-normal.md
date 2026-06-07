# 02 · Login — pantalla normal (estado inicial vacío)

> Primera pantalla de la app. Tokens en `00-sistema-diseno.md`. HTML: `html/01-login-normal.html`.

## Propósito
Permitir que un usuario registrado inicie sesión con su email y contraseña, con la menor fricción
posible, y ofrecer accesos secundarios a recuperación de contraseña y a registro. Al ser la
**primera pantalla**, también cumple una función de marca: presentar CareWell con claridad.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│                                                │
│                  ╭────────╮                    │   logo 72×72 (ícono marca)
│                  │  ◐ ●   │                    │   margen superior ~56 dp
│                  ╰────────╯                    │
│                  CareWell                      │   wordmark bicolor (Care/Well)
│              Cuidá en equipo                   │   tagline · bodyMedium textSecondary
│                                                │
│   Email                                        │   label externo · labelMedium
│   ┌────────────────────────────────────────┐  │
│   │ ✉  tucorreo@ejemplo.com                │  │   AppTextField reposo · 56 dp
│   └────────────────────────────────────────┘  │
│                                                │
│   Contraseña                                   │
│   ┌────────────────────────────────────────┐  │
│   │ 🔒  Ingresá tu contraseña           👁  │  │   AppTextField + toggle ver
│   └────────────────────────────────────────┘  │
│                                                │
│                      ¿Olvidaste tu contraseña? │   link primary, alineado derecha
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │                Ingresar                  │  │   PrimaryButton full-width 56 dp
│   └────────────────────────────────────────┘  │
│                                                │
│   ───────────────  o  ───────────────────────  │   divider con label
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │   ¿No tenés cuenta?  Crear cuenta        │  │   bloque tappable ≥48 dp → US-01
│   └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Logo + wordmark | Ícono de marca 72×72 dp (círculo teal con figura coral), centrado, margen superior ~56 dp. Debajo wordmark "**Care**Well" (`Care` #16201F, `Well` #1A8C82, 22 px bold). Tagline "Cuidá en equipo" en `bodyMedium`/`textSecondary`. |
| 2 | Campo Email | `AppTextField` en reposo. Label externo "Email". Prefijo ✉ 20 dp. Placeholder "tucorreo@ejemplo.com" (`textDisabled`). Teclado `emailAddress`, sin autocapitalización. |
| 3 | Campo Contraseña | `AppTextField` en reposo. Label "Contraseña". Prefijo 🔒. Placeholder "Ingresá tu contraseña". Sufijo 👁 (toggle ver/ocultar, oculto por defecto). |
| 4 | Link recuperar | `SecondaryTextButton` "¿Olvidaste tu contraseña?" `labelMedium`/`primary`, alineado a la derecha bajo el campo contraseña. |
| 5 | Botón "Ingresar" | `PrimaryButton` full-width, 56 dp, radio 16, fondo `primary`. **Siempre habilitado.** |
| 6 | Divider con label | Línea `outline` 1 dp con "o" centrado, margen vertical `xl (24)`. Separa la acción primaria del acceso a registro. |
| 7 | Bloque de registro | Fila centrada tappable ≥48 dp: "¿No tenés cuenta?" (`bodyMedium`/`textSecondary`) + "**Crear cuenta**" (`labelMedium` bold/`primary`). Borde sutil opcional para resaltar la zona. → US-01. |

## Interacciones y comportamiento
- **Tap en Email / Contraseña:** foco → borde 2 dp `primary`; abre teclado correspondiente.
- **Toggle 👁:** alterna mostrar/ocultar contraseña; el ícono cambia a `visibility_off` cuando es visible.
- **"Ingresar":** dispara validación local (ver [03]); si OK, pasa a estado de carga [06].
- **"¿Olvidaste tu contraseña?":** navega a US-03 (recuperación), slide-right + fade 250 ms.
- **"Crear cuenta" (o toda la fila):** navega a US-01 Paso 1, slide-right + fade 250 ms. Feedback pressed 70% opacidad.
- Con teclado abierto, el contenido hace scroll; el bloque de registro no se ancla al fondo.

## Estados alternativos (si aplica)
- Con datos ingresados → [03 con-datos].
- Error de campo vacío → [04].
- Error de credenciales (401) → [05].
- Sin conexión → [06].
- Cargando → [07].

## Navegación (de dónde viene / a dónde va)
- **Entrada:** arranque de la app (post-splash), logout, o retorno desde US-01/US-03.
- **Salida:** Home/Menú principal (US-04) tras login exitoso; US-03 (recuperar); US-01 (registro).
