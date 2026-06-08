# 04 · Nueva contraseña — establecer la contraseña desde el link del email

> Pantalla que abre el deep link del email. Tokens en `00-sistema-diseno.md`. HTML: `html/03-nueva-contrasena.html`.

## Propósito

Permitir al usuario establecer una nueva contraseña segura una vez que accedió al link enviado
por email. Es el punto de entrada externo al flujo: el usuario no viene desde dentro de la app
sino desde su cliente de email. Por eso la pantalla incluye el logo CareWell para dar contexto
de marca y no tiene AppBar.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│                                                │   sin AppBar (deep link)
│                                                │
│                  ╭────────╮                    │   logo 64×64 dp
│                  │  ◐ ●   │                    │   (ícono marca — versión reducida)
│                  ╰────────╯                    │
│                  CareWell                      │   wordmark bicolor
│                                                │
│   Nueva contraseña                             │   headlineMedium · textPrimary
│   Creá una contraseña segura para tu cuenta.  │   bodyMedium · textSecondary
│                                                │
│   Nueva contraseña                             │   label externo · labelMedium
│   ┌────────────────────────────────────────┐  │
│   │ 🔒  ••••••••                        👁  │  │   AppTextField + toggle · 56 dp
│   └────────────────────────────────────────┘  │
│   ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░  Media             │   PasswordStrengthMeter 2/3 (#E0A100)
│                                                │
│   Confirmar contraseña                         │
│   ┌────────────────────────────────────────┐  │
│   │ 🔒  ••••••••                        👁  │  │   AppTextField + toggle · 56 dp
│   └────────────────────────────────────────┘  │
│   (helper reservado 18 dp)                     │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │           Guardar contraseña           │  │   PrimaryButton full-width 56 dp
│   └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Logo + wordmark | Ícono 64×64 dp (versión reducida del logo de Login). Wordmark "CareWell" ("Care" `textPrimary`, "Well" `primary`). Sin tagline. Centrado. Margen superior 40 dp. |
| 2 | Título | `headlineMedium` (24 sp bold) "Nueva contraseña". Margen superior 28 dp. |
| 3 | Subtítulo | `bodyMedium` `textSecondary` "Creá una contraseña segura para tu cuenta." Margen superior 6 dp. |
| 4 | Campo "Nueva contraseña" | `AppTextField`. Label externo. Prefijo LOCK 20 dp. Sufijo VISIBILITY 20 dp (toggle). Texto enmascarado por defecto. Margen superior 24 dp. |
| 5 | PasswordStrengthMeter | 3 segmentos horizontales debajo del campo. Estado "Media" (2 de 3 activos): primeros 2 segmentos en #E0A100 (amarillo-naranja), 3er segmento en `outline` (#C5CECE). Label "Media" a la derecha, `labelSmall` color #E0A100. Margen superior 8 dp. |
| 6 | Campo "Confirmar contraseña" | `AppTextField`. Label externo. Prefijo LOCK 20 dp. Sufijo VISIBILITY 20 dp. Enmascarado. Helper reservado 18 dp para error de "las contraseñas no coinciden". Margen superior 16 dp. |
| 7 | Botón "Guardar contraseña" | `PrimaryButton` full-width, 56 dp, radio 16. Margen superior 24 dp. Valida al pulsar. |

## Reglas de validacion

- **Longitud mínima:** 8 caracteres. Error: "La contraseña debe tener al menos 8 caracteres."
- **Fortaleza:** igual a US-01 registro.
  - Baja (1/3, rojo #D14343): menos de 8 caracteres o solo números.
  - Media (2/3, #E0A100): 8+ chars, letras + números.
  - Alta (3/3, `success` #2E9E5B): 8+ chars, mayusculas, numeros y caracteres especiales.
- **Coincidencia:** si "Confirmar" no coincide con "Nueva contraseña", error inline en el campo
  de confirmación: "Las contraseñas no coinciden."
- **Validacion al pulsar "Guardar contraseña".** No se valida al blur para reducir fricción.

## Interacciones y comportamiento

- **Toggle VISIBILITY:** alterna ver/ocultar en cada campo de forma independiente.
- **"Guardar contraseña" con errores:** errores inline en los campos correspondientes, sin llamada al servidor.
- **"Guardar contraseña" válido:** botón loading + campos disabled → petición al servidor con el token del deep link.
- **Respuesta 200:** navega a `05-cambio-exitoso` (`pushReplacement`).
- **Token expirado / inválido:** banner de error "El link expiró. Solicitá uno nuevo." + link a `01-solicitar-email`.
- **Sin AppBar:** no hay forma de volver atrás dentro del flujo. Back del sistema cierra la app o vuelve al cliente de email.

## Navegacion (de donde viene / a donde va)

- **Entrada:** deep link externo desde el email → ruta `/recover/reset?token=…`.
- **Salida exitosa:** `05-cambio-exitoso` → `pushReplacement /recover/success`.
- **Salida por token inválido:** error en pantalla + link manual a `01-solicitar-email`.
