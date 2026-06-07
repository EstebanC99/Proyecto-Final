# US-14 Modificacion de datos de persona a cargo — Sistema de diseno

> Este flujo hereda en su totalidad el sistema de diseno definido en US-01:
> `Documentacion/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Aca solo se documentan las decisiones especificas del flujo de edicion de persona.
>
> El patron de edicion inline campo por campo es identico al implementado en US-07
> (Edicion del perfil de usuario). Se reutilizan los mismos componentes: `DataRow`,
> `InlineEditingRow`, `InlineInput` con foco teal, botones CHECK/CLOSE.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryContainer #C9EDE8` |
| Secundario | `secondaryContainer #FCE2DA` |
| Success | `success #2E9E5B` · `successContainer #D8F0E1` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Radios | inputs `radiusMd 12` · cards `radiusMd 16` · chips `radiusFull 999` |
| Alturas | input 56 dp · objetivo tactil min. 48 dp |
| Tipografia | familia `Inter` (fallback `'Segoe UI', Arial, sans-serif`) |

---

## 2. Componentes reutilizados de US-07

- **`DataRow`**: fila de dato en modo lectura con icono, label/valor y boton EDIT 20dp.
  Identica a US-07 §DataRow. Tap en lapiz activa `InlineEditingRow`.
- **`InlineEditingRow`**: fila en modo edicion: icono + input inline foco teal + CHECK/CLOSE.
  Identica a US-07 §InlineEditingRow.
- **`InlineInput`**: input borde 2dp `#1A8C82`, radius 12dp, alto 56dp, valor precargado.
- **Snackbar de exito**: bg `#323232`, texto blanco, icono CHECK `#2E9E5B`.

---

## 3. Componentes especificos de US-14

### 3.1 ProfileHeader (persona a cargo)

Diferencia respecto a US-07 (perfil propio): el encabezado no permite editar la foto
desde aqui (solo desde el formulario completo). Se muestra solo el avatar con la inicial
y el nombre. El badge es "Persona a cargo" (variante teal, igual a RoleBadge Responsable).

| Propiedad | Valor |
|---|---|
| Padding | 24dp |
| Avatar | 80dp, bg `#C9EDE8`, inicial 36px 700 `#0A3D38` |
| Nombre | 20px, 700, `#16201F`, centrado |
| Badge | "Persona a cargo", bg `#C9EDE8`, texto `#0A3D38`, 12px 600, radius 999, padding 4px 12px |

### 3.2 MORE_VERT (menu contextual)

Boton de 3 puntos en AppBar (extremo derecho). Al pulsarlo, abre un menu contextual
modal (bottom de pantalla o dropdown) con las opciones adicionales de la persona:
- "Eliminar persona" → inicia US-15

Solo se muestra si el usuario es Responsable con permiso de eliminacion.
El icono es MORE_VERT 24dp, color `#16201F`, tap target 40x40dp.

---

## 4. Decisiones especificas de US-14

1. **Edicion inline, campo por campo.** Igual que US-07: el lapiz EDIT activa un unico
   campo a la vez. Si hay un campo activo y el usuario toca otro lapiz, el campo activo
   se cierra sin guardar y se abre el nuevo. Esto simplifica el flujo y reduce errores.

2. **Campos editables vs. no editables.**
   - Editables: Nombre completo, Email.
   - No editables desde esta pantalla: DNI (identificador unico del sistema), Fecha de nacimiento
     (cambio requiere proceso adicional). Estas filas muestran un icono INFO en lugar de EDIT,
     con tooltip "No editable desde aqui".
   - En el mockup HTML, DNI y Fecha de nac. no tienen boton EDIT para comunicar esto.

3. **Acceso a eliminacion via MORE_VERT.** Separar "Eliminar" del flujo de edicion principal
   reduce el riesgo de accion accidental. El MORE_VERT comunica "hay mas opciones" sin
   mostrar siempre el boton destructivo. Solo aparece para Responsables con permiso.

4. **Snackbar tras guardar.** Al confirmar un cambio (CHECK), se guarda y se muestra un
   snackbar con el nombre de la persona: "Datos de [Nombre] actualizados". Esto confirma
   la accion sin cambiar de pantalla ni interrumpir el flujo.

5. **Persistencia del estado de edicion.** Al pulsar ARROW_BACK con un campo en edicion,
   se descarta el campo activo (sin guardar) y se navega atras. No se muestra dialogo de
   confirmacion (cambio parcial, bajo impacto).

---

## 5. Mapa de estados

| Estado | Archivo HTML | Disparador |
|---|---|---|
| Perfil en lectura | `01-perfil-persona.html` | tap en tarjeta desde US-13 |
| Campo en edicion | `02-edicion.html` | tap en lapiz EDIT de un campo |
| Guardado exitoso | `03-guardado.html` | tap en CHECK con valor valido |
