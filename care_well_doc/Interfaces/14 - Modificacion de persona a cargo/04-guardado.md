# US-14 Modificacion de persona a cargo — Estado: Guardado exitoso

> Estado de la pantalla tras confirmar la edicion de un campo (tap en CHECK con valor valido).
> La pantalla vuelve al modo de lectura normal y un Snackbar confirma el cambio al usuario.

---

## Objetivo

Confirmar de forma visible pero no intrusiva que el dato fue guardado correctamente.
El usuario debe poder continuar navegando el perfil o salir sin necesidad de descartar
ningun modal o dialogo.

---

## Descripcion del estado

La fila que estaba en edicion colapsa de vuelta al modo lectura, mostrando el nuevo
valor ("alicia.nueva@ejemplo.com" en el ejemplo). Un Snackbar aparece en la zona
inferior de la pantalla con la confirmacion.

---

## Especificacion del Snackbar de exito

| Propiedad | Valor |
|---|---|
| Background | `#323232` |
| Texto | "Datos de Alicia actualizados" · 14px 500 `#FFFFFF` |
| Icono CHECK | 20dp, color `#2E9E5B` (success), a la izquierda del texto |
| Border-radius | 12dp |
| Padding | 12px 16px |
| Margin | 16px desde los bordes laterales, 24dp desde el fondo |
| Duracion | 3 s, cierre automatico con fade-out 200 ms |
| Posicion | Bottom, sobre el contenido (no desplaza el layout) |
| Ancho | 100% del area - 32dp de margin (stretch) |

El Snackbar no tiene boton de accion (no hay "Deshacer" para esta operacion: el cambio
ya fue persistido. Una futura iteracion podria agregar "Deshacer" con ventana de 3 s).

---

## Layout del estado

```
┌─────────────────────────────┐
│ StatusBar                   │
├─────────────────────────────┤
│ AppBar: [←] Alicia Rodriguez [⋮]│
├─────────────────────────────┤
│ ProfileHeader (sin cambios) │
├─────────────────────────────┤
│ DataRow — Nombre completo   [EDIT]│
│ DataRow — DNI (sin EDIT)    │
│ DataRow — Fecha de nac.     │
│ DataRow — Email (nuevo valor)[EDIT]│  ← valor actualizado
│                             │
└─────────────────────────────┘
                                    ┌─────────────────────────┐
                                    │[✓] Datos de Alicia      │  ← Snackbar
                                    │    actualizados         │
                                    └─────────────────────────┘
```

---

## Interacciones

- El Snackbar se cierra solo despues de 3 s. No requiere interaccion del usuario.
- La pantalla es completamente interactiva mientras el Snackbar esta visible.
- El usuario puede tocar otros botones EDIT para iniciar una nueva edicion.
- El usuario puede navegar atras (ARROW_BACK) hacia US-13.
