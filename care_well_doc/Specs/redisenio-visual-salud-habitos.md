# Rediseño visual — Mi salud (hub) y Hábitos de vida

> **Destinatario:** `dev-flutter`.
> **Autor:** `arquitecto-software`.
> **Fuente visual:** `care_well_doc/Interfaces/Redisenios visuales/carewell-salud-mockup.html`
> y `carewell-habitos-mockup.html`.
> **Alcance:** solo capa `presentation` del frontend + 2 providers nuevos. **No** toca
> `domain`, `infrastructure` ni el backend.
> **Estado:** decisiones D1 a D5 **confirmadas por el cliente** (2026-08-12). En particular:
> check de habito realizado en `primary` (D2) y `RefreshIndicator` en el hub de Salud. No quedan
> decisiones abiertas: el plan se ejecuta tal cual esta escrito.

---

## 0. Resumen ejecutivo

| Pantalla | Archivo | Que cambia |
|---|---|---|
| Mi salud (hub) | `presentation/screens/health/health_screen.dart` | Ficha de salud pasa a card destacada con chips de resumen; grid 2x2 de 4 tarjetas iguales pasa a 2 tarjetas con metrica + 1 tile ancho de Eventos; "Linea de tiempo" pasa a boton solido |
| Habitos de vida | `presentation/screens/health/habits_screen.dart` | Header de progreso del dia; agrupacion Pendientes/Completados; card de habito con color por tipo y check circular en lugar del chip "Pendiente/Realizado" |

**Exclusion pedida explicitamente:** los *dots* de "habitos realizados anteriormente" del mockup
de Habitos (fila de 7 puntitos bajo el titulo) **NO se implementan**. Consecuencia tecnica: no
hace falta traer historial de realizaciones en el listado, asi que el contrato de
`HabitoVidaRepository` queda intacto.

---

## 1. Decisiones de diseño (con alternativas)

### D1 - Colores por tipo de habito: helper sobre tokens existentes, sin tokens nuevos
El mockup usa 5 pares de color por tipo (naranja, verde, indigo, celeste, teal). La app no tiene
tokens de "tipo de habito" en `AppPalette`.

- **Recomendado:** crear `TipoHabitoTheme` (espejo exacto de
  `widgets/agenda/tipo_evento_theme.dart`) que mapee id de tipo a `IconData` + acento +
  contenedor **usando tokens ya existentes**. Ventaja: funciona en claro y oscuro sin ampliar la
  paleta, y no hay hex sueltos.
- **Alternativa:** agregar 10 tokens nuevos (`habitFoodAccent/Container`, etc.) a `AppPalette`
  claro + oscuro. Mas fiel al mockup, pero infla una paleta ya grande y obliga a definir y testear
  variantes oscuras de colores que solo se usan en un listado.

Mapeo recomendado:

| Tipo (`TiposHabitoConst`) | Icono | Acento | Contenedor |
|---|---|---|---|
| `actividadFisica` (1) | `Icons.directions_run` | `habitsAccent` | `habitsContainer` |
| `alimentacion` (2) | `Icons.restaurant` | `success` | `successContainer` |
| `sueno` (3) | `Icons.bedtime_outlined` | `moodAccent` | `moodContainer` |
| `hidratacion` (4) | `Icons.water_drop_outlined` | `info` | `infoContainer` |
| `otro` (5) / default | `Icons.self_improvement` | `primary` | `primaryContainer` |

### D2 - Color del check de habito realizado: `primary`
El mockup pinta el check con el teal de marca. La app venia usando `success` (chip verde
"Realizado").

- **Recomendado:** `primary` en el circulo de check, por fidelidad al mockup y porque el check ya
  comunica el estado por forma (relleno + tick) sin necesitar el verde.
- **Alternativa:** `success`, para no romper la convencion "verde = realizado" que ya usan el
  bottom sheet de realizacion y el detalle del habito.
- **En cualquier caso:** no mezclar. Si se elige `primary`, dejar el boton "Marcar como realizado"
  del `HabitoRealizacionSheet` como esta (verde) es una inconsistencia menor aceptada; anotarla
  como follow-up, no resolverla en esta tanda.

### D3 - Grid del hub: `IntrinsicHeight` + `Row`, no `GridView.count`
El `GridView.count(childAspectRatio: 0.9)` actual fija la relacion de aspecto y desborda con
escalas tipograficas grandes. Se reemplaza por el patron ya usado en `home_screen.dart`
(`IntrinsicHeight` + `Row` con dos `Expanded`), que deja que la altura la fije el contenido.

