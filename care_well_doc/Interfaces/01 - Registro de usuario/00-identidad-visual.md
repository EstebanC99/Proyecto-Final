# CareWell — Identidad Visual (Sistema de Diseño)

> Fuente de verdad del sistema de diseño para la capa de presentación (Flutter / Material 3).
> Todos los demás documentos de esta carpeta referencian los tokens definidos aquí.
> Identificadores de color/tipografía en inglés para mapear 1:1 con el `ColorScheme` y
> `TextTheme` de Flutter.

---

## 1. Concepto de marca

CareWell acompaña a personas cuidadoras en momentos de cansancio, apuro o estrés. La identidad
debe transmitir:

- **Confianza y calidez** → un verde-azulado (teal) sereno como color principal, evocando salud,
  calma y cuidado, lejos del "clínico frío" de un azul puro o del "alarma" de un rojo.
- **Modernidad y claridad** → superficies amplias, mucho espacio en blanco, bordes redondeados
  generosos y una jerarquía tipográfica fuerte.
- **Accesibilidad** → contraste alto (WCAG AA mínimo), objetivos táctiles grandes (>= 48 dp),
  tipografía legible y nunca depender solo del color para comunicar estado.

Principio rector: **"Calma operativa"**. La interfaz no compite por atención; guía paso a paso.

---

## 2. Paleta de colores

### 2.1 Color primario — Teal (cuidado, confianza)

| Token | HEX | Uso |
|---|---|---|
| `primary` | `#1A8C82` | Color de marca. Botones primarios, foco activo, barra de progreso, links de acción. |
| `primaryHover` | `#157469` | Estado pressed/hover del primario. |
| `primaryContainer` | `#C9EDE8` | Fondos suaves de realce (chips, badges, fondos de íconos). |
| `onPrimary` | `#FFFFFF` | Texto/íconos sobre `primary`. |
| `onPrimaryContainer` | `#0A3D38` | Texto sobre `primaryContainer`. |

### 2.2 Color secundario — Coral cálido (humano, acento)

Usado con moderación para aportar calidez humana sin alarmar. No se usa para acciones de
peligro (eso es `error`).

| Token | HEX | Uso |
|---|---|---|
| `secondary` | `#F2785C` | Acentos cálidos, ilustraciones, detalle de la pantalla de éxito. |
| `secondaryContainer` | `#FCE2DA` | Fondos suaves de acento. |
| `onSecondary` | `#FFFFFF` | Texto sobre `secondary`. |

### 2.3 Neutros (texto y superficies)

| Token | HEX | Uso |
|---|---|---|
| `background` | `#F6F8F8` | Fondo general de pantalla (gris muy claro con tinte teal). |
| `surface` | `#FFFFFF` | Tarjetas, campos, hojas/modales. |
| `surfaceVariant` | `#EDF1F1` | Superficies sutilmente diferenciadas (campos en reposo, dividers de zona). |
| `outline` | `#C5CECE` | Bordes de campos en reposo, divisores. |
| `outlineStrong` | `#9AA5A5` | Bordes de mayor contraste cuando se necesita. |
| `textPrimary` | `#16201F` | Texto principal (titulares, valores). |
| `textSecondary` | `#566060` | Texto secundario, labels, ayudas. |
| `textDisabled` | `#9AA5A5` | Placeholder, texto deshabilitado. |

### 2.4 Colores de estado (semánticos)

| Token | HEX | Container | Uso |
|---|---|---|---|
| `error` | `#D14343` | `errorContainer #FBE3E3` | Errores de validación, campos inválidos, destructivo. |
| `success` | `#2E9E5B` | `successContainer #D8F0E1` | Confirmaciones, contraseña fuerte, pantalla de éxito. |
| `warning` | `#E0A100` | `warningContainer #FBF0CF` | Advertencias, contraseña de fortaleza media. |
| `info` | `#2E77C2` | `infoContainer #DBE9FB` | Mensajes informativos neutros. |

> Material 3 no tiene roles `success`/`warning` nativos: se definen como **colores de extensión
> del tema** vía `ThemeExtension` (clase `AppStatusColors`). Ver sección 7.

### 2.5 Indicador de fortaleza de contraseña (escala dedicada)

