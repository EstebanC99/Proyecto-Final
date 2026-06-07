# 02 · Perfil editable — estado inicial de edicion

> Pantalla de US-07 en su estado de reposo dentro del flujo de edicion: todos los campos
> editables muestran el boton EDIT (lapiz). Tokens en `00-sistema-diseno.md`. HTML: `html/01-perfil-editable.html`.

## Proposito

Presentar el perfil del usuario con indicacion clara de que los campos son editables,
sin entrar en modo edicion hasta que el usuario lo solicite explicitamente (tap en el lapiz).

## Wireframe (ASCII)

```
+----------------------------------------------+  <- background (#F6F8F8)
| 9:41                                  5G 100% |   status bar (#16201F)
+----------------------------------------------+
|  <-  Mi Perfil                                |   AppBar surface (#FFF)
+----------------------------------------------+
|                                               |
|              [  M  ]                          |   avatar 80dp primaryContainer
|           Maria Garcia                        |   nombre 20px bold
|          [Responsable]                        |   chip rol primaryContainer
|                                               |
+----------------------------------------------+   border-bottom #C5CECE
|                                               |
|  [email]  Email                    [lapiz]   |   fila 64dp min
|           maria.garcia@ejemplo.com            |   EDIT 20dp primary a la derecha
|                                               |   tap target del lapiz: 48x48dp
+----------------------------------------------+
|  [tel]    Telefono                 [lapiz]   |
|           +54 9 11 1234-5678                  |
+----------------------------------------------+
|  [badge]  DNI                      [lapiz]   |
|           12.345.678                          |
+----------------------------------------------+
|  [person] Rol en el sistema                   |   SIN lapiz (no editable)
|           Responsable                         |
+----------------------------------------------+
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | Igual a US-06. |
| 2 | AppBar | Igual a US-06: ARROW_BACK + "Mi Perfil". Back descarta cambios no guardados. |
| 3 | Encabezado de perfil | Identico a US-06: avatar + nombre + chip de rol. Solo lectura. |
| 4 | Fila Email (editable) | Igual a US-06 mas boton EDIT 20dp color `primary #1A8C82` a la derecha. Tap target del boton: 48x48dp. |
| 5 | Fila Telefono (editable) | Idem fila Email. |
| 6 | Fila DNI (editable) | Idem fila Email. |
| 7 | Fila Rol (no editable) | Sin boton EDIT. Apariencia identica a US-06. |

## Interacciones y comportamiento

- **Tap en el lapiz de una fila:** activa el modo edicion inline de ese campo.
  Ver estado [03] (`html/02-campo-en-edicion.html`).
- **Tap en el cuerpo de la fila (fuera del lapiz):** sin efecto. No activa edicion.
  Esto evita activaciones accidentales.
- **AppBar ARROW_BACK:** vuelve a US-06. Si no hay cambios no guardados, el pop es
  limpio. Si habia un campo activo (edge case), se descarta primero.

## Navegacion

- **Entrada:** US-06 Mi Perfil (push desde el boton editar de la AppBar).
- **Salida:** tap EDIT de fila -> estado campo en edicion (mismo route).
  Back -> US-06 (pop).
