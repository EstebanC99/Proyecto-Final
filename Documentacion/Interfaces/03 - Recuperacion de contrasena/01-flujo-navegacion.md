# US-03 Recuperación de contraseña — Flujo de navegación

> Mapa de navegación del flujo de recuperación. Referencia los tokens de
> `00-sistema-diseno.md` (que a su vez hereda `01 - Registro de usuario/00-identidad-visual.md`).
> Ruta base en `go_router`: `/recover` (push desde `/login`).

---

## 1. Vista general (happy path + ramas de error)

```
                                          ┌──────────────────────────────────────┐
                        tap               │     SOLICITAR EMAIL  [01]            │
   Login ─────────────────────────────►  │  AppBar + ARROW_BACK                 │
   "¿Olvidaste tu contraseña?"           │  Título: "Recuperar contraseña"      │
   go_router push /recover               │  Email [ ________________________ ]  │
                                          │  [      Enviar link               ]  │
                                          │      Volver al inicio de sesión      │
                                          └──────────────┬───────────────────────┘
                                                         │ tap "Enviar link"
                                          ┌──────────────▼───────────────────────┐
                                          │    ¿Email registrado en el sistema?   │
                                          └──────┬──────────────────────┬─────────┘
                                            sí   │                      │  no
                                                 ▼                      ▼
                              ┌──────────────────────────┐  ┌────────────────────────────────┐
                              │   EMAIL ENVIADO  [02]    │  │  ERROR EMAIL NO REG.  [04]     │
                              │ Ícono MARK_EMAIL_READ    │  │  Banner error + campo con      │
                              │ "Revisá tu email"        │  │  valor no registrado           │
                              │ email en negrita         │  │  "No encontramos una cuenta…"  │
                              │ [Volver al inicio sesión]│  └──────────────┬────────────────┘
                              │  ¿No recibiste? Reenviar │                 │ usuario corrige
                              └───────────┬──────────────┘                 └──► [01]
                                          │ tap "Reenviar"
                                          └──► reenvía (mismo estado [02])

   ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ CORTE: el usuario va al email ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─

   deep link desde email ──────────────►  ┌──────────────────────────────────────┐
   (ruta: /recover/reset?token=...)        │   NUEVA CONTRASEÑA  [03]            │
                                           │  Logo CareWell 64 dp                 │
                                           │  "Nueva contraseña"                  │
                                           │  Nueva pass [ ______________ ] 👁   │
                                           │  PasswordStrengthMeter (2/3 media)  │
                                           │  Confirmar  [ ______________ ] 👁   │
                                           │  [     Guardar contraseña       ]   │
                                           └──────────────┬───────────────────────┘
                                                          │ tap "Guardar contraseña"
                                                          │ servidor confirma
                                                          ▼
                                           ┌──────────────────────────────────────┐
                                           │   CAMBIO EXITOSO  [05]               │
                                           │  Logo CareWell 64 dp                 │
                                           │  CHECK_CIRCLE 80dp (successContainer)│
                                           │  "¡Contraseña actualizada!"          │
                                           │  [   Ir al inicio de sesión      ]   │
                                           └──────────────┬───────────────────────┘
                                                          │ tap botón
                                                          ▼ pushReplacement → /login
                                                      LOGIN [01]
```

---

## 2. Tabla de transiciones

| Origen | Destino | Disparador | Animación / Mecanismo |
|---|---|---|---|
| Login | Solicitar email [01] | tap "¿Olvidaste tu contraseña?" | `push`, slide-right + fade 250 ms |
| Solicitar email [01] | Email enviado [02] | servidor confirma envío (200) | `push /recover/sent`, slide-right + fade 250 ms |
| Solicitar email [01] | Error email no reg. [04] | servidor responde email no encontrado | banner fade + slide-down 150 ms (misma ruta, estado de la pantalla) |
| Email enviado [02] | Login | tap "Volver al inicio de sesión" | `pop` hasta `/login`, slide-left + fade 250 ms |
| Email enviado [02] | Email enviado [02] | tap "¿No recibiste? Reenviar" | reenvía petición; feedback "Reenviando…" 1 s (mismo estado) |
| ARROW_BACK (AppBar) [01] | Login | tap flecha | `pop`, slide-left + fade 250 ms |
| ARROW_BACK (AppBar) [02] | Solicitar email [01] | tap flecha | `pop`, slide-left + fade 250 ms |
| Deep link email | Nueva contraseña [03] | apertura del link externo | app abre directamente en `/recover/reset?token=…` |
| Nueva contraseña [03] | Cambio exitoso [05] | servidor confirma cambio (200) | `pushReplacement /recover/success`, fade 250 ms |
| Cambio exitoso [05] | Login | tap "Ir al inicio de sesión" | `pushReplacement /login`, limpia stack de recuperación |

---

## 3. Reglas de gobierno del flujo

- **El botón "Enviar link" valida formato de email antes de llamar al servidor.** Si el campo
  está vacío o el email tiene formato incorrecto, el error es inline en el campo (nunca llega
  al servidor). Si el formato es correcto pero el email no existe, el error es un banner de pantalla.

- **No se revela si el email existe.** El banner de error [04] usa el mensaje
  "No encontramos una cuenta con ese email" sin distinguir entre "email incorrecto" y
  "email no registrado". Decisión de seguridad equivalente a la de US-02.

- **El link de email es de uso único.** Una vez que el usuario establece la nueva contraseña
  en [03], el token se invalida en el servidor. Si intenta usar el mismo link nuevamente,
  la app muestra un error genérico (fuera del alcance de este mockup).

- **No hay navegación interna entre [03] y [04] por back.** La pantalla [03] se abre desde un
  deep link externo; el back del sistema en Android cierra la app o vuelve al estado previo del
  sistema, no hay pantalla anterior dentro del flujo.

- **Flujo compartido con US-09.** Las pantallas [03] y [05] son las mismas que usa el flujo
  de cambio de contraseña desde Configuración. La diferencia es el contexto de navegación
  (ver `00-sistema-diseno.md` §2).
