# Emergencias — Hallazgos menores de la code-review de la Fase 5

> **Destinatario:** `dev-flutter`
> **Autor:** `arquitecto-software`
> **Estado:** especificación cerrada
> **Origen:** hallazgos 4 a 9 (prioridad menor) de la code-review de la Fase 5
> **Alcance:** solo Flutter. Ningún cambio de contrato con el backend.

---

## 0. Cómo leer esta spec

Cuatro entregas **independientes entre sí**: se pueden hacer en cualquier orden, o parcialmente.

Las tres primeras corrigen hallazgos de la review; ninguno es un bug visible hoy, son trampas para
el próximo que toque el código (más un defecto visual en tema oscuro). La cuarta es una feature
chica que le da uso a código que hoy no tiene consumidor.

| Entrega | Origen | Por qué |
|---|---|---|
| A — Robustez del ciclo de vida | hallazgos 6, 7, 9 | Barato, y el 9 hoy rompe el arranque en un clone limpio |
| B — Payload de notificación | hallazgo 4 | Desactiva una trampa antes de que exista |
| C — Tokens de color | hallazgo 8 | Defecto visible en tema oscuro |
| D — Historial de emergencias | hallazgo 5 | Feature nueva; le da consumidor al camino de lectura |

**Si vas a hacer una sola, hacé la A.** Es la única donde hay algo roto hoy.

---

## Entrega A — Robustez del ciclo de vida

### A.1 — `Firebase.initializeApp()` deja la app sin arrancar en un clone limpio

**Hallazgo 9. Archivo:** `lib/main.dart:18`

Esto subió de prioridad respecto de la review original, porque verifiqué algo que había dado por
sentado:

```
$ git check-ignore -v care_well_app/android/app/google-services.json
.gitignore:402:**/google-services.json
```

El `google-services.json` **no está versionado**. Entonces, en cualquier clone nuevo del repo —
otra máquina tuya, una PC de la facultad, un evaluador de la tesis — `Firebase.initializeApp()`
lanza excepción en `main()` y **la app no abre**. Ni siquiera llega al login.

Una app entera caída por una funcionalidad que definimos explícitamente como *best effort*.

**El arreglo tiene que ser completo o no sirve.** Un `try/catch` suelto haría arrancar la app y
después explotaría igual en `FirebasePushMessagingService`, que es peor: falla más tarde y más
lejos de la causa.

**a)** En `main.dart`:

```dart
// El push es best effort: si Firebase no está configurado (por ejemplo, un clone
// sin google-services.json), la app tiene que arrancar igual, sin notificaciones.
var pushDisponible = false;
try {
  await Firebase.initializeApp();
  pushDisponible = true;
} catch (e) {
  debugPrint('Firebase no disponible, push deshabilitado: $e');
}
```

y pasarlo por override:

```dart
ProviderScope(
  overrides: [
    notificationSchedulerProvider.overrideWithValue(scheduler),
    pushDisponibleProvider.overrideWithValue(pushDisponible),
  ],
  child: const CareWellApp(),
)
```

**b)** En `di_providers.dart`, el flag y el servicio nulo:

```dart
/// Indica si el SDK de mensajería push se inicializó correctamente.
/// Se sobreescribe desde `main.dart`; el default `false` es el que usan los tests.
final pushDisponibleProvider = Provider<bool>((ref) => false);

final pushMessagingServiceProvider = Provider<PushMessagingService>((ref) {
  return ref.watch(pushDisponibleProvider)
      ? FirebasePushMessagingService()
      : const NullPushMessagingService();
});
```

**c)** `lib/infrastructure/notifications/null_push_messaging_service.dart` — implementación inerte:
`requestPermission()` devuelve `false`, `obtenerToken()` devuelve `null`, los streams son
`Stream.empty()`, `getInitialMessage()` devuelve `null`.

> Es el mismo patrón que ya usa el backend con `PushSenderNulo` cuando no hay credenciales de
> Firebase. Vale la pena mantener la simetría entre las dos puntas.

