# Persistencia del Resumen inteligente (US 9.16) — Frontend (Flutter)

> **Destinatario:** `dev-flutter`
> **Autor:** `arquitecto-software`
> **Estado:** lista para implementar — el backend ya está implementado, compilado y con tests en verde.
> **Alcance:** `care_well_app/lib/` — `infrastructure/datasources/api`, `presentation/providers/summary`,
> `presentation/screens/summary`, `presentation/screens/home`, `presentation/widgets/summary` y sus tests.
> Docstrings de `domain/datasources` y `domain/repositories` (sólo comentarios, sin cambiar firmas).
> **Specs hermanas:** `resumen-diario-persistencia-backend.md` · `resumen-diario-persistencia-modelo-doc.md`
> **Última revisión:** 2026-08-13 (backend ya implementado + conexión del Home)

---

## 0. Cambios respecto de la versión anterior de esta spec

Esta spec fue escrita **antes** de implementar el backend y quedó desactualizada en dos puntos.
Leer esto antes que nada:

1. **El campo del body NO se llama `forzarActualizacion`, se llama `actualizar`.**
   La implementación final del backend es
   `GenerarResumenDiarioQuery { int PersonaCuidadaID; bool Actualizar; }`.
   Si se manda `forzarActualizacion`, System.Text.Json lo descarta en silencio, `Actualizar` queda en
   `false` y el botón "Actualizar" nunca regenera. Es el error más fácil de cometer en esta tarea.
   El nombre del parámetro Dart (`forzarActualizacion`) no cambia: sólo cambia la clave del JSON.
2. **Se suma el Home al alcance** (pedido explícito del cliente, 2026-08-13): la card hero deja de
   mostrar un texto de relleno y pasa a disparar la generación al abrir el Home, con estado
   "Generando…" mientras carga y el `resumenAcotado` + la hora de generación cuando resuelve.

---

## 1. Contexto: qué hace hoy el backend

El endpoint dejó de invocar al modelo de IA en cada consulta: persiste un resumen por persona
cuidada (tabla `t_ResumenDiario`, una fila por persona) y aplica esta regla:

- **Consulta normal** (`actualizar: false`): si existe un resumen de esa persona generado el mismo
  día calendario y hace menos de 3 horas, lo devuelve tal cual — respuesta en milisegundos y con el
  `generadoEn` **original** (no el momento de la consulta).
- **Consulta forzada** (`actualizar: true`): regenera contra el modelo, salvo que el último resumen
  tenga menos de **1 minuto** (piso anti-doble-tap: en ese caso devuelve el vigente, sin error y sin
  avisar que no regeneró).
- Los resúmenes **sin datos** no se persisten: se recalculan siempre, pero es un camino barato
  (cortocircuito previo, no llega al modelo).
- Si el contenido guardado no se puede deserializar, el backend lo trata como si no existiera y
  regenera. Nunca devuelve `null`.

### Contrato HTTP

```
POST /api/ResumenDiario/generar        (Bearer JWT)

Body:
{ "personaCuidadaID": 12, "actualizar": false }

200:
{
  "resumenAcotado": "…",              // string|null  <- es lo que va en la card del Home
  "estadoAnimo": "…",                 // string|null
  "resumenHabitos": "…",              // string|null
  "habitos": [ { "descripcion": "…", "completado": true } ],
  "eventosSalud": [ { "descripcion": "…", "hora": "…", "actividadHabitoAsociado": null } ],
  "recomendaciones": ["…"],
  "recordatoriosHoy": ["…"],
  "recordatoriosManana": ["…"],
  "habitosManana": [ { "descripcion": "…", "completado": false } ],
  "generadoEn": "2026-08-13T14:32:10",
  "tieneDatos": true
}

503: { "mensaje": "El servicio de generación de resumen diario no está disponible…" }
499: la solicitud fue cancelada por el cliente
```

`actualizar` es opcional (default `false`). La forma de la respuesta no cambia respecto de lo que ya
mapea `ResumenInteligenteModel`: no hay que tocar models, mappers ni entidades.

