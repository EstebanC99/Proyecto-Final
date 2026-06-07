# US-17 — Pantalla: Confirmación de alta exitosa (02-exito.html)

## Objetivo
Confirmar al Responsable que la acción se completó correctamente, identificar al nuevo miembro
por nombre y orientar hacia el siguiente paso natural (volver al equipo).

## Cuándo se muestra
Inmediatamente después de que el servidor confirma el alta del nuevo responsable en el equipo.

## Layout (jerarquía de componentes, top → bottom)

```
StatusBar (28px, dark)
Contenido centrado (flex column, align-items center, justify-content center, flex: 1, padding 24px)
  ├── CircleIcon (112px, bg #D8F0E1)
  │     └── CHECK_CIRCLE 80px, color #2E9E5B
  ├── Titulo "Responsable agregado" (22px bold, margin-top 24px)
  ├── Body (15px, text-center, max-width 300px, margin-top 12px)
  └── BtnPrimario "Volver al equipo" (margin-top 40px, width 100%, max-width 320px)
```

## Especificación de cada componente

### Pantalla
- Sin AppBar: el flujo está terminado, no hay "atrás" lógico
- Fondo: #F6F8F8
- Contenedor: height = (844 - 28)px, flex column, justify-content center, align-items center

### CircleIcon
- Width / height: 112px, border-radius 50%
- Background: #D8F0E1 (success container)
- CHECK_CIRCLE SVG: 80px, color #2E9E5B (success)
- Centrado dentro del circulo

### Titulo
- Texto: "Responsable agregado"
- No usar signo de exclamacion en el titulo (tono sobrio, profesional)
- 22px / font-weight 700 / color #16201F / text-align center
- margin-top: 24px

### Body
- Texto: "Carlos Pérez ya es parte del equipo de cuidado de Alicia. Recibirá una notificación."
- "Carlos Pérez": bold / #16201F
- Resto: regular / #566060
- 15px / line-height 1.55 / text-align center / max-width 300px
- margin-top: 12px

### Boton primario
- Texto: "Volver al equipo"
- Height 56px, bg #1A8C82, color #FFFFFF, border-radius 16px, font 16px bold
- Width: 100%, max-width 320px
- margin-top: 40px
- Accion: limpia el stack de navegacion hasta US-16 (no permite "atras" al formulario)

## Datos de ejemplo
- Nombre nuevo responsable: Carlos Pérez
- Nombre persona bajo cuidado: Alicia

## Interacciones
- Tap "Volver al equipo" → navega a US-16 con stack limpio (pop until US-16)
- Swipe-back deshabilitado o redirige tambien a US-16 (no vuelve al formulario)

## Consideraciones de accesibilidad
- El nombre del nuevo miembro se muestra en el body: feedback concreto de qué acción se realizó
- Unico boton en pantalla: zero ambiguedad sobre el siguiente paso

## Anotaciones de diseño
1. Sin AppBar: el flujo se completo, el "atras" no tiene sentido semantico aqui
2. Nombre del nuevo responsable en el body: confirmacion especifica, no generica
3. Mencion de la notificacion: tranquiliza al Responsable (no necesita avisar manualmente)
4. Circulo success 112px: celebracion visual sin ser exagerada, coherente con el contexto de cuidado
5. Boton unico: elimina decision fatigue al final del flujo
