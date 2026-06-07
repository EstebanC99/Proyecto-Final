# US-04 Creacion de credenciales — Flujo de navegacion

> Mapa de navegacion del flujo de primera creacion de credenciales.
> Referencia los tokens de `00-sistema-diseno.md`.
> Ruta base sugerida en `go_router`: `/crear-credenciales?email=<email>` (recibe el email
> como query param desde el Login; nunca se puede navegar directamente sin ese param).

---

## 1. Vista general (happy path + ramas de error)

```
                 ┌─────────────────────────────────────────┐
  login detecta  │      DETECCION  [01]                     │
  Persona sin  ──►  Logo CareWell (icono 64 dp + wordmark)  │
  credenciales   │  Circulo primaryContainer + person_add   │
                 │  "Primera vez por aca"                    │
                 │  "Encontramos tu perfil... <email>"       │
                 │  [  Crear mi contraseña  ]  ─────────────┼──► [02]
                 │                                           │
                 │  No soy yo · Ir al inicio  ──────────────┼──► Login vacío (US-02 [01])
                 └───────────────────────────────────────────┘

                 ┌─────────────────────────────────────────┐
  tap "Crear   ──►     FORMULARIO  [02]                    │
  mi contraseña" │  AppBar con ARROW_BACK                   │
                 │  "Creá tu contraseña"                    │
                 │  email de solo lectura                   │
                 │                                          │
                 │  [LOCK] Nueva contraseña  [VISIBILITY]   │
                 │  PasswordStrengthMeter (3 segmentos)     │
                 │                                          │
                 │  [LOCK] Confirmar contraseña             │
                 │                                          │
                 │  [ ] Acepto los Terminos y Condiciones   │
                 │                                          │
                 │  [  Crear acceso  ]  ────────────────────┼──► [03] si T&C marcado + valida
                 └──────────────────────────────────────────┘
                          │
                          │ ARROW_BACK
                          ▼
                    DETECCION [01]

                 ┌──────────────────────────────────────────┐
  tap "Crear    ──►     CARGANDO  [03]                      │
  acceso" OK     │  Igual que [02] pero:                    │
                 │  - Campos disabled (bg surfaceVariant)   │
                 │  - Boton: spinner + "Creando acceso..."  │
                 └───┬───────────────┬──────────────────────┘
                     │ 201 OK        │ error servidor / red
                     ▼               ▼
              ┌──────────────┐  ┌───────────────────────────┐
              │  EXITO  [04] │  │  FORMULARIO [02]          │
              │              │  │  + InlineErrorBanner       │
              │  check_circle│  │  "No pudimos crear tu     │
              │  80dp verde  │  │   acceso. Intentá de nuevo"│
              │  "Ya tenés   │  └───────────────────────────┘
              │   acceso"    │
              │  [Ir al      │
              │   inicio de  │
              │   sesion]    │
              └──────┬───────┘
                     │ tap "Ir al inicio de sesion"
                     ▼
              Login (US-02 [01]) con email precargado
              (pushReplacement — no se puede volver a este flujo)
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| Login [cargando] (US-02 [06]) | Deteccion [01] | respuesta del server: Persona sin credenciales | `pushReplacement`, slide-up + fade 300 ms |
| Deteccion [01] | Formulario [02] | tap "Crear mi contraseña" | push, slide-left + fade 250 ms |
| Deteccion [01] | Login vacio (US-02 [01]) | tap "No soy yo · Ir al inicio" | `popUntil` login, fade 200 ms |
| Formulario [02] | Deteccion [01] | ARROW_BACK | pop, slide-right + fade 250 ms |
| Formulario [02] | Cargando [03] | tap "Crear acceso" (T&C marcado + valida OK) | boton → loading, inputs disable, fade 150 ms (sin cambio de ruta) |
| Cargando [03] | Exito [04] | 201 Created | `pushReplacement`, slide-up + fade 300 ms |
| Cargando [03] | Formulario [02] + banner error | error / timeout | boton vuelve de loading, banner fade + slide-down 150 ms |
| Exito [04] | Login (US-02 [01]) con email | tap "Ir al inicio de sesion" | `pushReplacement`, fade 250 ms |

---

## 3. Reglas de gobierno del flujo

- **Entrada exclusiva desde Login.** No existe una ruta directa a `/crear-credenciales` sin
  el query param `?email=`. Si falta, `go_router` redirige al Login. Esto garantiza que el
  email siempre sea conocido y validado por el servidor antes de mostrar este flujo.

- **Email inmutable en el formulario.** El backend ya confirmó que ese email corresponde a
  una Persona existente sin contraseña. Permitir editarlo aqui crearía inconsistencias.
  El usuario que quiera usar otro email debe salir con "No soy yo".

- **Validacion al pulsar "Crear acceso", no al blur.**
  - Campo vacio: error inline bajo el campo, no se envía.
  - Contraseñas no coinciden: error inline bajo "Confirmar contraseña".
  - T&C no marcado: el boton esta `disabled`; esta validacion es previa al tap.

- **Boton "Crear acceso" disabled si T&C no esta marcado.** Es la unica excepcion a la
  regla "boton primario siempre habilitado": aceptar los T&C es un requisito legal, no
  una validacion de datos. El estado `disabled` (fondo outline, texto atenuado) lo comunica
  con claridad.

- **Back del sistema (Android) en Deteccion [01]:** al ser el primer paso del flujo redirigido,
  el back no debe volver a "Login cargando". Se usa `pushReplacement` al navegar desde Login,
  por lo que el back desde Deteccion sale al Login vacio (comportamiento correcto).

- **El banner de error (servidor) se limpia al editar cualquier campo.** Si el servidor devuelve
  error y el usuario modifica la contraseña o confirmar, el banner desaparece on-change.

- **Pantalla de exito reemplaza el stack.** Se usa `pushReplacement` en dos momentos:
  1. Login → Deteccion (para que Back no vuelva al Login-cargando).
  2. Cargando → Exito (para que Back no vuelva al formulario una vez creadas las credenciales).
  Desde Exito, el unico camino es ir al Login.