---

## 2. Qué hay que lograr

1. Que el flag `forzarActualizacion` —que ya existe en toda la cadena de la app pero el datasource
   ignora— llegue al backend como `actualizar`.
2. Que la carga normal (entrar a la pantalla, cambiar de persona) use `false` y aproveche la caché;
   que "Actualizar" y el pull-to-refresh usen `true`.
3. Que el **Home dispare la generación al abrirse** y que la card hero muestre:
   "Generando…" mientras carga, y luego el `resumenAcotado` + la hora de generación.
4. Que el Home nunca se degrade por una falla de la IA (el error queda contenido dentro de la card).
5. Que la documentación en código deje de decir "sin caché".

---

## 3. Decisiones de diseño

### D1 — Provider: `AsyncNotifier` en lugar de `FutureProvider` + `invalidate`

`resumenInteligenteProvider` es hoy un `FutureProvider.autoDispose` y el refresh se hace con
`ref.invalidate`, que re-ejecuta el provider sin poder indicarle "esta vez forzá".

| Opción | Cómo | Trade-off |
|---|---|---|
| **A — `AsyncNotifier` (elegida)** | `AsyncNotifierProvider.autoDispose` con `build()` (no fuerza) y método público `refrescar()` (fuerza) | Caso de uso canónico de Riverpod: estado async + side-effect explícito. La intención vive en el provider, no en el widget. Cuesta reescribir el provider y sus tests. Verificado contra `riverpod 3.3.2`. |
| B — `FutureProvider.autoDispose.family` con `bool` | La pantalla observa `provider(forzar)` con un flag local | Menos código, pero el estado de UI ("¿estoy forzando?") queda en el widget y la family mantiene dos entradas de caché para el mismo dato — con el Home consumiendo el mismo provider, es un bug esperando a pasar. |
| C — Dejar `invalidate` y forzar siempre | El backend recibiría siempre `true` | Anula el objetivo: cada apertura del Home volvería a pegarle al modelo. Descartada. |

### D2 — Home y `/summary` comparten la misma instancia del provider (obligatorio)

No crear un provider nuevo para el Home. Motivo concreto: el endpoint puede tardar decenas de segundos
en CPU, y el escenario "abro el Home y toco *Ver resumen completo* antes de que termine" va a ser
habitual. Con **un solo** provider, el segundo consumidor se engancha al `Future` en curso; con dos
providers se disparan **dos inferencias completas** para la misma persona (y una de las dos escrituras
se pierde silenciosamente contra el índice único de `t_ResumenDiario`).

Consecuencias buscadas:

- Como el Home queda montado al hacer `push` de `/summary`, el provider `autoDispose` no se descarta:
  `/summary` abre con el valor ya resuelto, sin request nuevo.
- Al volver de `/summary` al Home después de un `refrescar()`, la card hero ya muestra el texto nuevo.
- Al cambiar la persona de contexto, `build()` se re-ejecuta (sigue habiendo `ref.watch` de la
  persona) y ambas pantallas se actualizan juntas.

### D3 — Estados de la card hero: agregar `SummaryHeroLoading` y `SummaryHeroError`

`SummaryHeroState` hoy sólo tiene `SummaryHeroContent` y `SummaryHeroEmpty`
(`widgets/summary/summary_hero_card.dart:13-49`). Faltan carga y error.

- **Elegido:** dos variantes nuevas en el `sealed class`. Los `switch` de `_Cuerpo` (línea ~200) y
  `_Cta` (línea ~256) son exhaustivos, así que el compilador marca exactamente lo que falta completar.
  La card sigue siendo puramente presentacional (no lee providers): el Home traduce el `AsyncValue`.
- **Alternativa descartada:** reusar `SummaryHeroEmpty` con dos `reason` nuevos. Más barato, pero el
  error necesita un CTA distinto (Reintentar, que no navega) y "vacío" y "roto" son cosas distintas
  para el usuario; mezclarlas es la clase de atajo que después nadie desarma.

### D4 — Hora de generación visible en el Home (confirmado con el cliente)

