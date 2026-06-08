# 05 · Creacion de credenciales — Exito

> Pantalla de confirmacion tras crear las credenciales exitosamente. Sin AppBar.
> Tokens en `00-sistema-diseno.md`. HTML: `html/04-exito.html`.

## Proposito
Confirmar de forma clara y positiva que las credenciales fueron creadas, dar cierre
emocional al flujo y guiar al usuario al inicio de sesion con el menor paso adicional posible.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar
│                                               │
│                  ╭────────╮                   │   logo 64×64
│                  │  ◐ ●   │                   │
│                  ╰────────╯                   │
│                  CareWell                     │   wordmark bicolor
│                                               │
│                                               │
│              ┌──────────────────┐             │   circulo 112 dp bg successContainer
│              │                  │             │   (#D8F0E1)
│              │   check_circle   │             │
│              │      80 dp       │             │   icono color success (#2E9E5B)
│              │                  │             │
│              └──────────────────┘             │
│                                               │
│        ¡Listo! Ya tenes acceso                │   displaySmall 30 px bold textPrimary
│                                               │   centrado
│   Tu contraseña fue creada. Ahora podés       │   bodyLarge 16 px textSecondary
│   iniciar sesión con tu email y tu nueva      │   centrado · margen top 12 dp
│   contraseña.                                 │
│                                               │
│  ┌──────────────────────────────────────────┐ │
│  │       Ir al inicio de sesion              │ │   PrimaryButton 56 dp
│  └──────────────────────────────────────────┘ │   margen top 32 dp
│                                               │
└───────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Logo + wordmark | Icono 64×64 dp + wordmark bicolor "CareWell". Sin tagline. Margen top ~48 dp. Identico al de la pantalla de Deteccion para consistencia visual del flujo. |
| 2 | Circulo ilustrativo | 112×112 dp, fondo `successContainer` (#D8F0E1), bordes circulares. Icono `check_circle` 80 dp color `success` (#2E9E5B) centrado. El tamaño mayor (vs 96 dp de Deteccion) enfatiza el logro. |
| 3 | Titulo | `displaySmall` (30 px, 700) "¡Listo! Ya tenes acceso". Color `textPrimary`. Centrado. Margen top 28 dp desde el circulo. |
| 4 | Cuerpo | `bodyLarge` (16 px, 400) color `textSecondary`. Centrado. Texto: "Tu contraseña fue creada. Ahora podés iniciar sesión con tu email y tu nueva contraseña." Margen top 12 dp. |
| 5 | Boton "Ir al inicio de sesion" | `PrimaryButton` full-width 56 dp radio 16. Fondo `primary`. Margen top 32 dp. `pushReplacement` al Login con email precargado. |

## Interacciones y comportamiento
- **Tap "Ir al inicio de sesion":** `pushReplacement` a Login (US-02 [01]) con el email
  precargado en el campo correspondiente. Animacion fade 250 ms.
  El usuario ya no puede volver a la pantalla de exito ni al formulario de credenciales
  (el stack de navegacion queda limpio: solo Login).
- **Back del sistema (Android):** ignorado en esta pantalla. El stack ya fue reemplazado por
  `pushReplacement` en el paso anterior; no hay a donde retroceder dentro de US-04.
  Se implementa con `PopScope` `canPop: false`, o simplemente el stack ya no contiene
  pantallas de US-04.
- **Animacion de entrada:** al llegar desde Cargando, el circulo verde puede hacer un
  "pulse" suave de entrada (escala 0.8 → 1.0, 300 ms ease-out) para reforzar el exito.
  Respetar `reduce-motion`: si esta activo, aparece directamente en escala 1.0.

## Estados alternativos
Esta pantalla tiene un unico estado visual. No hay variaciones de datos (el email no se
muestra aqui para no crear ansiedad por si el usuario empieza a dudar del email correcto).

## Navegacion (de donde viene / a donde va)
- **Entrada:** desde Cargando [03] via `pushReplacement` tras respuesta 201 Created.
- **Salida:** Login (US-02 [01]) con email precargado, via `pushReplacement`.
  No existe ninguna otra salida: el usuario no puede volver atras desde esta pantalla.
