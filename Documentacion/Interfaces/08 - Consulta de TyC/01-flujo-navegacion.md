# US-08 Consulta de Términos y Condiciones — Flujo de navegación

> Mapa de navegación del flujo de consulta de T&C dentro del módulo Configuración.
> Ruta sugerida en `go_router`: `/settings/terms` (hija de `/settings`).

---

## 1. Vista general (happy path)

```
                    ┌──────────────────────────────────────┐
   Menú principal ──►       CONFIGURACIÓN  [01]             │
   (Home / US-04)  │   ── CUENTA ──────────────────────    │
                    │   [PERSON]  Mi Perfil            [›]  │
                    │   ── SEGURIDAD Y PRIVACIDAD ──────    │
                    │   [SECURITY]  Cambio contraseña  [›]  │
                    │   ── LEGAL ────────────────────────   │
                    │   [DESCRIPTION]  T&C          ●[›]   │  ← ítem activo (primaryContainer)
                    │   ── SESIÓN ───────────────────────   │
                    │   [LOGOUT]  Cerrar sesión        [›]  │
                    │   [DELETE]  Eliminar cuenta      [›]  │
                    └─────────────────┬────────────────────┘
                           tap "Términos y condiciones"
                                      ▼
                    ┌──────────────────────────────────────┐
                    │   TÉRMINOS Y CONDICIONES  [02]        │
                    │   AppBar: ← Términos y condiciones   │
                    │   ─────────────────────────────────  │
                    │   1. ACEPTACIÓN DE TÉRMINOS           │
                    │   Al registrarse y utilizar...        │
                    │   2. USO DEL SERVICIO                 │
                    │   CareWell es una herramienta...      │
                    │   [continúa...]                       │
                    │                                       │
                    │        Deslizá para leer mas         │
                    └─────────────────┬────────────────────┘
                              ARROW_BACK o back del sistema
                                      ▼
                    ┌──────────────────────────────────────┐
                    │       CONFIGURACIÓN  [01]             │
                    │   (ítem T&C ya sin resalte)           │
                    └──────────────────────────────────────┘
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Configuración [01] | T&C [02] | tap ítem "Términos y condiciones" | push, slide-up + fade 250 ms |
| T&C [02] | Configuración [01] | ARROW_BACK o gesto back | pop, slide-down + fade 250 ms |

---

## 3. Reglas de gobierno del flujo

- **El ítem se resalta al tocar.** Al hacer tap en "Términos y condiciones", el ítem
  toma fondo `primaryContainer` mientras se ejecuta la transición. Al volver, el resalte
  desaparece (el ítem vuelve a su estado neutro).

- **No hay acciones en la pantalla T&C.** No hay botón "Aceptar", "Guardar" ni similar.
  Es una pantalla de solo lectura. La única acción disponible es volver.

- **El back del sistema (Android) funciona igual que ARROW_BACK.** Hace `pop()` y
  regresa a Configuración.

- **Contenido estático.** Los T&C se leen de un archivo local (no hay petición de red),
  por lo que la pantalla [02] está disponible sin conexión. No se muestra estado de error
  de red.

- **Acceso desde Configuración, no desde el registro.** Este flujo solo se alcanza desde
  `/settings`. El contenido es idéntico al bottom sheet de T&C en US-01 Paso 2, pero la
  pantalla es diferente (standalone vs. modal).

- **Scroll:** el usuario puede leer todo el contenido haciendo scroll vertical. La AppBar
  queda fija. No hay paginación.
