# US-02 Inicio de sesión — Flujo de navegación

> Mapa de navegación del flujo de login. Referencia los tokens de
> `00-sistema-diseno.md` (que a su vez hereda `01 - Registro de usuario/00-identidad-visual.md`).
> Ruta base sugerida en `go_router`: `/login` (pantalla raíz tras splash / logout).

---

## 1. Vista general (happy path + ramas de error)

```
                    ┌──────────────────────────────────┐
   arranque app ───►│        LOGIN — VACÍO  [01]        │
   o logout         │  Logo CareWell (prominente)       │
                    │  Email   [          ]             │
                    │  Pass    [          ]  👁          │
                    │  ¿Olvidaste tu contraseña? ───────┼──► US-03 (recuperar)
                    │  [        Ingresar        ]        │
                    │  ─────────────────────────────    │
                    │  ¿No tenés cuenta? Crear cuenta ──┼──► US-01 (registro)
                    └───────────────┬──────────────────┘
                       usuario escribe email + contraseña
                                    ▼
                    ┌──────────────────────────────────┐
                    │       LOGIN — CON DATOS  [02]     │
                    │  Email y contraseña completados   │
                    └───────────────┬──────────────────┘
                                    │ tap "Ingresar"
                                    ▼
                         ┌──────────────────────┐
                         │  ¿Algún campo vacío?  │
                         └───┬──────────────┬────┘
                       sí    │              │  no
                             ▼              ▼
              ┌────────────────────┐   ┌──────────────────────────────┐
              │ CAMPO VACÍO  [03]  │   │     LOGIN — CARGANDO  [06]    │
              │ error inline en el │   │ Botón spinner + inputs        │
              │ campo específico   │   │ deshabilitados                │
              │ (no se envía nada) │   │ "Verificando…"                │
              └─────────┬──────────┘   └───┬──────────┬──────────┬─────┘
                        │ corregir         │ 200      │ 401      │ sin red
                        └──► [02]          ▼          ▼          ▼
                                   ┌──────────┐ ┌──────────┐ ┌──────────────┐
                                   │  HOME /  │ │ CREDEN-  │ │ SIN CONEXIÓN │
                                   │  MENÚ    │ │ CIALES   │ │   [05]       │
                                   │ PRINCIPAL│ │ INCORR.  │ │ banner info  │
                                   │ (US-04)  │ │  [04]    │ │ + Reintentar │
                                   └──────────┘ │ banner   │ └──────┬───────┘
                                                │ error    │        │ Reintentar
                                                └────┬─────┘        └──► [06]
                                                     │ corregir y reintentar
                                                     └──► [06]
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Splash / logout | Login vacío [01] | arranque de la app | fade-in 250 ms |
| Login [01] | Login con datos [02] | usuario escribe | sin transición (mismo estado) |
| Login [02] | Cargando [06] | "Ingresar" (validación local OK) | botón→loading, inputs disable, fade 150 ms (no cambia de ruta) |
| Login [02] | Campo vacío [03] | "Ingresar" con campo vacío | error inline fade + slide-down 4 dp, 150 ms (no envía) |
| Campo vacío [03] | Login con datos [02] | usuario completa el campo | error se limpia on-change |
| Cargando [06] | Home / Menú (US-04) | respuesta 200 | `pushReplacement`, fade 250 ms |
| Cargando [06] | Credenciales incorrectas [04] | respuesta 401 | botón vuelve de loading, banner error fade + slide-down |
| Cargando [06] | Sin conexión [05] | fallo de red / timeout | botón vuelve de loading, banner info fade + slide-down |
| Credenciales [04] | Cargando [06] | corregir + "Ingresar" | igual que [02]→[06] |
| Sin conexión [05] | Cargando [06] | tap "Reintentar" | reenvía la última petición |
| Login (cualquiera) | US-03 recuperar | tap "¿Olvidaste tu contraseña?" | push, slide-right + fade 250 ms |
| Login (cualquiera) | US-01 registro | tap "Crear cuenta" | push, slide-right + fade 250 ms |

---

## 3. Reglas de gobierno del flujo

- **Botón "Ingresar" siempre habilitado.** La validación local (campos vacíos) se dispara al
  pulsarlo. Si hay campos vacíos, hace foco/scroll al primer campo inválido y **no** envía la
  petición. (Heredado: misma filosofía "habilitado + validación al submit" que US-01, pero acá
  sin validación al blur.)

- **Dos tipos de error, mutuamente excluyentes en su presentación:**
  - *Local (campo vacío):* error inline en el campo → estado [03]. Nunca llega al servidor.
  - *Servidor (401):* banner superior `InlineErrorBanner` → estado [04]. **No marca campos**
    (seguridad: no revela si el email existe).

- **Sin conexión es prioritario sobre el 401.** Si no hay red, ni siquiera se intenta validar
  credenciales; se muestra el banner `info` [05] con "Reintentar". El acceso a Internet es
  mandatorio (criterio de aceptación).

- **El banner de error se limpia al editar.** Al modificar email o contraseña tras un 401, el
  banner [04] desaparece on-change; así el reintento parte limpio.

- **Back del sistema (Android) en Login:** al ser la pantalla raíz, el back sale de la app
  (comportamiento estándar). No hay navegación hacia atrás dentro del login.

- **Persistencia:** al volver de US-03 (recuperar) o de US-01 (registro), el email puede venir
  precargado en el campo (mejor continuidad para el usuario).
