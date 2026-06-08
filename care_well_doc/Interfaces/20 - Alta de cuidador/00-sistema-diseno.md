# US-20 — Sistema de diseño: Alta de cuidador en el equipo

## Contexto de la pantalla
Permite al responsable agregar un nuevo cuidador al equipo de cuidado de una persona a cargo. El flujo tiene dos pasos integrados en una sola pantalla: ingresar el email del cuidador y configurar los permisos iniciales (restrictivos por defecto). Al finalizar, se muestra una pantalla de exito.

## Diferencia clave con US-18 (permisos de responsable)
Los permisos por defecto del cuidador son mas restrictivos que los del responsable. El cuidador solo tiene acceso de lectura habilitado inicialmente; cualquier permiso de escritura o accion require activacion explicita por el responsable. Esto sigue el principio de minimo privilegio.

## Paleta aplicada
| Token             | Valor     | Uso en esta pantalla                                  |
|-------------------|-----------|-------------------------------------------------------|
| primary           | #1A8C82   | Toggle ON, botón "Agregar cuidador", foco en campo    |
| primaryContainer  | #C9EDE8   | (no usado en este flujo)                              |
| bg                | #F6F8F8   | Fondo de pantalla                                     |
| surface           | #FFFFFF   | Campo email, filas de permisos                        |
| surfaceVariant    | #EDF1F1   | Separadores                                           |
| textPrimary       | #16201F   | Labels, etiquetas de permisos                         |
| textSecondary     | #566060   | Subtítulo, helper text, nota bajo la lista            |
| outline           | #C5CECE   | Borde del campo, toggle OFF                           |
| success           | #2E9E5B   | Icono CHECK_CIRCLE en pantalla de exito               |
| successContainer  | #D8F0E1   | Círculo contenedor del icono en pantalla de exito     |

## Tipografía
| Uso                           | Tamaño | Peso   |
|-------------------------------|--------|--------|
| Subtítulo de pantalla         | 14px   | 400    |
| Label del campo               | 13px   | 500    |
| Valor en campo                | 16px   | 400    |
| Título sección permisos       | 14px   | 700    |
| Etiqueta de permiso           | 15px   | 500    |
| Nota bajo la lista            | 13px   | 400 italic|
| Titulo pantalla de exito      | 22px   | 700    |
| Cuerpo pantalla de exito      | 15px   | 400    |

## Componentes clave
- **AppTextField**: campo de email, height 56px, border 1px #C5CECE, radius 12px, icono EMAIL a la izquierda, helper text 12px.
- **PermissionRow**: identico a US-18.
- **ToggleSwitch**: identico a US-18 (ON = #1A8C82, OFF = #C5CECE).
- **NoteText**: texto italic 13px #566060, margin 12px 16px.
- **SuccessScreen**: pantalla de exito con icono en circulo, titulo, cuerpo y boton primario.
- **SuccessCircle**: circulo 112px bg #D8F0E1, icono CHECK_CIRCLE 80px color #2E9E5B centrado.

## Accesibilidad
- Helper text del campo es anunciable por lectores de pantalla.
- La nota bajo la lista tiene suficiente contraste (gris oscuro sobre fondo blanco).
- La pantalla de exito es anunciable como region live para lectores de pantalla.
