# US-09 Cambio de contraseña — Flujo de navegación

> Mapa de navegación del flujo de cambio de contraseña dentro del módulo Configuración.
> Ruta sugerida en `go_router`: `/settings/change-password` (hija de `/settings`).

---

## 1. Vista general (happy path + ramas de error)

```
                    ┌──────────────────────────────────────┐
   Configuración ───►    CONFIGURACIÓN  [01]                │
                    │   [SECURITY]  Cambio contraseña ●[›]  │  ← ítem activo (primaryContainer)
                    └─────────────────┬────────────────────┘
                           tap "Cambio de contraseña"
                                      ▼
                    ┌──────────────────────────────────────┐
                    │   CAMBIAR CONTRASEÑA  [02]            │
                    │   "Nueva contraseña"                  │
                    │   "Tu nueva contraseña                │
                    │    reemplazará la actual."            │
                    │   [🔒 Contraseña actual        👁]    │
                    │   [🔒 Nueva contraseña         👁]    │
                    │   [|||  Fuerte                    ]   │  ← PasswordStrengthMeter
                    │   [🔒 Confirmar nueva contraseña ]    │
                    │   [     Guardar cambios           ]   │
                    └─────────────────┬────────────────────┘
                                      │ tap "Guardar cambios"
                                      ▼
                     ┌────────────────────────────────────┐
                     │   ¿Hay campos vacíos o invalidos?  │
                     └─────┬──────────────────────┬───────┘
                      si   │                      │  no
                           ▼                      ▼
              ┌──────────────────────┐   ┌──────────────────────────────┐
              │  ERROR LOCAL  [02b]   │   │  ENVIANDO...  [02c]           │
              │  error inline en el  │   │  Botón spinner + campos       │
              │  campo específico    │   │  deshabilitados               │
              └──────────┬───────────┘   └──────┬──────────┬────────────┘
                         │ corregir             │ 200      │ 401
                         └──► [02]             ▼          ▼
                                       ┌──────────┐  ┌───────────────────────┐
                                       │  ÉXITO   │  │  ERROR ACTUAL  [02b]   │
                                       │  [03]    │  │  "Contraseña actual    │
                                       │  check + │  │   incorrecta"          │
                                       │  mensaje │  │  borde error en campo  │
                                       └────┬─────┘  └──────────┬────────────┘
                                            │ CTA                │ corregir
                                            ▼                    └──► [02]
                                   go('/settings')
                                   [01] Configuración
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Configuración [01] | Cambiar contraseña [02] | tap ítem "Cambio de contraseña" | push, slide-up + fade 250 ms |
| Cambiar contraseña [02] | Enviando [02c] | "Guardar cambios" (validación local OK) | botón → loading, campos disable, fade 150 ms (sin cambio de ruta) |
| Enviando [02c] | Éxito [03] | respuesta 200 | push reemplazando [02], fade 300 ms |
| Enviando [02c] | Error local [02b] | respuesta 401 (contraseña actual incorrecta) | botón vuelve de loading, error inline slide-down 150 ms |
| Éxito [03] | Configuración [01] | tap "Volver a Configuración" | `go('/settings')`, fade 250 ms |
| Cambiar contraseña [02] | Configuración [01] | ARROW_BACK | pop, slide-down + fade 250 ms |

---

## 3. Reglas de gobierno del flujo

- **Validación en cascada al pulsar "Guardar cambios":**
  1. Campos vacíos: el primero vacío recibe foco y muestra error inline. No se envía nada.
  2. Nueva contraseña no cumple el mínimo de seguridad: error inline + medidor en "Débil".
  3. Confirmación no coincide con nueva contraseña: error inline en el campo de confirmación.
  4. Si pasa todo lo anterior, se envía la petición.

- **El error de contraseña actual incorrecta viene del servidor (401).** No se puede
  validar localmente. Se muestra inline en el campo "Contraseña actual" al recibir la
  respuesta.

- **Los errores inline se limpian al editar el campo.** El campo modificado abandona el
  estado de error `on-change`.

- **Back desde [02] no guarda cambios parciales.** El formulario se descarta al hacer pop.

- **La sesión permanece activa después del éxito.** `go('/settings')` navega sin re-login.

- **El botón "Guardar cambios" está siempre habilitado** (sin validación continua en
  tiempo real). La validación ocurre al pulsar.

- **Toggle de visibilidad independiente por campo.** Cada campo de contraseña tiene su
  propio ícono VISIBILITY; no se sincronizan entre sí.
