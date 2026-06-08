# US-16 — Pantalla: Equipo vacío (02-equipo-vacio.html)

## Objetivo
Comunicar claramente que aún no hay miembros en el equipo y guiar al Responsable hacia la
acción de agregar el primer integrante, sin generar confusión ni angustia.

## Cuándo se muestra
- Primera vez que se crea una persona bajo cuidado y aún no se asignó ningún miembro al equipo.
- Después de eliminar todos los miembros del equipo (caso borde).

## Layout (jerarquía de componentes, top → bottom)

```
StatusBar (28px, dark)
AppBar
  ├── IconButton ARROW_BACK (40px)
  └── Título "Mi equipo" (18px bold)
  (sin botón ADD: no hay contexto todavía / se usa el botón principal)
Contenido centrado (flex column, align-items center, justify-content center, flex: 1)
  ├── ChipContexto ("Viendo equipo de: Alicia Rodríguez") — igual que estado con datos
  ├── Separador vertical 40px
  ├── CircleIcon (88px, bg #C9EDE8, border-radius 50%)
  │     └── PERSON_ADD 48px color #1A8C82
  ├── Título vacío (20px bold #16201F, margin-top 20px)
  ├── Descripción (14px regular #566060, text-align center, max-width 280px, margin-top 8px)
  └── BtnPrimario "Agregar miembro" (margin-top 32px, width 100%, max-width 280px)
```

## Especificación de cada componente

### AppBar (estado vacío)
- Sin botón ADD (se omite para no fragmentar la atención; el botón primario es la CTA única)
- Resto igual al estado con datos

### ChipContexto
- Mismo estilo que en 01-equipo.html
- Se mantiene para que el usuario sepa siempre de qué persona se habla

### Ilustración / empty state
- Círculo 88px x 88px, bg #C9EDE8, border-radius 50%
- PERSON_ADD 48px, color #1A8C82, centrado dentro del círculo
- margin-top: calculado para centrado vertical (ver HTML)

### Texto vacío
- Título: "Equipo sin miembros" / 20px bold / #16201F / text-align center
- Descripción: "Agregá responsables y cuidadores para coordinar el cuidado de Alicia."
  / 14px / #566060 / text-align center / line-height 1.5 / max-width 280px

### Botón primario
- Texto: "Agregar miembro"
- Estilo: igual a btn-primary del sistema (height 56px, bg #1A8C82, radius 16px, blanco)
- Ancho: 100% dentro de max-width 280px

## Interacciones
- Tap "Agregar miembro" → navega a US-17 (alta de responsable)
- Tap ARROW_BACK → vuelve al Menú principal

## Anotaciones de diseño
1. CTA única visible: sin FAB y sin ADD en AppBar para concentrar la atención en el botón primario
2. Lenguaje motivador y orientado a la acción: "Agregá" en imperativo directo
3. Nombre de la persona en la descripción: refuerza el contexto sin necesidad de leer el chip
4. Círculo con icono: pattern empty-state reconocible; no usa ilustraciones pesadas
5. Centrado vertical real (justify-content center en el contenedor): no queda pegado al top