`SummaryHeroCard` **ya** pinta la hora en el encabezado cuando `SummaryHeroContent.generadoEn != null`
(método `_hora()`, líneas 133-139). Alcanza con pasarle `generadoEn` de la entidad. Es la contrapartida
de la decisión de no invalidar la caché cuando cambian las fuentes (ver §7, L2): el usuario tiene que
poder ver que el texto es de hace un rato.

### D5 — Qué mostrar cuando no hay persona de contexto

El provider resuelve a `null` si no hay persona seleccionada. Se reusa
`SummaryHeroEmpty(reason: noGenerado)` cambiándole el copy a algo del estilo
"Elegí una persona a cargo para ver su resumen del día." y el CTA a "Ver resumen". Así el valor del
enum no queda muerto (al conectar el provider quedaría sin uso) y el tap sigue llevando a `/summary`,
que ya tiene su propio mensaje de "Primero agregá una persona a cargo".
Ajustar en consecuencia `test/presentation/widgets/summary/summary_hero_card_test.dart:95-140`.

### D6 — El "Reintentar" del banner de `/summary` sigue siendo `invalidate`, no `refrescar()`

Reintentar una carga que falló no es lo mismo que pedir una regeneración: si el backend tiene un
resumen vigente, corresponde mostrarlo (rápido y gratis) en vez de gastar otra inferencia.

---

## 4. Pasos de implementación

### Commit 1 — Datasource: enviar el flag con el nombre correcto

**Editar:** `lib/infrastructure/datasources/api/api_summary_datasource.dart`

```dart
  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.obtenerResumenInteligentePath,
        data: {
          'personaCuidadaID': personaId,
          // OJO: la clave del backend es 'actualizar' (GenerarResumenDiarioQuery.Actualizar).
          'actualizar': forzarActualizacion,
        },
        options: Options(
          receiveTimeout: ApiConfig.receiveTimeoutResumenInteligente,
        ),
      );
      // ... resto sin cambios
```

- Quitar el comentario "Se ignora a propósito: el backend no cachea el resumen en el MVP".
- Actualizar el docstring de la clase: el `receiveTimeout` generoso sigue haciendo falta porque el
  primer pedido del día (y el forzado) sí invocan al modelo.
- No tocar `ApiConfig.receiveTimeoutResumenInteligente` (2:30 > 100 s del backend, ya validado).

**También (sólo docstrings):** `lib/domain/datasources/summary_datasource.dart` y
`lib/domain/repositories/summary_repository.dart` — reemplazar "en el MVP no hay caché…" por la regla
real (§1). Las firmas ya contemplan `forzarActualizacion`.

### Commit 2 — Provider: distinguir carga inicial de refresh forzado

**Reemplazar:** `lib/presentation/providers/summary/summary_providers.dart`

```dart
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resumen inteligente (US 9.16) de la persona de contexto.
///
/// El backend cachea el resumen por persona (mismo día, menos de 3 h): la carga
/// normal reutiliza el último vigente y sólo [SummaryNotifier.refrescar] pide una
/// regeneración real contra el modelo de IA.
///
/// Se encadena a [personaVisualizacionSeleccionadaProvider]: si no hay persona
/// seleccionada resuelve a `null`.
///
/// Lo consumen el Home (card hero) y la pantalla `/summary`, y tiene que ser la
/// misma instancia: la generación puede tardar decenas de segundos y dos
/// providers distintos dispararían dos inferencias en paralelo para la misma
/// persona.
class SummaryNotifier extends AsyncNotifier<ResumenInteligente?> {
  @override
  Future<ResumenInteligente?> build() => _obtener(forzarActualizacion: false);

  /// Regeneración explícita: botón "Actualizar" y pull-to-refresh de `/summary`.
  Future<void> refrescar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _obtener(forzarActualizacion: true));
  }

  Future<ResumenInteligente?> _obtener({
    required bool forzarActualizacion,
  }) async {
    final persona = await ref.watch(
      personaVisualizacionSeleccionadaProvider.future,
    );
    if (persona == null) return null;

    return ref
        .read(summaryRepositoryProvider)
        .obtenerResumen(
          personaId: persona.id,
          forzarActualizacion: forzarActualizacion,
        );
  }
}

final resumenInteligenteProvider =
    AsyncNotifierProvider.autoDispose<SummaryNotifier, ResumenInteligente?>(
      SummaryNotifier.new,
    );
```

