# US-29 Recomendaciones médicas — Sistema de diseño

> Hereda el sistema de diseño global de CareWell. Este archivo documenta únicamente las
> decisiones específicas del sub-módulo Recomendaciones dentro de Mi salud.

---

## 1. Acento del sub-módulo

| Concepto              | Token / valor                                     |
|-----------------------|---------------------------------------------------|
| Acento recomendaciones| `recsAccent #16A34A` / container `#F0FDF4`        |

Verde `#16A34A` transmite bienestar y salud preventiva. Cumple WCAG AA sobre blanco.

## 2. Componentes específicos

### 2.1 Banner de disclaimer
- Bg `#F0FDF4`, borde izquierdo 4 px `#16A34A`, radius 8 px.
- Ícono INFO 16 dp color `#16A34A` alineado arriba-izquierda.
- Texto 13 px, `textSecondary`, con fragmento en negrita: "No reemplazan la consulta médica".
- Padding 12 px. Margen 16 px horizontal.

### 2.2 RecommendationCard
- Bg `#FFFFFF`, radius 12 px, padding 16 px, sombra `0 2px 8px rgba(0,0,0,0.06)`.
- Fila cabecera: ícono 24 dp color acento + título 700 16 px.
- Cuerpo: texto 14 px `textSecondary`, 2–3 líneas.
- Sin acciones adicionales en MVP (solo lectura).

## 3. Notas de accesibilidad
- El disclaimer es obligatorio y debe estar siempre visible al cargar la pantalla (no colapsable).
- El contraste del verde `#16A34A` sobre `#F0FDF4` supera 4.5:1.
