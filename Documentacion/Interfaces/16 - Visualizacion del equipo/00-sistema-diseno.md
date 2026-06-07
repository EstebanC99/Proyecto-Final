# US-16 — Sistema de diseño (Mi equipo)

Referencia al sistema de diseño global de CareWell. Esta pantalla no introduce tokens nuevos.

## Paleta aplicada

| Token            | Valor     | Uso en este módulo                          |
|------------------|-----------|---------------------------------------------|
| primary          | #1A8C82   | AppBar, FAB, botón primario, toggles ON     |
| bg               | #F6F8F8   | Fondo de pantalla                           |
| surface          | #FFFFFF   | Cards de miembro                            |
| surfaceVariant   | #EDF1F1   | Fondo de secciones                          |
| textPrimary      | #16201F   | Nombre del miembro                          |
| textSecondary    | #566060   | Email, headers de sección                  |
| outline          | #C5CECE   | Bordes sutiles                              |
| primaryContainer | #C9EDE8   | Avatar bg, badge Responsable bg, chip ctx  |
| secondaryContainer | #FCE2DA | Badge Cuidador bg                           |
| success          | #2E9E5B / #D8F0E1 | (no aplica en esta pantalla)        |
| error            | #D14343 / #FBE3E3 | (no aplica en esta pantalla)        |

## Tipografía

- Familia: 'Segoe UI', Arial, sans-serif
- Nombre miembro: 15px / bold / #16201F
- Email miembro: 13px / regular / #566060
- Header sección: 12px / 600 / #566060 / uppercase / letter-spacing 0.8px
- Badge: 11px / 600 / border-radius 999px / padding 2px 8px
- Chip contexto: 13px / regular-bold mixto / border-radius 12px / padding 8px 16px
- AppBar título: 18px / bold

## Componentes específicos de este módulo

### MemberCard
- bg #FFF, border-radius 12px, padding 14px 16px
- Sombra: 0 1px 4px rgba(0,0,0,0.08)
- Layout: flex row, align-items center, gap 12px
- Avatar: 44px circle, bg primaryContainer (#C9EDE8), inicial en color #0A3D38, font 18px bold
- Columna de texto: flex 1
- Badge + CHEVRON_RIGHT al extremo derecho

### Chip de contexto (persona bajo cuidado)
- bg #C9EDE8, border-radius 12px, padding 8px 16px
- Texto "Viendo equipo de:" 13px regular + nombre bold

### Sección header
- Texto 12px / 600 / uppercase / #566060
- margin-bottom 8px, margin-top 20px (primera sección 0)

### FAB
- 56px circular, bg #1A8C82, icono ADD blanco
- Sombra: 0 4px 12px rgba(26,140,130,0.35)
- Posición: absolute bottom 24px right 16px

## Objetivos táctiles
- MemberCard: min-height 72px (tap area completa)
- FAB: 56px (cumple mínimo 48px)
- Botón AppBar ADD: 40px circular