Notas:

- El `ref.watch` de la persona vive en `_obtener`, así que la suscripción se mantiene también después
  de un `refrescar()`: si cambia la persona de contexto, `build()` se vuelve a ejecutar.
- El repositorio se toma con `ref.read` (dependencia estable de DI, no fuente reactiva).
- El nombre público `resumenInteligenteProvider` no cambia: el resto de la app no se entera.

### Commit 3 — Pantalla `/summary`: usar `refrescar()` en ambos disparadores

**Editar:** `lib/presentation/screens/summary/summary_screen.dart`

- Botón "Actualizar" de la `ContextAppBar` (línea ~44):

```dart
            onPressed: cargando
                ? null
                : () => ref.read(resumenInteligenteProvider.notifier).refrescar(),
```

- `onRefresh` del `RefreshIndicator` (línea ~60):

```dart
              onRefresh: () async {
                // Si ya hay una generación en curso, sólo se espera: un segundo
                // pedido forzado gastaría otra inferencia de IA.
                if (ref.read(resumenInteligenteProvider).isLoading) {
                  await ref.read(resumenInteligenteProvider.future);
                  return;
                }
                await ref.read(resumenInteligenteProvider.notifier).refrescar();
              },
```

- Botón "Reintentar" del `InlineErrorBanner` (línea ~116): **dejarlo** como
  `ref.invalidate(resumenInteligenteProvider)` (ver D6).
- Actualizar el docstring de `SummaryScreen` (hoy dice "No hay caché").

### Commit 4 — Card hero: estados de carga y error

**Editar:** `lib/presentation/widgets/summary/summary_hero_card.dart`

1. Agregar al `sealed class SummaryHeroState`:

```dart
/// El resumen se está generando (o consultando) en este momento.
class SummaryHeroLoading extends SummaryHeroState {
  const SummaryHeroLoading();
}

/// No se pudo obtener el resumen (backend caído, timeout, sin conexión).
class SummaryHeroError extends SummaryHeroState {
  const SummaryHeroError();
}
```

2. Completar los `switch` exhaustivos:
   - `_Cuerpo` (línea ~200): `SummaryHeroLoading() => 'Generando el resumen del día…'` y
     `SummaryHeroError() => 'No pudimos generar el resumen ahora.'`
   - `_Cta` (línea ~256): `SummaryHeroLoading() => 'Generando…'` y
     `SummaryHeroError() => 'Reintentar'`.
3. En `SummaryHeroLoading`, mostrar además un indicador sutil de actividad junto al copy
   (`SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))` con el color
   `onHero`, o el patrón ya usado en `summary_generation_chip.dart` / `summary_loading_skeleton.dart`,
   lo que quede más consistente). **No** reemplazar la card entera por un skeleton: el usuario tiene
   que seguir viendo "Resumen del día" y entender que se está generando.
4. En `SummaryHeroLoading`, ocultar la flecha `arrow_forward_rounded` del CTA (todavía no hay adónde
   ir con contenido). En `SummaryHeroError`, el CTA es "Reintentar" y **no navega**: agregar un
   `onRetry` opcional (`VoidCallback?`) al widget que, cuando el estado es `SummaryHeroError`, se use
   en lugar de `onTapVerCompleto` en el `InkWell`. Si es `null`, la card no es interactiva.
5. Ajustar el copy de `SummaryHeroEmptyReason.noGenerado` según D5.
6. La card sigue sin conocer providers ni entidades de dominio.

### Commit 5 — Home: disparar la generación y pintar el resumen acotado

**Editar:** `lib/presentation/screens/home/home_screen.dart` (hoy líneas 91-105: texto hardcodeado)

