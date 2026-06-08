# US-22 — Especificacion: Dialog de confirmacion de baja

## Objetivo de pantalla
Solicitar confirmacion explicita al Responsable antes de quitar a la Cuidadora del equipo,
informando las consecuencias y la reversibilidad de la accion.

## Layout (jerarquia de componentes)

```
[Pantalla de fondo atenuada — permisos de Sandra bajo scrim rgba(0,0,0,0.4)]
  StatusBar
  AppBar "Permisos de Sandra"
  MemberHeader (Sandra Ruiz, badge Cuidadora salmon)
  SectionTitle "Permisos sobre Alicia Rodriguez"
  PermissionsList (6 filas con estado actual)

[Dialog M3 — centrado sobre el scrim]
  Column (bg #FFF, border-radius 28px, padding 24px, margin 24px)
    - PERSON_REMOVE 48px, color #D14343, centrado
    - "¿Quitar a Sandra del equipo?" 18px/700 #16201F, centrado
    - Texto cuerpo 14px #566060, centrado, line-height 1.55
    - Boton "Quitar del equipo" bg #D14343 #FFF 44px radius 12px
    - Boton "Cancelar" borde #C5CECE #16201F 44px radius 12px, margin-top 10px
```

## Contenido del dialog

### Titulo
"¿Quitar a Sandra del equipo?"

### Cuerpo
"Sandra Ruiz perdera el acceso a los datos de Alicia y ya no podra realizar
tareas de cuidado. Esta accion se puede revertir agregandola nuevamente."

### Botones
- Primario destructivo: "Quitar del equipo" — bg #D14343, texto #FFF
- Secundario: "Cancelar" — borde 1.5px #C5CECE, texto #16201F

## Accesibilidad
- Dialog con role="dialog" aria-modal="true" aria-labelledby="dialog-title"
- Focus inicial en el boton "Cancelar" (prevencion de accion accidental)
- Icono PERSON_REMOVE con aria-hidden="true"
- Texto del cuerpo describe consecuencias y reversibilidad

## Interacciones
- Tap "Quitar del equipo": ejecuta la baja, muestra loading en boton, navega a lista Mi equipo
- Tap "Cancelar": cierra dialog, regresa a pantalla de permisos
- Tap en scrim (fuera del dialog): equivale a Cancelar
- Back gesture del sistema: equivale a Cancelar

## Diferencias vs US-19 (baja de Responsable)
- Fondo: pantalla de permisos de Sandra (cuidadora, badge salmon) en lugar de Carlos
- Texto del dialog: genero femenino y rol "Cuidadora"
- Consecuencias diferenciadas: "ya no podra realizar tareas de cuidado"
  vs "ya no podra gestionar su cuidado" (US-19)
