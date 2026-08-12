# Persistencia del Resumen inteligente (US 9.16) — Frontend (Flutter)

> **Destinatario:** `dev-flutter`
> **Autor:** `arquitecto-software`
> **Estado:** pendiente de implementar — **depende de que el backend esté desplegado**
> **Alcance:** `care_well_app/lib/` — `domain/datasources`, `domain/repositories`, `infrastructure/datasources/api`, `presentation/providers/summary`, `presentation/screens/summary` y sus tests.
> **Specs hermanas:** `resumen-diario-persistencia-backend.md` · `resumen-diario-persistencia-modelo-doc.md`

---

## 1. Contexto: qué cambia del lado del servidor

El backend deja de invocar al modelo de IA en cada consulta. Ahora persiste el resumen por persona
cuidada y aplica esta regla:

- **Consulta normal** (`forzarActualizacion: false`, default): si existe un resumen de la persona
  generado **el mismo día y hace menos de 3 horas**, lo devuelve tal cual — respuesta en
  milisegundos y con el `generadoEn` original (no el momento de la consulta).
- **Consulta forzada** (`forzarActualizacion: true`): regenera contra el modelo, salvo que el último
  resumen tenga menos de 1 minuto (piso anti-doble-tap; en ese caso devuelve el vigente).
- Los resúmenes **sin datos** no se cachean: siempre se recalculan (es un camino barato, no llega
  al modelo).

**Contrato HTTP** (`POST /api/ResumenDiario/generar`), body:

```json
{ "personaCuidadaID": 12, "forzarActualizacion": false }
```

`forzarActualizacion` es opcional (default `false`); la respuesta no cambia de forma.

## 2. Qué hay que lograr en la app

1. Que el flag `forzarActualizacion` —que ya existe en toda la cadena de la app pero se **ignora**
   en el datasource— llegue efectivamente al backend.
2. Que la **carga normal** (entrar a la pantalla, cambiar de persona de contexto) use `false`
   y aproveche la caché.
3. Que **"Actualizar" y el pull-to-refresh** usen `true`.
4. Que la documentación en código deje de decir "sin caché".

### Decisión de diseño principal

`resumenInteligenteProvider` es hoy un `FutureProvider.autoDispose` y el refresh se hace con
`ref.invalidate`, que re-ejecuta el provider **sin poder indicarle** "esta vez forzá". Hay que poder
distinguir los dos disparadores.

| Opción | Cómo | Trade-off |
|---|---|---|
| **A — `AsyncNotifier` (recomendada)** | `AsyncNotifierProvider.autoDispose<SummaryNotifier, ResumenInteligente?>` con `build()` (no fuerza) y método público `refrescar()` (fuerza) | Es el caso de uso canónico de Riverpod: estado async + side-effect explícito. La intención queda en el provider, no en el widget. Cuesta reescribir el provider y sus tests. Verificado contra `riverpod 3.3.2`: `AsyncNotifierProvider.autoDispose` existe con esa firma. |
| B — `FutureProvider.autoDispose.family<..., bool>` | La pantalla observa `provider(forzar)` con un flag local | Menos código, pero el estado de UI (¿estoy forzando?) queda en el widget y la family mantiene dos entradas de caché para el mismo dato. |
| C — Dejar `invalidate` y forzar siempre | El backend recibiría siempre `true` | Anula el objetivo del requerimiento (cada apertura de pantalla volvería a pegarle al modelo). Descartada. |

Se implementa la **opción A**.

---

## 3. Pasos de implementación

### Paso 1 — Datasource: enviar el flag

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
          'forzarActualizacion': forzarActualizacion,
        },
        options: Options(
          receiveTimeout: ApiConfig.receiveTimeoutResumenInteligente,
        ),
      );
      // ... resto sin cambios
```

Quitar el comentario `// Se ignora a propósito: el backend no cachea el resumen en el MVP.` y
actualizar el docstring de la clase: el `receiveTimeout` generoso sigue siendo necesario porque el
**primer** pedido del día (o el forzado) sí invoca al modelo.

### Paso 2 — Documentación de los contratos de dominio

**Editar:** `lib/domain/datasources/summary_datasource.dart` y
`lib/domain/repositories/summary_repository.dart`

Sólo docstrings (las firmas ya contemplan `forzarActualizacion`): reemplazar
"*en el MVP no hay caché, por lo que cada llamada genera de nuevo*" por la regla real —
el backend reutiliza el último resumen de la persona generado el mismo día dentro de las últimas
3 horas; `forzarActualizacion: true` pide una regeneración explícita.

