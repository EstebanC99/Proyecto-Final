# US-35 Ficha de salud — Componente: Formulario de ítem (bottom sheet reutilizable)

## Objetivo
Dar de alta o editar, de forma rápida y sin salir de la pantalla de Ficha de salud, un ítem de
alguna de las 3 listas (Antecedente, Alergia o Enfermedad), sin persistir nada contra el backend
hasta que se presione "Guardar ficha" en la pantalla principal.

## Decisión de diseño: un solo componente, 3 configuraciones
Se especifica **un único componente de presentación** (`ItemFormBottomSheet`), parametrizable por
tipo de ítem. Los 3 tipos comparten:
- El mismo chrome de bottom sheet (grabber, header con título + botón cerrar, footer con acción
  primaria y, en edición, acción destructiva de texto).
- El mismo comportamiento de guardado local (no hay llamada a red desde el sheet).
- El mismo patrón de validación (botón primario deshabilitado hasta que los campos obligatorios
  de ese tipo estén completos).

Lo único que cambia por tipo es el **set de campos** (tabla abajo) y el texto de los títulos/
placeholders. Para `dev-flutter` esto se traduce en un solo widget de presentación con una
configuración de campos por tipo (enum o lista de descriptores), no en 3 widgets distintos.

## Layout común (jerarquía de componentes)

```
Scrim (sobre la pantalla de Ficha de salud, atenuada)
BottomSheet
  Grabber
  SheetHeader
    Título ("Nuevo {tipo}" en alta / "Editar {tipo}" en edición)
    IconButton "close" (arriba a la derecha)
  Divider
  SheetBody (scrollable si el contenido no entra)
    Campo(s) según tipo — ver tabla de campos
  Divider
  SheetFooter (fijo dentro del sheet)
    PrimaryButton ("Agregar" en alta / "Guardar cambios" en edición)
    [solo en edición] TextButton destructivo "Eliminar {tipo}"
```

## Campos por tipo de ítem

### Antecedente
| Campo            | Tipo de control          | Obligatorio | Placeholder / ejemplo                                  |
|-------------------|----------------------------|:-----------:|-----------------------------------------------------------|
| Nombre            | `AppTextField`             | Sí          | "Ej. Hipertensión"                                        |
| Descripción       | Textarea (min-height 80px) | Sí          | "Ej. Diagnosticada en 2015, controlada con medicación"     |
| Vínculo familiar   | `AppTextField`             | Sí          | "Ej. madre, padre, propio"                                 |

### Alergia
| Campo            | Tipo de control          | Obligatorio | Placeholder / ejemplo                                  |
|-------------------|----------------------------|:-----------:|-----------------------------------------------------------|
| Nombre            | `AppTextField`             | Sí          | "Ej. Penicilina"                                           |
| Reacción          | Textarea (min-height 80px) | Sí          | "Ej. Erupción cutánea y dificultad para respirar"          |
| Medicamento       | `AppTextField`             | No          | "Ej. Amoxicilina (opcional)"                                |

### Enfermedad
| Campo            | Tipo de control          | Obligatorio | Placeholder / ejemplo                                  |
|-------------------|----------------------------|:-----------:|-----------------------------------------------------------|
| Nombre            | `AppTextField`             | Sí          | "Ej. Hipotiroidismo"                                        |
| Vigente           | Switch "Activa" / "Resuelta"| Sí (tiene valor por defecto) | Por defecto: **Activa** al crear un ítem nuevo             |
| Observación       | Textarea (min-height 56px) | No          | "Ej. Controlada con Levotiroxina 50mcg (opcional)"           |

> El switch "Vigente" siempre tiene un valor (no puede quedar "sin definir"), por eso no bloquea
> el botón primario aunque conceptualmente sea "obligatorio": simplemente parte en "Activa".

## Estados

### Alta (ítem nuevo)
- Todos los campos vacíos (excepto el switch "Vigente" en Enfermedad, que arranca en "Activa").
- Botón primario "Agregar" **deshabilitado** hasta completar los campos obligatorios de ese tipo.
- No se muestra el botón "Eliminar {tipo}" (no aplica: todavía no existe el ítem).

### Edición (ítem existente)
- Campos precargados con los valores actuales del ítem.
- Botón primario "Guardar cambios" habilitado desde el inicio (ya había datos válidos); se
  deshabilita si el usuario borra un campo obligatorio dejándolo vacío.
- Se muestra el botón de texto destructivo "Eliminar {tipo}" debajo del botón primario.

### Error de validación
- Si el usuario intenta guardar con un campo obligatorio vacío (caso borde, ej. quedó vacío tras
  editar): el campo correspondiente pasa a estado error (borde 2px `error`, texto de ayuda
  `labelSmall` "Este campo es obligatorio" debajo), igual que el `AppTextField` global. El botón
  primario permanece deshabilitado mientras subsista el error.

## Interacciones
- Tap `close` o swipe-down del sheet → cierra sin aplicar cambios (alta: descarta el ítem que se
  estaba creando; edición: descarta los cambios hechos, el ítem original permanece igual en la
  lista).
- Tap "Agregar" (alta, habilitado) → agrega el ítem a la lista local de la sección correspondiente
  en la pantalla de Ficha de salud, cierra el sheet, la nueva card aparece al final de la lista.
- Tap "Guardar cambios" (edición, habilitado) → actualiza el ítem en la lista local, cierra el
  sheet, la card refleja los nuevos valores en su posición actual.
- Tap "Eliminar {tipo}" (solo edición) → cierra el sheet, quita el ítem de la lista local y
  dispara el mismo `Snackbar` con "Deshacer" que el ícono de borrado directo en la card (ver
  `00-sistema-diseno.md` §3.7).
- Tap en el switch "Vigente" (solo Enfermedad) → alterna entre "Activa"/"Resuelta" con transición
  de color 150ms, sin efecto en los demás campos.

## Navegación de entrada/salida
- Entrada: desde la pantalla de Ficha de salud, tap "+ Agregar" de una sección (modo alta) o tap
  en una card de ítem existente (modo edición).
- Salida: tap `close`/swipe-down (sin guardar cambios en el sheet), tap "Agregar"/"Guardar
  cambios" (aplica cambios localmente) o tap "Eliminar {tipo}" (quita el ítem). En los 3 casos se
  vuelve a la pantalla de Ficha de salud, nunca se navega a otro lugar.
