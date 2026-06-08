# US-23 — Sistema de diseño: Módulo Agenda

## Color de módulo
El módulo Agenda usa azul `#0284C7` como color de acento, coherente con el tile del home.

| Token            | Valor     | Uso en Agenda                              |
|------------------|-----------|--------------------------------------------|
| moduleColor      | #0284C7   | AppBar icon, chips, hora, FAB, botones     |
| moduleContainer  | #E0F2FE   | Chip de contexto bg, chip de recordatorio  |
| moduleText       | #0284C7   | Hora del evento, texto chips módulo        |
| primary          | #1A8C82   | Acciones genéricas fuera del módulo        |
| bg               | #F6F8F8   | Fondo de pantallas                         |
| surface          | #FFFFFF   | Tarjetas de evento                         |
| surfaceVariant   | #EDF1F1   | Separadores, campos disabled               |
| textPrimary      | #16201F   | Títulos, nombres                           |
| textSecondary    | #566060   | Descripciones, metadatos                   |
| outline          | #C5CECE   | Bordes de campos, separadores              |
| error            | #D14343   | Banner evento vencido                      |
| errorContainer   | #FBE3E3   | Fondo banner error                         |
| success          | #2E9E5B   | (no se usa en este módulo)                 |

## Tipografía (igual que el sistema global)
- Títulos AppBar: 18px bold
- Label grupo fecha: 12px uppercase bold `#566060`
- Hora evento: 14px bold `#0284C7`
- Título evento: 15px bold `#16201F`
- Descripción evento: 13px `#566060`
- Chips: 11px medium

## Componentes específicos del módulo

### EventCard
- bg: #FFFFFF, radius: 12px, padding: 14px 16px, shadow: 0 1px 4px rgba(0,0,0,0.08)
- margin: 0 16px 8px
- Layout: flex row, gap 12px
- Col izq (hora): 44px mínimo, alineada arriba
- Col der: flex 1
- Estado pasado: opacity 0.5, lock icon 16px inline

### DateGroupLabel
- Formato: "HOY · 5 JUN", "MAÑANA · 6 JUN", "MAR · 8 JUN"
- 12px uppercase bold `#566060`
- padding: 16px 16px 6px

### ChipContexto (persona a cargo)
- bg: #E0F2FE, color: #0284C7, 13px, radius: 999px, padding: 6px 14px
- Margen: 0 16px 12px

### FAB Agenda
- 56px, radius: 16px, bg: #0284C7, color: #FFFFFF
- Sombra: 0 4px 12px rgba(2,132,199,0.35)
- Posición: absolute bottom 24px right 16px
