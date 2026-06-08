# US-24 — Pantalla: Evento guardado (éxito)

## Objetivo
Confirmar visualmente que el evento fue creado. Pantalla de cierre del flujo,
sin AppBar (el flujo se completó, no tiene sentido volver al formulario).

## Layout
```
StatusBar (28px)
SuccessContainer (centrado vertical)
  ├── Círculo 112px bg #E0F2FE
  │   └── CHECK_CIRCLE 80px color #0284C7
  ├── Título "Evento guardado" (22px bold)
  ├── Body con nombre del evento en bold + fecha y hora
  │   "Toma de medicación quedó agendado para el 5 de junio a las 09:00.
  │    El equipo recibirá una notificación."
  └── Botón "Ver agenda" (bg #0284C7)
```

## Interacciones
- "Ver agenda" → US-23 agenda lista (el nuevo evento ya aparece)
- Tap fuera o back del SO → US-23 agenda lista

## Anotaciones de diseño
1. Sin AppBar: el flujo se completó, no hay retorno al formulario
2. Círculo bg #E0F2FE (azul suave) con ícono azul módulo: coherencia cromática
3. Nombre del evento en bold: feedback específico confirma qué se guardó
4. Mención de notificación al equipo: refuerza el valor colaborativo del producto