### D4 - Datos del hub: 3 consultas nuevas al abrir "Salud"
Las metricas del mockup ("2 de 5 completados hoy", "Hoy: alegre", "Ultimo: hace 3 dias", chips de
la ficha) obligan a que el hub deje de ser estatico: pasa a consultar ficha de salud, habitos,
animo de hoy y ultimo evento.

- **Recomendado (esta tanda):** reusar los providers existentes (`fichaSaludProvider`,
  `habitosProvider`, `animoHoyProvider`) y agregar `ultimoEventoSaludProvider`. Cada tarjeta
  degrada sola: si su fuente esta en `loading` o `error`, muestra la card **sin** la linea de
  metrica (nunca un error a pantalla completa).
- **Trade-off:** hasta 4 requests al entrar a Salud. Aceptable para el MVP porque son consultas
  chicas y cacheadas por Riverpod dentro de la sesion de pantalla.
- **Follow-up backend (fuera de alcance):** un read model `ResumenSaludDataView`
  (`GET /salud/resumen/{personaId}`) que devuelva las 4 metricas en una sola query. Si se hace,
  solo cambian los providers; los widgets no se tocan.

### D5 - Permisos: la ficha sigue gateada, el resto no
`fichaSaludProvider` solo se observa cuando `puedeVerSaludProvider` resolvio `true`; si no, no se
dispara la consulta (evita un 403 en el hub). La card de ficha conserva los 3 estados actuales de
`HealthCategoryCard`: *loading* (spinner en el trailing, sin atenuar), *sin permiso* (atenuada +
candado, sin tap), *habilitada* (chevron + chips).

---

## 2. Mapeo de tokens (mockup a AppPalette)

Prohibido dejar hex sueltos en los widgets. Equivalencias:

| Mockup | Token |
|---|---|
| `#FFF` (cards) | `surface` |
| `#F4F7F6` (fondo) | `background` |
| `#E5EAE6` (lineas) | `outline` |
| `#212121` / `#757575` | `textPrimary` / `textSecondary` |
| `#9AA5A0` (rotulos de seccion) | `textDisabled` |
| `#00897B` / `#00695C` (teal) | `primary` / `primaryHover` |
| `#E0F2F0` | `primaryContainer` |
| `#D63B57` + `#FDE7EB` (ficha) | `healthAccent` + `healthContainer` |
| `#FFEDD5` (habitos) | `habitsContainer` |
| `#E9EAF7` (animo) | `moodContainer` |
| `#E1F1F7` (eventos) | `infoContainer` |
| `#F6FAF9` (card completada) | `surfaceVariant` |
| `#E6EDEB` (barra apagada) | `surfaceVariant` |
| sombra `0 1px 3px rgba(0,0,0,.06)` | `AppSpacing.elev1` |
| radios 14-16 px | `AppSpacing.radiusLg` (16) |
| radios 12-13 px | `AppSpacing.radiusMd` (12) |

El `ContextAppBar` actual ya reproduce el appbar del mockup (avatar con anillo, rotulo en
versales, nombre, badge de rol, chevron): **no se toca**.

---

## 3. Fase 0 - Helpers compartidos

### 3.1 `presentation/widgets/shared/section_label.dart` (nuevo)
Rotulo de seccion en versales, usado por ambas pantallas ("SEGUIMIENTO", "PENDIENTES - 3",
"COMPLETADOS - 2").

```dart
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text, this.count, this.padding});
  final String text;         // se muestra en mayusculas
  final int? count;          // si != null, se concatena " · $count"
  final EdgeInsets? padding; // default: EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm)
}
```

Estilo: `fontSize: 11`, `fontWeight: w700`, `letterSpacing: 1.1`, `color: textDisabled`,
texto en mayusculas. `Semantics(header: true)`. Exportar en el barrel de `widgets/shared`.

### 3.2 `presentation/widgets/health/tipo_habito_theme.dart` (nuevo)
Copiar la forma de `widgets/agenda/tipo_evento_theme.dart`:

```dart
abstract final class TipoHabitoTheme {
  static IconData iconFor(int tipoId);
  static Color accentFor(BuildContext context, int tipoId);
  static Color containerFor(BuildContext context, int tipoId);
}
```

Tabla de D1. Exportar en `widgets/health/health.dart`.

