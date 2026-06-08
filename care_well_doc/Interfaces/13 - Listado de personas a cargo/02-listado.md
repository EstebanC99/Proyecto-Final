# US-13 Listado de personas a cargo — Estado: Lista con personas

> Pantalla principal del modulo "Personas a cargo". Muestra la lista de personas
> asociadas al usuario autenticado, agrupadas por el rol que cumple el usuario
> en el equipo de cada persona (Responsable / Cuidador).

---

## Objetivo

Permitir al usuario ver de un vistazo todas las personas a cargo asociadas a su cuenta,
entender su rol en cada relacion y navegar al perfil de cualquiera de ellas para ver
detalle, editar o iniciar la eliminacion.

---

## Layout y jerarquia de componentes

```
┌─────────────────────────────┐  h: 28dp
│ StatusBar (9:41 · 5G 100%)  │
├─────────────────────────────┤  h: 56dp
│ AppBar                      │
│ [←]  Personas a cargo       │
├─────────────────────────────┤
│ SectionLabel: COMO RESPONSABLE │  h: 40dp aprox, padding 12 20 8
│                             │
│ ┌─────────────────────────┐ │  PersonCard — Alicia
│ │ [A] Alicia Rodriguez    │ │
│ │     82 años [Responsable]│ │
│ │                       › │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │  PersonCard — Carlos
│ │ [C] Carlos Mendez       │ │
│ │     74 años [Responsable]│ │
│ │                       › │ │
│ └─────────────────────────┘ │
│                             │
│ SectionLabel: COMO CUIDADOR │  h: 40dp aprox
│                             │
│ ┌─────────────────────────┐ │  PersonCard — Rosa
│ │ [R] Rosa Fernandez      │ │
│ │     68 años [Cuidador]  │ │
│ │                       › │ │
│ └─────────────────────────┘ │
│                             │
│                    [FAB +]  │  absoluto, bottom 24 right 20
└─────────────────────────────┘
```

---

## Especificacion de componentes

### AppBar
- Altura: 56 dp
- Fondo: `#FFFFFF`
- Borde inferior: 1px `#C5CECE`
- Sombra: `0 1px 3px rgba(0,0,0,0.06)`
- Contenido: ARROW_BACK (24dp) izq. · titulo "Personas a cargo" 18px 700 centrado/izq.

### SectionLabel
- Font: 12px, 600, uppercase, letter-spacing 0.8px
- Color: `#566060`
- Padding: 12px 20px 8px
- Background: transparente (sobre `#F6F8F8`)

### PersonCard
- Background: `#FFFFFF`
- Border-radius: 16dp
- Margin: 0 16px 10px
- Padding: 16dp
- Sombra: `0 1px 4px rgba(0,0,0,0.08)`
- Layout: flex row, gap 12dp, align-items center

**Avatar (52dp):**
- Circulo, bg `#C9EDE8`, inicial nombre 22px 700 color `#0A3D38`

**Bloque central (flex: 1):**
- Nombre: 16px, 700, `#16201F`
- Fila inferior: edad 13px 400 `#566060` + RoleBadge

**RoleBadge Responsable:** bg `#C9EDE8`, texto `#0A3D38`, 11px 600, radius 999, padding 3px 9px
**RoleBadge Cuidador:** bg `#FCE2DA`, texto `#7A2E1A`, 11px 600, radius 999, padding 3px 9px

**CHEVRON_RIGHT (20dp):** color `#9AA5A5`, margen izq. auto, flex-shrink 0

**Interaccion:** tap en toda la tarjeta → navega a US-14 (perfil persona).
Ripple sobre el area completa de la tarjeta.

### FAB
- 56 x 56dp, border-radius 16dp
- Background: `#1A8C82`
- Icono ADD 24dp, color `#FFFFFF`
- Sombra: `0 4px 12px rgba(26,140,130,0.35)`
- Posicion: absoluto, bottom 24dp, right 20dp
- Solo visible para Responsable con permiso de alta

---

## Estados de la pantalla

| Estado | Descripcion |
|---|---|
| Con datos | Lista con personas, con secciones segun roles del usuario |
| Vacio | Ver `02-listado-vacio.html` y `03-listado-vacio.md` |
| Cargando | Skeleton loaders en lugar de las tarjetas (3 filas placeholder) |

---

## Interacciones

- **Tap en tarjeta:** push a US-14 (perfil detalle de la persona). Animacion slide-right.
- **Tap en FAB:** push a US-12 (alta de persona a cargo). Animacion slide-up.
- **Back:** pop al menu principal. Animacion slide-left.
- **Scroll:** la lista es scrollable si hay muchas personas; el FAB permanece en posicion fija.
