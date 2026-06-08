# US-01 Registro de usuario — Flujo de navegación

> Mapa de navegación del flujo de registro. Referencia los tokens de `00-identidad-visual.md`.
> Ruta base sugerida en `go_router`: `/register` con sub-rutas/estado interno por paso.

---

## 1. Vista general (happy path + ramas)

```
                         ┌─────────────────────────┐
                         │   PANTALLA DE ENTRADA    │
                         │   (Login)  [02]          │
                         │                          │
                         │  "¿Aún no tenés cuenta?  │
                         │      Crear cuenta" ──────┼──┐
                         └─────────────────────────┘  │ tap "Crear cuenta"
                                                       ▼
                         ┌─────────────────────────────────────┐
                         │  REGISTRO · PASO 1  [03]             │
                         │  Datos personales                   │
                         │  Progreso: ▰▰▰▰▱▱▱▱  (Paso 1 de 2)  │
                         │                                     │
                         │  nombre · apellido · email · tel.   │
                         │                                     │
                         │  [ Continuar ]   (valida al blur)   │◄──────┐
                         └───────────┬─────────────────────────┘       │
                          back (←)   │ Continuar (todo válido)          │ back (←)
                          al Login   │                                  │ desde Paso 2
                                     ▼                                  │
                         ┌─────────────────────────────────────┐       │
                         │  REGISTRO · PASO 1 — ERROR  [04]     │       │
                         │  (mismo paso, campo inválido en blur)│       │
                         │  Botón "Continuar" bloquea avance    │       │
                         │  hasta corregir.                     │       │
                         └───────────┬─────────────────────────┘       │
                                     │ (al corregir → vuelve a [03])    │
                                     ▼                                  │
                         ┌─────────────────────────────────────┐       │
                         │  REGISTRO · PASO 2  [05]             │───────┘
                         │  Credenciales                        │
                         │  Progreso: ▰▰▰▰▰▰▰▰  (Paso 2 de 2)  │
                         │                                     │
                         │  contraseña (+fortaleza [06])        │
                         │  confirmar contraseña                │
                         │  [✓] Acepto los T&C ──┐              │
                         │                       │ tap enlace   │
                         │  [ Crear cuenta ]     ▼              │
                         └───────┬───────────────┴──────────────┘
                                 │            ┌──────────────────────┐
                                 │            │ BOTTOM SHEET T&C [07] │
                                 │            │ (overlay sobre Paso 2)│
                                 │            │ [Cerrar] / [Aceptar]  │
                                 │            └──────────┬───────────┘
                                 │                       │ cierra → vuelve a [05]
                                 │ tap "Crear cuenta"
                                 │ (todo válido + T&C ✓)
                                 ▼
                         ┌─────────────────────────────────────┐
                         │  ESTADO DE CARGA  [08]               │
                         │  Overlay con spinner sobre Paso 2    │
                         │  "Creando tu cuenta…"                │
                         └───────┬───────────────────┬─────────┘
                                 │                   │
                    éxito (201)  │                   │ error: email ya existe (409)
                                 ▼                   ▼
              ┌────────────────────────┐   ┌────────────────────────────────┐
              │  PANTALLA DE ÉXITO [09]│   │  ERROR: EMAIL YA REGISTRADO [10]│
              │  ✓ "¡Cuenta creada!"   │   │  Banner bajo campo email +      │
              │  [ Ir al login ]       │   │  banner superior con acción     │
              └───────────┬────────────┘   │  "Iniciar sesión"               │
                          │                 └───────────┬─────────────────────┘
        tap "Ir al login" │                    tap "Iniciar sesión"
                          ▼                             ▼
                  ┌───────────────────────────────────────────┐
                  │            PANTALLA DE ENTRADA (Login)      │
                  │  (campo email pre-poblado cuando aplique)   │
                  └───────────────────────────────────────────┘
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Login | Paso 1 | tap "Crear cuenta" | push, slide-right + fade 250 ms |
| Paso 1 | Paso 2 | "Continuar" (válido) | slide horizontal (entra desde derecha) 250 ms |
| Paso 2 | Paso 1 | back (←) | slide horizontal (entra desde izquierda) 250 ms |
| Paso 1 | Login | back (←) | pop estándar |
| Paso 2 | Bottom Sheet T&C | tap enlace "T&C" | modal slide-up M3 |
| Bottom Sheet | Paso 2 | "Cerrar"/"Aceptar"/scrim/swipe-down | dismiss slide-down |
| Paso 2 | Carga | "Crear cuenta" (válido) | overlay fade-in 150 ms (no cambia de ruta) |
| Carga | Éxito | respuesta 201 | reemplaza ruta, fade 250 ms |
| Carga | Paso 2 + Error email | respuesta 409 | overlay fade-out + foco a banner |
| Éxito | Login | tap "Ir al login" | pushReplacement, fade |
| Error email | Login | tap "Iniciar sesión" | push, lleva email a Login |

---

## 3. Reglas de gobierno del flujo

- **Validación field-by-field al perder foco (blur).** El botón de avance ("Continuar" /
  "Crear cuenta") está **habilitado siempre** visualmente, pero al pulsarlo dispara una
  validación global del paso; si hay errores, hace foco/scroll al primer campo inválido y no
  avanza. (Alternativa de diseño documentada en cada pantalla: deshabilitar hasta validez. Se
  elige "habilitado + validación al submit" para no dejar al usuario sin feedback de por qué no
  puede avanzar.)
- **Persistencia entre pasos:** al volver de Paso 2 a Paso 1, los datos del Paso 1 se conservan.
  Al volver de Paso 1 a Login, se descartan (con confirmación si hay datos cargados — ver [03]).
- **T&C obligatorio:** el botón "Crear cuenta" del Paso 2 solo procede si el checkbox está
  marcado; si no, al pulsar muestra error inline en el checkbox.
- **Back del sistema (Android):** respeta la misma jerarquía que el botón "atrás" del app bar.
- **El email "ya registrado" es un error de servidor (409)**, no de validación local; por eso se
  resuelve en Paso 2 al hacer submit (no en Paso 1), ver [10].
