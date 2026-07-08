# US-36 Observaciones de bienestar — Sistema de diseño

> Alertas heurísticas automáticas (sin IA generativa, sin diagnóstico) sobre patrones recientes
> de ánimo y cumplimiento de hábitos de la persona a cargo. Hereda el sistema de diseño global
> de CareWell definido en `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Este archivo documenta únicamente las decisiones específicas del componente
> "Observaciones de bienestar" dentro del hub de Mi salud.

---

## 1. Continuidad con el hub de Mi salud

No es una card de acceso a un sub-módulo (no forma parte del grid 2×2 de
`health_screen.dart`): es una **tarjeta contenedora independiente**, condicional, que se ubica
por encima del grid. Ver ubicación exacta en `01-flujo-navegacion.md` §3 y layout completo en
`02-tarjeta-observaciones-bienestar.md`.

Reutiliza tokens ya existentes en `AppColors` (`care_well_app/lib/config/theme/app_colors.dart`)
sin crear ninguno nuevo:

| Concepto                          | Token / valor                                      |
|------------------------------------|-----------------------------------------------------|
| Ícono/header del contenedor        | `primary #1A8C82` sobre `primaryContainer #C9EDE8`  |
| Severidad "Atención"               | `warning #E0A100` / `warningContainer #FBF0CF`      |
| Severidad "Informativa"            | `info #2E77C2` / `infoContainer #DBE9FB`            |
| Categoría Ánimo                    | `moodAccent #7C3AED` / `moodContainer #EDE9FE`      |
| Categoría Hábito                   | `habitsAccent #EA580C` / `habitsContainer #FFEDD5`  |

**Decisión deliberada de exclusión:** no se usa `emergencyRed`/`emergencyContainer` (reservado a
Emergencia) ni `error`/`errorContainer` (reservado a fallos técnicos). El tono más urgente
disponible para este componente es `warning`/`info`, nunca rojo.

**Actualización (interacción colapsado/expandido):** la regla "el header usa el teal de marca,
no un color de estado" descripta originalmente en este párrafo **aplica únicamente al estado
expandido** de la tarjeta (cuando las filas ya están visibles y aportan su propia gradación
semántica). Desde la revisión de interacción que introdujo el banner colapsado por defecto, ese
banner **sí** refleja la severidad más urgente presente (usa los mismos tokens `warning`/
`warningContainer` o `info`/`infoContainer` ya definidos en §2, nunca un token nuevo) porque, en
ese estado, es la única señal visible sobre el conjunto de observaciones. El detalle completo de
ambos tratamientos (colapsado con severidad vs. expandido neutro) está en
`02-tarjeta-observaciones-bienestar.md` → "¿Por qué el banner colapsado reutiliza exactamente el
lenguaje visual de una fila de severidad?".

---

## 2. Severidad — codificación visual (nunca solo color)

Regla general del sistema (identidad visual §2.6): **ningún estado se comunica solo por color**.
Por eso cada fila de alerta combina tres señales redundantes: orden, color de borde/fondo y una
etiqueta de texto explícita con ícono propio.

| Severidad     | Orden          | Fondo de fila                | Borde izq. 3px | Ícono + texto de etiqueta                          |
|----------------|----------------|-------------------------------|------------------|-----------------------------------------------------|
| **Atención**   | Siempre arriba | `warningContainer #FBF0CF`    | `warning #E0A100`| ícono `priority_high` + texto "Atención", ambos en `#8A6400` (variante oscurecida del warning, **mismo criterio ya establecido** en `StatusChip` de Ficha de salud §3.6 para cumplir AA 4.5:1 sobre fondo claro) |
| **Informativa**| Siempre abajo  | `surface #FFFFFF` + borde 1px `outline #C5CECE` | `info #2E77C2` | ícono `info` + texto "Informativa", en `info #2E77C2` directo (ya usado sin ajuste en Ficha de salud para Enfermedades — el ratio de este token es suficiente sin oscurecer) |

**Por qué la fila Informativa no lleva `infoContainer` de fondo:** si ambas severidades llevaran
fondo tintado, la tarjeta se percibiría como "toda alarmada" (dos bloques de color apilados).
Reservar el tinte de fondo solo para Atención genera una jerarquía visual real: lo urgente pesa
más, lo informativo es liviano y casi neutro — coherente con "Calma operativa" y con la
instrucción explícita de no alarmar de más.

---