Con `obtenerToken()` devolviendo `null`, `PushTokenSynchronizer.registrarDispositivo()` corta solo
en su guarda `if (token == null) return;` — ese camino ya está cubierto por el test
*"no registra nada si el proveedor no devuelve token"*.

**d)** Documentá en el README de `care_well_app` que hace falta el `google-services.json` y de
dónde se baja. Hoy no está escrito en ningún lado y es lo primero que traba a alguien que clona.

### A.2 — `cerrarSesionProvider` vive en la carpeta equivocada

**Hallazgo 6. Archivo:** `lib/presentation/providers/notifications/push_token_providers.dart:87`

Es la operación de cierre de sesión de toda la app. El próximo que la busque va a abrir
`providers/auth/` y no la va a encontrar; en el mejor caso pierde tiempo, en el peor **escribe un
`logout()` directo** y vuelve a saltearse la baja del dispositivo — que es exactamente el bug que
`cerrarSesionProvider` existe para prevenir.

Mover el provider tal cual a `lib/presentation/providers/auth/auth_providers.dart`:

```dart
/// Cierra la sesión dando de baja el dispositivo push en el ORDEN correcto.
///
/// El endpoint de baja exige JWT: si se llamara después de limpiar la sesión devolvería 401
/// y el dispositivo seguiría recibiendo las emergencias de un equipo del que ya se desconectó.
///
/// SIEMPRE cerrar sesión por acá, nunca llamando a `logout()` directo.
final cerrarSesionProvider = Provider<Future<void> Function()>((ref) { ... });
```

La dependencia queda `auth -> notifications`, que es la dirección correcta: auth orquesta, el
sincronizador de token es un colaborador.

No hay que tocar imports en las pantallas: todo entra por el barrel `providers.dart`.

Mové también su grupo de tests (`group('cerrarSesionProvider', ...)`) a
`test/presentation/providers/auth/auth_providers_test.dart`, para que los tests sigan espejando
`lib/`.

### A.3 — Carrera entre el alta y la baja del dispositivo

**Hallazgo 7. Archivo:** `lib/presentation/providers/notifications/push_token_providers.dart:72`

El alta es fire-and-forget:

```dart
synchronizer.registrarDispositivo().catchError((_) {});
```

Si el usuario cierra sesión antes de que resuelva, `eliminar` puede llegar al backend **antes** que
`registrar`. El backend procesa el `registrar` último, `RegistrarUso()` reactiva el dispositivo y
queda `Activo = 1` para un usuario que ya se fue.

Requiere cerrar sesión en menos de un segundo, así que es improbable — pero es exactamente el
escenario *"me di cuenta de que entré con la cuenta equivocada y salí enseguida"*, que es
justamente cuando más importa que la baja funcione.

Guardar el `Future` del alta y esperarlo antes de dar de baja:

```dart
class PushTokenSynchronizer {
  /// Alta en curso. Se espera antes de dar de baja para que el backend no
  /// procese el registro DESPUÉS de la baja y reactive el dispositivo.
  Future<void>? _altaEnCurso;

  Future<void> registrarDispositivo() {
    final alta = _registrarDispositivo();
    _altaEnCurso = alta;
    return alta;
  }

  Future<void> _registrarDispositivo() async {
    await _pushMessaging.requestPermission();
    final token = await _pushMessaging.obtenerToken();
    if (token == null) return;
    await registrarToken(token);
  }

  Future<void> darDeBajaDispositivo() async {
    // Nunca dejar que una falla del alta impida la baja.
    try {
      await _altaEnCurso;
    } catch (_) {}
    _altaEnCurso = null;

    final token = await _pushMessaging.obtenerToken();
    if (token == null) return;
    await _dispositivoRepository.eliminar(token: token);
  }
}
```

> El `try/catch` alrededor del `await _altaEnCurso` no es decorativo: si el alta falló, ese
> `Future` está completado con error y sin él la baja se abortaría por una falla ajena.

**Test a agregar** en `push_token_providers_test.dart`:

```
la_baja_espera_a_que_termine_el_alta_en_curso()
```

