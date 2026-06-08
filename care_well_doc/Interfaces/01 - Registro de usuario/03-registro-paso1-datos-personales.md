# 03 · Registro · Paso 1 — Datos personales

> Tokens en `00-identidad-visual.md`. Flujo en `01-flujo-navegacion.md`.

## Propósito
Recolectar los datos personales de la persona que se registra (registro neutro, sin rol).

## Wireframe

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ ┌──┐                                           │   FlowAppBar 56 dp
│ │← │                                           │   back → Login (con confirm si hay datos)
│ └──┘                                           │
│                                                │
│  ▰▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱▱▱        Paso 1 de 2        │   StepProgressBar 50% + contador
│                                                │
│  Creá tu cuenta                                │   headlineMedium, textPrimary
│  Empecemos con tus datos personales.           │   bodyMedium, textSecondary
│                                                │
│  Nombre                                        │   label labelMedium textSecondary
│  ┌────────────────────────────────────────┐   │
│  │ 👤  Ej. María                           │   │   AppTextField (reposo)
│  └────────────────────────────────────────┘   │
│  ·línea helper reservada (vacía)·              │
│                                                │
│  Apellido                                      │
│  ┌────────────────────────────────────────┐   │
│  │ 👤  Ej. González                        │   │
│  └────────────────────────────────────────┘   │
│  ·                                             │
│                                                │
│  Email                                         │
│  ┌────────────────────────────────────────┐   │
│  │ ✉  tucorreo@ejemplo.com                │   │   keyboard emailAddress
│  └────────────────────────────────────────┘   │
│  Lo usarás para iniciar sesión.                │   helper labelSmall textSecondary
│                                                │
│  Teléfono                                      │
│  ┌────────────────────────────────────────┐   │
│  │ 📞  +54 9 11 1234 5678                  │   │   keyboard phone
│  └────────────────────────────────────────┘   │
│  ·                                             │
│                                                │
│                ( espacio flexible )            │
│  ┌────────────────────────────────────────┐   │
│  │               Continuar                  │   │   PrimaryButton full-width 56 dp
│  └────────────────────────────────────────┘   │
│         Ya tenés cuenta?  Iniciar sesión       │   link secundario, centrado
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | `FlowAppBar` | Solo leading "atrás". Sin título. Fondo `background`. |
| 2 | `StepProgressBar` | Track 6 dp `surfaceVariant`, relleno `primary` al **50%**. A la derecha "Paso 1 de 2" `labelMedium` `textSecondary`. Margen inferior `xl`. |
| 3 | Título | "Creá tu cuenta" `headlineMedium` `textPrimary`. |
| 4 | Subtítulo | "Empecemos con tus datos personales." `bodyMedium` `textSecondary`. Margen inferior `xl`. |
| 5 | Campo **Nombre** | `AppTextField`, prefijo 👤, `textCapitalization: words`, requerido. Placeholder "Ej. María". |
| 6 | Campo **Apellido** | igual, placeholder "Ej. González", requerido. |
| 7 | Campo **Email** | prefijo ✉, teclado `emailAddress`, `autocorrect off`, requerido. Helper persistente: "Lo usarás para iniciar sesión." |
| 8 | Campo **Teléfono** | prefijo 📞, teclado `phone`. Requerido (confirmado: registro pide teléfono). Placeholder formato internacional. |
| 9 | `PrimaryButton` "Continuar" | full-width 56 dp. Habilitado siempre; valida al pulsar. |
| 10 | Link "Iniciar sesión" | `SecondaryTextButton` centrado bajo el botón, para quien llegó por error. |

Separación entre campos: `lg (16)`. Padding horizontal de pantalla: `xl (24)`. Cuerpo en
`SingleChildScrollView` para evitar overflow con teclado abierto; el botón "Continuar" hace
scroll con el contenido (no fijo) salvo en pantallas altas donde queda al fondo por el spacer.

## Reglas de validación (al blur, field-by-field)

| Campo | Regla | Mensaje de error |
|---|---|---|
| Nombre | No vacío; 2–50 caracteres; letras/espacios/guiones/apóstrofo. | "Ingresá tu nombre." |
| Apellido | No vacío; 2–50; mismo set. | "Ingresá tu apellido." |
| Email | No vacío; formato email válido (regex estándar). | "Ingresá un email válido." |
| Teléfono | No vacío; 7–20 dígitos (admite +, espacios, guiones). | "Ingresá un teléfono válido." |

> El email **duplicado** NO se valida acá (es del servidor, ver Paso 2 / [10]). Acá solo formato.

## Interacciones y comportamiento
- **Al perder foco (blur)** de un campo: se ejecuta su validación. Si falla, el campo pasa a
  estado **error** (ver [04]); si pasa, vuelve/permanece en reposo.
- **Foco siguiente:** "Enter"/"Siguiente" del teclado mueve al campo siguiente; en el último
  (teléfono) la acción es "Listo".
- **Tap "Continuar":**
  - Valida los 4 campos. Si todos OK → navega a **Paso 2 [05]** (slide horizontal) conservando
    los datos.
  - Si hay error → hace scroll/foco al primer campo inválido y muestra sus errores. No avanza.
- **Back (← o gesto Android):** si hay al menos un campo con datos, abre un **diálogo de confirmación**
  "¿Salir del registro? Se perderán los datos ingresados." [Cancelar] / [Salir]. Si no hay datos,
  vuelve directo al Login.
- **Persistencia:** al volver desde Paso 2, los 4 campos conservan sus valores.

## Estados alternativos
- **Reposo / con datos:** este documento.
- **Error de validación:** ver [04].
- No hay estados de carga/empty en este paso (no consulta backend).

## Navegación
- **Entrada:** desde Login [02] ("Crear cuenta"); o retroceso desde Paso 2 [05].
- **Salida:** "Continuar" → Paso 2 [05]; back → Login [02].
