# 05 · Login — credenciales incorrectas (error de servidor 401)

> Estado tras respuesta 401 del servidor. Tokens en `00-sistema-diseno.md`.
> HTML: `html/04-login-credenciales-incorrectas.html`.

## Propósito
Comunicar que el email y la contraseña no coinciden con ninguna cuenta válida, **sin revelar**
cuál de los dos está mal (decisión de seguridad), y ofrecer un camino claro para recuperar la
contraseña si el usuario no la recuerda.

## Contexto
Las credenciales incorrectas son un error de **servidor (401)**, no detectable localmente. Por eso:
- Se muestra como **banner superior** (`InlineErrorBanner`), no como error de campo.
- **No se marca ningún campo** ni se dice "email incorrecto" o "contraseña incorrecta". El mensaje
  es genérico: si reveláramos cuál está mal, un atacante podría enumerar emails registrados.
- Los valores ingresados **se conservan** para que el usuario corrija sin reescribir todo.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐
│ 9:41                                  5G 100% │
│                  ╭────────╮                    │
│                  │  ◐ ●   │   CareWell         │
│                  ╰────────╯                    │
│                                                │
│   ┌────────────────────────────────────────┐  │   InlineErrorBanner
│   │ ⓧ  El email o la contraseña son        │  │   fondo errorContainer #FBE3E3
│   │    incorrectos. Revisalos e intentá     │  │   ícono+texto error #D14343
│   │    de nuevo.                            │  │   radio 12, padding 12-16
│   └────────────────────────────────────────┘  │
│                                                │
│   Email                                        │
│   ┌────────────────────────────────────────┐  │   SIN marca de error
│   │ ✉  maria.gomez@gmail.com               │  │   (valor conservado)
│   └────────────────────────────────────────┘  │
│                                                │
│   Contraseña                                   │
│   ┌────────────────────────────────────────┐  │   SIN marca de error
│   │ 🔒  ••••••••••                      👁  │  │   (valor conservado)
│   └────────────────────────────────────────┘  │
│                                                │
│                      ¿Olvidaste tu contraseña? │   ← acción útil resaltada
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │                Ingresar                  │  │   listo para reintentar
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
| 1 | `InlineErrorBanner` | Fondo `errorContainer` (#FBE3E3), radio `radiusMd (12)`, padding 12–16 dp. Ícono `error` 20 dp `error` (#D14343) + texto `bodyMedium`/`error`: "El email o la contraseña son incorrectos. Revisalos e intentá de nuevo." Insertado entre el logo y el campo Email. |
| 2 | Campos Email / Contraseña | **Sin** borde de error. Conservan los valores ingresados. La contraseña vuelve a estado enmascarado. |
| 3 | Link "¿Olvidaste tu contraseña?" | Se mantiene; es la salida natural si el usuario no recuerda la contraseña. Sin cambio de estilo, pero el banner lo vuelve más relevante. |
| 4 | Botón "Ingresar" | Habilitado; reintentar dispara una nueva petición → carga [07]. |

## Interacciones y comportamiento
- **Aparición:** tras 401 desde carga [07]; el botón sale de `loading`, los inputs se rehabilitan,
  el banner aparece (fade + slide-down) y el foco se mueve al banner (lector lo anuncia).
- **Limpieza on-change:** al editar email o contraseña, el banner desaparece; el reintento parte limpio.
- **Reintento con los mismos datos:** vuelve a carga [07] y, si sigue 401, reaparece este banner
  (no se apilan banners).
- **Distinción de errores:** este banner es exclusivo del 401. La falta de red usa el banner `info`
  de [06]; los campos vacíos usan error inline [04]. Nunca se combinan 401 + error de campo.

## Estados alternativos (si aplica)
- Sin conexión → [06] (banner `info`, no `error`).
- Campo vacío → [04] (error inline).
- Reintento OK → carga [07] → Home.

## Navegación (de dónde viene / a dónde va)
- **Entrada:** desde carga [07] tras respuesta 401.
- **Salida:** corregir + "Ingresar" → carga [07]; "¿Olvidaste tu contraseña?" → US-03.