Con un `_FakeDispositivoRepository` cuyo `registrar` quede pendiente en un `Completer`: disparar
`registrarDispositivo()` sin await, llamar a `darDeBajaDispositivo()`, completar el alta, y
verificar que el `log` compartido quedó en `['registrar', 'eliminar']`. Es el mismo mecanismo del
test de orden que ya escribiste para el logout.

---

## Entrega B — Payload de notificación desambiguado

**Hallazgo 4. Archivos:** `push_notification_providers.dart:82`, `local_notification_scheduler.dart:53`

### El problema

La notificación local que se emite en foreground lleva:

```dart
payload: message.personaId?.toString(),   // "12"
```

Y el handler de taps es un TODO que dice esperar otra cosa:

```dart
onDidReceiveNotificationResponse: (details) {
  // TODO(deeplink): navegar al evento vía payload (details.payload = eventId).
},
```

Un entero pelado, **indistinguible** entre un id de persona y un id de evento de agenda. El día que
se implemente el deep link de agenda, un `"12"` de emergencia va a resolver como evento de agenda
12 y navegar a cualquier lado. Y va a ser un bug carísimo de diagnosticar, porque el síntoma
aparece en la feature de agenda y la causa está en la de emergencias.

**Verifiqué que hoy no hay datos heredados**: `scheduleEventReminder` se invoca sin `payload`
(`agenda_providers.dart:294`), así que el único payload que existe en el sistema es el de
emergencia. No hay migración ni compatibilidad hacia atrás que sostener. Es el momento más barato
posible para arreglarlo.

### B.1 — Tipar el payload en domain

**Archivo nuevo:** `lib/domain/notifications/notification_payload.dart`

```dart
/// Payload de una notificación local, con su tipo explícito.
///
/// Se serializa como `"<tipo>:<id>"`. El tipo es obligatorio: un id suelto no
/// permite saber a qué feature pertenece y hace ambiguo el destino del deep link.
class NotificationPayload {
  final String tipo;
  final int id;

  const NotificationPayload({required this.tipo, required this.id});

  String encode() => '$tipo:$id';

  /// Devuelve `null` si el texto no tiene el formato esperado.
  static NotificationPayload? decode(String? raw) {
    if (raw == null) return null;

    final separador = raw.indexOf(':');
    if (separador <= 0) return null;

    final id = int.tryParse(raw.substring(separador + 1));
    if (id == null) return null;

    return NotificationPayload(tipo: raw.substring(0, separador), id: id);
  }
}
```

Exportar en el barrel `domain/notifications/notifications.dart`.

Tests en `test/domain/notifications/notification_payload_test.dart`: ida y vuelta, y `decode`
devolviendo `null` para `null`, `''`, `'12'`, `':12'`, `'emergencia:'` y `'emergencia:abc'`.

### B.2 — Emitir el payload tipado

En `push_notification_providers.dart`, dentro de `pushForegroundProvider`:

```dart
payload: message.personaId == null
    ? null
    : NotificationPayload(
        tipo: TiposPushConst.emergencia,
        id: message.personaId!,
      ).encode(),
```

> Reusa `TiposPushConst.emergencia`, el mismo discriminador que ya viaja en el `data` del push.
> Un solo vocabulario para "esto es una emergencia" en todo el cliente.

### B.3 — Exponer los taps como stream

El `NotificationScheduler` hoy recibe taps y los tira a la basura. Hay que dejarlos salir, pero
**sin** que `infrastructure` sepa navegar.

En `domain/notifications/notification_scheduler.dart`:

```dart
/// Payloads de las notificaciones locales que el usuario tocó.
///
/// Emite solo los que se pudieron decodificar; los inválidos se descartan.
Stream<NotificationPayload> get onNotificationTap;
```

En `LocalNotificationScheduler`:

- Un `StreamController<NotificationPayload>.broadcast()` privado.
- En `onDidReceiveNotificationResponse`, decodificar y publicar si no es `null` (y borrar el TODO).
- En `init()`, revisar `getNotificationAppLaunchDetails()`: si la app la abrió una notificación
  local, publicar también ese payload.
- Cerrar el controller en un `dispose()`.

