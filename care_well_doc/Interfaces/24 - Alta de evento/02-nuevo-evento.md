# US-24 — Pantalla: Formulario nuevo evento

## Objetivo
Permitir al usuario crear un evento en la agenda de la persona a cargo con fecha, hora,
descripción y opción de recordatorio al equipo. Flujo corto, mínima fricción.

## Layout (jerarquía de componentes)
```
StatusBar (28px)
AppBar (56px)
  ├── ARROW_BACK
  └── Título "Nuevo evento"
ScrollContent (padding 16px 24px 32px)
  ├── Field: Fecha *
  │   ├── Label externo "Fecha *"
  │   └── Input con prefijo CALENDAR + valor "05/06/2026"
  ├── Field: Hora *
  │   ├── Label externo "Hora *"
  │   └── Input con prefijo ACCESS_TIME + valor "09:00"
  ├── Field: Descripción *
  │   ├── Label externo "Descripción *"
  │   └── Textarea 80px con prefijo DESCRIPTION + placeholder
  ├── Fila de notificación (toggle ON)
  │   ├── NOTIFICATIONS + label + sublabel
  │   └── Toggle CSS ON (bg #0284C7)
  └── Botón "Guardar evento" (bg #0284C7)
```

## Interacciones
- Tap campo Fecha → date picker nativo del SO
- Tap campo Hora → time picker nativo del SO
- Textarea: foco con teclado, crece hasta 80px luego scrollea
- Toggle notificación: tap alterna ON/OFF
- "Guardar evento": valida todos los campos, muestra errores inline si hay, navega a éxito si OK

## Anotaciones de diseño
1. Notificaciones locales MVP: sin integración Google Calendar
2. Campos con asterisco * son requeridos: label indica obligatoriedad
3. Toggle ON por defecto: fomenta uso de recordatorios (valor diferencial del producto)
4. Validación al submit, no al blur: menos interrupciones mientras se completa
