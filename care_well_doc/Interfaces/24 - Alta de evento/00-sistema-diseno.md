# US-24 — Sistema de diseño: Alta de evento

Hereda el sistema de diseño del módulo Agenda (US-23/00-sistema-diseno.md).

## Componentes específicos de esta pantalla

### Toggle de notificación
- Fila de 56px mínimo, border-bottom 1px solid #EDF1F1
- Ícono NOTIFICATIONS 20px color #566060
- Label 15px bold + sublabel 12px #566060
- Toggle CSS estado ON: bg #0284C7 (azul módulo, no teal)

### Formulario de evento
Tres campos con label externo e ícono prefijo:
- Fecha: CALENDAR 20px
- Hora: ACCESS_TIME 20px
- Descripción: DESCRIPTION 20px + textarea 80px de alto (no input de línea única)

### Textarea
- height: 80px, padding: 12px 16px, resize: none
- Misma estética que los inputs (bg #FFF, border 1px solid #C5CECE, radius 12px)
- Texto 15px, placeholder 15px #9AA5A5

### Botón primario del módulo
- bg: #0284C7 (azul módulo), height 56px, radius 16px, font 16px bold
