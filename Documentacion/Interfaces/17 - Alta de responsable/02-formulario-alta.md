# US-17 — Pantalla: Formulario de alta de responsable (01-formulario-alta.html)

## Objetivo
Capturar el email del nuevo responsable y mostrar los permisos que se le asignarán por defecto,
con posibilidad de ajustarlos antes de confirmar la acción.

## Layout (jerarquía de componentes, top → bottom)

```
StatusBar (28px, dark)
AppBar
  ├── IconButton ARROW_BACK (40px)
  └── Titulo "Agregar responsable" (18px bold)
ScrollView (padding 16px 24px 32px)
  ├── Subtitulo de contexto (14px, margin-top 16px)
  ├── Separador 20px
  ├── FieldLabel "Email del responsable" (13px)
  ├── AppTextField (56px, prefijo EMAIL, placeholder)
  ├── HelperText (18px reservado, invisible en estado normal)
  ├── Separador 24px
  ├── BloquePermisos
  │     ├── Header (titulo 15px bold + body 13px)
  │     ├── Separador interno 8px
  │     ├── PermissionRow "Editar datos de la persona" [toggle ON]
  │     ├── PermissionRow "Gestionar agenda" [toggle ON]
  │     └── PermissionRow "Gestionar equipo" [toggle ON]
  ├── Separador 28px
  └── BtnPrimario "Agregar responsable"
```

## Especificación de cada componente

### AppBar
- Identico al de US-16 pero sin boton ADD
- Titulo: "Agregar responsable" (puede requerir reduccion de font a 16px si el titulo es largo)

### Subtitulo de contexto
- "El responsable podrá gestionar datos y coordinar el cuidado de"
  + salto de linea (o espacio) + "**Alicia Rodríguez**."
- Implementacion: 14px / color #566060 / margin-top 16px
- "Alicia Rodríguez": 14px bold / color #16201F

### AppTextField (campo email)
- Label externo: "Email del responsable" / 13px / font-weight 500 / #566060
- Height 56px, bg #FFFFFF, border 1px solid #C5CECE, border-radius 12px
- Prefijo: EMAIL SVG 20px / color #566060
- Placeholder: "email del nuevo responsable" / 16px / #9AA5A5
- HelperText: espacio 18px siempre reservado debajo del campo
  - En reposo: invisible (color transparent o altura fija con texto "")
  - En error: "Texto de error" / 12px / #D14343

### BloquePermisos
- Contenedor: bg #FFFFFF, border-radius 12px, overflow hidden
- Sombra: 0 1px 4px rgba(0,0,0,0.06)
- margin-top: 24px (despues del helper)

#### Header del bloque
- Padding: 14px 16px 10px
- Titulo: "Permisos asignados" / 15px bold / #16201F
- Body: "El responsable obtendrá acceso completo. Podés ajustarlo después."
  / 13px / #566060 / margin-top 4px / line-height 1.45

#### PermissionRow
- Padding: 12px 16px
- Layout: flex row, align-items center, justify-content space-between
- Separador entre filas: 1px solid #EDF1F1 (no en la ultima fila)
- Label: 14px / regular / #16201F
- Toggle: 40x22px, ON state

#### Toggle ON (CSS puro, sin JS)
- Contenedor div: width 40px, height 22px, bg #1A8C82, border-radius 999px
- Posicion relativa
- Circulo: width 18px, height 18px, border-radius 50%, bg #FFFFFF
- Posicion absoluta: top 2px, left 20px (desplazado a la derecha = estado ON)

### Boton primario
- Texto: "Agregar responsable"
- Height 56px, bg #1A8C82, color #FFFFFF, border-radius 16px, font 16px bold
- Width: 100%
- margin-top: 28px desde el bloque de permisos

## Datos de ejemplo
- Nombre persona: Alicia Rodríguez
- Campo email: placeholder (estado inicial)
- Los 3 permisos aparecen activados (ON)

## Interacciones
- Tap campo email → foco, teclado email, borde teal 2px
- Tap toggle (si fuera interactivo en HTML estatico): cambio visual ON/OFF
  (en prototipo estatico todos los toggles quedan ON para mostrar el estado default)
- Tap "Agregar responsable" → validacion + (si ok) navega a 02-exito.html
- Tap ARROW_BACK → vuelve a US-16

## Consideraciones de accesibilidad
- Los toggles tienen su contenedor con min 44px de alto (padding implicito o wrapper)
  para facilitar el tap en pantallas reales
- El campo email dispara teclado tipo email (inputmode="email" en Flutter)
- Los labels de campo son externos (siempre visibles, no se ocultan al escribir)

## Anotaciones de diseño
1. Permisos full por defecto para responsable: decisión de diseño para reducir fricción
2. "Podés ajustarlo después": reduce la ansiedad de decision, referencia a US-18
3. Helper text con altura reservada: evita layout shift al aparecer errores
4. Toggle pre-activados en estado inicial: onboarding sin fricciones
5. Boton siempre habilitado: validacion al pulsar (no bloquear antes de intentar)
