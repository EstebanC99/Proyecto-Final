# 06 · Login — sin conexión a internet (error de red)

> Estado tras fallo de red / timeout. Tokens en `00-sistema-diseno.md`.
> HTML: `html/05-login-sin-conexion.html`.

## Propósito
Informar que no hay conexión a Internet (mandatoria para iniciar sesión) y ofrecer una acción
clara para reintentar, **sin culpar a las credenciales** del usuario.

## Contexto
El criterio de aceptación indica que el acceso a Internet es mandatorio: "si no hay conexión, se
informa al usuario." Se distingue deliberadamente del error 401:
- Usa el container `info` (#DBE9FB) con ícono `wifi_off`, **no** el color `error`. Un banner rojo
  haría pensar al usuario que sus datos están mal, cuando el problema es la red.
- Incluye una acción **"Reintentar"** que reenvía la última petición.
- Los datos del formulario se conservan.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐
│ 9:41                                  5G 100% │
│                  ╭────────╮                    │
│                  │  ◐ ●   │   CareWell         │
│                  ╰────────╯                    │
│                                                │
│   ┌────────────────────────────────────────┐  │   banner info (no error)
│   │ ⊘  Sin conexión a Internet.            │  │   fondo infoContainer #DBE9FB
│   │    Revisá tu red e intentá de nuevo.    │  │   ícono wifi_off + texto info
│   │                            [ Reintentar ]│  │   acción a la derecha/debajo
│   └────────────────────────────────────────┘  │
│                                                │
│   Email                                        │
│   ┌────────────────────────────────────────┐  │   valor conservado, sin error
│   │ ✉  maria.gomez@gmail.com               │  │
│   └────────────────────────────────────────┘  │
│                                                │
│   Contraseña                                   │
│   ┌────────────────────────────────────────┐  │   valor conservado, sin error
│   │ 🔒  ••••••••••                      👁  │  │
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
| 1 | Banner de red | Fondo `infoContainer` (#DBE9FB), radio `radiusMd (12)`, padding 12–16 dp, borde sutil `info`. Ícono `wifi_off` 20 dp `info` (#2E77C2) + texto `bodyMedium`/`info`: "Sin conexión a Internet. Revisá tu red e intentá de nuevo." |
| 2 | Acción "Reintentar" | `SecondaryTextButton` `info`/`primary` dentro del banner (a la derecha o en segunda línea). Reenvía la última petición de login. |
| 3 | Campos | Conservan los valores. Sin marca de error (el problema no son ellos). |
| 4 | Botón "Ingresar" | También permite reintentar (equivalente a "Reintentar"). |

## Interacciones y comportamiento
- **Aparición:** cuando la petición de login falla por red/timeout (antes de obtener respuesta del
  servidor). El botón sale de `loading`, inputs se rehabilitan, banner aparece (fade + slide-down),
  foco al banner.
- **"Reintentar":** reenvía la petición → vuelve a carga [07]. Si vuelve a fallar, el banner persiste.
- **Detección de reconexión (opcional):** si la app detecta que la red volvió, puede atenuar/quitar
  el banner automáticamente y habilitar "Reintentar" como acción primaria.
- **Limpieza:** el banner no se limpia al editar campos (el problema es la red, no los datos);
  se quita al reintentar con éxito o al detectarse conexión.

## Estados alternativos (si aplica)
- Reintento con red → carga [07] → éxito / 401 [05].
- Si tras reconectar las credenciales fallan → 401 [05].

## Navegación (de dónde viene / a dónde va)
- **Entrada:** desde carga [07] ante fallo de red. También puede mostrarse de entrada si la app
  detecta ausencia de red antes de enviar.
- **Salida:** "Reintentar" / "Ingresar" → carga [07].