| Nivel | Token | HEX |
|---|---|---|
| Débil | `strengthWeak` | `#D14343` (= `error`) |
| Media | `strengthMedium` | `#E0A100` (= `warning`) |
| Fuerte | `strengthStrong` | `#2E9E5B` (= `success`) |

### 2.6.1 Escala de estado de ánimo (dedicada, US-31)

Escala de 5 tonos roja→ámbar→verde para el selector tipo carrusel de "Estado de ánimo". Son
tokens propios (no se reutilizan `error`/`warning`/`success` sueltos) para no acoplar la
semántica de otros módulos a esta escala de sentimiento.

| Nivel | Token | HEX |
|---|---|---|
| Muy mal | `moodScaleVeryBad` | `#D14343` |
| Mal | `moodScaleBad` | `#C85A2E` |
| Regular (default) | `moodScaleNeutral` | `#E0A100` |
| Bien | `moodScaleGood` | `#8CAA22` |
| Muy bien | `moodScaleVeryGood` | `#2E9E5B` |

**Regla de uso:** estos tokens solo se aplican a elementos decorativos (fondo a alpha ~0.16,
anillo a alpha 1.0, puntos de indicador). **Nunca como color de texto sobre `surface`/blanco**:
`moodScaleNeutral` da ~2.3:1 de contraste, por debajo del mínimo WCAG. El texto asociado
(nombre del estado) siempre va en `textPrimary`.

### 2.6 Verificación de contraste (WCAG)