**Refactor de deduplicacion (incluido, bajo riesgo):** eliminar los `_iconTipo` duplicados de
`habits_screen.dart:137` y `habit_detail_screen.dart:23` y usar `TipoHabitoTheme`.
`habit_form_screen.dart` mantiene su `_placeholder` (es copy, no tema visual).

### 3.3 `presentation/widgets/health/ultimo_registro_format.dart` (nuevo)
Funcion pura, testeable sin arbol de widgets:

```dart
/// Rotulo relativo de la ultima vez que paso algo ("hoy", "ayer", "hace 3 dias"...).
String textoRelativoDesde(DateTime fecha, {DateTime? ahora});
```

Reglas (todo truncado a año-mes-dia, hora local):
- 0 dias: `hoy`
- 1 dia: `ayer`
- 2 a 6 dias: `hace N dias`
- 7 a 13: `hace 1 semana`; 14 a 29: `hace N semanas`
- 30 a 59: `hace 1 mes`; 60 a 364: `hace N meses`
- 365 o mas: `hace mas de un año`

Sin `intl` (no hace falta) y con `ahora` inyectable para tests.

---

## 4. Fase 1 - Providers

### 4.1 `providers/health/evento_salud_providers.dart` - `ultimoEventoSaludProvider` (nuevo)
Necesario porque `eventoSaludAnteriorProvider` esta anclado al dia seleccionado en la pantalla de
Eventos (y lo excluye), asi que no sirve para el hub.

```dart
/// Ventana hacia atras en la que el hub de Salud busca el ultimo evento.
const _ventanaUltimoEvento = Duration(days: 90);

/// Ultimo evento de salud registrado (hasta hoy inclusive) de la persona de
/// contexto, dentro de los ultimos 90 dias. Alimenta la tarjeta "Eventos de
/// salud" del hub. Independiente del dia seleccionado en la pantalla de eventos.
final ultimoEventoSaludProvider = FutureProvider.autoDispose<EventoSalud?>((ref) async { ... });
```

Detalles:
- `persona == null` devuelve `null`.
- `desde = hoy - 90 dias`, `hasta = hoy + 1 dia` (para incluir los de hoy).
- Filtrar `!e.fechaHora.isAfter(ahora)`, ordenar descendente por `fechaHora`, devolver el primero.
- Agregarlo a `_invalidarEventosSalud(ref)` (linea 127) para que alta/baja de eventos lo refresque.
- `autoDispose`: el hub es transitorio y conviene refrescar al entrar.

### 4.2 `providers/health/habito_vida_providers.dart` - `progresoHabitosHoyProvider` (nuevo)
Lo consumen las dos pantallas (metrica del hub y header de progreso), asi que no va en el widget.

```dart
typedef ProgresoHabitos = ({int total, int completados});

/// Progreso de habitos del dia derivado de [habitosProvider]: no hace I/O propio.
final progresoHabitosHoyProvider = Provider<AsyncValue<ProgresoHabitos>>((ref) {
  return ref.watch(habitosProvider).whenData(
    (h) => (total: h.length, completados: h.where((x) => x.realizacion != null).length),
  );
});
```

Nota: `habito.realizacion` ya viene acotada al dia (la API devuelve la realizacion de hoy). No
agregar filtro de fecha en presentacion.

---

## 5. Fase 2 - Pantalla Habitos de vida

### 5.1 `widgets/health/habits_day_progress_header.dart` (nuevo)
Banda de progreso del dia, fija bajo el AppBar (fuera del scroll).

- Contenedor: `color: surface`, `padding: EdgeInsets.all(AppSpacing.lg)`,
  `border: Border(bottom: BorderSide(color: outline))` (el borde superior del mockup es invisible
  contra el AppBar: se omite).
- Fila superior (`CrossAxisAlignment.baseline`): `"$completados de $total"` (22, w700,
  `textPrimary`) + `SizedBox(width: sm)` + `"habitos de hoy"` (13, `textSecondary`).
- Barras: `Row` de `total` segmentos `Expanded`, `height: 8`, radio 4, separados por 5; los
  primeros `completados` en `habitsAccent`, el resto en `surfaceVariant`.
- **Guarda de densidad:** si `total > 12`, en lugar de segmentos dibujar UNA barra continua de
  8 dp con relleno proporcional (`FractionallySizedBox`), para que no queden astillas de 2 px.
