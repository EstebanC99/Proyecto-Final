# US-25 — Sistema de diseño: Modificación de evento

Hereda el sistema de diseño del módulo Agenda (US-23/00-sistema-diseno.md).

## Componentes específicos de esta pantalla

### Banner informativo (evento editable)
- bg: #E0F2FE, color: #0284C7
- padding: 12px 14px, radius: 10px, display flex, gap 8px
- Ícono CALENDAR 16px + texto 13px
- Margen bottom: 20px

### Banner de error (evento vencido)
- bg: #FBE3E3, color: #D14343
- padding: 12px 14px, radius: 10px, display flex, gap 8px
- Ícono LOCK 16px + texto 13px
- Margen bottom: 20px

### Campos disabled
- bg: #EDF1F1, border: 1px solid #C5CECE
- Texto de valor: #9AA5A5
- prefix icon: #9AA5A5
- cursor: not-allowed

### Botón disabled
- bg: #C5CECE, color: #FFFFFF
- cursor: not-allowed
- sin sombra