## 3. Categoría — codificación visual (ícono + color, nunca redundante con texto)

La categoría (Ánimo / Hábito) se comunica **solo** mediante forma de ícono + color de acento,
sin etiqueta de texto adicional — mismo criterio ya usado en Ficha de salud para diferenciar
Antecedentes/Alergias/Enfermedades (ahí tampoco hay un label "Antecedente:" redundante; el ícono
y el color ya lo dicen). No es una violación de la regla "nunca solo color" porque el ícono
**cambia de forma** entre categorías (no es el mismo glifo con distinto color).

| Categoría | Ícono                  | Círculo (28dp) fondo | Ícono color |
|-----------|--------------------------|------------------------|--------------|
| Ánimo     | `mood` (mismo glifo que la card del hub) | `moodContainer #EDE9FE` | `moodAccent #7C3AED` |
| Hábito    | `directions_run` (mismo glifo que la card del hub) | `habitsContainer #FFEDD5` | `habitsAccent #EA580C` |

Se usa el **contenedor tenue + ícono coloreado** (patrón de `HealthListItemCard`, Ficha de
salud), no el círculo sólido con ícono blanco de las tiles de navegación del hub — este
componente es una fila de lista informativa, no un acceso principal, y debe pesar visualmente
menos que las cards de navegación del grid.

---

## 4. Componentes específicos

### 4.1 `WellbeingObservationsCard` (contenedor)
> **Nota (interacción colapsado/expandido):** lo que sigue describe el contenedor en su estado
> **expandido**. Por defecto la tarjeta arranca **colapsada** (banner compacto con severidad
> agregada) y el usuario la expande a pedido — ver la especificación completa de ambos estados,
> la interacción de toggle y el layout colapsado en `02-tarjeta-observaciones-bienestar.md`. Los
> puntos de este apartado (fondo, radio, header neutro, subtítulo, filas) siguen describiendo
> correctamente el estado expandido, sin cambios.

- Fondo `surface #FFFFFF`, radio `radiusLg 16`, padding 16px, sombra `elev1`. Igual "peso" visual
  que las `HealthListSection` de Ficha de salud — se percibe como una tarjeta más del hub, no
  como un banner de sistema.
- Header (estado expandido): círculo 32dp `primaryContainer` + ícono `visibility` 18dp `primary`
  + título "Observaciones de bienestar" (`titleMedium`-like, 16px/700, `textPrimary`) + badge de
  contador total (mismo estilo que `health-section-badge` de Ficha: fondo `surfaceVariant`,
  texto `textSecondary`, 11px/700, radio full, padding 2px 8px) — ej. "3" + ícono
  `expand_more_rounded` 18dp `textSecondary` (affordance de colapsar).
- Subtítulo fijo debajo del header, 12px `textSecondary`, line-height 1.4: **"Generadas
  automáticamente a partir de tus registros recientes. No reemplazan una consulta profesional."**
  > Nota de diseño (propuesta, no parte de la especificación funcional original): este
  > microcopy es una adición de UX para reforzar en pantalla, con lenguaje simple, la aclaración
  > "sin diagnóstico" ya definida a nivel de producto/documentación. Si `analista-funcional`
  > prefiere una redacción distinta para el documento LaTeX, esta línea debe mantenerse
  > sincronizada con esa redacción.
- Debajo, lista vertical de `WellbeingObservationRow`, gap 10px, **ya vienen ordenadas por
  severidad** (Atención primero) — el componente de presentación no reordena, solo pinta en el
  orden recibido.
- Sin footer, sin CTA, sin acción de "descartar todo": el único affordance es el tap por fila.
- **Sin límite visual duro de filas.** El diseño no trunca ni pagina: todas las alertas se
  apilan y el conjunto scrollea junto con el resto del hub (la tarjeta vive dentro del
  `SingleChildScrollView` del hub, no en un contenedor de altura fija). Si en la práctica el
  número de alertas por hábito pudiera crecer sin límite (una por hábito abandonado), se
  recomienda que el **backend** acote la cantidad de observaciones activas devueltas — no es
  responsabilidad de esta capa de presentación agregar un "ver más" que no fue pedido. A
  coordinar con `arquitecto-software` si se detecta necesario.
- Animación de entrada: `FadeInDown` (paquete `animate_do`), 350 ms, igual criterio que otras
  cards del hub (`FullWidthActionTile` usa `FadeInUp`; se elige la dirección opuesta para
  esta tarjeta, ya que al estar más arriba en el layout tiene más sentido que "caiga" desde
  arriba en vez de "subir").

