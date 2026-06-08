# US-07 Edicion del perfil — Sistema de diseno

> Este flujo **hereda en su totalidad** el sistema de diseno definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`,
> y extiende los componentes introducidos en US-06:
> `care_well_doc/Interfaces/06 - Visualizacion del perfil/00-sistema-diseno.md`.
> Aca solo se documentan las **decisiones especificas del flujo de edicion de perfil**.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryContainer #C9EDE8` · `onPrimaryContainer #0A3D38` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `disabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Exito | `success #2E9E5B` · `successContainer #D8F0E1` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Radios | input `radiusMd 12` · boton `radiusLg 16` · snackbar `8px` |
| Alturas | fila de dato min. 64 dp · input inline 56 dp · objetivo tactico min. 48 dp |
| Tipografia | familia `Inter` (fallback: `'Segoe UI', Arial, sans-serif`) |

---

## 2. Patron de edicion: inline campo a campo

### Justificacion

La edicion de perfil usa un patron **inline, campo a campo** en lugar de un formulario
completo editable. Este patron responde a las necesidades de los usuarios de CareWell:

- **Personas cuidadoras apuradas** que rara vez editan todos los campos a la vez.
  El patron inline les permite tocar el lapiz del dato que necesitan actualizar,
  cambiarlo y confirmar sin que el resto de la pantalla cambie.
- **Menor riesgo de error accidental.** Un formulario completamente editable invita a
  tocar campos no intencionados. El lapiz por fila es una barrera minima de intencion.
- **Feedback inmediato y contextual.** El resultado del guardado (exito o error) se
  muestra en el contexto del campo que se edito, no al final de un formulario largo.

### Estados del patron

| Estado | Disparador | Descripcion |
|---|---|---|
| Solo lectura con lapiz | entrada a la pantalla | Cada fila muestra el boton EDIT 20dp a la derecha |
| Campo en edicion | tap en boton EDIT de una fila | La fila se convierte en input inline |
| Guardando | tap en CHECK (confirmar) | Input disabled + spinner reemplaza a CHECK/CLOSE |
| Cambio guardado | respuesta 200 del servidor | Vuelve a solo lectura + snackbar de exito 3 s |
| Error al guardar | respuesta de error del servidor | Input vuelve a habilitado + mensaje de error inline bajo el campo |

### Restriccion clave

**Solo un campo puede estar en edicion a la vez.** Si el usuario toca el lapiz de otra
fila mientras hay un campo en edicion, ese campo se cancela automaticamente (equivalente
a tocar CLOSE) y el nuevo campo entra en modo edicion. Esta regla evita estados
inconsistentes y simplifica la gestion del formulario en el provider.

---

## 3. Nuevos componentes introducidos en US-07

### 3.1 `ProfileDataRow` en modo edicion

Extension del componente definido en US-06. Cuando una fila entra en modo edicion:

| Propiedad | Valor |
|---|---|
| Input altura | 56 dp (AppTextField heredado de US-01) |
| Borde focus | 2 dp `primary #1A8C82` |
| Fondo | `surface #FFFFFF` |
| Valor precargado | el dato actual del campo (no placeholder) |
| Acciones inline | CLOSE (cancelar, color `textSecondary #566060`) + CHECK (guardar, color `primary #1A8C82`), ambos 48×48 dp de objetivo tactico |
| Padding de fila | 12px vertical · 24px horizontal (igual que en reposo) |

### 3.2 Estado guardando (spinner inline)

Cuando el usuario confirma el cambio (CHECK), el input entra en estado disabled y los
botones CLOSE/CHECK son reemplazados por un spinner de 16 dp:

```css
width: 16px; height: 16px;
border: 2px solid #C5CECE;
border-top-color: #1A8C82;
border-radius: 50%;
/* animacion: rotate 0.8s linear infinite (en Flutter: CircularProgressIndicator small) */
```

La fila ocupa el mismo espacio que en modo edicion; no hay salto de layout.

### 3.3 `Snackbar` de exito

| Propiedad | Valor |
|---|---|
| Posicion | `position: absolute; bottom: 24px; left: 24px; right: 24px;` |
| Fondo | `#323232` (estandar Material) |
| Texto | `#FFFFFF`, 14 px |
| Icono prefijo | CHECK 20 dp, color `success #2E9E5B` |
| Border-radius | 8 px |
| Padding | 14px vertical · 16px horizontal |
| Duracion | 3 s, luego auto-dismiss con fade-out 200 ms |
| Accion | ninguna (el mensaje es informativo, no requiere accion del usuario) |

---

## 4. Restricciones de edicion por campo

| Campo | Editable | Validacion |
|---|---|---|
| Nombre completo | Si | No vacio, min. 2 caracteres |
| Email | Si | Formato de email valido · unicidad validada en servidor |
| Telefono | Si | Solo numeros, +, espacios y guiones · min. 7 digitos |
| DNI | Si | Solo numeros, puntos opcionales · min. 7 digitos |
| Rol en el sistema | No | El rol lo asigna el sistema; no editable por el usuario |

> La restriccion del campo Rol se mantiene visualmente con la ausencia del boton EDIT
> en esa fila. No hay tooltip ni explicacion adicional; la ausencia del lapiz es suficiente.

---

## 5. Mapa de estados de la pantalla

| Estado | HTML de referencia |
|---|---|
| Perfil editable (todos los campos con lapiz) | `html/01-perfil-editable.html` |
| Campo en edicion (Telefono activo) | `html/02-campo-en-edicion.html` |
| Guardando cambio | `html/03-guardando.html` |
| Cambio guardado + snackbar | `html/04-cambio-guardado.html` |
