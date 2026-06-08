# US-14 Modificacion de persona a cargo — Estado: Campo en edicion

> Estado de la pantalla de perfil cuando el usuario activo ha tocado el lapiz EDIT
> de un campo. Muestra ese campo en modo InlineEditingRow con input en foco teal
> y botones CHECK (guardar) y CLOSE (cancelar).

---

## Objetivo

Permitir al usuario editar un dato especifico de la persona a cargo de forma rapida,
sin salir de la pantalla de perfil. La edicion es in-place: el campo activo se expande
visualmente dentro de la lista de datos, sin modales ni pantallas nuevas.

---

## Descripcion del estado

El usuario ha tocado EDIT en la fila "Email". La fila se transforma:
- Antes: fila de lectura con label "Email", valor "alicia@ejemplo.com" y boton EDIT
- Despues: fila de edicion con icono EMAIL, input inline en foco teal con el valor
  precargado, cursor visible, botones CLOSE y CHECK a la derecha

Los demas campos permanecen en modo lectura (con sus lapices disponibles).

---

## Layout del campo en edicion (InlineEditingRow)

```
┌───────────────────────────────────────────┐
│[EMAIL]  [alicia@ejemplo.com|]  [CLOSE][CHECK]│  h: 80dp aprox
└───────────────────────────────────────────┘
```

### Especificacion InlineEditingRow

| Propiedad | Valor |
|---|---|
| Padding | 12px 24px |
| Altura minima | 80dp (expandida respecto a 64dp de lectura) |
| Background | `#FFFFFF`, borde inferior `#C5CECE` |
| Icono | EMAIL 20dp, color `#566060`, flex-shrink 0 |
| InlineInput | ver abajo |
| Botones accion | CLOSE + CHECK, 48x48dp cada uno |

### Especificacion InlineInput

| Propiedad | Valor |
|---|---|
| Flex | 1 (ocupa espacio disponible entre icono y botones) |
| Altura | 56dp |
| Border | 2dp solid `#1A8C82` |
| Border-radius | 12dp |
| Background | `#FFFFFF` |
| Padding | 0 16dp |
| Font | 16px 400 `#16201F` |
| Valor precargado | valor actual del campo |
| Cursor | barra 2dp `#1A8C82`, animacion blink |

### Boton CLOSE (cancelar)
- Tap target: 48x48dp
- Icono CLOSE 20dp, color `#566060`
- Descarta el cambio y restaura el valor original
- La fila vuelve a modo lectura

### Boton CHECK (guardar)
- Tap target: 48x48dp
- Icono CHECK 20dp, color `#1A8C82`
- Guarda el valor (llama al repositorio)
- La fila vuelve a modo lectura con el nuevo valor
- Se muestra snackbar "Datos de Alicia actualizados"

---

## Validaciones

| Campo | Validacion | Error |
|---|---|---|
| Nombre completo | No vacio, min. 2 caracteres | Borde `#D14343` + mensaje bajo el input |
| Email | Formato valido o vacio | Borde `#D14343` + mensaje "Email invalido" |

Si la validacion falla al pulsar CHECK, el input muestra borde `#D14343` y un mensaje
de error inline debajo del input (no se cierra la fila de edicion).

---

## Interacciones

- **Tap CHECK con valor valido:** guarda, colapsa fila, snackbar de exito.
- **Tap CHECK con valor invalido:** muestra error inline, mantiene fila abierta.
- **Tap CLOSE:** descarta, colapsa fila, restaura valor original. Sin confirmacion.
- **Tap lapiz de otro campo:** cierra campo actual sin guardar, abre el nuevo. Sin confirmacion.
- **Tap ARROW_BACK con campo activo:** cierra campo sin guardar, navega a US-13. Sin dialogo.
- **Teclado virtual:** el layout se ajusta (scroll) para que el input quede visible sobre el teclado.