- `Semantics(label: '$completados de $total habitos completados hoy')` mas `ExcludeSemantics`
  sobre las barras.
- API: `const HabitsDayProgressHeader({required this.completados, required this.total});`
  (widget tonto, sin Riverpod: la pantalla le pasa los numeros).

### 5.2 `widgets/health/habito_card.dart` (nuevo, sale de `habits_screen.dart`)
Reemplaza a `_HabitoCard` y `_RealizacionChip` (hoy privados en la pantalla, lineas 121 a 262).

```dart
class HabitoCard extends StatelessWidget {
  const HabitoCard({
    super.key,
    required this.habito,
    required this.onTap,
    this.onToggleRealizacion, // null => check no accionable (sin permiso)
  });
}
```

Layout (`Row`, altura por contenido):
1. **Leading:** cuadrado 44x44, `borderRadius: radiusMd`, fondo
   `TipoHabitoTheme.containerFor(context, habito.tipo.id)`, icono
   `TipoHabitoTheme.iconFor(...)` de 20 dp en `accentFor(...)`.
2. `SizedBox(width: AppSpacing.md)`.
3. **Centro (`Expanded`, `Column` alineada a start):**
   - Categoria: descripcion del tipo en mayusculas, 11, `w700`, `letterSpacing: .5`, color
     `accentFor(...)`, `maxLines: 1`, ellipsis.
   - `SizedBox(height: 2)`.
   - Descripcion: `habito.descripcion`, 14, `w500`, `height: 1.35`, `maxLines: 2`, ellipsis.
     - Pendiente: `textPrimary`, sin decoracion.
     - Realizado: `textSecondary` mas `decoration: TextDecoration.lineThrough` con
       `decorationColor: outline`.
   - **Sin fila de dots** (exclusion del cliente).
4. `SizedBox(width: AppSpacing.sm)`.
5. **Trailing, `_CheckCircle`:** circulo de 30 dp centrado dentro de un area tactil de 48 dp
   (`SizedBox(width: 48, height: 48)` mas `InkWell(customBorder: CircleBorder())`).
   - Pendiente: `border: Border.all(color: outline, width: 2)`, sin relleno.
   - Realizado: relleno `primary` (ver D2) mas `Icon(Icons.check, size: 16, color: onPrimary)`.
   - `AnimatedContainer(duration: 150ms)` para que el cambio de estado no sea un salto.
   - `key: ValueKey('habito-check-${habito.id}')` (lo usan los tests).
   - `Semantics(button: true, checked: realizado, label: 'Marcar <descripcion> como realizado')`.
   - Si `onToggleRealizacion == null`: se renderiza igual pero sin `onTap` (mismo criterio que hoy).

Contenedor de la card: `margin: EdgeInsets.only(bottom: AppSpacing.sm)`,
`padding: EdgeInsets.all(AppSpacing.md)`, `borderRadius: radiusLg`, `boxShadow: elev1`, color
`surface` (pendiente) o `surfaceVariant` (realizado). Todo el cuerpo es tappable (`InkWell` con
`onTap` al detalle); el check intercepta su propio tap.

Exportar en `widgets/health/health.dart`.

### 5.3 `screens/health/habits_screen.dart` (reescritura del body)

```
Scaffold
 - appBar: ContextAppBar(eyebrow: 'Habitos de vida')        // sin cambios
 - body: Column
    - HabitsDayProgressHeader(...)     // solo si hay habitos (data no vacia)
    - Expanded(
        habitosAsync.when(
          loading: _HabitosSkeleton(),  // mas skeleton de la banda de progreso
          error:   InlineErrorBanner(...),
          data:    RefreshIndicator( ListView(...) )
        ))
 - floatingActionButton: FAB (si puedeRegistrar)
```

Dentro del `ListView` (`padding: EdgeInsets.fromLTRB(lg, 0, lg, xxxl)`):
1. `SectionLabel(text: 'Pendientes', count: pendientes.length)` - **solo si hay pendientes**.
2. `HabitoCard` de cada pendiente, en el orden que devuelve el provider.
3. `SectionLabel(text: 'Completados', count: completados.length)` - **solo si hay completados**.
4. `HabitoCard` de cada completado.

Reglas:
- `pendientes = habitos.where((h) => h.realizacion == null)`, `completados` el complemento.
  **No reordenar dentro de cada grupo** (estabilidad visual al marcar y desmarcar).
