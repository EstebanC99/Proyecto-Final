# 04 · Creacion de credenciales — Cargando

> Estado de espera mientras el servidor crea las credenciales. Tokens en `00-sistema-diseno.md`.
> HTML: `html/03-cargando.html`.

## Proposito
Dar feedback inmediato de que el sistema esta procesando la creacion de credenciales,
bloquear reenvios duplicados y evitar que el usuario abandone el flujo a mitad de la
peticion. La carga de creacion de cuenta es rapida (~1-2 s); se usa el mismo patron
"suave" del Login (boton loading + inputs disabled) sin overlay ni scrim.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar
│ ←  Creá tu contraseña                         │   AppBar (ARROW_BACK inactivo en carga)
├──────────────────────────────────────────────┤
│                                               │
│  Tu email de acceso sera                      │
│  maria@ejemplo.com                            │   email estatico (sin cambio)
│                                               │
│  Nueva contraseña                             │
│  ┌──────────────────────────────────────────┐ │
│  │ LOCK  ••••••••••••             VISIBILITY │ │   disabled · bg surfaceVariant (#EDF1F1)
│  └──────────────────────────────────────────┘ │   texto atenuado · no editable
│  [███████████████████████] Fuerte             │   medidor fijo (no cambia)
│                                               │
│  Confirmar contraseña                         │
│  ┌──────────────────────────────────────────┐ │
│  │ LOCK  ••••••••••••                        │ │   disabled · bg surfaceVariant
│  └──────────────────────────────────────────┘ │
│                                               │
│  [x] Acepto los Terminos y Condiciones        │   checkbox fijo (no interactivo)
│                                               │
│  ┌──────────────────────────────────────────┐ │
│  │    ◌  Creando acceso...                  │ │   PrimaryButton LOADING
│  └──────────────────────────────────────────┘ │   fondo #C5CECE · spinner 22 dp
│                                               │
└───────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Estado en carga | Detalle |
|---|---|---|---|
| 1 | AppBar | Inactivo | ARROW_BACK visualmente presente pero sin accion. El usuario no debe poder salir a mitad de la peticion. |
| 2 | Email de solo lectura | Sin cambio | Identico al estado reposo. |
| 3 | Campo "Nueva contraseña" | Disabled | Fondo `surfaceVariant` (#EDF1F1). Texto/iconos atenuados. `pointerEvents: none`. |
| 4 | PasswordStrengthMeter | Fijo | No se actualiza; muestra el ultimo estado. Atenuado. |
| 5 | Campo "Confirmar contraseña" | Disabled | Identico al campo anterior. |
| 6 | Checkbox T&C | Fijo | Visualmente marcado (como lo dejo el usuario) pero no interactivo. |
| 7 | Boton loading | Loading | Fondo `#C5CECE` (disabled visual). Spinner `CircularProgressIndicator` 22 dp color `#FFFFFF` a la izquierda. Texto "Creando acceso..." color `#FFFFFF`. No clickeable. |

## Interacciones y comportamiento
- **Entrada al estado:** al pulsar "Crear acceso" con validacion local OK; boton transiciona a
  loading en 150 ms (fade), inputs pasan a disabled simultaneamente.
- **Bloqueo de interaccion:** toda la pantalla queda no editable. El ARROW_BACK del AppBar
  esta visualmente presente (no desaparece) pero sin `onPressed` durante la carga para no
  interrumpir la peticion.
- **Back del sistema (Android):** ignorado durante la carga (se implementa con `PopScope`
  `canPop: false`).
- **Duracion esperada:** ~1-3 s. Si supera ~10 s se trata como timeout → banner de error
  en el formulario [02].
- **Salidas:**
  - 201 Created → `pushReplacement` a Exito [04], slide-up + fade 300 ms.
  - Error / timeout → vuelve al formulario [02] + `InlineErrorBanner` con mensaje
    "No pudimos crear tu acceso. Intentá de nuevo."

## Estados alternativos
Es el estado intermedio entre el formulario [02] y los resultados (Exito [04] / Error).
No tiene sub-estados propios.

## Navegacion (de donde viene / a donde va)
- **Entrada:** desde Formulario [02] al pulsar "Crear acceso" con validacion OK.
- **Salida:** Exito [04] (201) o Formulario [02] + banner de error (fallo).
