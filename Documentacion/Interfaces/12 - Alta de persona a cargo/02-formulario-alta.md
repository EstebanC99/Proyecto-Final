# 02 · Alta de persona a cargo — Formulario inicial (estado vacío)

> Pantalla principal del flujo. Tokens en `00-sistema-diseno.md`. HTML: `html/01-formulario-alta.html`.

## Proposito
Permitir al Responsable registrar una nueva persona a cargo con los datos mínimos necesarios,
con la menor fricción posible. La persona registrada queda en el sistema sin credenciales
propias: no puede iniciar sesión, pero forma parte del equipo de cuidado.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  bg #F6F8F8
│ 9:41                                  5G 100% │  status bar
│ ◄  Nueva persona a cargo                       │  AppBar 56dp · surface #FFF
│────────────────────────────────────────────────│  divider 1dp outline
│                                                │
│ Completá los datos de la persona que           │  subtítulo bodyMedium textSecondary
│ vas a registrar.                               │
│                                                │
│                   ╭────────╮                   │  avatar 80dp circle
│                   │  [+ph] │                   │  border dashed outline
│                   ╰────────╯                   │
│               Agregar foto                     │  link 12px primary bold
│                                                │
│  Nombre *                                      │
│  ┌─────────────────────────────────────────┐  │
│  │ [person]  Ej. Juan                      │  │  AppTextField reposo
│  └─────────────────────────────────────────┘  │
│                                                │
│  Apellido *                                    │
│  ┌─────────────────────────────────────────┐  │
│  │ [person]  Ej. García                    │  │
│  └─────────────────────────────────────────┘  │
│                                                │
│  Documento (DNI) *                             │
│  ┌─────────────────────────────────────────┐  │
│  │ [badge]   Ej. 12.345.678                │  │
│  └─────────────────────────────────────────┘  │
│                                                │
│  Fecha de nacimiento *                         │
│  ┌─────────────────────────────────────────┐  │
│  │ [cal]     DD/MM/AAAA                    │  │
│  └─────────────────────────────────────────┘  │
│                                                │
│  Email (opcional)                              │
│  ┌─────────────────────────────────────────┐  │
│  │ [email]   juan@ejemplo.com              │  │
│  └─────────────────────────────────────────┘  │
│                                                │
│  [ ] Acepto los Términos y Condiciones         │  checkbox 22dp · link tappable
│                                                │
│  ┌─────────────────────────────────────────┐  │
│  │         Registrar persona               │  │  PrimaryButton DISABLED
│  └─────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | AppBar | Fila 56 dp, fondo `surface #FFF`, sombra `0 1px 0 #C5CECE`. ARROW_BACK 24 dp izquierda (`primary`). Título "Nueva persona a cargo" centrado, `titleMedium` 17 px bold `textPrimary`. |
| 2 | Subtítulo | `bodyMedium` 14 px, color `textSecondary #566060`. Margen 16 dp bajo el AppBar. |
| 3 | Bloque de foto | Círculo 80 dp centrado, fondo `surfaceVariant #EDF1F1`, borde 2 dp dashed `outline #C5CECE`. Ícono ADD_PHOTO 24 dp `textDisabled`. Debajo: texto "Agregar foto" 12 px `primary` bold. Tap abre bottom-sheet con opciones Galería / Cámara. |
| 4 | Campo Nombre | `AppTextField` reposo. Label "Nombre *". Prefijo PERSON 20 dp. Placeholder "Ej. Juan". Teclado `name`. |
| 5 | Campo Apellido | `AppTextField` reposo. Label "Apellido *". Prefijo PERSON 20 dp. Placeholder "Ej. García". |
| 6 | Campo DNI | `AppTextField` reposo. Label "Documento (DNI) *". Prefijo BADGE 20 dp. Placeholder "Ej. 12.345.678". Teclado `number`. Valida formato al blur. |
| 7 | Campo Fecha | `AppTextField` reposo. Label "Fecha de nacimiento *". Prefijo CALENDAR_MONTH 20 dp. Placeholder "DD/MM/AAAA". Tap abre `showDatePicker` nativo. |
| 8 | Campo Email | `AppTextField` reposo. Label "Email (opcional)". Prefijo EMAIL 20 dp. Placeholder "juan@ejemplo.com". Teclado `emailAddress`. Campo nullable, no valida vaciado. |
| 9 | Checkbox T&C | Fila 48 dp mín. CHECKBOX_BLANK 22 dp `textSecondary`. Texto "Acepto los **Términos y Condiciones**"; "Términos y Condiciones" es un link `primary` que abre el bottom-sheet de TyC. |
| 10 | Botón | `PrimaryButton` full-width 56 dp. **Disabled** hasta que T&C esté marcado: fondo `outline #C5CECE`, texto `textDisabled`. Al marcarse T&C → fondo `primary #1A8C82`, texto `#FFF`. |

## Interacciones y comportamiento

- **Tap ARROW_BACK:** pop, vuelve a la lista de personas a cargo sin confirmacion.
- **Tap bloque foto:** abre bottom-sheet "Agregar foto" con dos opciones: "Desde galería" y
  "Tomar foto". Tras seleccionar, el avatar muestra la foto elegida; el texto cambia a
  "Cambiar foto".
- **Foco en campos de texto:** borde 2 dp `primary #1A8C82`.
- **Blur en DNI:** valida formato; si inválido muestra helper error (ver [02]).
- **Tap en Fecha:** abre date-picker nativo (Flutter `showDatePicker`). En el mockup HTML
  se representa como input de texto.
- **Marcar T&C:** habilita el botón (transicion de color 150 ms).
- **Tap "Registrar persona" (habilitado):** dispara validacion local; si OK, pasa a [03].

## Navegacion

- **Entrada:** push desde la lista de personas a cargo (tap "+").
- **Salida:** pop (ARROW_BACK) a lista · [03] cargando · TyC bottom-sheet (sin cambio de ruta).