- Animacion de entrada: `FadeInUp` (`animate_do`) con delay escalonado de 50 ms **acotado a los
  primeros 6 items** (`delay: Duration(milliseconds: 50 * min(i, 6))`).
- Estado vacio: se mantiene el actual (icono, "Sin habitos registrados", ayuda). Ajustes: icono en
  `habitsAccent` atenuado, y el texto de ayuda solo si `puedeRegistrar == true` (si no puede, el
  boton + no existe y el copy miente).
- FAB: mismo `onPressed` y color (`habitsAccent`), pero
  `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg))`
  para el squircle del mockup.
- `RefreshIndicator` y el gateo por `esMiembroEquipoActivoProvider` y
  `puedeRegistrarHabitosProvider`: **sin cambios funcionales**.

---

## 6. Fase 3 - Pantalla Mi salud (hub)

### 6.1 `widgets/health/health_record_highlight_card.dart` (nuevo)
Card destacada de Ficha de salud (widget tonto: recibe datos y callbacks, no usa Riverpod).

```dart
class HealthRecordHighlightCard extends StatelessWidget {
  const HealthRecordHighlightCard({
    super.key,
    required this.onTap,
    this.factorSanguineo,          // null => sin ficha cargada
    this.cantidadAlergias = 0,
    this.cantidadEnfermedades = 0,
    this.cantidadAntecedentes = 0,
    this.enabled = true,           // permiso en false => atenuada mas candado
    this.loading = false,          // permiso o ficha en curso => trailing spinner
    this.datosDisponibles = true,  // false => no dibuja la fila de chips
  });
}
```

Layout:
- Contenedor `surface`, `borderRadius: radiusLg`, `boxShadow: elev1`, `clipBehavior: antiAlias`,
  `border: Border(left: BorderSide(color: healthAccent, width: 4))`,
  `padding: EdgeInsets.all(AppSpacing.lg)`.
- Fila principal: cuadrado 44x44 (`radiusMd`, fondo `healthContainer`,
  `Icon(Icons.medical_services_outlined, 22, healthAccent)`), gap `md`,
  `Expanded(Column(['Ficha de salud' 16/w700/textPrimary, 'Datos clinicos para una emergencia'
  12.5/textSecondary]))`, y trailing: `CircularProgressIndicator` de 14 dp si `loading`,
  `Icons.chevron_right` si esta habilitada, `Icons.lock_outline` si no.
- Fila de chips (solo si `datosDisponibles && enabled && !loading`): separador
  `Divider(height: 1, color: outline)` con `md` arriba y abajo, y un `Wrap(spacing: 8,
  runSpacing: 8)` con:
  - `Grupo <factorSanguineo>` (valor en `w700`), fondo `surfaceVariant`, texto `textSecondary`.
    Si `factorSanguineo == null`, chip `Sin grupo cargado` en el mismo estilo.
  - `N alergias` **solo si N > 0**, fondo `healthContainer`, texto `healthAccent`.
  - `N enfermedades` solo si N > 0, estilo neutro.
  - `N antecedentes` solo si N > 0, estilo neutro.
  - Pluralizacion explicita: `1 alergia` / `2 alergias`, `1 enfermedad` / `2 enfermedades`,
    `1 antecedente` / `2 antecedentes`.
  - Chip: `padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)`,
    `borderRadius: radiusSm`, `fontSize: 12`.
- Sin permiso: `Opacity(0.5)` sobre toda la card y `onTap` nulo (igual que hoy en
  `HealthCategoryCard`).
- `MergeSemantics` con label "Ficha de salud, <resumen de chips>".
- Area tactil de 48 dp o mas garantizada por el padding.

### 6.2 `widgets/health/health_metric_card.dart` (nuevo; reemplaza a `health_category_card.dart`)
Una sola clase con dos layouts, para no duplicar tokens ni estados:

```dart
enum HealthMetricCardLayout { grid, wide }

class HealthMetricCard extends StatefulWidget {
  const HealthMetricCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.label,
    required this.onTap,
    this.metricPrefix,   // 'Hoy: ' | 'Ultimo: ' | null
    this.metricValue,    // '2 de 5' | 'Bien' | 'hace 3 dias'
    this.metricSuffix,   // ' completados hoy' | ' · Dolor de garganta' | null
    this.layout = HealthMetricCardLayout.grid,
    this.delay = Duration.zero,
  });
}
```

