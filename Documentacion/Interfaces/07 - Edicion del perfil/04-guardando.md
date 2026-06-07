# 04 · Guardando — estado de carga durante el guardado

> Estado transitorio mientras se envia el cambio al servidor. Se muestra tras tap en CHECK.
> Tokens en `00-sistema-diseno.md`. HTML: `html/03-guardando.html`.

## Proposito

Comunicar al usuario que su cambio esta siendo procesado, bloqueando interacciones
adicionales sobre el campo para evitar doble envio o estados inconsistentes.

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
|  [tel]  [+54 9 11 1234-5678      ] [spinner] |  <- GUARDANDO
|           input disabled, bg #EDF1F1          |     spinner 16dp
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
| 1 | Input disabled | Mismo layout que estado de edicion [03]. Fondo cambia a `surfaceVariant #EDF1F1`. Borde 1dp `outline #C5CECE` (pierde el borde focus primary de 2dp). Texto 16px `disabled #9AA5A5`. No responde a tap ni teclado. |
| 2 | Spinner | 16x16dp. Borde 2dp `outline #C5CECE`, borde superior `primary #1A8C82`. Border-radius 50%. Animacion de rotacion continua (en Flutter: `SizedBox` con `CircularProgressIndicator` de `strokeWidth: 2`, `color: primary`). Reemplaza los botones CLOSE y CHECK. |
| 3 | Boton AppBar ARROW_BACK | Deshabilitado o ignorado durante el guardado para evitar salir con un request pendiente. En Flutter: `WillPopScope` o `PopScope` que bloquea el back mientras `isLoading == true`. |
| 4 | Lapices de otras filas | Se mantienen visibles pero deshabilitados (opacidad 0.4) para indicar que la pantalla esta parcialmente bloqueada. |

## Interacciones y comportamiento

- **Sin interaccion posible en el campo activo.** El input esta disabled; el teclado
  se cierra automaticamente si estaba abierto.
- **Duracion esperada:** menos de 2 s en condiciones normales. Si supera los 10 s
  (timeout de red), se cancela el request, el campo vuelve al estado de edicion [03]
  y se muestra un mensaje de error inline ("No se pudo guardar. Intenta de nuevo.").
- **No hay boton de cancelar durante el guardado.** La operacion es corta; agregar un
  "Cancelar" genera complejidad de rollback innecesaria para este flujo.

## Navegacion

- **Desde:** Campo en edicion [03], tap CHECK con valor valido.
- **Hacia:** Cambio guardado [04] (respuesta 200) · Campo en edicion [03] con error (respuesta de error).
