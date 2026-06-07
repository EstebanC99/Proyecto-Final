# 06 · Indicador de fortaleza de contraseña (estados Media y Fuerte)

> Variante de estado del campo Contraseña en el Paso 2 [05]. Componente `PasswordStrengthMeter`.
> Tokens en `00-identidad-visual.md` (sección 2.5 y 5.6).

## Propósito
Comunicar de forma visual y textual qué tan robusta es la contraseña que el usuario escribe,
para guiarlo a elegir una más segura sin bloquearlo.

## Algoritmo de scoring (determinístico, sin dependencias)

Se calcula un `score` 0–4 sumando criterios cumplidos:

1. Longitud >= 8 caracteres.
2. Longitud >= 12 caracteres.
3. Incluye minúsculas **y** mayúsculas.
4. Incluye al menos un número.
5. Incluye al menos un símbolo (no alfanumérico).

> Implementación: contar criterios cumplidos (máx 5) y mapear. Como hay 5 criterios para 3
> niveles, se mapea por umbrales:

| Criterios cumplidos | Nivel | Color | Segmentos llenos | Etiqueta |
|---|---|---|---|---|
| 0 (campo vacío) | — | `surfaceVariant` | 0 / 3 | "Mínimo 8 caracteres" (helper neutro) |
| 1–2 (cumple long. mínima pero poco más) | **Débil** | `strengthWeak` (#D14343) | 1 / 3 | "Débil" |
| 3 | **Media** | `strengthMedium` (#E0A100) | 2 / 3 | "Media" |
| 4–5 | **Fuerte** | `strengthStrong` (#2E9E5B) | 3 / 3 | "Fuerte" |

Reglas duras:
- Si longitud < 8 → siempre **Débil** (no puede ser Media/Fuerte aunque tenga símbolos),
  y además el campo está en error al blur ("mínimo 8 caracteres").
- El meter tiene **3 segmentos** visuales; el color es uniforme para todos los segmentos llenos
  según el nivel.

## Wireframe — estado MEDIA

```
  Contraseña                                       labelMedium textSecondary
  ┌────────────────────────────────────────┐
  │ 🔒  Maria2024                       👁  │      (visible o ••••)
  └────────────────────────────────────────┘
  ▰▰▰▰▰▰▰  ▰▰▰▰▰▰▰  ▱▱▱▱▱▱▱     Media           2 seg. amarillos + 1 gris
  └ strengthMedium ─┘ └surfaceV.┘  ↑labelSmall, color strengthMedium
  Sumá un símbolo (ej. ! ? #) para reforzarla.     bodyMedium/labelSmall hint textSecondary
```

## Wireframe — estado FUERTE

```
  Contraseña
  ┌────────────────────────────────────────┐
  │ 🔒  Maria_2024!cuido                👁  │
  └────────────────────────────────────────┘
  ▰▰▰▰▰▰▰  ▰▰▰▰▰▰▰  ▰▰▰▰▰▰▰     Fuerte ✓       3 seg. verdes
  └────── strengthStrong ──────┘  ↑labelSmall, color strengthStrong + check 14dp
  ¡Buena elección! Tu contraseña es segura.        hint positivo textSecondary
```

## Componentes y especificaciones

| Elemento | Detalle |
|---|---|
| Meter (3 segmentos) | Fila de 3 barras iguales, alto **6 dp**, gap **6 dp**, radio `radiusFull`. Ancho del meter ≈ 60% del ancho del campo; la etiqueta va a la derecha en la misma fila. |
| Segmento lleno | Color del nivel actual (`strengthMedium`/`strengthStrong`/`strengthWeak`). |
| Segmento vacío | Color `surfaceVariant`. |
| Etiqueta de nivel | `labelSmall` (12) **Medium**, color = color del nivel. Texto: "Débil"/"Media"/"Fuerte". En "Fuerte" se agrega ícono check 14 dp del mismo color. |
| Hint contextual | Línea `labelSmall` color `textSecondary` bajo el meter que sugiere cómo mejorar (solo en Débil/Media). En Fuerte: mensaje positivo. |
| Transición de color | Cambio de color/llenado animado 200 ms `easeOut` al cambiar de nivel. |

## Interacciones y comportamiento
- Se actualiza **on-change** (en cada pulsación), no al blur. El blur solo dispara la validación
  de "mínimo 8".
- La etiqueta textual SIEMPRE acompaña al color (accesibilidad: no solo color).
- El meter es **informativo**: no bloquea el submit por sí mismo (salvo la regla de mínimo 8, que
  es una validación del campo, no del meter). Ver nota de política en [05].
- En modo "mostrar contraseña" (toggle 👁 activo), el meter sigue funcionando igual.
- Lector de pantalla: el meter expone un `Semantics` con label "Fortaleza de la contraseña: Media"
  (actualizado en vivo, `liveRegion`).

## Estados alternativos
- **Vacío:** 0 segmentos, helper neutro "Mínimo 8 caracteres".
- **Débil:** 1 segmento `strengthWeak`, etiqueta "Débil", hint para mejorar.
- **Media:** 2 segmentos `strengthMedium` (este doc).
- **Fuerte:** 3 segmentos `strengthStrong` (este doc).
- **< 8 caracteres + blur:** además del meter en Débil, el campo muestra error de validación.

## Navegación
- No cambia la navegación; es un componente embebido en el Paso 2 [05].
