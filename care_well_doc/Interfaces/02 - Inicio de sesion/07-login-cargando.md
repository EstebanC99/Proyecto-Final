# 07 · Login — cargando (verificando credenciales)

> Estado de espera mientras el servidor verifica las credenciales. Tokens en `00-sistema-diseno.md`.
> HTML: `html/06-login-cargando.html`.

## Propósito
Dar feedback inmediato de que el sistema está procesando el login, evitar envíos duplicados y
bloquear la edición mientras dura la verificación, sin oscurecer la pantalla.

## Contexto
A diferencia del registro (US-01), que usa un overlay con scrim sobre el formulario, el login usa
un estado de carga **suave**:
- El botón "Ingresar" pasa a estado `loading` (spinner + sin texto).
- Los inputs quedan **deshabilitados** (fondo `surfaceVariant`, no editables).
- **No** hay scrim oscuro. El login es rápido (~1 s); un overlay completo se percibe pesado.

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
│   ┌────────────────────────────────────────┐  │   disabled (surfaceVariant)
│   │ ✉  maria.gomez@gmail.com               │  │   texto atenuado, no editable
│   └────────────────────────────────────────┘  │
│                                                │
│   Contraseña                                   │
│   ┌────────────────────────────────────────┐  │   disabled (surfaceVariant)
│   │ 🔒  ••••••••••                      👁  │  │   toggle inactivo
│   └────────────────────────────────────────┘  │
│                                                │
│                      ¿Olvidaste tu contraseña? │   atenuado (no interactivo)
│                                                │
│   ┌────────────────────────────────────────┐  │   PrimaryButton LOADING
│   │              ◌  Verificando…             │  │   spinner 20dp onPrimary
│   └────────────────────────────────────────┘  │   sin texto-botón estándar
│                                                │
│   ───────────────  o  ───────────────────────  │
│   ┌────────────────────────────────────────┐  │   atenuado (no interactivo)
│   │   ¿No tenés cuenta?  Crear cuenta        │  │
│   └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Botón "Ingresar" loading | Mantiene fondo `primary`. Reemplaza el texto por `CircularProgressIndicator` 20 dp color `onPrimary`. Opcionalmente acompaña con texto "Verificando…". No clickeable. |
| 2 | Campo Email (disabled) | Fondo `surfaceVariant` (#EDF1F1), texto atenuado, borde `outline`. No editable, no recibe foco. |
| 3 | Campo Contraseña (disabled) | Igual; el toggle 👁 queda inactivo. |
| 4 | Links secundarios | "¿Olvidaste tu contraseña?" y "Crear cuenta" atenuados (opacidad ~50%) y no interactivos durante la carga, para evitar abandonar el flujo a mitad de la petición. |

## Interacciones y comportamiento
- **Entrada al estado:** al pulsar "Ingresar" con validación local OK; fade 150 ms (no cambia de ruta).
- **Bloqueo de input:** toda la pantalla queda no editable; reintentos/duplicados imposibles.
- **Duración esperada:** ~0.5–2 s. Si supera ~10 s, tratar como timeout → banner sin conexión [06].
- **Salidas:**
  - 200 OK → `pushReplacement` a Home/Menú (US-04), fade 250 ms.
  - 401 → vuelve el formulario con banner de credenciales [05].
  - Fallo de red / timeout → banner sin conexión [06].
- Respetar reduce-motion: el spinner se mantiene (es indicador de estado, no decorativo).

## Estados alternativos (si aplica)
- Es el estado intermedio entre [03/05/06] y el resultado (Home / [05] / [06]).

## Navegación (de dónde viene / a dónde va)
- **Entrada:** desde [03 con-datos], o reintento desde [05]/[06], al pulsar "Ingresar".
- **Salida:** Home (US-04) / credenciales incorrectas [05] / sin conexión [06].
