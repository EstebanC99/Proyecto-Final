# 09 · Pantalla de éxito — cuenta creada

> Pantalla completa de confirmación. Tokens en `00-identidad-visual.md`.

## Propósito
Confirmar de forma clara y cálida que la cuenta se creó, y dirigir al usuario al login para
iniciar sesión.

## Wireframe

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│                                                │   (sin app bar / sin back:
│                                                │    el flujo de registro terminó)
│                                                │
│                                                │
│                  ╭──────────╮                  │
│                 │            │                 │   círculo successContainer
│                 │     ✓      │                 │   (#D8F0E1) 96dp,
│                 │            │                 │   check success(#2E9E5B) 48dp
│                  ╰──────────╯                  │   anim. ZoomIn/ElasticIn
│                                                │
│              ¡Cuenta creada!                   │   displaySmall textPrimary, center
│                                                │
│   Ya podés iniciar sesión con tu email y       │   bodyLarge textSecondary, center
│   empezar a organizar el cuidado.              │   (máx ~2 líneas, ancho 80%)
│                                                │
│                                                │
│                ( espacio flexible )            │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │              Ir al login                │  │   PrimaryButton full-width 56dp
│   └────────────────────────────────────────┘  │
│                                                │   margen inferior safe-area 24dp
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Sin app bar | El flujo terminó; no hay "atrás". El back del sistema lleva al Login (no reabre el registro). |
| 2 | Ilustración / ícono de éxito | Círculo `successContainer` (#D8F0E1) de 96 dp con ícono check (`check_rounded`) 48 dp color `success` (#2E9E5B). Centrado vertical-superior. Animación de entrada con `animate_do` (ZoomIn + pequeño "pop"/ElasticIn), 400 ms. Opcional: anillo de acento `secondary` muy sutil. |
| 3 | Título | "¡Cuenta creada!" `displaySmall` (30/Bold) `textPrimary`, centrado. Margen superior 24 dp. |
| 4 | Mensaje | "Ya podés iniciar sesión con tu email y empezar a organizar el cuidado." `bodyLarge` `textSecondary`, centrado, ancho máx ~80%. |
| 5 | Botón "Ir al login" | `PrimaryButton` full-width 56 dp, anclado hacia el fondo (con spacer flexible arriba). Texto `labelLarge`. |

Layout centrado: bloque ícono+textos agrupado en el tercio superior-central; botón al fondo con
spacer flexible. Padding horizontal `xl (24)`.

## Interacciones y comportamiento
- **Entrada animada:** ícono ZoomIn/ElasticIn; título y mensaje con fade-in escalonado (delay 150
  y 250 ms). Respetar reduce-motion (degradar a fade simple).
- **Tap "Ir al login":** navega al **Login [02]** con `pushReplacement` (limpia el stack del
  registro: no se puede "volver" al formulario ya enviado). Transición fade.
- **Pre-poblado opcional:** se puede pasar el email recién registrado al Login para precargar el
  campo y reducir fricción (coordinar con arquitecto-software si el Login lo soporta).
- **Back del sistema:** equivale a "Ir al login" (lleva al Login, nunca al formulario).
- **Accesibilidad:** anunciar la pantalla como "Cuenta creada con éxito"; foco inicial en el
  título. El botón es el único objetivo accionable.

## Estados alternativos
- No aplica (es un estado terminal de éxito; no hay loading/error aquí).

## Navegación
- **Entrada:** desde Estado de carga [08] tras respuesta 201.
- **Salida:** "Ir al login" / back → Login [02] (con stack de registro limpiado).
