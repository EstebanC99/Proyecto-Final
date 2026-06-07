# 03 · Campo en edicion — estado de edicion inline

> Estado de la pantalla US-07 cuando el usuario toco el lapiz de la fila "Telefono".
> Tokens en `00-sistema-diseno.md`. HTML: `html/02-campo-en-edicion.html`.

## Proposito

Permitir que el usuario modifique el valor de un campo especifico de su perfil de forma
inline, sin salir de la pantalla ni reemplazar el layout completo por un formulario.

## Wireframe (ASCII)

```
+----------------------------------------------+
| 9:41                                  5G 100% |
+----------------------------------------------+
|  <-  Mi Perfil                                |
+----------------------------------------------+
|              [  M  ]                          |
|           Maria Garcia                        |
|          [Responsable]                        |
+----------------------------------------------+
|  [email]  Email                    [lapiz]   |
|           maria.garcia@ejemplo.com            |
+----------------------------------------------+
|  [tel]  [+54 9 11 1234-5678      ] [X] [v]  |  <- CAMPO ACTIVO
|           input 56dp, borde 2dp primary       |     X=CLOSE textSecondary
|                                               |     v=CHECK primary
+----------------------------------------------+
|  [badge]  DNI                      [lapiz]   |
|           12.345.678                          |
+----------------------------------------------+
|  [person] Rol en el sistema                   |
|           Responsable                         |
+----------------------------------------------+
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Fila Telefono activa | La fila se expande verticalmente para alojar el input de 56dp mas el padding. El ancho del input ocupa el espacio disponible entre el icono y los botones de accion. |
| 2 | Input inline | Altura 56dp. Fondo `surface #FFFFFF`. Borde 2dp `primary #1A8C82`. Radius 12px. Padding horizontal 16px. Valor precargado: "+54 9 11 1234-5678". Fuente 16px `textPrimary`. Teclado `phone`. |
| 3 | Boton CLOSE | CLOSE SVG 20dp, color `textSecondary #566060`. Tap target 48x48dp. Cancela la edicion y descarta el cambio. El campo vuelve a su valor original. |
| 4 | Boton CHECK | CHECK SVG 20dp, color `primary #1A8C82`. Tap target 48x48dp. Valida y envia el cambio. |
| 5 | Filas restantes | Email y DNI mantienen su lapiz. Rol permanece sin lapiz. Comportamiento: si el usuario toca el lapiz de otra fila, la fila activa se cancela automaticamente. |

## Interacciones y comportamiento

- **CHECK (confirmar):** valida el valor. Si es valido, avanza a estado Guardando [04].
  Si no es valido, muestra un mensaje de error inline bajo el input (borde cambia a
  `error #D14343`) y no envia el request.
- **CLOSE (cancelar):** colapsa el input, restaura el valor original en la fila,
  vuelve al estado Perfil editable [02].
- **Tap en lapiz de otra fila:** cancela el campo activo (como CLOSE silencioso) y
  activa la nueva fila en modo edicion.
- **Back del sistema:** equivale a CLOSE; descarta el cambio no guardado y colapsa el campo.
  Si no habia campo activo, pop hacia US-06.
- **Teclado:** el input recibe foco inmediatamente al activarse. En Android, el layout
  no se redimensiona (se usa `resizeToAvoidBottomInset: false` o `Scaffold`
  con scroll) para evitar saltos visuales.

## Navegacion

- **Desde:** Perfil editable [02], tap en EDIT de la fila Telefono.
- **Hacia:** Guardando [03] (CHECK valido) · Perfil editable [02] (CLOSE o back).