> Ojo con el orden en `init()`: publicar el launch details **después** de crear el controller
> broadcast. Un broadcast no bufferea, así que si se emite antes de que exista un suscriptor el
> evento se pierde. Si te resulta frágil, guardá el launch payload en un campo y exponelo con un
> `Future<NotificationPayload?> getLaunchPayload()`, igual que hace `getInitialMessage()` en el
> servicio de push. Cualquiera de las dos sirve; la segunda es más predecible.

### B.4 — Rutear el tap

En `pushDeepLinkProvider`, suscribirse también a `onNotificationTap` y reusar el coordinator que
ya existe:

```dart
final tapSubscription = ref
    .read(notificationSchedulerProvider)
    .onNotificationTap
    .listen((payload) {
      if (payload.tipo != TiposPushConst.emergencia) return;
      coordinator.procesar(PushMessage(datos: {
        'tipo': payload.tipo,
        'personaId': payload.id.toString(),
      }));
    });
ref.onDispose(tapSubscription.cancel);
```

Así el tap en foreground termina en el mismo `EmergencyDeepLinkCoordinator` que el tap en
background, con la misma lógica de sesión pendiente. Una sola ruta de decisión.

> **No** implementes el deep link de agenda en esta entrega. El TODO se borra porque el handler
> pasa a delegar en el stream, pero routear la agenda es otra feature con su propio alcance.

---

## Entrega C — Colores hardcodeados que rompen el tema oscuro

**Hallazgo 8.** Son dos, y **los dos tienen token disponible** en `AppPalette`. No hay que
inventar nada de diseño.

### C.1 — Gradiente de fondo

**Archivo:** `lib/presentation/screens/emergency/emergency_screen.dart:52`

```dart
colors: [Color(0xFFFFF1F0), context.colors.surface],
```

Rosa muy claro degradando a la superficie del tema. En oscuro, `surface` es casi negro: el
gradiente va de rosa pastel a negro. Se ve roto.

`AppPalette` ya define `emergencyContainer` en ambos temas — claro `0xFFFEE2E2`, oscuro
`0xFF3B1E20` — que es exactamente el rol de "fondo tenue del módulo de emergencia":

```dart
colors: [context.colors.emergencyContainer, context.colors.surface],
```

### C.2 — Estado presionado del botón

**Archivo:** `lib/presentation/widgets/emergency/emergency_button.dart:85`

```dart
color: _pressed ? const Color(0xFFB02F2F) : context.colors.emergencyRed,
```

`0xFFB02F2F` es un `emergencyRed` oscurecido a mano. En tema oscuro el rojo base es más claro
(`0xFFE2727A`), así que presionar el botón lo **oscurece de golpe** en vez de dar el feedback sutil
que da en claro.

Acá sí hace falta un token nuevo. En `AppPalette`, junto a `emergencyRed` y `emergencyContainer`:

```dart
/// Estado presionado del botón de emergencia.
final Color emergencyRedPressed;
```

- Claro: `Color(0xFFB02F2F)` — el valor actual, no se toca nada visualmente.
- Oscuro: `Color(0xFFC65C64)` — un paso más oscuro que `0xFFE2727A`, manteniendo el sentido
  "presionado = más oscuro" y el contraste con el texto blanco encima.

Acordate de sumarlo al constructor, a los dos temas y al `copyWith` (`app_palette.dart:310` y
alrededores).

> **Fuera de alcance:** los otros hardcodeos que aparecen en `grep -rn "Color(0xFF" lib/presentation/`
> (`care_team_screen`, `dependents_screen`, `home_screen`, `person_card`, `member_card`,
> `health_screen`, `ficha_salud_screen`). Son de la deuda conocida del tema oscuro y se atacan como
> tarea propia, no colgados de esta.

---

## Entrega D — Historial corto de emergencias

> **Sustituye** al hallazgo 5 de la review ("camino de lectura sin consumidor").
> Decisión tomada: en vez de borrar el código muerto o solo fijarlo con un test, se le da uso.
> **No pasa por `disenador-ui`**: se resuelve reutilizando los patrones visuales que ya tiene la
> pantalla. La documentación la actualiza después `analista-funcional`.

### Contexto

