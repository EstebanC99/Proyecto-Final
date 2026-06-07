# US-06 Visualización del perfil — Flujo de navegación

> Mapa de navegación del flujo de visualización de perfil. Referencia los tokens de
> `00-sistema-diseno.md`. Ruta sugerida en `go_router`: `/profile` (parte del shell
> principal, accesible desde el menú lateral o bottom navigation).

---

## 1. Vista general

```
  Menú principal (US-04)
  o bottom nav / drawer
          │
          │ tap "Mi Perfil"
          ▼
  ┌───────────────────────────────────────┐
  │       MI PERFIL — CON DATOS  [01]     │
  │  AppBar: ← Mi Perfil                  │
  │  ┌─────────────────────────────────┐  │
  │  │   Avatar (M) · María García     │  │
  │  │   [Responsable]                 │  │
  │  └─────────────────────────────────┘  │
  │  ✉ Email       maria.garcia@...        │
  │  ─────────────────────────────────    │
  │  ☎ Teléfono   +54 9 11 1234-5678      │
  │  ─────────────────────────────────    │
  │  ID DNI        12.345.678              │
  │  ─────────────────────────────────    │
  │  👤 Rol        Responsable             │
  └───────────────────────────────────────┘
          │
          │ tap ARROW_BACK o gesto de back
          ▼
  Menú principal (US-04)

          │  (acceso alternativo desde dentro de esta pantalla)
          │  → si existe un FAB o botón de edición en la AppBar
          ▼
  US-07 Edición del perfil
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Menú principal / nav shell | Mi Perfil [01] | tap ítem de navegación | slide-up + fade 250 ms (transición de shell) |
| Mi Perfil [01] | Menú / pantalla anterior | tap ARROW_BACK o gesto de back | slide-down + fade 250 ms |
| Mi Perfil [01] | US-07 Edición | tap botón editar (si disponible en AppBar) | push slide-right + fade 250 ms |
| US-07 Edición | Mi Perfil [01] | guardado exitoso o cancelación | pop con datos actualizados (si hubo cambio) |

---

## 3. Reglas de gobierno del flujo

- **Solo lectura estricta.** Ningún elemento de la pantalla dispara edición. Esta pantalla
  existe para consulta rápida: el usuario la abre, lee sus datos y sale. La edición requiere
  navegar a US-07.

- **Back de sistema (Android).** Comportamiento estándar: vuelve a la pantalla anterior en
  el stack (menú principal o el punto de entrada al perfil).

- **Carga de datos.** Al entrar a la pantalla, se dispara el fetch del perfil. Si los datos
  están en caché (Riverpod StateNotifier), se muestran inmediatamente; el refresh se hace en
  segundo plano. Si no hay caché, se muestra el estado de carga (skeleton).

- **Actualización post-edición.** Al regresar de US-07 con un cambio confirmado, la pantalla
  refleja los nuevos valores sin necesidad de un fetch adicional (el provider de perfil ya
  tiene el estado actualizado).

- **Acceso desde US-07.** El botón de acción de edición (si se ubica en la AppBar de Mi Perfil)
  lleva a US-07 como push. Al volver (pop), el estado del perfil se recupera del provider
  actualizado.

---

## 4. Puntos de entrada y salida

| Punto | Tipo | Descripción |
|---|---|---|
| Menú principal (US-04) | Entrada | Ítem "Mi Perfil" en bottom nav o drawer |
| Configuración (settings) | Entrada alternativa | Acceso desde sección "Cuenta" en settings |
| US-07 Edición | Salida | Botón editar en AppBar (si presente) |
| Menú principal | Salida | Back navigation |