- Fondo `surface` (ya no el tinte del acento), `radiusLg`, `elev1`,
  `padding: EdgeInsets.all(AppSpacing.lg)`; estado pressed: `elev0` mas fondo levemente teñido
  (`Color.alphaBlend(accentColor.withValues(alpha: .06), surface)`), `AnimatedContainer` 100 ms.
- **grid:** icono 42x42 (`radiusMd`, fondo `containerColor`, icono 20 en `accentColor`),
  `SizedBox(height: 11)`, label (15, w700, `textPrimary`, `maxLines: 2`), `SizedBox(height: 5)`,
  linea de metrica.
- **wide:** `Row` con el mismo icono, gap `md`, `Expanded(Column([label, metrica]))` y
  `chevron_right` en `textDisabled`.
- Linea de metrica: `Text.rich` con `metricPrefix` y `metricSuffix` en `textSecondary` (12.5) y
  `metricValue` en `w700` mas `textPrimary`. Si `metricValue == null` no se dibuja el valor
  (evita el guion feo mientras carga) y queda solo el suffix como copy de vacio.
- `FadeInUp` con `delay` (coherente con `NavTile` y `FullWidthActionTile`).
- Borrar `health_category_card.dart` y su export del barrel (su unico uso es el hub).
  `full_width_action_tile.dart` **se conserva**: lo usa `EmergencyTile`.

### 6.3 `screens/health/health_screen.dart` (reescritura del body)
Orden vertical (scroll con `padding: EdgeInsets.all(AppSpacing.lg)`):

1. `WellbeingObservationsBanner()` - **sin cambios** (ya trae su gap inferior y se auto-oculta).
2. `HealthRecordHighlightCard(...)` que navega a `AppRoutes.healthRecordName`.
3. `SectionLabel(text: 'Seguimiento')`.
4. `IntrinsicHeight(Row([Expanded(habitos), SizedBox(md), Expanded(animo)]))`.
5. `SizedBox(height: AppSpacing.md)` mas `HealthMetricCard` en layout `wide` para Eventos de salud.
6. `SizedBox(height: AppSpacing.lg)` mas boton "Ver linea de tiempo".

Contenido y fuentes de datos:

| Pieza | Provider | Texto |
|---|---|---|
| Ficha (chips) | `puedeVerSaludProvider` + `fichaSaludProvider` | `Grupo 0+`, `2 alergias`, `1 antecedente` |
| Habitos | `progresoHabitosHoyProvider` | prefix null, value `"$c de $t"`, suffix `' completados hoy'`. Si `total == 0`: value null y suffix `'Sin habitos cargados'` |
| Animo | `animoHoyProvider` | prefix `'Hoy: '`, value `'${moodEmoji(estado)} ${estado.descripcion}'`. Sin registro: value null, suffix `'Sin registro hoy'` |
| Eventos | `ultimoEventoSaludProvider` | prefix `'Ultimo: '`, value `textoRelativoDesde(e.fechaHora)`, suffix `' · ${e.tipo.descripcion}'`. Sin eventos: value null, suffix `'Sin eventos registrados'` |

Reglas transversales del hub:
- **Degradacion:** cada card lee su provider con
  `switch (async) { AsyncData(:final value) => ..., _ => null }` (mismo criterio que
  `home_screen.dart:33`). Un `error` de una metrica nunca tumba la pantalla.
- **Gateo de la ficha:** `final puedeVer = ref.watch(puedeVerSaludProvider);` y solo si
  `puedeVer.value == true` se hace `ref.watch(fichaSaludProvider)`. Con `puedeVer.isLoading`,
  `loading: true` en la card.
- Iconos y colores: Habitos `Icons.self_improvement` con `habitsAccent`/`habitsContainer`;
  Animo `Icons.mood` con `moodAccent`/`moodContainer`; Eventos `Icons.event_note_outlined` con
  `info`/`infoContainer` (reemplaza el `Color(0xFF0284C7)` hardcodeado de la linea 92).
- Navegacion: identica a la actual (`healthHabitsName`, `healthMoodNewName`, `healthEventsName`,
  `healthRecordName`, `healthTimelineName`).
- Estado "sin persona de contexto": se mantiene tal cual (mensaje centrado).
- Linea de tiempo: `FullWidthActionTile` pasa de `outlined` a
  `style: FullWidthActionTileStyle.filled`, `color: context.colors.primary`,
  `icon: Icons.timeline`, `label: 'Ver linea de tiempo'` (con acento correcto en el codigo),
  `delay: const Duration(milliseconds: 180)`.