### Paso 3 — Provider: distinguir carga inicial de refresh forzado

**Editar (reemplazar):** `lib/presentation/providers/summary/summary_providers.dart`

```dart
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resumen inteligente (US 9.16) de la persona de contexto.
///
/// El backend cachea el resumen por persona durante 3 horas: la carga normal
/// reutiliza el último vigente y sólo [SummaryNotifier.refrescar] pide una
/// regeneración real contra el modelo de IA.
///
/// Se encadena a [personaVisualizacionSeleccionadaProvider]: si no hay persona
/// seleccionada resuelve a `null`. Es `autoDispose`, así que al volver a entrar
/// a la pantalla se re-consulta (barato: normalmente pega en la caché del
/// backend).
class SummaryNotifier extends AsyncNotifier<ResumenInteligente?> {
  @override
  Future<ResumenInteligente?> build() => _obtener(forzarActualizacion: false);

  /// Regeneración explícita: botón "Actualizar" y pull-to-refresh.
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

- El `ref.watch` de la persona vive en `_obtener`, así que la suscripción se mantiene también tras un
  `refrescar()`: si cambia la persona de contexto, `build()` se vuelve a ejecutar.
- El repositorio se toma con `ref.read` (es una dependencia estable de DI, no una fuente reactiva),
  igual que en el provider actual salvo por el `watch`.
- El nombre público `resumenInteligenteProvider` no cambia: el resto de la app no se entera.

### Paso 4 — Pantalla: usar `refrescar()` en ambos disparadores

**Editar:** `lib/presentation/screens/summary/summary_screen.dart`

- Botón "Actualizar" de la `ContextAppBar`:

```dart
            onPressed: cargando
                ? null
                : () => ref.read(resumenInteligenteProvider.notifier).refrescar(),
```

- `onRefresh` del `RefreshIndicator`:

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

- Botón "Reintentar" del `InlineErrorBanner`: **dejarlo** como
  `ref.invalidate(resumenInteligenteProvider)`. Es el reintento de una carga que falló, no un pedido
  de regeneración; si el backend tiene un resumen vigente, corresponde mostrarlo.
- Actualizar el docstring de `SummaryScreen` (hoy dice "No hay caché"): la pantalla muestra el último
  resumen vigente del backend y los dos disparadores de refresh piden una regeneración explícita.

### Paso 5 — Tests

- `test/infrastructure/datasources/api/api_summary_datasource_test.dart`
  - el body incluye `forzarActualizacion: false` cuando no se pasa el parámetro;
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
- `test/presentation/screens/summary/summary_screen_test.dart`
  - el tap en "Actualizar" produce una llamada con `forzarActualizacion: true`;
  - el pull-to-refresh, ídem;
  - con una generación en curso, el botón está deshabilitado y el pull no dispara una segunda
    llamada.

```bash
cd care_well_app
flutter analyze
flutter test
```

---

## 4. Criterios de aceptación

1. Entrar a la pantalla de Resumen dos veces seguidas (o volver desde otra pantalla) dentro de las
   3 h: el contenido es el mismo, la respuesta es inmediata y el chip "generado hace…" refleja el
   momento **original** de generación (no "hace unos segundos").
2. Tocar "Actualizar" o hacer pull-to-refresh: se ve el skeleton, la llamada demora lo que tarda el
   modelo y el "generado hace…" pasa a "hace unos segundos".
3. Cambiar de persona de contexto: se consulta el resumen de la nueva persona (cacheado o no).
4. Con una generación en curso, el botón "Actualizar" queda deshabilitado y el pull-to-refresh no
   encadena un segundo pedido.
5. Sin persona a cargo: se sigue mostrando el mensaje de "Primero agregá una persona a cargo".
6. `flutter analyze` sin issues nuevos y `flutter test` en verde.

## 5. Fuera de alcance

- No se cachea nada del lado de la app (ni disco ni memoria más allá del ciclo del provider
  `autoDispose`): la caché es responsabilidad del backend. Un caché local sumaría una segunda
  política de expiración que mantener sincronizada.
- No se cambia la UI, ni el copy de la pantalla, ni el disclaimer de IA.
- No se renombra el endpoint (`/generar`), aunque semánticamente ahora sea más un "obtener":
  hacerlo implicaría un cambio coordinado backend + app sin beneficio funcional.

## 6. Commit sugerido

`feat(app): forzar regeneración del resumen desde actualizar y pull-to-refresh`
