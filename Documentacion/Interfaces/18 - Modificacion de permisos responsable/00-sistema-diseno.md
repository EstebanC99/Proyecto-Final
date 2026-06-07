# US-18 — Sistema de diseño: Modificación de permisos de responsable

## Contexto de la pantalla
Permite al responsable principal ajustar los permisos granulares de otro responsable del equipo de cuidado sobre una persona a cargo concreta. Los cambios se aplican vía API en tiempo real al guardar.

## Paleta aplicada
| Token           | Valor     | Uso en esta pantalla                        |
|-----------------|-----------|---------------------------------------------|
| primary         | #1A8C82   | Toggle ON, botón "Guardar cambios"          |
| primaryContainer| #C9EDE8   | Avatar del miembro                          |
| bg              | #F6F8F8   | Fondo de pantalla                           |
| surface         | #FFFFFF   | Header de miembro, filas de permisos        |
| surfaceVariant  | #EDF1F1   | Separadores, fondo AppBar                   |
| textPrimary     | #16201F   | Nombre, etiquetas de permisos               |
| textSecondary   | #566060   | Email, subtítulos                           |
| outline         | #C5CECE   | Bordes, toggle OFF                          |
| success         | #2E9E5B   | Icono check en snackbar de confirmación     |
| snackbar bg     | #323232   | Fondo del snackbar                          |

## Tipografía
| Uso                    | Tamaño | Peso   |
|------------------------|--------|--------|
| Nombre del miembro     | 16px   | 700    |
| Título sección permisos| 14px   | 700    |
| Etiqueta de permiso    | 15px   | 500    |
| Email                  | 13px   | 400    |
| Badge "Responsable"    | 12px   | 600    |
| Snackbar               | 14px   | 500    |

## Componentes clave
- **MemberHeader**: card con avatar inicial, nombre, badge de rol y email. Altura aprox. 88px. Fondo surface, border-bottom surfaceVariant.
- **PermissionRow**: fila 56px con etiqueta y toggle. Tap en toda la fila invierte el estado.
- **ToggleSwitch**: 40x22px. ON = #1A8C82, thumb derecha. OFF = #C5CECE, thumb izquierda.
- **PrimaryButton**: altura 56px, radius 16px, bg #1A8C82, texto blanco 16px bold. Fijo al fondo, padding horizontal 16px, margin-bottom 24px.
- **Snackbar**: posicionado 16px sobre el botón, bg #323232, texto blanco, icono CHECK #2E9E5B a la izquierda.

## Accesibilidad
- Toda la fila de permiso es tappable (min 56px).
- Contraste texto/fondo supera 4.5:1 en todos los casos.
- El badge de rol usa color + texto (no solo color).
- El snackbar es anunciable por lectores de pantalla (role="status").