```dart
    final resumenAsync = ref.watch(resumenInteligenteProvider);

    final SummaryHeroState estadoResumen = switch (resumenAsync) {
      AsyncLoading() => const SummaryHeroLoading(),
      AsyncError() => const SummaryHeroError(),
      AsyncData(value: null) =>
        const SummaryHeroEmpty(reason: SummaryHeroEmptyReason.noGenerado),
      AsyncData(:final value) when !value!.tieneDatos ||
              (value.resumenAcotado?.isEmpty ?? true) =>
        const SummaryHeroEmpty(reason: SummaryHeroEmptyReason.sinDatos),
      AsyncData(:final value) => SummaryHeroContent(
        texto: value!.resumenAcotado!,
        generadoEn: value.generadoEn,
      ),
    };
```

y en el árbol:

```dart
                SummaryHeroCard(
                  delay: const Duration(milliseconds: 50),
                  state: estadoResumen,
                  onTapVerCompleto: () =>
                      context.pushNamed(AppRoutes.summaryName),
                  onRetry: () => ref.invalidate(resumenInteligenteProvider),
                ),
```

Reglas duras de este paso:

- **El Home no se bloquea**: nada de loader global ni de `await`. El resto de la pantalla (selector de
  contexto, grid 2×2, tile de emergencia) tiene que seguir 100% usable mientras la card dice
  "Generando…". El peor caso es ~2:30 de `receiveTimeout`.
- **Un error de IA nunca sale de la card**: sin `SnackBar`, sin banner global, sin diálogo.
- Reemplazar el comentario "Acceso al Resumen inteligente (estático: no dispara la IA)" y el docstring
  de `HomeScreen`, que quedan mintiendo.
- Cuidar el orden del `switch`: el patrón `AsyncData(value: null)` va **antes** que
  `AsyncData(:final value)`. Si preferís evitar los `!`, usá `case AsyncData(:final value)` y adentro
  un `if (value == null)`.

---

## 5. Tests

- `test/infrastructure/datasources/api/api_summary_datasource_test.dart`
  - el body incluye `'actualizar': false` cuando no se pasa el parámetro;
  - incluye `true` cuando se pide forzar;
  - se mantiene el `receiveTimeout` propio.
- `test/infrastructure/repositories/summary_repository_impl_test.dart`
  - agregar el caso que verifica la propagación de `forzarActualizacion: true`.
- `test/presentation/providers/summary/summary_providers_test.dart` (reescribir para el notifier)
  - `build` llama al repositorio con `forzarActualizacion: false`;
  - `refrescar()` llama con `true` y deja el estado en `AsyncData`;
  - sin persona seleccionada resuelve `null` sin tocar el repositorio;
  - si el repositorio falla, el estado queda en `AsyncError` (tanto en `build` como en `refrescar`);
  - al cambiar la persona de contexto se vuelve a consultar.
- `test/presentation/widgets/summary/summary_hero_card_test.dart`
  - `SummaryHeroLoading` muestra el copy "Generando…" y el indicador de actividad;
  - `SummaryHeroError` muestra "Reintentar" y dispara `onRetry` (y no `onTapVerCompleto`);
  - ajustar los tests de `noGenerado` al copy nuevo (D5).
- `test/presentation/screens/home/home_screen_test.dart`
  - **Atención:** el Home pasa a depender de un provider nuevo. El `ProviderScope` de `_pumpHome`
    (overrides en las líneas ~109-131) tiene que overridear el resumen; si no, los tests existentes
    van a intentar pegarle a la API real. Agregar un override de `summaryRepositoryProvider` con un
    fake (o de `resumenInteligenteProvider`), parametrizable igual que `animoOverride`.
  - caso "loading" -> se ve "Generando…";
  - caso "data con resumenAcotado" -> se ve el texto y la hora de `generadoEn`;
  - caso "error" -> se ve "Reintentar" y el resto del Home sigue funcionando.