`EmergencyRepository.getEmergenciasByPersona` ya existe, está implementado contra
`POST /api/Emergencia/obtener` y **nadie lo llama**. Esta entrega le da un consumidor real.

Ventaja: **no hace falta tocar `domain` ni `infrastructure`.** Todo el trabajo es de presentación
más una constante. El contrato ya está resuelto (ver hoja de contrato en la spec de la Fase 5,
sección 3).

### El principio que manda sobre todo lo demás

**La pantalla de Emergencia existe para activar una emergencia. El historial es accesorio y no
puede degradarla nunca.**

De ahí se desprende todo lo que sigue: sin spinner que compita por la atención, sin banner de
error, sin excepción que tumbe el `build`, y sin desplazar el botón de su posición actual. Si el
historial falla, la pantalla tiene que seguir sirviendo para lo único que importa.

Si en algún momento dudás entre dos alternativas de implementación, resolvé por acá.

### D.1 — Constante

**Archivo nuevo:** `lib/domain/global/emergencias_const.dart`

```dart
/// Parámetros del módulo de Emergencia.
abstract final class EmergenciasConst {
  /// Cantidad de emergencias que trae el historial corto de la pantalla.
  static const int cantidadHistorialCorto = 5;
}
```

Exportar en el barrel `lib/domain/global/global_const.dart`.

> Cinco es suficiente para dar contexto ("¿pasó algo hace poco?") sin convertir la pantalla en un
> listado. Si más adelante hace falta el historial completo, es otra pantalla, no este bloque.

### D.2 — Provider

En `lib/presentation/providers/emergency/emergency_providers.dart`:

```dart
/// Últimas emergencias registradas para la persona de contexto.
///
/// `autoDispose` a propósito: la pantalla se abandona al activar una emergencia
/// (se navega a la de alerta enviada), así que al volver a entrar el provider se
/// reconstruye y el historial ya incluye la emergencia recién creada. No hace
/// falta invalidarlo a mano desde `activarEmergenciaProvider`.
final historialEmergenciasProvider =
    FutureProvider.autoDispose<List<Emergencia>>((ref) async {
  final persona = await ref.watch(
    personaVisualizacionSeleccionadaProvider.future,
  );
  if (persona == null) return [];

  return ref
      .read(emergencyRepositoryProvider)
      .getEmergenciasByPersona(
        persona.id,
        cantidad: EmergenciasConst.cantidadHistorialCorto,
      );
});
```

> El backend ya devuelve las emergencias **de la más reciente a la más antigua**
> (`OrderByDescending(e => e.FechaHora)` en `EmergenciaRepository`). **No las reordenes en el
> cliente**: sería duplicar una regla que ya vive del otro lado y que además condiciona qué 5
> registros llegan.

Si al volver a la pantalla vieras datos viejos (dependería de cómo el shell de `go_router`
conserve el estado), agregá `ref.invalidate(historialEmergenciasProvider)` al final de
`activarEmergenciaProvider`. Comprobalo antes de sumarlo: si el `autoDispose` alcanza, no lo
agregues.

### D.3 — Widget del ítem

**Archivo nuevo:** `lib/presentation/widgets/emergency/emergency_history_tile.dart`

```dart
/// Fila del historial corto de emergencias.
///
/// Muestra cuándo se activó y quién la activó. Es un registro inmutable: no
/// tiene acciones ni navegación.
class EmergencyHistoryTile extends StatelessWidget {
  const EmergencyHistoryTile({super.key, required this.emergencia});

  final Emergencia emergencia;
  ...
}
```

Contenido de cada fila:

| Elemento | Valor | Estilo |
|---|---|---|
| Ícono | `Icons.history` | `size: 16`, `context.colors.textSecondary` |
| Línea 1 | `'{d MMM yyyy} · {HH:mm}'` | `fontSize: 14`, `textPrimary`, `w600` |
| Línea 2 | `'Activada por {activador.nombre} {activador.apellido}'` | `fontSize: 12`, `textSecondary` |
| Línea 3 (condicional) | `emergencia.descripcion` | `fontSize: 12`, `textSecondary`, `maxLines: 2`, `overflow: ellipsis` |

