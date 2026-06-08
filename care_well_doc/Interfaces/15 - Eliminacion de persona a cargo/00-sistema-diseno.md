# US-15 Eliminacion de persona a cargo — Sistema de diseno

> Este flujo hereda en su totalidad el sistema de diseno definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Aca solo se documentan las decisiones especificas del flujo de eliminacion de persona.
>
> El patron de dialog de confirmacion es similar al implementado en US-11
> (Eliminacion de cuenta), con la diferencia clave de que NO incluye un campo
> de texto de confirmacion explicita: la eliminacion de una persona a cargo es
> grave pero reversible en escenarios reales (se puede volver a registrar), a
> diferencia de la eliminacion de cuenta que es irreversible total.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Warning | `warning #E0A100` · `warningContainer #FFF3CD` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Radios | dialog `radiusXl 28` · botones `radiusLg 12` |
| Alturas | boton 44 dp (dialog, compacto) · objetivo tactil min. 44 dp |
| Tipografia | familia `Inter` (fallback `'Segoe UI', Arial, sans-serif`) |

---

## 2. Componente especifico: ConfirmDeletePersonDialog

Dialog M3 de confirmacion de eliminacion. Especificaciones:

| Propiedad | Valor |
|---|---|
| Fondo | `surface #FFFFFF` |
| Border-radius | 28 dp (`radiusXl`) |
| Margin horizontal | 24 dp |
| Padding interior | 24 dp |
| Icono superior | WARNING 24dp, color `#E0A100`, centrado |
| Titulo | 18 px, 700, `#16201F`, centrado |
| Cuerpo | 14 px, 400, `#566060`, alineado izquierda, interlineado 1.5 |
| Boton "Eliminar" | altura 44dp, bg `#D14343`, texto `#FFFFFF` 15px 700, radius 12dp, width 100% |
| Boton "Cancelar" | altura 44dp, borde 1px `#C5CECE`, texto `#16201F` 15px 500, radius 12dp, width 100% |
| Separacion entre botones | 8dp |
| Scrim (overlay) | `rgba(0, 0, 0, 0.4)` sobre la pantalla de perfil |

---

## 3. Comparacion con DestructiveConfirmDialog de US-11

| Aspecto | US-11 (Eliminar cuenta) | US-15 (Eliminar persona) |
|---|---|---|
| Impacto | Irreversible total (cuenta + datos + membresias) | Alto (datos de la persona) |
| Friccion intencional | Campo de texto "DELETE" obligatorio | Sin campo de texto |
| Boton destructivo | Disabled hasta escribir "DELETE" | Siempre habilitado |
| Icono | WARNING amber | WARNING amber (mismo) |
| Altura boton | 56 dp | 44 dp (mas compacto) |
| Racional | Perdida total; cumple Ley 25.326 | Grave pero sin la irreversibilidad maxima de eliminar cuenta |

---

## 4. Decisiones especificas de US-15

1. **Dialog sin campo de texto de confirmacion.** La eliminacion de una persona a cargo
   es una accion destructiva pero de menor impacto sistemico que eliminar una cuenta.
   En contexto de cuidado, la persona puede volver a registrarse. Agregar el campo
   "DELETE" generaria friccion excesiva para el usuario cuidador que esta apurado.
   El texto del cuerpo describe las consecuencias de forma clara y eso es suficiente.

2. **El dialog se muestra sobre el perfil de la persona (US-14), no sobre la lista.**
   El usuario ya esta en el contexto de la persona especifica; ver su perfil atenuado
   detras del dialog refuerza "a quien se va a eliminar" sin posibilidad de confusion.

3. **Texto del cuerpo especifico y con consecuencias.** El cuerpo menciona el nombre de
   la persona y las consecuencias concretas: datos eliminados y acceso al equipo de
   cuidado. No es un mensaje generico.

4. **Boton "Cancelar" visible y prominente.** Ocupa el mismo ancho que "Eliminar" y
   esta posicionado debajo de este, haciendo que la salida sea tan facil como confirmar.

5. **Solo Responsable con permiso puede eliminar.** El menu contextual MORE_VERT
   que lleva a este dialog solo aparece para Responsables autorizados. Un Cuidador
   no tiene acceso a esta opcion.

6. **Tras la eliminacion exitosa:** se navega a US-13 (listado) con un Snackbar
   "Alicia fue eliminada del sistema". Si la lista queda vacia, se muestra el estado
   vacio de US-13.

---

## 5. Mapa de estados del dialog

| Estado | Descripcion |
|---|---|
| Inicial | Dialog visible, boton "Eliminar" habilitado, boton "Cancelar" disponible |
| Eliminando | Boton "Eliminar" muestra spinner, boton "Cancelar" disabled |
| Error de red | Dialog persiste, mensaje de error inline bajo los botones, reintentar |
| Exito | Dialog se cierra, navega a US-13, Snackbar de confirmacion |
