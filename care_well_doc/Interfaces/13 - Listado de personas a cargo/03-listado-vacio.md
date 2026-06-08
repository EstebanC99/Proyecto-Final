# US-13 Listado de personas a cargo — Estado: Lista vacia

> Estado de la pantalla cuando el usuario autenticado no tiene ninguna persona
> a cargo registrada (Responsable nuevo o Cuidador aun sin asignaciones).

---

## Objetivo

Comunicar claramente que no hay personas registradas todavia, reducir la sensacion de
"pantalla rota" y guiar al usuario hacia la accion de alta con una propuesta de valor
visible y un CTA accesible.

---

## Layout y jerarquia de componentes

```
┌─────────────────────────────┐  h: 28dp
│ StatusBar                   │
├─────────────────────────────┤  h: 56dp
│ AppBar: [←] Personas a cargo│
├─────────────────────────────┤
│                             │
│                             │
│          (espacio)          │  flex: 1, centrado vertical
│                             │
│     ┌──────────────┐        │
│     │ [PERSON 48dp]│        │  circulo 80dp bg #C9EDE8
│     └──────────────┘        │
│                             │  mt: 24dp
│   Sin personas a cargo      │  18px 700 #16201F centrado
│                             │  mt: 8dp
│  Registra a las personas    │  14px 400 #566060 centrado
│  bajo tu cuidado para       │  max-width 260dp
│  comenzar a organizarte     │
│                             │  mt: 32dp
│  ┌───────────────────────┐  │
│  │   + Agregar persona   │  │  PrimaryButton 56dp radius 16
│  └───────────────────────┘  │  mx: 40dp
│                             │
│                             │
└─────────────────────────────┘
```

---

## Especificacion de componentes

### AppBar
Identica al estado con datos. ARROW_BACK + "Personas a cargo".
Sin FAB en la barra; el FAB desaparece en estado vacio para reducir redundancia.

### Contenedor de estado vacio
- Layout: flex column, align-items center, justify-content center
- Padding horizontal: 40dp
- Ocupa el area disponible entre AppBar y fondo de pantalla

### Icono en circulo
- Circulo: 80 x 80dp, bg `#C9EDE8`, border-radius 50%
- Icono PERSON: 48dp, color `#1A8C82`, centrado

### Texto titulo
- "Sin personas a cargo"
- Font: 18px, 700, `#16201F`
- Margin-top: 24dp

### Texto cuerpo
- "Registra a las personas bajo tu cuidado para comenzar a organizarte."
- Font: 14px, 400, `#566060`
- Text-align: center
- Max-width: 260dp
- Margin-top: 8dp
- Line-height: 1.5

### Boton primario
- Texto: "Agregar persona"
- Altura: 56dp, border-radius: 16dp
- Background: `#1A8C82`, texto `#FFFFFF`, 16px 700
- Margin-top: 32dp
- Width: 100% del contenedor (menos padding horizontal)
- Solo visible si el usuario tiene permiso de alta; si no tiene permiso, se reemplaza
  por un texto: "Un Responsable puede agregarte a un equipo de cuidado."

---

## Interacciones

- **Tap en "Agregar persona":** push a US-12 (alta). Animacion slide-up.
- **Back:** pop al menu principal.

---

## Diferencias con estado con datos

| Aspecto | Con datos | Vacio |
|---|---|---|
| FAB | Visible, bottom-right | Oculto |
| Contenido | SectionLabels + PersonCards | EmptyState centrado |
| CTA | FAB | Boton primario centrado |