### 4.2 `WellbeingObservationRow` (fila de alerta)
- Contenedor: radio `radiusMd 12`, padding 12px, borde izquierdo 3px del color de severidad
  (§2), fondo según severidad (§2). Objetivo táctil >= 48dp de alto (se garantiza con el padding
  + contenido, sin forzar una altura fija — el mensaje puede necesitar más de 2 líneas).
- Estructura interna (`Row` flex):
  1. Círculo de categoría 28dp (§3), alineado al tope del bloque de texto.
  2. Columna de contenido (flex, gap 4px vertical):
     - Etiqueta de severidad: ícono 14dp + texto 11px/700 uppercase, letter-spacing 0.3px,
       color según §2.
     - Mensaje: texto **completo, sin truncar** (`bodyMedium`-like, 14px/400, `textPrimary`,
       line-height 1.4). Se prioriza la legibilidad completa del mensaje de salud por sobre la
       compacidad — coherente con el principio de accesibilidad del proyecto; la fila crece en
       alto lo que necesite.
  3. `chevron_right` 20dp, color `textSecondary`, alineado verticalmente al centro del círculo
     de categoría (no al centro de todo el bloque, para que no "flote" raro si el mensaje ocupa
     3 líneas). Es el mismo ícono de affordance ya usado en `HealthCategoryCard` del hub — refuerza
     que esta fila **navega a otra pantalla** (a diferencia de las cards de Ficha de salud, que
     abren un sheet de edición local; acá el criterio es distinto porque el destino es una
     pantalla de detalle ya existente, no una edición in-place).
- **Feedback pressed:** toda la fila oscurece ~5% al presionar (mismo criterio que `tl-card` de
  Línea de tiempo), ripple estándar de Material.
- **No lleva ningún ícono de cierre/descarte.** Decisión de producto ya confirmada: las alertas
  son efímeras y se recalculan solas; no hay affordance de "X" en ningún estado.

---

## 5. Datos que la fila necesita del backend (nota para `arquitecto-software`)

Para poder navegar correctamente al tocar una fila, la capa de presentación necesita, por cada
observación:

| Campo         | Tipo                                                                 | Uso en UI |
|----------------|-----------------------------------------------------------------------|-----------|
| `tipo`         | enum: `animo_bajo_sostenido` \| `deterioro_animo` \| `abandono_habito` \| `caida_cumplimiento` | Solo informativo/telemetría; la UI no decide destino por `tipo`, sino por `categoria`. |
| `severidad`    | enum: `atencion` \| `informativa`                                     | Orden + color de fila (§2). |
| `categoria`    | enum: `animo` \| `habito`                                             | Ícono/color de fila (§3) + define destino de navegación. |
| `mensaje`      | texto ya interpolado por backend                                      | Contenido de la fila, se muestra tal cual. |
| `habitoId`     | identificador del hábito (**solo si `categoria == habito`**)          | Necesario para `context.pushNamed(AppRoutes.healthHabitDetailName, ...)` con el id correcto — a confirmar que el DataView de observaciones lo incluya. |

Las alertas de categoría `animo` no necesitan un id: navegan siempre al historial de ánimo
general de la persona de contexto (no a un registro puntual).

---

## 6. Notas de accesibilidad

- Severidad nunca depende solo de color/orden: siempre hay ícono + texto ("Atención"/
  "Informativa").
- Categoría se diferencia por forma de ícono, no solo color — cumple igual el espíritu de la
  regla aunque el patrón ya esté precedentado sin texto redundante en Ficha de salud.
- El mensaje nunca se trunca: la información de salud completa siempre es visible sin necesidad
  de un tap adicional para "expandir".
- Objetivo táctil de cada fila >= 48dp de alto.
- Contraste: "Atención" usa `#8A6400` (no el `warning` crudo) sobre `warningContainer`, mismo
  ajuste ya validado en el sistema para ese par fondo/texto.
- **Banner colapsado:** el toggle expandir/colapsar tiene objetivo táctil >= 48dp (todo el
  header es tappable, no solo el ícono de chevron). Cuando el banner refleja severidad
  "Atención", la urgencia se comunica con tres señales redundantes (fondo + ícono `priority_high`
  + texto explícito "requieren atención"), igual que a nivel de fila — ver
  `02-tarjeta-observaciones-bienestar.md`.
