# US-36 Observaciones de bienestar — Componente: WellbeingObservationsCard

> **Revisión de interacción (post feedback de producto):** este componente ya **no se muestra
> expandido de entrada**. Ahora aparece **colapsado por defecto**, como un banner compacto con
> el contador de observaciones, y el usuario lo expande a pedido. El objetivo, los datos y la
> lista interna de alertas (una vez expandida) **no cambian** respecto a la versión anterior —
> lo que cambia es que ya no se le "regala" toda esa información de entrada al hub.

## Objetivo
Avisar, dentro del hub de Mi salud, que existen alertas heurísticas automáticas (no
diagnósticas) sobre patrones recientes de ánimo y de cumplimiento de hábitos de la persona a
cargo — **sin imponer su detalle completo de entrada** — y permitir que la persona cuidadora
las expanda cuando quiera profundizar, priorizando siempre las más urgentes ("Atención") sobre
las meramente informativas, y ofreciendo desde la lista expandida un atajo directo a la
pantalla de dominio correspondiente.

## Layout (jerarquía de componentes)

```
Hub Mi salud — SingleChildScrollView
  [si observaciones.isNotEmpty]
  WellbeingObservationsCard (StatefulWidget local; expanded: bool, default false)
    │
    ├── Header (siempre visible, es el único tap target de expandir/colapsar)
    │     │
    │     ├── [expanded == false] → _CollapsedHeader  (ver §Estados "Colapsado")
    │     │       ├── Círculo 28dp (tinte según severidad agregada — ver §Estados)
    │     │       ├── Columna
    │     │       │     ├── "Observaciones de bienestar" (14px/700)
    │     │       │     └── [solo si hay >= 1 "Atención"] caption "X de N requieren atención"
    │     │       │            (12px/700, `#8A6400`, con ícono `priority_high` 14dp)
    │     │       ├── Badge contador ("N")
    │     │       └── Ícono `chevron_right_rounded` 18dp `textSecondary`
    │     │
    │     └── [expanded == true] → _ExpandedHeader  (idéntico al header original ya diseñado)
    │             ├── Círculo 32dp `primaryContainer` + ícono `visibility` `primary`
    │             ├── "Observaciones de bienestar" (16px/700)
    │             ├── Badge contador ("N")
    │             └── Ícono `expand_more_rounded` 18dp `textSecondary`
    │
    └── AnimatedSize (220ms, easeInOut — mismo primitivo ya usado en
        `HealthEventsMonthList`/`HealthEventDayGroupHeader`, US-30/33)
          [expanded == false] → SizedBox.shrink()
          [expanded == true]  →
            Column
              ├── Subtítulo — "Generadas automáticamente a partir de tus registros recientes.
              │                No reemplazan una consulta profesional."
              └── Lista vertical (gap 10px), ordenada Atención → Informativa
                    WellbeingObservationRow × N   (sin cambios — ver detalle abajo)
                      ├── Círculo de categoría 28dp (moodContainer/habitsContainer + ícono acento)
                      ├── Columna de contenido
                      │     ├── Etiqueta de severidad (ícono + texto, ver 00-sistema-diseno.md §2)
                      │     └── Mensaje completo (sin truncar)
                      └── chevron_right (affordance de navegación a otra pantalla)
  SizedBox (separación xl = 24dp) — el gap hacia el grid es siempre el mismo, sin importar si
  la tarjeta está colapsada o expandida (crece hacia abajo, no empuja el gap).
  GridView 2×2 (sin cambios — Hábitos / Ficha de salud / Eventos / Estado de ánimo)
  FullWidthActionTile "Línea de tiempo" (sin cambios)
