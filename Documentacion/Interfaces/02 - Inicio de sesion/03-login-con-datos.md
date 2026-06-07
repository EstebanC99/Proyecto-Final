# 03 · Login — con datos ingresados

> Estado del formulario completo, antes de enviar. Tokens en `00-sistema-diseno.md`.
> HTML: `html/02-login-con-datos.html`.

## Propósito
Mostrar el formulario con email y contraseña completados, listo para enviar. Representa el momento
inmediatamente anterior al tap en "Ingresar" del happy path.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐
│ 9:41                                  5G 100% │
│                  ╭────────╮                    │
│                  │  ◐ ●   │   CareWell         │
│                  ╰────────╯                    │
│              Cuidá en equipo                   │
│                                                │
│   Email                                        │
│   ┌────────────────────────────────────────┐  │
│   │ ✉  maria.gomez@gmail.com               │  │   valor real (textPrimary)
│   └────────────────────────────────────────┘  │
│                                                │
│   Contraseña                                   │
│   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │   borde 2dp primary (foco)
│   ┃ 🔒  ••••••••••                      👁  ┃  │   dots · toggle ocultar
│   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
│                                                │
│                      ¿Olvidaste tu contraseña? │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │                Ingresar                  │  │   listo para enviar
│   └────────────────────────────────────────┘  │
│   ───────────────  o  ───────────────────────  │
│   ┌────────────────────────────────────────┐  │
│   │   ¿No tenés cuenta?  Crear cuenta        │  │
│   └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Campo Email (con valor) | Muestra "maria.gomez@gmail.com" en `bodyLarge`/`textPrimary`. Borde `outline` (reposo, sin foco). |
| 2 | Campo Contraseña (con foco) | Borde 2 dp `primary` (campo activo). Valor enmascarado con dots ("••••••••••"). Sufijo 👁 visible. |
| 3 | Botón "Ingresar" | `PrimaryButton` en reposo, listo para recibir el tap. |
| 4 | Resto | Link recuperar, divider y bloque de registro idénticos a [02 normal]. |

## Interacciones y comportamiento
- El campo con foco muestra borde `primary`; al desenfocar vuelve a `outline` (en login **no** se
  valida al blur, así que no aparecen errores por perder foco).
- 👁 alterna entre dots y texto plano de la contraseña.
- Tap "Ingresar" → validación local OK (ambos con contenido) → estado de carga [07].

## Estados alternativos (si aplica)
- Si al pulsar "Ingresar" algún campo estuviera vacío → [04].
- Tras enviar: carga [07] → éxito (Home) / 401 [05] / sin red [06].

## Navegación (de dónde viene / a dónde va)
- **Entrada:** desde [02 normal] a medida que el usuario escribe.
- **Salida:** "Ingresar" → carga [07]; o accesos secundarios (US-03 / US-01).
