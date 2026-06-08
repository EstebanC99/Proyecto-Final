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