```

`WellbeingObservationRow` (fila de alerta dentro de la lista expandida) **no tiene cambios** de
diseño respecto a la versión anterior: ver `00-sistema-diseno.md` §2, §3 y §4.2 para su
especificación completa (colores, tipografía, feedback pressed, accesibilidad).

## ¿Por qué el banner colapsado reutiliza exactamente el lenguaje visual de una fila de severidad?

En vez de inventar un tercer tratamiento visual ("neutro"/"resumen"), el banner colapsado toma
prestado — literalmente los mismos tokens y estructura — el tratamiento ya definido para las
filas individuales en `00-sistema-diseno.md` §2:

| Severidad agregada presente          | Fondo del banner                                | Borde izq. 3px | Círculo 28dp (ícono)                                |
|----------------------------------------|---------------------------------------------------|------------------|--------------------------------------------------------|
| Hay al menos 1 observación "Atención" | `warningContainer #FBF0CF`                        | `warning #E0A100`| Círculo **sólido** `warning #E0A100` + ícono `priority_high` **blanco** |
| Todas las observaciones son "Informativa" | `surface #FFFFFF` + borde 1px `outline #C5CECE` | `info #2E77C2`   | Círculo **sólido** `info #2E77C2` + ícono `info` **blanco** |

**Por qué el ícono del banner es un círculo sólido (no el "contenedor tenue + ícono coloreado"
que usan las filas):** es el mismo patrón que ya usan los `nav-tile` del grid 2×2 del hub
(círculo sólido de color + ícono blanco). Se elige a propósito para que el banner colapsado se
perciba con **más peso visual que una fila individual** — es un resumen/indicador, no un ítem de
lista — mientras que las filas, una vez expandidas, mantienen su tratamiento más liviano
("container tenue") ya documentado en §3. Esta diferencia de tratamiento (sólido arriba, tenue
abajo) refuerza la jerarquía: primero el resumen, después el detalle.

Esto responde directamente a la pregunta de diseño planteada: **el colapsado sí refleja la
severidad más urgente presente, nunca se mantiene neutro si hay algo que amerite atención.**
Motivo: en estado colapsado, el banner es la **única** señal visible sobre el estado de las
observaciones — no hay filas debajo que ya comuniquen la urgencia por su cuenta. Ocultar la
severidad detrás de un color de marca neutro en ese momento sería, paradójicamente, alarmar de
*menos* de lo necesario y obligar a un tap extra solo para enterarse de que algo requiere
atención.

**Contraparte — por qué el header SÍ vuelve a ser neutro (teal de marca) una vez expandido:**
la decisión original de `00-sistema-diseno.md` §1 ("el header usa `primary`, no un color de
estado, porque son las filas las que aportan la gradación semántica") se mantiene, pero ahora
se aplica **solo al estado expandido**. Una vez que las filas están visibles, repetir el tinte
de severidad en el header sería redundante y haría que la tarjeta se perciba "toda alarmada"
(mismo argumento que ya usa §2 para no tintar de fondo la fila Informativa). El color se
"muda" de lugar según cuánta información ya es visible:
- **Colapsado:** el header concentra la señal de severidad (es lo único que hay).
- **Expandido:** el header vuelve a ser neutro; la severidad ya vive en cada fila.

No se crea ningún token de color nuevo — se reutilizan exclusivamente los ya definidos en
`00-sistema-diseno.md` §1/§2 (`warning`, `warningContainer`, `info`, `infoContainer`, `primary`,
`primaryContainer`), en las dos combinaciones fijas de arriba.

## Estados

### Estado "Colapsado — con Atención" (default, alertas mixtas o solo Atención) — ver `html/01-hub-con-observaciones.html`
- Banner de una o dos líneas, tinte `warningContainer`/borde `warning` (tabla de arriba).
- Línea 1: "Observaciones de bienestar" + badge contador (ej. "3") + `chevron_right_rounded`.
- Línea 2 (solo si hay >= 1 "Atención"): ícono `priority_high` 14dp + texto "2 de 3 requieren
  atención" en `#8A6400`, 12px/700. Si las 3 fueran "Atención", el texto dice "3 de 3 requieren
  atención" (no se hace un caso especial de "todas" para no agregar una rama de lógica extra;
  `dev-flutter` puede optar por simplificar a "Todas requieren atención" como pulido opcional,
  no obligatorio).
- Objetivo táctil de todo el banner >= 48dp de alto (se cumple con el padding + 1 o 2 líneas de
  contenido).
- Tap en cualquier punto del banner → expande in-place (ver Interacciones).

### Estado "Colapsado — solo Informativa" (sin ninguna "Atención") — ver `html/04-indicador-colapsado-variantes.html`
- Banner de una sola línea (más angosto que el caso anterior): fondo `surface` blanco + borde
  1px `outline` + borde izq. 3px `info`, ícono `info` en el círculo.
