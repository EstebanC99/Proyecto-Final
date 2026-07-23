# US-03 Recuperación de contraseña — Flujo de navegación

> **v2 (OTP).** Mapa de navegación del flujo de recuperación. Referencia los tokens de
> `00-sistema-diseno.md` (que a su vez hereda `01 - Registro de usuario/00-identidad-visual.md`).
> Rutas en `go_router`: `/auth/recover-password` → `/auth/reset-password` → `/auth/reset-password/success`.

---

## 1. Vista general (happy path + ramas de error)

```
                                          ┌──────────────────────────────────────┐
                        tap               │  02 · SOLICITAR CÓDIGO                │
   Login ─────────────────────────────►  │  AppBar + ARROW_BACK                 │
   "¿Olvidaste tu contraseña?"           │  StepProgressBar · Paso 1 de 2       │
   go_router push /auth/recover-password │  Email [ ________________________ ]  │
                                          │  [        Enviar código           ]  │
                                          │      Volver al inicio de sesión      │
                                          └──────────────┬───────────────────────┘
                                                         │ tap "Enviar código"
                                          ┌──────────────▼───────────────────────┐
                                          │       ¿Respuesta del backend?         │
                                          └───┬──────────────┬───────────────┬────┘
                                     200 (con  │   400 cuenta  │  400 límite / │
                                  o sin cuenta)│   no activa   │  sin conexión │
                                              ▼               ▼               ▼
                        ┌──────────────────────────┐  ┌──────────────┐  ┌──────────────┐
                        │ 03 · CONFIRMAR CÓDIGO    │  │ banner        │  │ banner        │
                        │ AppBar + ARROW_BACK      │  │ warning +     │  │ error (mismo  │
                        │ StepProgressBar 2 de 2   │  │ "Verificar mi │  │ mensaje del   │
                        │ Código [ ______ ]        │  │  email" ──►   │  │ backend)      │
                        │ (cooldown reenvío activo)│  │ VerifyEmail-  │  │ queda en [02] │
                        │ Nueva contraseña         │  │ Screen        │  │               │
                        │ [ ______________ ] 👁     │  └──────────────┘  └──────────────┘
                        │ PasswordStrengthMeter    │
                        │ Confirmar [ __________ ] │
                        │ [   Restablecer contr.  ]│
                        │  ¿No lo recibiste?       │
                        │  Reenviar código (60s)   │
                        └──────────────┬────────────┘
                                       │ tap "Restablecer contraseña"
                          ┌────────────▼─────────────┐
                          │   ¿Código y datos OK?     │
                          └───┬──────────────────┬────┘
                        sí    │                  │ no
                              ▼                  ▼
              ┌──────────────────────┐   error en el campo correspondiente
              │ 06 · CAMBIO EXITOSO  │   (código inválido/vencido/agotado,
              │ SuccessView          │   o banner general) — permanece en [03]
              │ "¡Contraseña         │
              │  actualizada!"       │
              │ [Ir al inicio de     │
              │  sesión]             │
              └──────────┬────────────┘
                         │ tap botón / back del sistema
                         ▼ goNamed → /auth/login
                     LOGIN
```

---

## 2. Tabla de transiciones

| Origen | Destino | Disparador | Mecanismo |
|---|---|---|---|
| Login | `02-solicitar-email` | tap "¿Olvidaste tu contraseña?" | `pushNamed(recoverPasswordName)` |
| `02-solicitar-email` | `03-confirmar-codigo` | servidor confirma envío (200, revela o no exista la cuenta) | `pushNamed(resetPasswordName, extra: email)` |
| `02-solicitar-email` | (misma pantalla) | servidor: cuenta no habilitada (400) | banner `warning` + acción "Verificar mi email" |
| `02-solicitar-email` | `VerifyEmailScreen` (US-01) | tap "Verificar mi email" en el banner | `pushNamed(verifyEmailName, extra: email)` |
| `02-solicitar-email` | (misma pantalla) | servidor: límite de envíos / sin conexión | banner `error` con el mensaje del backend |
| ARROW_BACK / "Volver al inicio de sesión" [02] | Login | tap | `context.pop()` |
| `03-confirmar-codigo` | `06-cambio-exitoso` | servidor confirma el cambio (200) | `goNamed(resetPasswordSuccessName)` |
| `03-confirmar-codigo` | (misma pantalla) | código inválido/vencido/agotado | error en el campo "Código de verificación" |
| `03-confirmar-codigo` | (misma pantalla) | tap "Reenviar código" (cooldown vencido) | reenvía `solicitar-reset-contrasena`; reinicia cooldown 60 s |
| ARROW_BACK [03] | `02-solicitar-email` | tap | `context.pop()` (vuelve con el email ya cargado) |
| `06-cambio-exitoso` | Login | tap "Ir al inicio de sesión" o back del sistema | `goNamed(loginName)` |

---

## 3. Reglas de gobierno del flujo

- **El botón "Enviar código" valida formato de email antes de llamar al servidor.** Si el campo
  está vacío o el email tiene formato incorrecto, el error es inline en el campo (nunca llega al
  servidor).

- **No se revela si el email existe, salvo el caso de cuenta no activa.** Si el email no está
  registrado, el backend responde 200 igual y la app avanza a `03-confirmar-codigo` como si el
  código se hubiera enviado (el usuario simplemente no va a recibir nada y, si vuelve a intentar
  con el código equivocado, va a ver el error de "código inválido" genérico — no se distingue de
  un código realmente vencido). La única excepción deliberada es la cuenta existente pero no
  activa (ver `00-sistema-diseno.md` §4.1): ahí sí se informa explícitamente, por decisión de
  producto.

- **El código es de un solo uso y expira a los 10 minutos.** Se muestra como `helperText` en el
  campo de código en `03-confirmar-codigo`.

- **Reenviar código y "cuenta no activa" comparten el límite de envíos por hora (5) con la
  verificación de email del registro.** Ver nota para `dev-flutter` en `00-sistema-diseno.md` §4.3.

- **`goNamed` (no `push`) al llegar a `06-cambio-exitoso`.** Reemplaza el stack de navegación para
  que el back del sistema no vuelva al formulario de `03-confirmar-codigo` (el código ya fue
  consumido por el backend; no tiene sentido poder reintentar).

- **Acceso directo a `/auth/reset-password` sin `extra` (email) redirige a `/auth/recover-password`.**
  Guarda de router equivalente a la que ya usa `VerifyEmailScreen`, pero apuntando al paso 1 de
  este flujo en particular (no a Login), porque el paso lógico anterior es "pedir el email", no
  "iniciar sesión".

- **Flujo compartido con US-09 solo en la pantalla de éxito.** A diferencia del v1 (que compartía
  también la pantalla de "nueva contraseña"), en esta versión `03-confirmar-codigo` es exclusiva
  de US-03 (incluye el campo de código, que US-09 no necesita porque el usuario ya está
  autenticado). Solo `06-cambio-exitoso` (`SuccessView`) se comparte entre ambos flujos.