- `test/presentation/screens/summary/summary_screen_test.dart`
  - el tap en "Actualizar" produce una llamada con `forzarActualizacion: true`;
  - el pull-to-refresh, ídem;
  - con una generación en curso, el botón está deshabilitado y el pull no dispara una segunda llamada.

```bash
cd care_well_app
flutter analyze
flutter test
```

---

## 6. Criterios de aceptación

1. **Home**: al abrirlo con una persona de contexto seleccionada, la card hero muestra "Generando…" y,
   al resolver, el `resumenAcotado` con la hora de generación en el encabezado.
2. Entrar al Home dos veces (o volver desde otra pantalla) dentro de las 3 h: el contenido es el mismo
   y aparece de inmediato; la hora mostrada es la de la generación **original**, no la de la consulta.
3. Con la generación en curso en el Home, tocar "Ver resumen completo": `/summary` muestra el mismo
   estado de carga y no se dispara un segundo POST (verificable en los logs del backend: una sola
   inferencia).
4. Tocar "Actualizar" o pull-to-refresh en `/summary`: se ve el skeleton, la llamada demora lo que
   tarde el modelo, y al volver al Home la card ya muestra el texto nuevo.
5. Doble tap en "Actualizar" dentro del mismo minuto: la segunda respuesta llega al instante con el
   mismo texto y sin error visible (piso anti-doble-tap del backend). No debe parecer una falla.
6. Backend caído / IA no disponible: la card del Home muestra "No pudimos generar el resumen ahora" +
   "Reintentar"; el resto del Home sigue funcionando; no aparece ningún SnackBar global.
7. Persona sin registros del día: la card muestra el copy de `sinDatos`.
8. Sin persona a cargo: la card muestra el copy de D5 y `/summary` sigue mostrando "Primero agregá una
   persona a cargo".
9. Cambiar de persona de contexto: se consulta el resumen de la nueva persona (cacheado o no).
10. `flutter analyze` sin issues nuevos y `flutter test` en verde.

---

## 7. Limitaciones conocidas (decisiones ya tomadas, no son bugs a arreglar acá)

- **L1 — La caché en memoria del provider sobrevive a la ventana de 3 h.** Mientras el Home siga
  montado, el valor resuelto queda en el provider y no se vuelve a consultar aunque el resumen del
  backend expire. En una sesión de app de varias horas, la card puede quedar mostrando el texto de la
  mañana. Salida del usuario: `/summary` -> "Actualizar". *Mejora futura barata (no ahora): invalidar
  el provider cuando la app vuelve a foreground.*
- **L2 — El backend no invalida la caché cuando cambian las fuentes.** Si el cuidador registra un
  hábito, un evento de salud o un estado de ánimo, el resumen puede seguir siendo el viejo hasta 3 h.
  Decisión del cliente (2026-08-13). Por eso la hora de generación es visible (D4).
- **L3 — Si cambia la forma de `ResumenDiarioDataView` en el backend**, las filas viejas deserializan
  a medias durante hasta 3 h. Se resuelve del lado del deploy (truncar `t_ResumenDiario`), no en la app.

## 8. Fuera de alcance

- No se cachea nada del lado de la app más allá del ciclo de vida del provider: la caché es
  responsabilidad del backend. Un caché local sumaría una segunda política de expiración que mantener
  sincronizada.
- No se cambian `domain/entities`, `infrastructure/models` ni los mappers: la respuesta no cambió de
  forma. (Sí conviene corregir el docstring de `ResumenInteligente`, que dice "no persistido".)
- No se rediseña `/summary` ni su disclaimer de IA.
- No se renombra el endpoint (`/generar`), aunque semánticamente ahora sea más un "obtener":
  implicaría un cambio coordinado backend + app sin beneficio funcional.

## 9. Commits sugeridos

1. `fix(app): enviar el flag actualizar al generar el resumen diario`
2. `refactor(app): resumen inteligente con AsyncNotifier para distinguir refresh forzado`
3. `refactor(app): la pantalla de resumen fuerza la regeneración con refrescar()`
4. `feat(app): estados de carga y error en la card de resumen del home`
5. `feat(app): el home genera y muestra el resumen acotado del día`
