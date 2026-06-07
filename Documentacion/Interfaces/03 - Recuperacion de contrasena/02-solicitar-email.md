# 02 · Solicitar email — pantalla de entrada al flujo

> Primera pantalla de US-03. Tokens en `00-sistema-diseno.md`. HTML: `html/01-solicitar-email.html`.

## Propósito

Permitir que el usuario ingrese su email para recibir el link de restablecimiento de contraseña.
Es la puerta de entrada al flujo desde Login. El diseño es deliberadamente simple: un solo campo,
un botón y un link de retorno. Mínima fricción.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ← Recuperar contraseña                        │   AppBar surface (#FFFFFF) con ARROW_BACK
│                                                │
│                                                │   sin logo (flujo interno con AppBar)
│                                                │
│   Recuperar contraseña                         │   headlineMedium · textPrimary
│   Ingresá el email asociado a tu cuenta        │
│   y te enviaremos un link para restablecer     │   bodyMedium · textSecondary
│   tu contraseña.                               │
│                                                │
│   Email                                        │   label externo · labelMedium
│   ┌────────────────────────────────────────┐  │
│   │ ✉  tucorreo@ejemplo.com                │  │   AppTextField reposo · 56 dp
│   └────────────────────────────────────────┘  │
│   (helper reservado 18 dp)                     │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │              Enviar link               │  │   PrimaryButton full-width 56 dp
│   └────────────────────────────────────────┘  │
│                                                │
│              Volver al inicio de sesión         │   SecondaryTextButton · centrado
│                                                │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | AppBar | Surface #FFFFFF, sombra sutil 2 dp. Ícono ARROW_BACK 24 dp (`textPrimary`). Sin título en AppBar (el título va en el contenido). Alto 56 dp. |
| 2 | Título | `headlineMedium` (24 sp bold) "Recuperar contraseña". Margen superior 32 dp desde AppBar. |
| 3 | Subtítulo | `bodyMedium` (16 sp regular) `textSecondary` "Ingresá el email asociado a tu cuenta y te enviaremos un link para restablecer tu contraseña." Margen superior 8 dp. |
| 4 | Campo Email | `AppTextField` en reposo. Label externo "Email". Prefijo correo 20 dp. Placeholder "tucorreo@ejemplo.com" (`textDisabled`). Margen superior 28 dp. Teclado `emailAddress`. Helper reservado 18 dp bajo el campo para mensajes de error inline. |
| 5 | Botón "Enviar link" | `PrimaryButton` full-width, 56 dp, radio 16, fondo `primary`. Margen superior 24 dp. Siempre habilitado; valida al pulsar. |
| 6 | Link "Volver" | `SecondaryTextButton` centrado "Volver al inicio de sesión". `labelMedium` bold, color `primary`. Margen superior 20 dp. Objetivo táctil mín. 48 dp. |

## Interacciones y comportamiento

- **Tap en Email:** foco → borde 2 dp `primary`; abre teclado email.
- **"Enviar link" con campo vacío:** error inline bajo el campo ("Ingresá tu email"), sin llamada al servidor.
- **"Enviar link" con formato incorrecto:** error inline "El formato del email no es válido".
- **"Enviar link" con email válido:** pasa a estado de carga (botón loading, campo disabled) → petición al servidor.
- **Respuesta 200:** navega a `02-email-enviado` (push).
- **Respuesta de email no registrado:** muestra `04-error-email-no-registrado` (banner, no cambia de ruta).
- **ARROW_BACK:** pop → vuelve a Login. Si el usuario había escrito un email, se descarta.
- **"Volver al inicio de sesión":** pop → vuelve a Login (mismo efecto que ARROW_BACK).

## Estados alternativos

- Con email escrito y válido: botón listo para enviar (no hay distinción visual en este mockup).
- Campo con error de formato: borde 2 dp `error`, helper con mensaje, ícono ERROR 16 dp.
- Cargando: botón con spinner (texto oculto), campo disabled (fondo `surfaceVariant`).
- Error de email no registrado: ver `05-error-email-no-registrado.md`.

## Navegacion (de donde viene / a donde va)

- **Entrada:** Login · tap "¿Olvidaste tu contraseña?" → `push /recover`.
- **Salida exitosa:** `02-email-enviado` → `push /recover/sent`.
- **Salida cancelar:** Login → `pop`.
