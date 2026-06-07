# US-28 Hábitos de vida — Pantalla: Registrar hábito

## Objetivo
Permitir al usuario registrar un hábito de forma rápida seleccionando la categoría y
describiendo libremente la actividad realizada.

## Layout (jerarquía de componentes)

```
StatusBar
AppBar (ARROW_BACK + "Nuevo hábito")
─ ScrollView vertical (padding 20px)
    SectionLabel "Categoría"
    ChipRow (Alimentación / Ejercicio / Sueño / Bienestar) — scroll horizontal
    SectionLabel "Descripción *"
    TextArea (ícono DESCRIPTION, min-height 80px, placeholder)
    SectionLabel "Fecha"
    DateField (ícono CALENDAR, pre-cargado hoy)
    SectionLabel "Hora (opcional)"
    TimeField (ícono ACCESS_TIME)
    Spacer
    PrimaryButton "Registrar" (bg #EA580C, 56dp, radius 16)
```

## Estados

### Estado inicial
Chip "Alimentación" pre-seleccionado. Fecha = hoy. Hora vacía. Descripción vacía.
Botón "Registrar" deshabilitado (opacity 0.5) hasta que haya descripción.

### Estado con descripción válida
Botón "Registrar" habilitado (opacity 1).

### Estado guardando
Botón pasa a loading (spinner blanco, texto "Guardando...").
Campos deshabilitados.

### Estado de error de guardado
Snackbar de error (bg `#D14343`) en la parte inferior: "No se pudo guardar. Intentá de nuevo."
Los campos vuelven a ser editables.

## Interacciones
- Tap en chip de categoría → selecciona y actualiza el placeholder de descripción con un
  ejemplo contextual.
- Tap en campo de fecha → abre date picker nativo del sistema.
- Tap en campo de hora → abre time picker nativo del sistema.
- Tap en "Registrar" con descripción vacía → nada (botón deshabilitado).
- Tap en "Registrar" con descripción → guarda, navega back con snackbar de éxito.
- Tap en ARROW_BACK → descarta el formulario y vuelve a la lista sin guardar.

## Navegación de entrada/salida
- Entrada: desde lista de hábitos (FAB) o desde detalle de categoría.
- Salida: ARROW_BACK → lista. Guardar exitoso → lista + snackbar.
