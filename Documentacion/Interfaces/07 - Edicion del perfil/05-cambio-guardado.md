# 05 · Cambio guardado — confirmacion visual del exito

> Estado final del flujo de edicion tras una respuesta exitosa del servidor.
> Tokens en `00-sistema-diseno.md`. HTML: `html/04-cambio-guardado.html`.

## Proposito

Confirmar al usuario que su cambio fue aplicado correctamente, mostrando el nuevo valor
en la fila y una notificacion contextual no intrusiva (snackbar).

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
|  [tel]    Telefono                 [lapiz]   |  <- NUEVO VALOR
|           +54 9 11 9999-8888                  |     (valor actualizado)
+----------------------------------------------+
|  [badge]  DNI                      [lapiz]   |
|           12.345.678                          |
+----------------------------------------------+
|  [person] Rol en el sistema                   |
|           Responsable                         |
+----------------------------------------------+

  +------------------------------------------+
  |  [v]  Telefono actualizado correctamente. |  <- SNACKBAR bottom:24px
  +------------------------------------------+
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Fila Telefono | Vuelve al estado de reposo (solo lectura) con el nuevo valor. El boton EDIT (lapiz) reaparece. El campo no tiene ningun indicador de "recien actualizado" mas alla del snackbar. |
| 2 | Resto del perfil | Identico al estado Perfil editable [02]. Todos los lapices habilitados. |
| 3 | Snackbar | Posicion: `position: absolute; bottom: 24px; left: 24px; right: 24px`. Fondo `#323232`. Texto "Telefono actualizado correctamente." 14px `#FFFFFF`. Icono CHECK 20dp color `success #2E9E5B` a la izquierda. Border-radius 8px. Padding 14px vertical · 16px horizontal. |
| 4 | Duracion snackbar | 3 s, luego fade-out 200 ms. Sin boton de accion (el mensaje es solo informativo). |

## Interacciones y comportamiento

- **Snackbar:** no bloquea interacciones. El usuario puede seguir editando otros campos
  mientras el snackbar esta visible.
- **El snackbar no tiene boton "Deshacer".** Revertir un cambio de perfil es una
  accion infrecuente y de bajo impacto; agregar "Deshacer" aumentaria la complejidad
  de la pantalla. El usuario puede simplemente editar el campo de nuevo.
- **Back durante snackbar:** el snackbar desaparece (junto con la pantalla). El valor
  ya esta guardado en el servidor; no hay perdida de datos.
- **Nuevo campo en edicion durante snackbar:** si el usuario toca otro lapiz antes de
  que el snackbar desaparezca, el snackbar se descarta inmediatamente y el nuevo campo
  entra en modo edicion.

## Navegacion

- **Desde:** Guardando [04], respuesta 200 del servidor.
- **Hacia:** Perfil editable [02] (tras auto-dismiss del snackbar, la pantalla queda en
  estado editable) · US-06 Mi Perfil (back).
