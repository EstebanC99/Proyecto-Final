# US-14 Modificacion de persona a cargo — Estado: Perfil en lectura

> Vista de detalle/perfil de una persona a cargo. Estado base desde el que parte
> la edicion. Muestra todos los datos de la persona en modo solo lectura, con
> botones EDIT disponibles para los campos modificables.

---

## Objetivo

Mostrar todos los datos registrados de la persona a cargo de forma clara y jerarquica.
Permitir al Responsable iniciar la edicion de cualquier campo editable con un tap.
Exponer el acceso a la eliminacion (US-15) mediante el menu contextual MORE_VERT.

---

## Layout y jerarquia de componentes

```
┌─────────────────────────────┐  h: 28dp
│ StatusBar                   │
├─────────────────────────────┤  h: 56dp
│ AppBar                      │
│ [←]  Alicia Rodriguez   [⋮] │
├─────────────────────────────┤  h: 140dp aprox
│ ProfileHeader               │
│    [A]  Alicia Rodriguez    │  Avatar 80dp centrado
│         [Persona a cargo]   │  Badge teal
├─────────────────────────────┤
│ DataSection (fondo #F6F8F8) │
│                             │
│ ┌─────────────────────────┐ │  DataRow — Nombre
│ │[PERSON] Nombre completo │ │
│ │         Alicia Rodriguez│[EDIT]│
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │  DataRow — DNI (sin EDIT)
│ │[BADGE]  DNI             │ │
│ │         23.456.789      │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │  DataRow — Fecha nac. (sin EDIT)
│ │[CALENDAR] Fecha de nac. │ │
│ │           15/03/1942    │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │  DataRow — Email
│ │[EMAIL]  Email           │ │
│ │         alicia@ejemplo.com│[EDIT]│
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

---

## Especificacion de componentes

### AppBar
- Altura: 56 dp
- Fondo: `#FFFFFF`, borde inferior `#C5CECE`
- Izquierda: ARROW_BACK 24dp, color `#16201F`, tap target 40x40dp
- Centro/izquierda: titulo "Alicia Rodriguez" 18px 700 `#16201F`
- Derecha: MORE_VERT 24dp, color `#16201F`, tap target 40x40dp

### ProfileHeader
- Background: `#FFFFFF`
- Padding: 24dp
- Border-bottom: 1px `#C5CECE`
- Layout: flex column, align center
- Avatar: 80dp, bg `#C9EDE8`, inicial "A" 36px 700 `#0A3D38`
- Nombre: 20px 700 `#16201F`, margin-top 12dp
- Badge "Persona a cargo": bg `#C9EDE8`, texto `#0A3D38`, 12px 600, radius 999, padding 4px 12px, margin-top 8dp

### DataRow (lectura)
Ver especificacion completa en `00-sistema-diseno.md` seccion 2.
- Altura minima: 64dp
- Padding: 12px 24px
- Fondo: `#FFFFFF`, borde inferior `#C5CECE`
- Icono izquierdo: 20dp, color `#566060`
- Label: 13px 400 `#566060`
- Valor: 16px 500 `#16201F`
- Boton EDIT (cuando editable): 48x48dp, icono EDIT 20dp color `#1A8C82`
- Sin boton EDIT para DNI y Fecha de nac.

### Menu contextual MORE_VERT
Al tap en MORE_VERT, se muestra un dropdown o bottom-sheet con:
- Item "Eliminar persona": icono DELETE 20dp color `#D14343`, label 14px `#D14343`
- Item "Cancelar" o cierre del menu

Solo accesible para Responsable con permiso de eliminacion.

---

## Estados de la fila de datos

| Campo | Editable | Motivo |
|---|---|---|
| Nombre completo | Si | Dato correctable directamente |
| DNI | No | Identificador de sistema; requiere proceso especial |
| Fecha de nacimiento | No | Dato sensible; requiere validacion adicional |
| Email | Si | Dato de contacto, modificable por el responsable |

---

## Interacciones

- **Tap EDIT en Nombre/Email:** activa `InlineEditingRow` para ese campo.
- **Tap MORE_VERT:** abre menu contextual con opcion "Eliminar persona".
- **Tap ARROW_BACK:** pop a US-13 (listado). Si hay campo activo, se descarta sin guardar.
- **Tap en cuerpo de fila (sin lapiz):** sin efecto (no abre edicion).
