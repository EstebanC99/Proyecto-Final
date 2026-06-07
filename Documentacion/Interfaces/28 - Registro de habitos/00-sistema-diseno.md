# US-28 Registro de hábitos de vida — Sistema de diseño

> El módulo Mi salud hereda el sistema de diseño global de CareWell definido en
> `Documentacion/Interfaces/02 - Inicio de sesion/00-sistema-diseno.md`.
> Este archivo documenta las decisiones específicas del módulo y el color de acento del
> sub-módulo Hábitos de vida.

---

## 1. Tokens del módulo Mi salud

| Concepto              | Token / valor                                     |
|-----------------------|---------------------------------------------------|
| Primario global       | `primary #1A8C82`                                 |
| Fondo                 | `background #F6F8F8`                              |
| Superficie            | `surface #FFFFFF`                                 |
| Superficie variante   | `surfaceVariant #EDF1F1`                          |
| Texto principal       | `textPrimary #16201F`                             |
| Texto secundario      | `textSecondary #566060`                           |
| Borde                 | `outline #C5CECE`                                 |
| Container primario    | `primaryContainer #C9EDE8`                        |

## 2. Acento del sub-módulo Hábitos de vida

| Concepto              | Token / valor                                     |
|-----------------------|---------------------------------------------------|
| Acento salud general  | `healthAccent #E11D48` / container `#FFF1F2`      |
| Acento hábitos        | `habitsAccent #EA580C` / container `#FFF7ED`      |

El color naranja `#EA580C` distingue visualmente el sub-módulo Hábitos dentro del módulo Mi
salud, manteniendo contraste WCAG AA sobre fondo blanco.

## 3. Componentes específicos

### 3.1 CategoryCard (card de categoría expandible)
- Fondo `#FFFFFF`, radius 12 px, padding 16 px, sombra `0 2px 8px rgba(0,0,0,0.06)`.
- Margen: 0 16 px 10 px.
- Fila de encabezado: ícono 24 dp color acento + nombre de categoría (weight 700, 16 px) + flecha
  chevron a la derecha.
- Fila de subtítulo: último registro en `textSecondary` 13 px.
- Chip de frecuencia: bg `#FFF7ED`, texto `#EA580C`, radius 20 px, font-size 12 px, padding 4 px 10 px.

### 3.2 Selector de categoría (chips horizontales)
- Scroll horizontal sin scroll-bar visible.
- Chip activo: bg `#FFF7ED`, borde 1.5 px `#EA580C`, texto `#EA580C`, weight 600.
- Chip inactivo: bg `#EDF1F1`, texto `#566060`.
- Altura 36 px, radius 18 px, padding 0 14 px.

### 3.3 FAB
- Tamaño 56 px, radius 16 px, bg `#EA580C`, ícono ADD blanco 24 dp.
- Posición: bottom 24 px, right 20 px.
- Sombra `0 4px 12px rgba(234,88,12,0.35)`.

### 3.4 Chip de contexto de persona
- Bg `#FFF1F2`, texto `#E11D48`, radius 20 px, padding 6 px 14 px, font-size 13 px, weight 600.
- Ícono persona 16 dp a la izquierda.

## 4. Alturas y espaciado
- AppBar: 56 px, bg `#FFFFFF`, sombra sutil `0 1px 3px rgba(0,0,0,0.08)`.
- Objetivo táctil mínimo: 48 dp.
- Textarea descripción: min-height 80 px, resize none.
- Botón primario: 56 dp alto, radius 16 px.
