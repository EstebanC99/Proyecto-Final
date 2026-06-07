# US-16 — Flujo y navegación (Visualización del equipo de cuidado)

## Objetivo de la pantalla
Permitir al Responsable ver el equipo de cuidado completo (responsables y cuidadores) asociado
a una persona bajo cuidado, con acceso rápido a la gestión de cada miembro y la opción de
agregar nuevos integrantes.

## Rol habilitado
Responsable (acceso completo). El Cuidador puede ver el equipo pero sin opciones de gestión.

## Entrada a esta pantalla
- Desde el Menú principal (home) a través del acceso "Mi equipo".
- Desde cualquier pantalla que redirija al módulo de equipo (por ejemplo, notificaciones de
  cambios en el equipo).

## Salida desde esta pantalla
| Acción del usuario                        | Destino                                  |
|-------------------------------------------|------------------------------------------|
| ARROW_BACK en AppBar                      | Menú principal (Home)                    |
| Tap botón ADD en AppBar                   | US-17 Formulario alta de responsable     |
| Tap FAB ADD (bottom-right)                | US-17 Formulario alta de responsable     |
| Tap en un MemberCard (Responsable)        | US-18 Gestión de permisos de responsable |
| Tap en un MemberCard (Cuidador)           | US-21 Gestión de permisos de cuidador    |
| Botón "Agregar miembro" (estado vacío)    | US-17 Formulario alta de responsable     |

## Estados de la pantalla

### Estado con datos (01-equipo.html)
- Chip de contexto muestra la persona actualmente seleccionada.
- Sección "RESPONSABLES" con cards de todos los responsables.
- Sección "CUIDADORES" con cards de todos los cuidadores.
- El usuario autenticado aparece con la etiqueta "(Vos)" junto a su nombre.
- FAB visible en bottom-right.

### Estado vacío (02-equipo-vacio.html)
- Sin secciones, sin cards.
- Ilustración + texto motivacional + botón de acción primario.
- FAB no visible en estado vacío (el botón primario cumple ese rol).

### Estado de carga (no maquetado, descripción)
- Skeleton loaders en lugar de las cards (3 rectangulos de 72px con shimmer).
- Chip de contexto visible pero con "---" como nombre.
- FAB oculto durante la carga.

### Estado de error (no maquetado, descripción)
- Mensaje inline: icono de advertencia + "No pudimos cargar el equipo. Intentá de nuevo."
- Botón secundario "Reintentar".

## Selector de contexto (persona bajo cuidado)
Si el usuario responsable tiene más de una persona a cargo, el chip de contexto es tappable
y abre un bottom sheet con la lista de personas para cambiar el contexto. En el MVP con una
sola persona, el chip es solo informativo (no tappable, cursor default).

## Jerarquía visual
1. Status bar
2. AppBar (título "Mi equipo" + acciones)
3. Chip de contexto (persona bajo cuidado)
4. Sección RESPONSABLES → lista de MemberCards
5. Sección CUIDADORES → lista de MemberCards
6. FAB flotante (sobre el contenido)