Formato de fecha, reusando el patrón que ya usa `health_event_card.dart:112`:

```dart
final fecha = DateFormat('d MMM yyyy', 'es').format(emergencia.fechaHora);
final hora = DateFormat('HH:mm').format(emergencia.fechaHora);
```

Ícono `history` y no `notifications_active`: esto ya pasó, no está pasando. El módulo usa rojo
para lo que es acción urgente; el historial es informativo y va en color neutro. **No uses
`emergencyRed` acá** — competiría visualmente con el botón, que es lo único que debe llamar la
atención en esta pantalla.

`Semantics` con label `'Emergencia del {fecha} a las {hora}, activada por {nombre} {apellido}'`.

> **Sobre la línea 3:** hoy `activarEmergenciaProvider` manda siempre `descripcion: null`, así que
> en la práctica no se va a ver nunca. Se implementa igual porque el campo existe en el contrato y
> en la entidad, y el día que se agregue el input de descripción no hay que volver acá. No
> inviertas tiempo en refinarla.

### D.4 — Integración en la pantalla

**Archivo:** `lib/presentation/screens/emergency/emergency_screen.dart`

Va **después** del texto `'Tocá el botón para enviar la alerta'` y **antes** del
`SizedBox(height: AppSpacing.xxxl)` final.

Esa ubicación no es casual: deja el botón exactamente donde está hoy, en el mismo scroll offset.
Si el historial fuera arriba, empujaría el botón hacia abajo y la cantidad de desplazamiento
dependería de cuántas emergencias haya — o sea, **el control más importante de la pantalla
cambiaría de lugar según los datos**. Inaceptable en una pantalla de emergencia.

```dart
const SizedBox(height: AppSpacing.xl),

ref.watch(historialEmergenciasProvider).when(
  // Sin spinner: el historial es accesorio y no debe competir con el botón.
  loading: () => const SizedBox.shrink(),
  // Silencioso: si el historial falla, la pantalla igual tiene que servir
  // para activar la emergencia. Nunca mostrar un error acá.
  error: (_, _) => const SizedBox.shrink(),
  data: (emergencias) => _HistorialCard(emergencias: emergencias),
),
```

El `_HistorialCard` replica el contenedor de la card del equipo (líneas 88-95): `context.colors.surface`,
`BorderRadius.circular(AppSpacing.radiusMd)`, `boxShadow: AppSpacing.elev1`,
`padding: EdgeInsets.all(AppSpacing.md)`.

Adentro:

1. Encabezado `'Últimas emergencias'`, mismo estilo que `'Equipo de cuidado'`
   (`fontSize: 14`, `w600`, `textPrimary`), con `Icon(Icons.history, size: 20)` en `textSecondary`.
2. Si `emergencias.isEmpty`: `'Sin emergencias registradas'` en `fontSize: 13`, `textSecondary`.
3. Si no: los `EmergencyHistoryTile` separados por `Divider(height: 1, color: context.colors.surfaceVariant)`,
   igual que hace `emergency_sent_screen.dart` con la lista del equipo.

> **Por qué el vacío sí se muestra y el error no.** "No hay emergencias registradas" es una
> respuesta exitosa y es información útil y tranquilizadora. `loading` y `error` no son respuestas:
> son estados donde el cliente no sabe nada, y en esta pantalla el silencio es mejor que el ruido.

Exportar `EmergencyHistoryTile` en el barrel `lib/presentation/widgets/emergency/emergency.dart`.

### D.5 — Permisos

**No agregues ninguna validación en el cliente.** El backend ya la hace:

```csharp
// ActivarEmergenciaBusinessService.Obtener
this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);
```

Cualquiera que pueda ver el contexto de la persona puede ver su historial de emergencias, que es
el criterio correcto. Si el usuario no tuviera permiso, la respuesta es 400 y el `error:` de D.4
lo absorbe en silencio.

Ojo con esto: un colaborador **sin** permiso `ActivarEmergencia` ve la pantalla con el botón
deshabilitado (`emergency_screen.dart:165`) y **sí** va a ver el historial. Es coherente —ver no es
activar— pero lo dejo señalado para que `analista-funcional` lo documente cuando le toque.

