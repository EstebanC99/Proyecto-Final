# US-17 — Flujo y navegación (Alta de responsable en el equipo)

## Objetivo de la pantalla
Permitir al Responsable agregar a otro usuario como responsable del equipo de cuidado,
ingresando su email y confirmando los permisos que tendrá por defecto.

## Rol habilitado
Responsable (unico rol con permiso para agregar miembros al equipo).

## Entrada a esta pantalla
- Desde US-16 (Mi equipo): tap en botón ADD de AppBar o tap en FAB.
- Desde US-16 (estado vacío): tap en botón "Agregar miembro".

## Salida desde esta pantalla

### Formulario (01-formulario-alta.html)
| Accion del usuario                      | Destino                                         |
|-----------------------------------------|-------------------------------------------------|
| ARROW_BACK en AppBar                    | US-16 (Mi equipo, estado previo)                |
| Tap "Agregar responsable" (exito)       | 02-exito.html                                   |
| Tap "Agregar responsable" (email vacio) | Permanece: helper text de error visible          |
| Tap "Agregar responsable" (email inv.)  | Permanece: helper text "Email no válido"         |
| Tap "Agregar responsable" (no registrado) | Permanece: helper text "Usuario no encontrado" |

### Exito (02-exito.html)
| Accion del usuario                      | Destino                                         |
|-----------------------------------------|-------------------------------------------------|
| Tap "Volver al equipo"                  | US-16 (Mi equipo, ahora con el nuevo miembro)   |
| Gesto swipe-back (Android)              | US-16 (Mi equipo)                               |

## Estados del formulario

### Estado normal / inicial (01-formulario-alta.html)
- Campo email vacio con placeholder.
- Bloque de permisos con los 3 toggles ON.
- Boton primario habilitado (la validacion ocurre al pulsar).
- Helper text reservado pero invisible.

### Estado campo en foco (no maquetado, descripcion)
- Campo email con borde #1A8C82 de 2px.
- Teclado de tipo email abierto.

### Estado error campo vacio (no maquetado, descripcion)
- Campo email con borde #D14343 de 2px.
- Helper text: "Este campo es obligatorio" en #D14343.

### Estado error email invalido (no maquetado, descripcion)
- Campo email con borde #D14343 de 2px.
- Helper text: "Ingresá un email válido" en #D14343.

### Estado error usuario no encontrado (no maquetado, descripcion)
- Campo email con borde #D14343 de 2px.
- Helper text: "No encontramos un usuario con ese email" en #D14343.

### Estado cargando (no maquetado, descripcion)
- Boton primario con spinner circular blanco, texto oculto.
- Campos deshabilitados (opacity 0.6).

## Pantalla de exito (02-exito.html)
- Pantalla de confirmacion, sin AppBar (flujo completado, no hay "atras").
- Solo boton "Volver al equipo" → limpia el stack hasta US-16.

## Jerarquia visual (formulario)
1. Status bar
2. AppBar (titulo + back)
3. Subtitulo con nombre de persona
4. Campo email
5. Bloque de permisos (titulo + body + filas)
6. Boton primario

## Jerarquia visual (exito)
1. Status bar (dark, igual)
2. Contenido centrado vertical: circulo-icono → titulo → body → boton