- Línea única: "Observaciones de bienestar" + badge contador + `chevron_right_rounded`. Sin
  segunda línea (no hay nada urgente que anunciar aparte del conteo).
- Mismo objetivo táctil >= 48dp, mismo tap para expandir.

### Estado "Expandido" (alertas mixtas: Atención + Informativa) — ver `html/03-hub-observaciones-expandido.html`
- El header vuelve al tratamiento neutro original: círculo 32dp `primaryContainer` + ícono
  `visibility` `primary`, título 16px/700, badge contador, ícono `expand_more_rounded`.
- Debajo del header, `AnimatedSize` revela el subtítulo fijo y la lista completa de filas, con
  las de severidad "Atención" arriba (fondo `warningContainer`) y las de "Informativa" abajo
  (fondo `surface` + borde `outline`) — **contenido idéntico al ya documentado**, sin cambios:
  1. **Atención / Ánimo** — "El ánimo de Alicia se registró como bajo en los últimos 3
     registros. Podría ser un buen momento para estar más atento o consultar con un
     profesional." → tap navega a Historial de ánimo.
  2. **Atención / Hábito** — "Hace 9 días que no se registra el hábito 'Caminata matutina', que
     antes se realizaba con regularidad." → tap navega al detalle del hábito "Caminata
     matutina".
  3. **Informativa / Hábito** — "El hábito 'Toma de medicación' se está registrando con menos
     frecuencia que lo habitual." → tap navega al detalle del hábito "Toma de medicación".
- Tap en el header (ahora con ícono `expand_more_rounded`) → vuelve a colapsar in-place.

### Estado "una sola alerta"
No requiere mockup separado: mismo layout con una única `WellbeingObservationRow` al expandir.
El badge del header muestra "1". Si esa única alerta es "Atención", el colapsado muestra "1 de 1
requiere atención" (singular: "requiere", no "requieren").

### Estado "sin alertas" (0 observaciones)
**No cambia respecto a la especificación anterior.** La tarjeta no se renderiza, ni colapsada ni
expandida. No existe un mockup para este estado porque no hay nada que mostrar: el hub queda
visualmente idéntico al ya documentado en `28 - Registro de habitos/html/00-mi-salud-hub.html`.
Ver también `01-flujo-navegacion.md` §5 para el tratamiento equivalente de los estados de carga
y error (mismo criterio: invisibilidad).

### Referencia de variantes de alerta (las 4 combinaciones posibles, dentro de la lista expandida) — ver `html/02-tarjeta-variantes-tipos.html`
Sin cambios: hoja de referencia aislada del componente que documenta, fila por fila, las 4
combinaciones tipo/severidad/categoría definidas en la especificación funcional. Esta hoja
representa el **contenido interno de la lista expandida** (no el banner colapsado), por eso no
requirió actualización con este cambio de interacción.

| # | Tipo                        | Severidad     | Categoría | Mensaje de ejemplo |
|---|-------------------------------|----------------|-----------|----------------------|
| 1 | `animo_bajo_sostenido`        | Atención       | Ánimo     | "El ánimo de Alicia se registró como bajo en los últimos 3 registros. Podría ser un buen momento para estar más atento o consultar con un profesional." |
| 2 | `deterioro_animo`             | Informativa    | Ánimo     | "El ánimo de Alicia muestra una tendencia a la baja respecto a las semanas anteriores." |
| 3 | `abandono_habito`             | Atención       | Hábito    | "Hace 9 días que no se registra el hábito 'Caminata matutina', que antes se realizaba con regularidad." |
| 4 | `caida_cumplimiento`          | Informativa    | Hábito    | "El hábito 'Toma de medicación' se está registrando con menos frecuencia que lo habitual." |

## Interacciones

### Expandir / colapsar (nuevo)
- **Tap en cualquier punto del header** (colapsado o expandido) → alterna el estado local
  `expanded` (`true`/`false`). Mismo patrón exacto ya implementado en
  `HealthEventDayGroupHeader`/`HealthEventsMonthList` (US-30/33): `InkWell` en el header +
  `AnimatedSize` (220ms, `Curves.easeInOut`) envolviendo el contenido condicional, e ícono que
  alterna entre `chevron_right_rounded` (colapsado) y `expand_more_rounded` (expandido) — sin
  rotación animada del ícono, solo swap del glifo, igual que el precedente.