### D.6 — Tests

**`test/presentation/providers/emergency/emergency_providers_test.dart`**

```
el_historial_es_vacio_si_no_hay_persona_de_contexto()
el_historial_pide_la_cantidad_definida_en_EmergenciasConst()
el_historial_devuelve_las_emergencias_en_el_orden_que_llegan_del_backend()
```

El segundo se verifica con un fake de `EmergencyRepository` que capture el `cantidad` recibido. El
tercero protege contra que alguien agregue un `sort` en el cliente "para asegurarse".

**`test/presentation/widgets/emergency/emergency_history_tile_test.dart`**

```
muestra_la_fecha_la_hora_y_el_activador()
muestra_la_descripcion_cuando_existe()
no_muestra_la_linea_de_descripcion_cuando_es_nula()
```

**`test/infrastructure/mappers/emergency_mapper_test.dart`** — el que había propuesto como opción
(b) del hallazgo 5. Ahora que el camino tiene consumidor real sigue valiendo la pena, porque es lo
único que fija el contrato del `EmergenciaDataView` del backend:

```
mapea_una_respuesta_real_de_obtener_emergencias()
```

Usá como entrada el JSON de la sección 3 de la spec de la Fase 5, verificando `id`, `persona`,
`activador`, `fechaHora` y `descripcion` nula.

### D.7 — Fuera de alcance

- Pantalla de historial completo o paginación.
- Detalle de una emergencia (tocar un ítem no hace nada).
- Input de descripción al activar (hoy siempre va `null`).
- Filtros por fecha o por activador.

Si algo de esto parece necesario mientras implementás, **reportalo en vez de agregarlo**.

---
## Criterios de aceptación

| # | Entrega | Verificación |
|---|---|---|
| 1 | todas | `flutter analyze` sin issues |
| 2 | todas | `flutter test` en verde, incluidos los nuevos |
| 3 | A.1 | Renombrando `google-services.json` a mano, la app **arranca igual** y se puede navegar; solo no hay push |
| 4 | A.1 | Restaurado el archivo, el push vuelve a funcionar sin más cambios |
| 5 | A.2 | `grep -rn "cerrarSesionProvider" lib/` lo ubica en `providers/auth/` |
| 6 | A.3 | Test nuevo de orden alta/baja en verde |
| 7 | B | `grep -rn "TODO(deeplink)" lib/` no devuelve nada |
| 8 | B | Con la app en foreground, tocar la notificación de emergencia cambia la persona de contexto |
| 9 | C | Con `ThemeMode.dark`, la pantalla de emergencia no muestra rosa pastel sobre fondo oscuro |
| 10 | C | `grep -n "Color(0xFF" lib/presentation/**/emergency*` no devuelve nada |
| 11 | D | El historial muestra las emergencias activadas, de la más reciente a la más antigua |
| 12 | D | Sin emergencias previas, muestra "Sin emergencias registradas" |
| 13 | D | Con el backend caído, la pantalla abre igual y el botón de emergencia sigue operativo |
| 14 | D | El botón de emergencia queda en la misma posición de scroll, haya 0 o 5 emergencias |

Los criterios 3 y 13 son los más importantes y **hay que probarlos a mano**. El 3 es el único que
valida que el arreglo de A.1 sirve para algo. El 13 valida el principio de la Entrega D: se prueba
apagando el backend y abriendo la pantalla de Emergencia.

---

## Notas de entorno

- Las pruebas en dispositivo físico las ejecuta Esteban manualmente. **No manipular el teléfono vía
  adb.**
- Los criterios 3, 4, 8 y 9 requieren correr la app; el resto se verifica con `analyze` y `test`.
- El criterio 8 se puede probar con un solo dispositivo: activá la emergencia desde otra cuenta
  (o desde la consola de FCM) con la app abierta en primer plano.

---

## Antes de codificar

Presentá el plan numerado y esperá confirmación, según tu flujo habitual.

Si algún número de línea no coincide con el estado real del código, guiate por el contenido citado.
Y si algo de esta spec choca con el código real, reportalo en vez de forzarlo.
