# US-30 Eventos de salud — Pantalla: Nuevo evento de salud

## Objetivo
Permitir al usuario registrar un evento de salud de la persona a cargo, seleccionando
el tipo, describiendo el evento y opcionalmente agregando observaciones.

## Layout (jerarquía de componentes)

```
StatusBar
AppBar (ARROW_BACK + "Nuevo evento de salud")
─ ScrollView vertical (padding 20px)
    SectionLabel "Tipo de evento *"
    ChipRow scrollable (Cita médica / Hospitalización / Medicación / Cirugía / Bienestar)
    SectionLabel "Descripción *"
    TextArea (ícono DESCRIPTION, min-height 80px)
    SectionLabel "Fecha *"
    DateField (ícono CALENDAR, pre-cargado hoy)
    SectionLabel "Observaciones"
    TextArea (ícono DESCRIPTION, min-height 60px, placeholder "Opcional")
    Spacer
    PrimaryButton "Registrar evento" (bg #E11D48, 56dp, radius 16)
```

## Estados

### Estado inicial
Chip "Cita médica" pre-seleccionado. Fecha = hoy. Descripción y observaciones vacías.
Botón "Registrar evento" deshabilitado.

### Estado con datos válidos
Descripción y fecha completos → botón habilitado.

### Estado guardando
Botón pasa a loading. Campos deshabilitados.

### Estado de error de guardado
Snackbar de error: "No se pudo registrar el evento. Intentá de nuevo."

## Interacciones
- Tap en chip de tipo → selecciona el tipo; el chip activo cambia a los colores del tipo.
- Tap en fecha → date picker nativo.
- Tap en "Registrar evento" sin descripción → botón deshabilitado, no hay acción.
- Tap en "Registrar evento" con datos válidos → guarda, vuelve a lista con snackbar de éxito.
- Tap en ARROW_BACK → descarta y vuelve a la lista sin guardar.

## Navegación de entrada/salida
- Entrada: lista de eventos (FAB).
- Salida: ARROW_BACK → lista. Guardar exitoso → lista + snackbar "Evento registrado".
