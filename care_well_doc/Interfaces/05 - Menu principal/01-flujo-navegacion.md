# US-05 Menú principal — Flujo de navegación

> Mapa de navegación del Home. Referencia los tokens de `00-sistema-diseno.md`.
> Ruta base en `go_router`: `/home` (raíz del `ShellRoute` post-login).
> No tiene botón de retorno; es la pantalla raíz de la sesión autenticada.

---

## 1. Vista general — accesos desde el Home

```
                    ┌───────────────────────────────────────────────┐
  login exitoso ───►│              HOME / MENÚ PRINCIPAL            │
  (US-02)          │  Header: logo + avatar "Hola, María ▾"         │
                    │  Fila accesos rápidos: [Mi Perfil] [Config]   │
                    │                                                │
                    │  ┌──────────────┐  ┌──────────────┐          │
                    │  │ Mi calendario│  │   Mi equipo  │          │
                    │  └──────────────┘  └──────────────┘          │
                    │  ┌──────────────┐  ┌──────────────┐          │
                    │  │ Personas     │  │   Mi salud   │          │
                    │  │  a cargo     │  │              │          │
                    │  └──────────────┘  └──────────────┘          │
                    │  ┌──────────────────────────────────┐        │
                    │  │           EMERGENCIA             │        │
                    │  └──────────────────────────────────┘        │
                    └───────────────────────────────────────────────┘
                         │         │          │          │
                         ▼         ▼          ▼          ▼
                    US-06        US-07      US-08       US-09
                  Mi Perfil   Configuración  (ver §2)   Emergencia
```

---

## 2. Tabla de accesos y rutas

| Acceso | Tipo | Ruta go_router | US destino |
|---|---|---|---|
| Avatar + "Hola, María ▾" | Header tappable | `/profile` | US-06 Mi Perfil |
| Botón "Mi Perfil" (fila rápida) | QuickAccessRow | `/profile` | US-06 Mi Perfil |
| Botón "Configuración" (fila rápida) | QuickAccessRow | `/settings` | US-07 Configuración |
| Tile "Mi calendario" | NavTile | `/agenda` | US-10 Agenda |
| Tile "Mi equipo" | NavTile | `/care-team` | US-11 Mi equipo |
| Tile "Personas a cargo" | NavTile | `/dependents` | US-12 Personas a cargo |
| Tile "Mi salud" | NavTile | `/health` | US-13 Mi salud |
| Tile "Emergencia" | EmergencyTile | `/emergency` | US-09 Emergencia |
| Tile "Personas a cargo" (estado vacío, tap `+`) | EmptyStateTile | `/dependents/new` | US-12 ABM nuevo |

---

## 3. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Login (US-02) | Home | respuesta 200 | `pushReplacement`, fade 250 ms |
| Home | Cualquier sección (tiles, fila rápida) | tap | `push`, slide-up + fade 250 ms |
| Home | Mi Perfil (header) | tap avatar / saludo | `push`, slide-right + fade 250 ms |
| Sección secundaria | Home | botón Atrás o back del sistema | `pop`, slide-down + fade 200 ms |
| Home | Emergencia | tap tile coral | `push`, slide-up acelerada 180 ms |

---

## 4. Reglas de gobierno del flujo

- **Pantalla raíz de la sesión.** El Home es la base del stack de navegación autenticado.
  El back del sistema (Android) en el Home muestra un diálogo de confirmación de salida de la app
  o minimiza a segundo plano (decisión de `dev-flutter` según convención de la plataforma).

- **Sin botón de retorno propio.** El `AppBar` del Home no muestra flecha de regreso.
  El título puede mostrar el nombre de la app o estar ausente (el header ya cumple esa función).

- **Retorno desde secciones secundarias.** Al volver de cualquier sección al Home, la pantalla
  vuelve a su estado previo (sin recarga). El tile de "Personas a cargo" actualiza su estado vacío
  si el usuario acaba de agregar su primera persona (via `Riverpod` con `ref.invalidate`).

- **Tile de emergencia no bloqueado.** No requiere haber cargado personas a cargo ni equipo para
  estar activo. Siempre navega a US-09.

- **Estado de carga del Home.** Si los datos del usuario aún no llegaron (primera carga post-login),
  los tiles del grid muestran un skeleton loader (ver `02-menu-principal.md` §Estado carga). El tile
  de emergencia y la fila de accesos rápidos se muestran inmediatamente (no dependen de datos remotos).

- **Sesión expirada.** Si el backend devuelve 401 desde cualquier sección secundaria, se navega a
  Login con `pushReplacement` (stack limpio). No ocurre dentro del Home mismo (la sesión fue
  validada al entrar).
