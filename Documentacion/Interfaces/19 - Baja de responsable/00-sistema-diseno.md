# US-19 — Sistema de diseño: Baja de responsable del equipo

## Contexto de la pantalla
Permite al responsable principal quitar a otro responsable del equipo de cuidado. Por tratarse de una acción que revoca acceso inmediatamente, requiere confirmación explícita mediante un dialog M3. La acción es reversible (el miembro puede ser re-invitado).

## Paleta aplicada
| Token            | Valor     | Uso en esta pantalla                              |
|------------------|-----------|---------------------------------------------------|
| primary          | #1A8C82   | (presente en la pantalla de fondo, atenuada)      |
| error            | #D14343   | Icono PERSON_REMOVE, botón "Quitar del equipo"    |
| errorContainer   | #FBE3E3   | (no utilizado directamente aqui)                  |
| bg               | #F6F8F8   | Fondo de pantalla base                            |
| surface          | #FFFFFF   | Fondo del dialog                                  |
| textPrimary      | #16201F   | Titulo del dialog                                 |
| textSecondary    | #566060   | Cuerpo del dialog                                 |
| outline          | #C5CECE   | Borde del boton "Cancelar"                        |
| overlay          | rgba(0,0,0,0.4) | Scrim sobre la pantalla de fondo           |

## Tipografía
| Uso                     | Tamaño | Peso   |
|-------------------------|--------|--------|
| Titulo del dialog       | 18px   | 700    |
| Cuerpo del dialog       | 14px   | 400    |
| Boton primario          | 15px   | 700    |
| Boton cancelar          | 15px   | 600    |

## Componentes clave
- **Overlay / Scrim**: `position:absolute; inset:0; background:rgba(0,0,0,0.4)`. La pantalla de fondo (permisos) se ve atenuada pero recognoscible, reforzando el contexto.
- **Dialog M3**: fondo #FFF, border-radius 28px, padding 24px, margin 24px auto. Elevacion sutil (box-shadow). No ocupa toda la pantalla.
- **PERSON_REMOVE 48px** centrado en la parte superior del dialog, color #D14343.
- **DestructiveButton**: bg #D14343, color #FFF, radius 12px, height 44px, texto 15px 700.
- **OutlineButton "Cancelar"**: border 1.5px #C5CECE, bg transparente, radius 12px, height 44px, texto #16201F 600.

## Principio de diseno: confirmacion de baja
- Se usa dialog y no pantalla completa porque la accion es reversible y de contexto puntual.
- No se pide confirmacion de texto (escribir el nombre) ya que seria friccion excesiva para usuarios menos tecnicos.
- El cuerpo del dialog informa explicitamente que la accion es reversible, reduciendo ansiedad.
- El boton destructivo va primero (mas visible), pero el "Cancelar" tiene igual tamano para facilitar el arrepentimiento.

## Accesibilidad
- El dialog tiene `role="dialog"` y `aria-modal="true"`.
- El foco se atrapa dentro del dialog mientras esta visible.
- El icono PERSON_REMOVE es decorativo (aria-hidden); el texto comunica la accion.
