# 04 · Login — error de campo vacío (validación local)

> Estado tras pulsar "Ingresar" con un campo sin completar. Tokens en `00-sistema-diseno.md`.
> HTML: `html/03-login-campo-vacio.html`.

## Propósito
Indicar de forma inmediata y específica qué campo falta completar, sin enviar la petición al
servidor. Es validación **local**, por eso el error es **inline en el campo**, no un banner.

## Contexto
El criterio de aceptación pide: "Si algún campo está vacío, se muestra error en ese campo al
intentar ingresar." La validación se dispara **al pulsar "Ingresar"** (no al blur). El caso
ilustrado es el campo **Email vacío** con la contraseña completada; si faltaran ambos, se marcan
ambos y el foco va al primero (Email).

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
│   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │   borde 2dp error (#D14343)
│   ┃ ✉  tucorreo@ejemplo.com                ┃  │   placeholder (vacío)
│   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
│   ⚠ Ingresá tu email                           │   labelSmall error + ícono 16dp
│                                                │
│   Contraseña                                   │
│   ┌────────────────────────────────────────┐  │
│   │ 🔒  ••••••••••                      👁  │  │   completo, sin error
│   └────────────────────────────────────────┘  │
│                                                │
│                      ¿Olvidaste tu contraseña? │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │                Ingresar                  │  │
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
| 1 | Campo Email (error) | Borde 2 dp `error` (#D14343). Sin valor (muestra placeholder). Recibe el foco automáticamente. |
| 2 | Mensaje inline | Bajo el campo: ícono `error` 16 dp `error` + texto "Ingresá tu email" en `labelSmall`/`error`. Ocupa la línea reservada de 18 dp (sin salto de layout). |
| 3 | Campo Contraseña | En reposo, sin error (tiene contenido). |
| 4 | Botón "Ingresar" | Sigue habilitado; volver a pulsar revalida. |

### Mensajes por campo

| Campo vacío | Mensaje inline |
|---|---|
| Email | "Ingresá tu email" |
| Contraseña | "Ingresá tu contraseña" |
| Ambos | Ambos campos marcados; foco en Email; cada uno con su mensaje. |

## Interacciones y comportamiento
- **Aparición:** al pulsar "Ingresar" con campo(s) vacío(s); fade + slide-down 4 dp, 150 ms. Foco
  al primer campo inválido (lector lo anuncia: "Email, error: Ingresá tu email").
- **Limpieza:** al empezar a escribir en el campo, el error se borra **on-change** y el borde
  vuelve a `outline`/`primary`.
- **No se envía nada al servidor** mientras haya un campo vacío.
- Si el email tiene formato inválido (no vacío pero mal formado) se usa el mismo patrón con el
  mensaje "Ingresá un email válido". (Validación de formato mínima; la verificación real es del servidor.)

## Estados alternativos (si aplica)
- Corregido → vuelve a [03 con-datos].
- Tras corregir y reenviar → carga [07] → éxito / 401 [05] / sin red [06].

## Navegación (de dónde viene / a dónde va)
- **Entrada:** desde [02]/[03] al pulsar "Ingresar" con campos vacíos.
- **Salida:** corregir + "Ingresar" → carga [07].
