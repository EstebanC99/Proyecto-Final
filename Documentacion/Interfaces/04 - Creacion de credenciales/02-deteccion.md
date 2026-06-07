# 02 · Creacion de credenciales — Deteccion (pantalla de bienvenida)

> Primera pantalla del flujo US-04. Sin AppBar. Tokens en `00-sistema-diseno.md`.
> HTML: `html/01-deteccion.html`.

## Proposito
Comunicar al usuario que el sistema reconoce su perfil pero que todavia no tiene contraseña,
y ofrecerle el camino claro para crearla. Tambien permite salir del flujo si el email
detectado no corresponde a quien tiene el dispositivo.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│                                                │
│                  ╭────────╮                    │   logo 64×64
│                  │  ◐ ●   │                    │   margen superior ~52 dp
│                  ╰────────╯                    │
│                  CareWell                      │   wordmark bicolor
│                                                │
│                                                │
│              ┌──────────────────┐              │   circulo 96 dp bg primaryContainer
│              │    person_add    │              │   icono 48 dp color primary
│              │      48 dp       │              │
│              └──────────────────┘              │
│                                                │
│           Primera vez por aca                  │   headlineMedium 24 px bold
│                                                │
│  Encontramos tu perfil en CareWell.            │   bodyLarge 16 px textSecondary
│  Para acceder, primero necesitas crear         │
│  una contraseña para tu cuenta                 │
│  maria@ejemplo.com.                            │   email en negrita textPrimary
│                                                │
│  ┌──────────────────────────────────────────┐  │
│  │         Crear mi contraseña              │  │   PrimaryButton 56 dp
│  └──────────────────────────────────────────┘  │
│                                                │
│           No soy yo · Ir al inicio             │   SecondaryTextButton centrado
│                                                │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Logo + wordmark | Icono de marca 64×64 dp (version ligeramente mas pequena que en Login para dar espacio al contenido central). Wordmark "CareWell" bicolor. Sin tagline en esta pantalla. |
| 2 | Circulo ilustrativo | 96×96 dp, fondo `primaryContainer` (#C9EDE8), bordes redondeados circulo. Icono `person_add` 48 dp color `primary` (#1A8C82) centrado. Representa "estamos esperando que te sumes". |
| 3 | Titulo | `headlineMedium` (24 px, 700) "Primera vez por aca" · color `textPrimary`. Centrado. Margen superior 28 dp desde el circulo. |
| 4 | Cuerpo | `bodyLarge` (16 px, 400) color `textSecondary`. Centrado. Texto: "Encontramos tu perfil en CareWell. Para acceder, primero necesitas crear una contraseña para tu cuenta". El email va en `<strong>` color `textPrimary`. Margen superior 12 dp. |
| 5 | Boton "Crear mi contraseña" | `PrimaryButton` full-width 56 dp radio 16. Fondo `primary`. Margen superior 32 dp. Navega a [02] Formulario. |
| 6 | Link "No soy yo" | `SecondaryTextButton` centrado. Texto: "No soy yo · Ir al inicio". `labelMedium` (14 px, 600) color `primary`. Objetivo tactil >= 48 dp. Margen superior 16 dp. Navega al Login vacio. |

## Interacciones y comportamiento
- **Tap "Crear mi contraseña":** push a `/crear-credenciales/formulario`, slide-left + fade 250 ms.
  El email se pasa como argumento de navegacion (no se re-lee desde la URL para evitar
  manipulacion; viene del estado de navegacion).
- **Tap "No soy yo · Ir al inicio":** `popUntil` Login, fade 200 ms. El email precargado en el
  Login se limpia (no tiene sentido precargar un email que el usuario rechazo).
- **Back del sistema (Android):** equivalente a "No soy yo" — vuelve al Login vacio.
  Se debe manejar con `WillPopScope` / `PopScope` en Flutter para que no vuelva al estado
  de carga previo.

## Estados alternativos
Esta pantalla tiene un unico estado visual. El email mostrado puede variar segun quien
intente ingresar, pero el layout es siempre el mismo.

## Navegacion (de donde viene / a donde va)
- **Entrada:** desde Login en estado de carga (US-02 [06]), via `pushReplacement` cuando el
  servidor detecta Persona sin credenciales (caso especifico, no el happy path del Login).
- **Salida:** Formulario [02] ("Crear mi contraseña") o Login vacio US-02 [01] ("No soy yo").