- `textPrimary` sobre `surface`/`background`: ratio ~14:1 (AAA).
- `textSecondary` sobre `surface`: ratio ~6.8:1 (AA, texto normal).
- `onPrimary` (#FFF) sobre `primary` (#1A8C82): ratio ~3.6:1 → **válido solo para texto >= 18.66 px bold o >= 24 px** (AA large). Para botones, el texto de botón es 16 px **bold**, lo que cumple el umbral de "large/bold". Cumple AA.
- Nunca comunicar estado solo por color: error siempre lleva ícono + texto; fortaleza lleva etiqueta textual ("Débil/Media/Fuerte").

---

## 3. Tipografía

**Familia:** `Inter` (sans-serif geométrica-humanista, excelente legibilidad en tamaños chicos,
amplia disponibilidad). Fallback del sistema: Roboto.

- Incluir `Inter` como fuente empaquetada (`pubspec.yaml` → `fonts:`), pesos 400/500/600/700.
- Numerales tabulares activados en indicadores y contadores donde aplique.

### 3.1 Escala tipográfica

| Rol (TextTheme M3) | Tamaño | Peso | Line-height | Uso |
|---|---|---|---|---|
| `displaySmall` | 30 | 700 Bold | 38 | Título de pantalla de éxito. |
| `headlineMedium` | 24 | 700 Bold | 32 | Título principal de cada paso ("Creá tu cuenta"). |
| `titleLarge` | 20 | 600 SemiBold | 28 | Subtítulos de sección, título de bottom sheet. |
| `titleMedium` | 16 | 600 SemiBold | 24 | Labels de paso del wizard, encabezados de bloque. |
| `bodyLarge` | 16 | 400 Regular | 24 | Texto de cuerpo, valores de input, párrafos T&C. |
| `bodyMedium` | 14 | 400 Regular | 20 | Texto de ayuda, descripciones secundarias. |
| `labelLarge` | 16 | 700 Bold | 20 | Texto de botones. |
| `labelMedium` | 13 | 500 Medium | 16 | Labels de campos (encima del input), captions, contador de pasos. |
| `labelSmall` | 12 | 500 Medium | 16 | Mensajes de error/ayuda bajo campos, etiqueta de fortaleza. |

**Color de texto por defecto:** `textPrimary`. Labels y ayudas: `textSecondary`. Errores: `error`.

---

## 4. Espaciado, grilla y radios

### 4.1 Escala de espaciado (base 4)
`xs=4` · `sm=8` · `md=12` · `lg=16` · `xl=24` · `xxl=32` · `xxxl=48`

- **Padding horizontal de pantalla:** `xl = 24 dp` (en pantallas angostas <360 dp, bajar a `lg = 16 dp`).
- **Separación vertical entre campos de formulario:** `lg = 16 dp`.
- **Separación entre bloques/secciones:** `xl = 24 dp`.

### 4.2 Radios (esquinas redondeadas)
| Token | Valor | Uso |
|---|---|---|
| `radiusSm` | 8 | Chips, badges pequeños. |
| `radiusMd` | 12 | Inputs, alerts/banners. |
| `radiusLg` | 16 | Tarjetas, botones (ver nota). |
| `radiusXl` | 28 | Bottom sheet (esquinas superiores), diálogos. |
| `radiusFull` | 999 | Avatares, barra de progreso, indicador de fortaleza. |

> **Botones:** radio `radiusLg = 16` (estética moderna, "soft"). Altura 56 dp.

### 4.3 Elevación y sombras
Estilo **plano con sombras suaves** (no Material clásico pesado).

| Token | Definición | Uso |
|---|---|---|
| `elev0` | sin sombra, solo `outline` 1 dp | Campos, tarjetas en reposo sobre `surface`. |
| `elev1` | y-offset 2, blur 8, color `#16201F` @ 6% | Tarjetas elevadas, app bar al hacer scroll. |
| `elev2` | y-offset 8, blur 24, color `#16201F` @ 12% | Bottom sheet, diálogos, overlay de carga. |

---

## 5. Componentes base (estilos canónicos)

### 5.1 Botón primario (`PrimaryButton`)
- Fondo `primary`, texto `onPrimary` con `labelLarge`.
- Altura **56 dp**, ancho completo (full-width) en formularios.
- Radio `radiusLg (16)`. Sin sombra en reposo; `elev1` opcional al pressed.
- Estados:
  - **Reposo:** fondo `primary`.
  - **Pressed:** fondo `primaryHover`.
  - **Disabled:** fondo `outline` (#C5CECE), texto `#FFFFFF` @ 70%. Cursor/feedback inhibido.
  - **Loading:** texto reemplazado por `CircularProgressIndicator` 20 dp color `onPrimary`, botón deshabilitado.

### 5.2 Botón secundario / texto (`SecondaryTextButton`)
- Sin fondo, texto `primary` con `labelLarge`. Para acciones como "Volver", "Ir al login" alterno.
- Altura 48 dp mínima.

### 5.3 Campo de texto (`AppTextField`)
- **Label superior externo** (fuera del campo, no floating), `labelMedium` color `textSecondary`,
  separado 6 dp del campo. Esto mejora legibilidad para usuarios con baja afinidad tecnológica
  (la etiqueta nunca "desaparece" al escribir).
- Caja del campo: fondo `surface`, borde 1 dp `outline`, radio `radiusMd (12)`, altura 56 dp,
  padding interno horizontal 16 dp.
- Texto del valor: `bodyLarge` color `textPrimary`. Placeholder: `bodyLarge` color `textDisabled`.
- Ícono prefijo opcional (20 dp, color `textSecondary`).
- **Estados:**
  - **Reposo:** borde `outline`.
  - **Foco:** borde 2 dp `primary`.
  - **Error:** borde 2 dp `error`; debajo, texto de error `labelSmall` color `error` con ícono
    de alerta 16 dp a la izquierda.
  - **Disabled:** fondo `surfaceVariant`, texto `textDisabled`.
- **Helper/error text** ocupa una línea reservada de 18 dp bajo el campo para evitar saltos de layout.

### 5.4 Checkbox (`AppCheckbox`)
- Caja 22 dp, radio 6 dp. Borde 2 dp `outlineStrong` sin marcar; relleno `primary` con check
  `onPrimary` marcado.
- Objetivo táctil total (caja + label) >= 48 dp de alto.

### 5.5 Barra de progreso del wizard (`StepProgressBar`)
- Track de altura 6 dp, fondo `surfaceVariant`, radio `radiusFull`.
- Relleno `primary`, animado (200 ms ease-out) al cambiar de paso.
- Encima/al lado: texto "Paso X de 2" en `labelMedium` color `textSecondary`.

### 5.6 Indicador de fortaleza de contraseña (`PasswordStrengthMeter`)
- Tres segmentos horizontales iguales, alto 6 dp, gap 6 dp, radio `radiusFull`.
- Segmentos se colorean según nivel (`strengthWeak/Medium/Strong`); los inactivos quedan `surfaceVariant`.
- Etiqueta textual a la derecha o debajo, `labelSmall`, con el color del nivel.

### 5.7 Banner de error de pantalla (`InlineErrorBanner`)
- Fondo `errorContainer`, ícono `error` 20 dp a la izquierda, texto `bodyMedium` color `error`,
  radio `radiusMd (12)`, padding 12–16 dp. Opcional acción/enlace a la derecha o debajo.

### 5.8 App bar de flujo (`FlowAppBar`)
- Fondo `background` (sin sombra en reposo, `elev1` al hacer scroll).
- Leading: ícono "atrás" (`arrow_back`, 24 dp, color `textPrimary`), objetivo táctil 48 dp.
- Sin título centrado (el título grande va en el cuerpo). Altura 56 dp.

### 5.9 Bottom sheet (`AppBottomSheet`)
- Fondo `surface`, esquinas superiores `radiusXl (28)`, `elev2`.
- Grabber (handle) 40x4 dp color `outline`, centrado, margen superior 12 dp.
- Scrim del fondo: negro @ 40%.

---

### 5.10 Selector de ánimo tipo carrusel (`MoodDialSelector`)
- Row centrada: flecha `‹` (56×56 dp) — blob circular (156×156 dp) — flecha `›` (56×56 dp).
- Blob: fondo del color de escala (§ 2.6.1) a alpha 0.16, anillo 3 dp al mismo color a alpha 1.0,
  emoji centrado a 64 px.
- Debajo del blob: label del estado (`titleLarge`-like, 20 px / 700, `textPrimary`) + 5 puntos
  de posición (8 dp, activo 10 dp coloreado con el tono de escala).
- Flechas: se deshabilitan visualmente (`textDisabled`, sin ripple) en los extremos del rango
  (Muy mal / Muy bien). Objetivo táctil 56 dp (por encima del mínimo de 48 dp, pensado para
  usuarios mayores).
- Interacción: tap de flecha o swipe horizontal sobre el blob; ambos disparan el mismo cambio
  de nivel. Transición 250 ms (slide + fade del emoji, interpolación de color del blob, fade
  del label). Feedback háptico (`HapticFeedback.selectionClick()`) en cada cambio.
- El color de la escala **no** determina el estilo del CTA de guardar: el botón de acción
  primaria de esa pantalla mantiene su color de marca fijo (ver 5.1), independiente del nivel
  seleccionado, para no mezclar semánticas ("botón rojo" ≠ "error").

## 6. Iconografía y motion

- **Íconos:** Material Symbols (Rounded), peso 400, tamaño base 24 dp (20 dp dentro de inputs).
- **Motion:**
  - Transición entre pasos del wizard: slide horizontal + fade, 250 ms, `easeInOutCubic`
    (avanzar entra desde la derecha; volver, desde la izquierda).
  - Aparición de errores bajo campo: fade + slide-down 4 dp, 150 ms.
  - Bottom sheet: slide-up estándar M3.
  - Pantalla de éxito: ícono con animación de "check" (scale-in + pop), 400 ms; usar `animate_do`
    (`ElasticIn` / `ZoomIn`).
- Respetar `MediaQuery.disableAnimations` / reduce-motion: degradar a fades simples.

---

## 7. Mapeo a Flutter (Material 3)

- `ThemeData(useMaterial3: true)` con `ColorScheme` construido manualmente desde los tokens
  de la sección 2 (no usar `fromSeed` para garantizar exactitud de marca).
- Roles M3 → tokens:
  - `primary → primary`, `onPrimary → onPrimary`, `primaryContainer → primaryContainer`.
  - `secondary → secondary`, `secondaryContainer → secondaryContainer`.
  - `surface → surface`, `surfaceContainerLowest/Low → background/surfaceVariant`.
  - `error → error`, `errorContainer → errorContainer`, `outline → outline`.
- `success`, `warning`, `info` y los `strength*`: vía `ThemeExtension<AppStatusColors>`.
- `TextTheme` mapeado según sección 3.
- Definir `inputDecorationTheme`, `filledButtonTheme`, `checkboxTheme`, `bottomSheetTheme`,
  `appBarTheme` con los estilos canónicos de la sección 5.
- Ubicación sugerida: `care_well_app/lib/config/theme/app_theme.dart` (+ `app_status_colors.dart`).

---

## 8. Tema oscuro

### 8.0 Activación y filosofía

El tema oscuro **no es seleccionable dentro de la app**: se activa automáticamente cuando el
sistema operativo del dispositivo está en modo oscuro (`ThemeMode.system` en el `MaterialApp`).
No hay toggle in-app; esta sección solo define la paleta y las adaptaciones de componentes que
`AppTheme` debe exponer como segundo `ThemeData` (`dark`).

Principios de adaptación (siguiendo Material 3 y las guías de accesibilidad ya vigentes en la
sección 2):

1. **Nunca negro puro / blanco puro.** Fondos con tinte teal muy oscuro (~`#0F1917`–`#1E2B29`,
   en línea con la práctica M3 de `#121212`–`#1A1A1A`); texto principal en blanco roto
   (`#EDF3F2`, ~95% de luminosidad) en vez de `#FFFFFF`.
2. **Los tonos vivos del claro se aclaran y desaturan, no se oscurecen.** `primary` (#1A8C82) y
   `secondary` (#F2785C) pierden legibilidad si se oscurecen sobre un fondo ya oscuro; en dark
   se usan versiones más claras y ligeramente menos saturadas de esos mismos matices.
3. **"Superficie elevada" = más clara, no con más sombra.** Siguiendo la técnica de *tonal
   elevation* de Material 3: en vez de oscurecer con una sombra negra (invisible sobre fondo
   oscuro), los elementos elevados usan un tono de superficie más claro (`surface` →
   `surfaceVariant`) y/o un borde sutil de 1 dp. Ver 8.9.
4. **La semántica de estado no cambia:** error sigue siendo rojo, success verde, warning ámbar,
   info azul; solo se ajusta el tono para que funcione sobre fondo oscuro.
5. **Los nombres de token son idénticos a los del tema claro** (`primary`, `onPrimary`,
   `background`, `error`, `strengthWeak`, `moodScaleGood`, etc.). Solo cambia el valor HEX y,
   quirúrgicamente, algún rol de componente (ver 8.10). Esto permite que `AppColors` pase a
   tener una variante `light` y una `dark` con la misma forma, sin renombrar nada en el resto
   del código.

### 8.1 Primario — Teal (dark)

| Token | Claro | Oscuro | Notas |
|---|---|---|---|
| `primary` | `#1A8C82` | `#4FBDB0` | Teal aclarado y algo menos saturado; sigue siendo reconociblemente "el verde de CareWell". |
| `primaryHover` | `#157469` | `#3FA89C` | Estado pressed/hover: versión algo más oscura que `primary` (dark), igual que en claro. |
| `primaryContainer` | `#C9EDE8` | `#1B3B37` | Container oscuro con tinte teal (no un teal claro): mismo rol, distinta dirección de luminosidad. |
| `onPrimary` | `#FFFFFF` | `#08302B` | Texto/íconos sobre `primary`. Como `primary` (dark) es un tono medio-claro, el texto pasa a oscuro. |
| `onPrimaryContainer` | `#0A3D38` | `#A9E6DD` | Texto claro sobre el container oscuro. |

### 8.2 Secundario — Coral (dark)

| Token | Claro | Oscuro | Notas |
|---|---|---|---|
| `secondary` | `#F2785C` | `#F59A82` | Coral aclarado/desaturado ~10-15%: el original ya es un tono vívido y vibra sobre fondo oscuro si no se suaviza. |
| `secondaryContainer` | `#FCE2DA` | `#3D2117` | Container oscuro con tinte coral/marrón cálido. |
| `onSecondary` | `#FFFFFF` | `#452016` | Con `secondary` (dark) más claro, el texto sobre el chip/botón pasa a un marrón oscuro cálido en vez de blanco. |
| `onSecondaryContainer` *(implícito, = `textPrimary`)* | `#16201F` | `#EDF3F2` | Mismo criterio que en claro (`theme.dart` mapea `onSecondaryContainer → textPrimary`). |

### 8.3 Neutros — texto y superficies (dark)

| Token | Claro | Oscuro | Notas |
|---|---|---|---|
| `background` | `#F6F8F8` | `#0F1917` | Fondo general. Gris-teal casi negro, no negro puro. |
| `surface` | `#FFFFFF` | `#16211F` | Tarjetas, campos, hojas — un paso "más claro" que `background` (elevación tonal M3: a más elevación, más clara la superficie). |
| `surfaceVariant` | `#EDF1F1` | `#1E2B29` | Superficie diferenciada / rol de "elevación 2" en dark (ver 8.9). |
| `outline` | `#C5CECE` | `#30403C` | Bordes de campos en reposo, divisores sutiles. |
| `outlineStrong` | `#9AA5A5` | `#5C7975` | Bordes de mayor contraste. Mismo valor que `textDisabled` (igual que en claro, donde ambos también coinciden). |
| `textPrimary` | `#16201F` | `#EDF3F2` | Texto principal. Blanco roto (~95% L), no `#FFFFFF`, para reducir el "vibrado" de texto muy claro sobre fondo muy oscuro. |
| `textSecondary` | `#566060` | `#9DB3AF` | Texto secundario, labels, ayudas. |
| `textDisabled` | `#9AA5A5` | `#5C7975` | Placeholder, texto deshabilitado. Deliberadamente por debajo de AA (igual criterio que en claro): el estado disabled está exento del requisito de contraste de texto de WCAG. |

### 8.4 Colores de estado — semánticos (dark)

| Token | Claro | Oscuro | Container claro | Container oscuro |
|---|---|---|---|---|
| `error` | `#D14343` | `#E2727A` | `#FBE3E3` | `#3B1E20` |
| `success` | `#2E9E5B` | `#6FCB8E` | `#D8F0E1` | `#1C3327` |
| `warning` | `#E0A100` | `#F0C05A` | `#FBF0CF` | `#3A2E12` |
| `info` | `#2E77C2` | `#6FA8E0` | `#DBE9FB` | `#1B2C3E` |

`onErrorContainer` (mapeado a `error` en `theme.dart`) usa el mismo criterio en dark: texto
`error` (dark) sobre `errorContainer` (dark) → ver contraste verificado en 8.8.

### 8.5 Indicador de fortaleza de contraseña (dark)

| Nivel | Token | Claro | Oscuro |
|---|---|---|---|
| Débil | `strengthWeak` | `#D14343` (= `error`) | `#E2727A` (= `error` dark) |
| Media | `strengthMedium` | `#E0A100` (= `warning`) | `#F0C05A` (= `warning` dark) |
| Fuerte | `strengthStrong` | `#2E9E5B` (= `success`) | `#6FCB8E` (= `success` dark) |

### 8.6 Escala de estado de ánimo (dark, US-31)

Se mantiene el criterio del claro: 5 tonos rojo→ámbar→verde, tokens propios (no reutilizan
`error`/`warning`/`success` sueltos salvo en los extremos, donde coinciden por diseño).

| Nivel | Token | Claro | Oscuro |
|---|---|---|---|
| Muy mal | `moodScaleVeryBad` | `#D14343` | `#E2727A` (= `error` dark) |
| Mal | `moodScaleBad` | `#C85A2E` | `#E0935F` |
| Regular (default) | `moodScaleNeutral` | `#E0A100` | `#F0C05A` (= `warning` dark) |
| Bien | `moodScaleGood` | `#8CAA22` | `#B4D06A` |
| Muy bien | `moodScaleVeryGood` | `#2E9E5B` | `#6FCB8E` (= `success` dark) |

**Regla de uso (se mantiene igual que en claro, sección 2.6.1):** estos tokens solo se aplican
a elementos decorativos (fondo del blob a alpha, anillo a alpha 1.0, puntos de indicador),
nunca como color de texto sobre `surface`/`background`. En dark, subir el alpha del fondo del
blob de `0.16` a **`0.20`** (ver 8.10): un mismo alpha bajo se percibe con menos presencia sobre
fondo oscuro que sobre fondo claro. El label del estado sigue siempre en `textPrimary` (dark).

> **Nota de consistencia doc↔código:** el código actual (`app_colors.dart`) tiene
> `moodScaleBad = #EA580C`, que no coincide con el `#C85A2E` documentado en la sección 2.6.1 de
> este archivo (fuente de verdad). Esta tabla de dark usa como ancla el valor **documentado**
> (`#C85A2E`). Si se decide adoptar `#EA580C` como valor real de claro, el oscuro correspondiente
> debería recalcularse (sería `#F0935F`, que coincide con el propuesto para `habitsAccent` dark
> en 8.11 — motivo de más para reconciliar el valor con `arquitecto-software`/`dev-flutter` antes
> de implementar dark).

### 8.7 Colores de marca reservados (Mi salud / Emergencia / IA) — no forman parte del set base

Estos tokens existen en `app_colors.dart` pero no estaban documentados en la sección 2 de este
archivo. Se incluyen acá por completitud, ya que el tema oscuro los necesita igual. Ver 8.11.

### 8.8 Verificación de contraste (WCAG) — dark

Ratios calculados con la fórmula de luminancia relativa de WCAG 2.x sobre los HEX finales:

| Par | Ratio | Nivel |
|---|---|---|
| `textPrimary` sobre `background` | ~16.0:1 | AAA |
| `textPrimary` sobre `surface` | ~14.7:1 | AAA |
| `textSecondary` sobre `surface` | ~7.5:1 | AAA (supera holgadamente el AA de texto normal) |
| `onPrimary` (#08302B) sobre `primary` (#4FBDB0) | ~6.3:1 | AA para texto normal (mejora respecto al claro, que solo llegaba a AA large/bold) |
| `onSecondary` (#452016) sobre `secondary` (#F59A82) | ~6.7:1 | AA |
| `error` (#E2727A) sobre `surface` | ~5.4:1 | AA |
| `error` sobre `errorContainer` (rol `onErrorContainer`) | ~5.0:1 | AA |
| `warning` (#F0C05A) sobre `surface` | ~9.7:1 | AAA |
| `info` (#6FA8E0) sobre `surface` | ~6.6:1 | AA/AAA |
| `success` (#6FCB8E) sobre `surface` | ~8.4:1 | AAA |
| `outlineStrong`/`textDisabled` (#5C7975) sobre `surface` | ~3.5:1 | Por debajo de AA de texto (intencional: disabled/placeholder, exento). Cumple el umbral de 3:1 para límites de componentes UI (WCAG 1.4.11). |

Igual que en claro (2.6): nunca comunicar estado solo por color; error siempre lleva ícono +
texto; fortaleza y ánimo siempre llevan etiqueta textual.

### 8.9 Elevación y sombras (dark)

Las sombras negras del claro (`elev1`, `elev2`) casi no se perciben sobre un fondo ya oscuro. En
dark se reemplazan por **elevación tonal** (superficie más clara) y bordes sutiles, no por más
sombra:

| Token | Claro | Oscuro |
|---|---|---|
| `elev0` | sin sombra, `outline` 1 dp | Igual (sin sombra, `outline` dark 1 dp). |
| `elev1` | y-offset 2, blur 8, `#16201F` @ 6% | Sin sombra. Fondo pasa de `surface` a `surfaceVariant` (tono más claro) + opcional borde 1 dp `outline`. |
| `elev2` | y-offset 8, blur 24, `#16201F` @ 12% | Sin sombra. Fondo `surfaceVariant` (en vez de `surface`) + borde superior sutil 1 dp `outline` en bottom sheet. Scrim de fondo sube de negro @ 40% a **negro @ 55%** (se necesita más opacidad para separar visualmente el modal de un fondo que ya es oscuro). |

### 8.10 Componentes base — adaptación a dark

| Componente | Ajustes en dark |
|---|---|
| **Botón primario** (5.1) | Fondo `primary` (dark), texto `onPrimary` (dark). Pressed: `primaryHover` (dark). **Disabled** (cambia de criterio respecto al claro): fondo `surfaceVariant`, texto `textDisabled` — en dark, rellenar el botón con un gris claro (equivalente al `outline` del claro) se ve fuera de lugar; se usa una superficie oscura neutra + texto tenue, igual al patrón M3 de "12% overlay sobre surface". Loading: `CircularProgressIndicator` `onPrimary` (dark). |
| **Botón secundario/texto** (5.2) | Texto `primary` (dark), sin fondo. |
| **Campo de texto** (5.3) | Fondo `surface` (dark), borde `outline` (dark). Foco: borde 2 dp `primary` (dark). Error: borde 2 dp `error` (dark) + texto error `error` (dark). Disabled: fondo `surfaceVariant` (dark), texto `textDisabled` (dark). Valor `textPrimary` (dark); placeholder `textDisabled` (dark). |
| **Checkbox** (5.4) | Sin marcar: borde 2 dp `outlineStrong` (dark). Marcado: relleno `primary` (dark), check `onPrimary` (dark). |
| **Barra de progreso del wizard** (5.5) | Track `surfaceVariant` (dark). Relleno `primary` (dark). |
| **Indicador de fortaleza** (5.6) | Segmentos activos con `strengthWeak/Medium/Strong` (dark); inactivos `surfaceVariant` (dark). |
| **Banner de error** (5.7) | Fondo `errorContainer` (dark), ícono y texto `error` (dark). |
| **App bar de flujo** (5.8) | Fondo `background` (dark) en reposo. Al hacer scroll, en vez de `elev1` (sombra): fondo `surfaceVariant` (dark) + borde inferior sutil 1 dp `outline` (dark). Ícono "atrás" `textPrimary` (dark). |
| **Bottom sheet** (5.9) | Fondo `surfaceVariant` (dark) en vez de `surface` (técnica de elevación tonal, ver 8.9), esquinas `radiusXl`, sin sombra. Grabber `outlineStrong` (dark) (necesita algo más de contraste que `outline` al estar sobre una superficie ya elevada). Scrim negro @ 55%. |
| **Selector de ánimo carrusel** (5.10) | Blob: fondo del color de escala (dark, 8.6) a **alpha 0.20** (subido desde 0.16 del claro), anillo 3 dp al mismo color alpha 1.0. Label `textPrimary` (dark). Flechas deshabilitadas en `textDisabled` (dark). El resto de la interacción (swipe, haptics, transición 250 ms) no cambia. |

### 8.11 Acentos de módulo — complemento (no forman parte del set base solicitado)

Tokens ya presentes en `app_colors.dart` para sub-módulos específicos (Mi salud, Hábitos,
Emergencia, IA), sin equivalente dark aún. Se proponen acá para que `dev-flutter` no quede
bloqueado más adelante; **no forman parte del pedido original de esta sección** y conviene
validarlos puntualmente con cada pantalla antes de darlos por definitivos:

| Token | Claro | Oscuro | Notas |
|---|---|---|---|
| `healthAccent` | `#E11D48` | `#F27C93` | Acento del módulo Ficha de salud. |
| `healthContainer` | `#FFE4E6` | `#3B1622` | |
| `habitsAccent` | `#EA580C` | `#F0935F` | Acento del sub-módulo Hábitos de vida. |
| `habitsContainer` | `#FFEDD5` | `#3A2414` | |
| `moodAccent` | `#7C3AED` | `#B69CF0` | Acento del sub-módulo Estados de ánimo dentro de Mi salud (distinto de la escala de 5 tonos de 8.6). |
| `moodContainer` | `#EDE9FE` | `#2A2140` | |
| `emergencyRed` | `#D14343` | `#E2727A` (= `error` dark) | En claro ya coincide con `error`; se mantiene la duplicación intencional en dark. |
| `emergencyContainer` | `#FEE2E2` | `#3B1E20` (= `errorContainer` dark) | |
| `aiAccent` | `#6366F1` | `#A5A8F5` | Contenido generado por IA (Resumen inteligente). |
| `aiContainer` | `#E0E7FF` | `#26254A` | |

### 8.12 Notas de implementación (Flutter)

- `AppColors` pasa de una única clase estática a exponer dos variantes (por ejemplo
  `AppColors.light` / `AppColors.dark`, o una clase por brillo) para no romper el patrón de
  constantes ya usado; `AppTheme` gana un segundo `ThemeData get dark`, con `ColorScheme`
  construido igual que `light` (sección 7) pero con `brightness: Brightness.dark` y los HEX de
  esta sección.
- `AppStatusColors` (`ThemeExtension`) necesita una segunda instancia estática, por ejemplo
  `AppStatusColors.dark`, con los valores de 8.4/8.5, y `AppTheme.dark` debe registrarla en
  `extensions: const [AppStatusColors.dark]`.
- La escala de ánimo (8.6) y los acentos de módulo (8.11) no viven en `AppStatusColors`
  (son constantes directas de `AppColors`); si se quiere que cambien con el tema en vez de leerse
  siempre del mismo lugar, conviene evaluar con `arquitecto-software`/`dev-flutter` si conviene
  moverlos también a una `ThemeExtension` en esta instancia, ya que hoy son `static const`
  fijos sin variante por brillo.
- `main.dart`/`MaterialApp`: `themeMode: ThemeMode.system`, `theme: AppTheme().light`,
  `darkTheme: AppTheme().dark`.
- Antes de implementar, reconciliar la discrepancia doc↔código de `moodScaleBad` señalada en 8.6.