- **No hay límite de toggles**: el usuario puede expandir y volver a colapsar tantas veces como
  quiera dentro de la misma visita al hub.
- **No es una navegación**: no hay push, no hay bottom sheet, no hay ruta nueva de `go_router`.
  Se eligió expandir in-place (empujando el grid hacia abajo) en vez de abrir una pantalla o
  sheet aparte por tres razones:
  1. **Consistencia con un patrón ya existente y ya implementado** en el mismo módulo de Mi
     salud (Eventos de salud, US-30/33) — reduce la superficie de patrones distintos que
     `dev-flutter` tiene que mantener y que la persona cuidadora tiene que aprender.
  2. **Menor fricción**: un bottom sheet o pantalla aparte agrega una transición y un "volver"
     extra para información que, una vez expandida, cabe perfectamente en el flujo normal de
     scroll del hub (la lista nunca fue larga — ver "sin límite visual duro" en
     `00-sistema-diseno.md` §4.1, y en la práctica se espera un puñado de alertas, no decenas).
  3. **Más simple de implementar**: un `bool` local + `AnimatedSize` es sensiblemente menos
     código y menos superficie de error (no hay que gestionar rutas, `WillPopScope`,
     `showModalBottomSheet` ni reconciliar el estado con el resto del hub) que una pantalla o
     sheet nuevos.
- El grid de sub-módulos y "Línea de tiempo" se desplazan hacia abajo cuando se expande (no hay
  overlay ni recorte); el usuario puede seguir scrolleando el hub con normalidad en cualquiera
  de los dos estados.

### Tap en una fila (dentro de la lista expandida) — sin cambios
- Tap en una fila de categoría **Hábito** → navega a `health-habit-detail` con el `habitoId` de
  la observación (ver `00-sistema-diseno.md` §5 sobre el dato requerido del backend).
- Tap en una fila de categoría **Ánimo** → navega a `health-mood-history` (historial general de
  ánimo de la persona de contexto; no hay un "registro puntual" al que apuntar).
- Feedback pressed: la fila tocada oscurece ~5% (ripple estándar).
- No hay swipe-to-dismiss, ni long-press, ni menú contextual en ninguna fila — el único gesto
  soportado sobre una fila es el tap simple.
- Scroll: la tarjeta (colapsada o expandida) forma parte del scroll general del hub; no tiene
  scroll propio ni altura máxima fija.

## Navegación de entrada/salida
- **Entrada:** no aplica navegación de entrada — el componente aparece "in place" al entrar al
  hub de Mi salud, **siempre colapsado por defecto**, condicionado a que existan observaciones
  para la persona de contexto.
- **Colapsar/expandir:** interacción local, sin navegación (ver Interacciones arriba).
- **Salida (desde una fila, solo en estado expandido):** tap en una fila → push (slide-right +
  fade) a Historial de ánimo o Detalle de hábito, según la categoría de la fila tocada. Volver
  con ARROW_BACK regresa al hub. Como la pantalla del hub típicamente **no se destruye** al
  hacer push sobre ella (queda debajo en el stack de `go_router`), el estado `expanded` del
  `State` local se conserva tal cual estaba antes de navegar — si el usuario expandió la
  tarjeta, tocó una fila y volvió, la va a encontrar expandida. Esto es intencional (respeta la
  última acción del usuario) y no requiere lógica adicional.
- **Reinicio del estado de expansión:** cambiar la persona de contexto en el `ContextSelector`
  reinicia `expanded` a `false` (colapsado) — mismo criterio de "empezar de cero" que ya aplica
  al recálculo de la lista de observaciones en sí (ver `01-flujo-navegacion.md` §5). Salir del
  hub y volver a entrar más tarde (si el widget llega a destruirse, ej. cierre de sesión o el
  hub deja de estar en el stack) también restablece el default colapsado, al ser estado de
  presentación puramente local (no persiste en ningún provider ni en backend).
