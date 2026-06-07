# US-19 — Pantalla: Confirmar baja de responsable (dialog)

## Objetivo
Solicitar confirmacion explicita antes de quitar a un responsable del equipo, informando las consecuencias y aclarando que la accion es reversible, para reducir fricciones y errores.

## Layout (jerarquía de componentes)
```
[Pantalla de fondo — permisos de Carlos, atenuada por scrim]

Scrim (position:absolute, inset:0, bg rgba(0,0,0,0.4))

Dialog M3 (centrado verticalmente en la mitad superior, margin 24px)
  ├─ PERSON_REMOVE 48px (color #D14343, centrado, margin-bottom 16px)
  ├─ Titulo "¿Quitar a Carlos del equipo?" (18px bold, centrado)
  ├─ Cuerpo (14px #566060, centrado, margin-top 8px)
  │    "Carlos Pérez perderá el acceso a los datos de Alicia y ya no
  │     podrá gestionar su cuidado. Esta acción se puede revertir
  │     agregándolo nuevamente."
  ├─ [Boton] "Quitar del equipo" (bg #D14343, blanco, radius 12px, height 44px, full-width)
  └─ [Boton] "Cancelar" (border 1.5px #C5CECE, neutro, radius 12px, height 44px, full-width, mt 10px)
```

## Especificación del Dialog
- Background: #FFFFFF
- Border-radius: 28px
- Padding: 24px
- Margin: 24px (desde los bordes del viewport)
- Box-shadow: 0 8px 32px rgba(0,0,0,0.18)
- Posicion vertical: centrado en la pantalla (transform: translateY(-10%) para visualmente mas arriba del centro)
- Ancho: 390 - 48px = 342px

## Especificación del Boton destructivo
- Background: #D14343
- Color: #FFFFFF
- Border-radius: 12px
- Height: 44px
- Font-size: 15px; font-weight: 700
- Width: 100% dentro del dialog

## Especificación del Boton cancelar
- Background: transparent
- Border: 1.5px solid #C5CECE
- Color: #16201F
- Border-radius: 12px
- Height: 44px
- Font-size: 15px; font-weight: 600
- Width: 100% dentro del dialog
- Margin-top: 10px

## Interacciones
- Tap "Quitar del equipo": boton pasa a loading (spinner blanco 18px), ambos botones se deshabilitan, tap en scrim bloqueado.
- Tap "Cancelar": dialog se cierra con animacion de scale-down + fade-out.
- Tap en scrim (fuera del dialog): cierra el dialog (solo si no esta en loading).
- Swipe hacia abajo sobre el dialog: cierra el dialog (comportamiento de bottom sheet alternativo si se implementa como tal).

## Jerarquía de comunicacion
1. Icono rojo: senala el nivel de alerta de la accion.
2. Titulo interrogativo: hace consciente al usuario de lo que esta a punto de hacer.
3. Cuerpo: explica consecuencias Y tranquiliza ("se puede revertir").
4. Boton destructivo primero: facilita la accion intencional.
5. Cancelar debajo: accesible pero secundario.
