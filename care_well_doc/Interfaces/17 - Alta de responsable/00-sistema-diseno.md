# US-17 — Sistema de diseño (Alta de responsable)

Referencia al sistema de diseño global de CareWell. Tokens adicionales usados en este módulo:

## Paleta aplicada

| Token              | Valor     | Uso en este módulo                              |
|--------------------|-----------|--------------------------------------------------|
| primary            | #1A8C82   | Botón primario, toggle ON                        |
| bg                 | #F6F8F8   | Fondo de pantalla                                |
| surface            | #FFFFFF   | Campos de texto, cards de permiso                |
| surfaceVariant     | #EDF1F1   | Fondo bloque de permisos                         |
| textPrimary        | #16201F   | Títulos, labels, texto principal                 |
| textSecondary      | #566060   | Subtítulos, helper text, body de permisos        |
| outline            | #C5CECE   | Borde de campos en reposo                        |
| primaryContainer   | #C9EDE8   | (no usado aquí directamente)                     |
| success            | #2E9E5B / #D8F0E1 | Pantalla de exito: icono y circulo        |

## Tipografía

- AppBar título: 18px / bold / #16201F
- Subtítulo de contexto: 14px / regular / #566060, negrita en nombre de persona
- Label de campo: 13px / 500 / #566060
- Placeholder de campo: 16px / regular / #9AA5A5
- Título bloque permisos: 15px / bold / #16201F
- Body bloque permisos: 13px / regular / #566060
- Label de permiso individual: 14px / regular / #16201F
- Helper text: 12px / regular / #566060 / espacio reservado 18px de alto
- Título éxito: 22px / bold / #16201F
- Body éxito: 15px / regular / #566060, negrita en nombre

## Componentes específicos de este módulo

### AppTextField
- Height: 56px, bg #FFFFFF, border 1px solid #C5CECE, border-radius 12px
- Foco: border 2px solid #1A8C82
- Layout: flex row, align-items center, padding 0 16px, gap 12px
- Prefijo: icono 20px color #566060
- Valor: 16px #16201F
- Placeholder: 16px #9AA5A5
- Helper: 12px #566060, posicion bajo el campo, altura reservada 18px

### Toggle switch (CSS puro)
- Contenedor: 40px x 22px, border-radius 999px
- Estado ON: bg #1A8C82, circulo blanco 18px desplazado a la derecha (left: 19px)
- Estado OFF (referencia): bg #C5CECE, circulo blanco desplazado a la izquierda (left: 1px)
- El circulo: 18px x 18px, border-radius 50%, bg #FFFFFF, posicion absoluta

### PermissionRow
- Layout: flex row, align-items center, justify-content space-between
- Padding: 12px 16px
- Label: 14px regular #16201F, flex 1
- Toggle al extremo derecho
- Separador entre filas: 1px solid #EDF1F1

### BloquePermisos
- bg #FFFFFF, border-radius 12px, overflow hidden
- Sombra: 0 1px 4px rgba(0,0,0,0.06)
- Header del bloque: padding 14px 16px 8px
  - Titulo: 15px bold #16201F
  - Body: 13px #566060, margin-top 4px

### Pantalla de exito
- Fondo: #F6F8F8 (igual al resto)
- Circulo de icono: 112px x 112px, bg #D8F0E1, border-radius 50%
- Icono CHECK_CIRCLE 80px: color #2E9E5B, centrado
- Titulo: 22px bold #16201F, text-align center
- Body: 15px #566060, text-align center, max-width 300px, line-height 1.55
- Boton primario: igual al sistema

## Objetivos tacticos
- AppTextField: 56px de alto
- Toggle: 40x22px (zona interactiva expandida a 44px con padding visual)
- PermissionRow: min-height 48px
- Boton primario: 56px