- `RefreshIndicator`: **recomendado agregarlo** (la pantalla ahora muestra datos, no solo
  accesos). Debe invalidar `fichaSaludProvider`, `habitosProvider`, `animoHoyProvider` y
  `ultimoEventoSaludProvider`.

---

## 7. Fase 4 - Tests

Actualizar (van a romper):
- `test/presentation/screens/health/health_screen_test.dart`
  - `find.byType(HealthCategoryCard)` pasa a `HealthMetricCard`.
  - Agregar overrides: `puedeVerSaludProvider`, `fichaSaludProvider`, `habitosProvider`,
    `animoHoyProvider`, `ultimoEventoSaludProvider`.
- `test/presentation/screens/health/habits_screen_test.dart`
  - El caso "marcar realizado disponible..." hoy tapea `find.text('Pendiente')`; pasa a
    `find.byKey(const ValueKey('habito-check-901'))`.
  - El caso "NO disponible si no es miembro" pasa a verificar que el `InkWell` del check tiene
    `onTap == null`.
- Revisar `habit_detail_screen_test.dart` si el refactor de `_iconTipo` cambia algun finder.

Agregar:
- `test/presentation/widgets/health/tipo_habito_theme_test.dart` - mapeo completo mas default.
- `test/presentation/widgets/health/ultimo_registro_format_test.dart` - bordes
  0/1/6/7/13/14/29/30/59/364/365 con `ahora` fijo.
- `test/presentation/widgets/health/habits_day_progress_header_test.dart` - `0 de N`, `N de N`,
  cantidad de segmentos, guarda de `total > 12`.
- `test/presentation/widgets/health/habito_card_test.dart` - pendiente vs realizado (tachado,
  check relleno), check no accionable con `onToggleRealizacion == null`, semantica `checked`.
- `test/presentation/widgets/health/health_record_highlight_card_test.dart` - chips con y sin
  alergias, sin ficha, `enabled: false` (candado, sin tap), `loading: true`.
- `test/presentation/widgets/health/health_metric_card_test.dart` - layouts grid y wide, metrica
  ausente.
- `habits_screen_test.dart` - casos nuevos: agrupacion (Pendientes/Completados con contadores) y
  que la seccion vacia no se renderiza.

Verificacion manual obligatoria antes de cerrar:
1. Tema claro y tema oscuro en ambas pantallas.
2. `textScaleFactor` 1.0 y 2.0 (sin overflow en las cards del grid ni en el header de progreso).
3. Persona de contexto **sin** permiso de ficha (card atenuada, sin request a ficha).
4. Persona sin habitos, sin animo de hoy y sin eventos (las 3 cards con su copy de vacio).
5. Habitos: 1 habito, 5 habitos, 15 habitos (guarda de barras), y todos completados (la seccion
   "Pendientes" no aparece).

Comandos: `flutter analyze` sin issues nuevos, `flutter test` en verde, `dart format .`.

---

## 8. Checklist de entrega

- [ ] `section_label.dart`, `tipo_habito_theme.dart`, `ultimo_registro_format.dart` creados y exportados
- [ ] `ultimoEventoSaludProvider` mas invalidacion en `_invalidarEventosSalud`
- [ ] `progresoHabitosHoyProvider`
- [ ] `habits_day_progress_header.dart`, `habito_card.dart`
- [ ] `habits_screen.dart` reescrita (sin dots, con agrupacion)
- [ ] `health_record_highlight_card.dart`, `health_metric_card.dart`
- [ ] `health_category_card.dart` eliminado y barrel actualizado
- [ ] `health_screen.dart` reescrita
- [ ] `_iconTipo` duplicados eliminados
- [ ] Tests actualizados y nuevos; analyze, test y format en verde

## 9. Fuera de alcance / follow-ups
- Dots de historial de realizaciones (excluidos por pedido del cliente).
- Endpoint agregado `ResumenSaludDataView` para colapsar las 4 consultas del hub (D4).
- Unificar el color de "realizado" entre el check y el bottom sheet (D2).
- Que la card de Animo navegue al historial cuando ya hay registro de hoy (hoy siempre va al alta).

> Nota de redaccion: este documento evita acentos en algunos bloques por limitaciones de la
> herramienta de escritura; en el codigo y en los textos de UI deben ir con la ortografia correcta
> (por ejemplo "Hábitos de vida", "Último", "Línea de tiempo").
