# 05 · Alta de persona a cargo — Pantalla de exito

> Estado final tras registro exitoso. Tokens en `00-sistema-diseno.md`. HTML: `html/04-exito.html`.

## Proposito
Confirmar al Responsable que la persona fue registrada correctamente, mencionando su nombre
en negrita para reforzar la identidad de quien fue dado de alta, y ofrecer dos caminos
claros: ir a la lista o registrar otra persona.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐
│ 9:41                                  5G 100% │  status bar
│                                                │
│                                                │
│                                                │
│             ╭──────────────────╮               │
│             │   [check 80dp]   │               │  circle 112dp · bg #D8F0E1
│             ╰──────────────────╯               │  ícono check #2E9E5B
│                                                │
│         ¡Persona registrada!                   │  displaySmall 28px bold
│                                                │
│   Juan García fue agregado a tu lista          │  bodyLarge 16px textSecondary
│   de personas a cargo.                         │  nombre en bold textPrimary
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│   ┌─────────────────────────────────────────┐  │
│   │       Ver personas a cargo              │  │  PrimaryButton 56dp
│   └─────────────────────────────────────────┘  │
│                                                │
│           Agregar otra persona                  │  link secondary 16px primary bold
│                                                │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Círculo de exito | 112 dp, border-radius 999 px, fondo `successContainer #D8F0E1`. CHECK_CIRCLE 80 dp color `success #2E9E5B`. Centrado verticalmente en la mitad superior. Animacion: ZoomIn 300 ms + rebote suave (ElasticOut). |
| 2 | Título | "¡Persona registrada!" `displaySmall` 28 px bold `textPrimary`. Margen 24 dp sobre el ícono. |
| 3 | Mensaje | "**Juan García** fue agregado a tu lista de personas a cargo." `bodyLarge` 16 px `textSecondary`. El nombre (**Juan García**) en bold `textPrimary`. Máx. 80% ancho, centrado. |
| 4 | Botón primario | "Ver personas a cargo" `PrimaryButton` full-width 56 dp, fondo `primary`. Anclado sobre el margen inferior. `pushReplacement` a lista. |
| 5 | Link secundario | "Agregar otra persona" centrado, 16 px `primary` bold. Debajo del botón, target 48 dp mín. `pushReplacement` a nuevo formulario vacío. |

## Interacciones y comportamiento

- **No hay AppBar.** Esta pantalla es un punto de cierre del flujo; no tiene sentido "volver"
  al formulario ya procesado.
- **Back del sistema (Android):** navega a la lista de personas a cargo (mismo destino que el
  botón primario). El back nunca vuelve al formulario.
- **"Ver personas a cargo":** `pushReplacement` + pop a la lista con refresh (la nueva persona
  debe aparecer).
- **"Agregar otra persona":** `pushReplacement` por un nuevo formulario vacío de alta. El stack
  no acumula formularios.
- El nombre en negrita es el nombre que el usuario ingresó en el campo Nombre + Apellido del
  formulario, interpolado en el mensaje para confirmar la identidad correcta.

## Navegacion

- **Entrada:** `pushReplacement` desde [03] cargando tras 201.
- **Salida:** "Ver personas a cargo" → lista · "Agregar otra persona" → nuevo [01].
