# Emergencias — Fase 5: cliente Flutter (notificaciones push)

> **Destinatario:** `dev-flutter`
> **Autor:** `arquitecto-software`
> **Estado:** especificación cerrada, lista para implementar
> **Depende de:** Fases 1 a 3 del backend (ya implementadas y verificadas)

---

## 1. Contexto y objetivo

El módulo de emergencias ya está terminado del lado del backend (.NET). Falta el cliente Flutter.

**Objetivo:** que al activar la emergencia desde un dispositivo, los miembros del equipo de
cuidado reciban una notificación push en sus dispositivos.

### Qué ya existe en el backend

- Entidad `DispositivoUsuario` (token FCM por instalación) con alta/baja por endpoint.
- Entidad `Emergencia` con `Persona` (contexto) y `Activador`. **No** tiene `Atendida`.
- Envío push vía Firebase Cloud Messaging, verificado end-to-end.
- El backend excluye de los destinatarios al **activador** y a la **persona cuidada**.
- Proyecto Firebase: `carewell-5a787`. El `google-services.json` ya está en
  `care_well_app/android/app/` y el plugin de Gradle ya está aplicado correctamente.
- `pubspec.yaml` ya declara `firebase_core` y `firebase_messaging`.

### Decisiones de producto ya tomadas (no reabrir)

| Decisión | Detalle |
|---|---|
| Sin "marcar como atendida" | La emergencia es un registro inmutable (log del hecho). |
| Sin coordenadas | La alerta es solo informativa. |
| Sin deduplicación | Activar 3 veces crea 3 emergencias. |
| Sin fallback por email/SMS | El push es el único canal. La latencia del email es incompatible con una emergencia. |
| Sin manejo de fallo de entrega | El aviso es best effort. Lo que se garantiza es el registro, no la entrega. |
| La persona cuidada no se autonotifica | No recibe la alerta de su propia emergencia. |

---

## 2. Reglas de arquitectura a respetar

- Clean Architecture layer-first: `presentation -> domain <- infrastructure`.
- `domain/` es Dart puro: NO puede importar Flutter ni paquetes externos.
- Ningún import de `firebase_messaging` fuera de `infrastructure/notifications/`.
- Estado con Riverpod, navegación con go_router, animaciones con animate_do.
- Archivos barrel por carpeta (`entities.dart`, `providers.dart`, `widgets.dart`, etc.).
- Implementaciones de repositorio con sufijo `_impl.dart`.
- Identificadores en inglés; comentarios y documentación en español.
- Tests en `test/` espejando la estructura de `lib/`.

---

## 3. Hoja de contrato de la API

Todos los endpoints requieren header `Authorization: Bearer <jwt>`.

### POST /api/Dispositivo/registrar  ->  200, sin cuerpo

```json
{ "token": "eJp7bUl_SG...", "plataforma": 1 }
```

### POST /api/Dispositivo/eliminar  ->  200, sin cuerpo

```json
{ "token": "eJp7bUl_SG..." }
```

### POST /api/Emergencia/activar  ->  200, SIN CUERPO DE RESPUESTA

```json
{ "personaID": 12, "descripcion": null }
```

### POST /api/Emergencia/obtener  ->  200

Request:

```json
{ "personaID": 12, "cantidad": 20 }
```

Response:

```json
[
  {
    "id": 7,
    "persona": {
      "id": 12, "nombre": "Maria", "apellido": "G.", "documento": "30111222",
      "fechaNacimiento": "1945-03-02T00:00:00", "email": null, "telefono": null
    },
    "activador": {
      "id": 3, "nombre": "Esteban", "apellido": "C.", "documento": "40111222",
      "fechaNacimiento": "1999-01-01T00:00:00", "email": "esteban@mail.com", "telefono": null
    },
    "fechaHora": "2026-08-05T14:32:10",
    "descripcion": null
  }
]
```

### Notas de serialización

- Respuestas en camelCase: `ID -> id`, `PersonaID -> personaID`, `FechaHora -> fechaHora`.
- Requests case-insensitive: se puede enviar `personaId` o `personaID`; ambos matchean.
- `fechaHora` es ISO-8601 sin offset (hora local del servidor). Mismo tratamiento que el
  resto de las fechas de la API.
- `activar` devuelve cuerpo vacío: el datasource NO debe intentar parsear la respuesta.

### Códigos de error

| Código | Caso |
|---|---|
| 400 | Sin permiso `ActivarEmergencia` sobre la persona de contexto |
| 401 | Sin JWT válido, o intento de dar de baja un dispositivo ajeno |
| 404 | Dispositivo inexistente al eliminar |

### Payload de la notificación push que envía el backend

- `title`: "Emergencia" (con emoji de alerta)
- `body`: "{ActivadorNombreCompleto} activó una alerta de emergencia para {PersonaNombreCompleto}."
- `data`: `{ "tipo": "EMERGENCIA", "emergenciaId": "7", "personaId": "12" }`
- `android.notification.channelId`: `emergencias`
- `android.priority`: `high`

---

## 4. Plan de implementación

### 4.1 Canal Android `emergencias`

**4.1.1** En `infrastructure/notifications/local_notification_scheduler.dart`, agregar un
segundo canal junto al de agenda:

```dart
static const _channelEmergenciaId = 'emergencias';    // DEBE coincidir EXACTO con el backend
static const _channelEmergenciaName = 'Emergencias';
```

Crearlo en `init()` con `Importance.max` (el de agenda usa `high`).

**4.1.2** En `android/app/src/main/AndroidManifest.xml`, dentro de `<application>`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="emergencias" />
```

> El channelId es un contrato con el backend (`CanalesNotificacionPush.Emergencias`).
> Si no coincide carácter por carácter, la notificación llega con importancia por defecto
> y no suena.

---

### 4.2 Domain — contratos puros

**4.2.1** `domain/notifications/push_message.dart`:

```dart
class PushMessage {
  final String? titulo;
  final String? cuerpo;
  final Map<String, String> datos;

  const PushMessage({this.titulo, this.cuerpo, this.datos = const {}});

  String? get tipo => datos['tipo'];
  int? get personaId => int.tryParse(datos['personaId'] ?? '');
  int? get emergenciaId => int.tryParse(datos['emergenciaId'] ?? '');
}
```

**4.2.2** `domain/notifications/push_messaging_service.dart`:

```dart
abstract class PushMessagingService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<String?> obtenerToken();
  Stream<String> get onTokenRefresh;
  Stream<PushMessage> get onMessage;           // app en foreground
  Stream<PushMessage> get onMessageOpenedApp;  // el usuario tocó la notificación
  Future<PushMessage?> getInitialMessage();    // app abierta desde estado terminado
}
```

**4.2.3** Exportar ambos en el barrel `domain/notifications/notifications.dart`.

**4.2.4** `domain/datasources/dispositivo_datasource.dart` y
`domain/repositories/dispositivo_repository.dart` (misma firma en ambos):

```dart
abstract class DispositivoDatasource {
  Future<void> registrar({required String token, required int plataforma});
  Future<void> eliminar({required String token});
}
```

Agregar a los barrels correspondientes.

**4.2.5** Constante de plataforma, junto a los demás `*Const` de `domain/entities/`:

```dart
abstract class PlataformasDispositivoConst {
  static const int android = 1;   // backend: DispositivoPlataformasEnum.Android
  static const int ios = 2;
}
```

---

### 4.3 Domain — ajustes de la entidad Emergencia

**4.3.1** En `domain/entities/emergency/emergencia.dart`:

- Eliminar el campo `atendida`.
- Agregar `final Persona activador;`.
- Actualizar `copyWith`.

**4.3.2** En `domain/datasources/emergency_datasource.dart` y
`domain/repositories/emergency_repository.dart`:

- Eliminar `marcarAtendida` por completo.
- `activarEmergencia` pasa de `Future<Emergencia>` a `Future<void>`.

---

### 4.4 Infrastructure — implementaciones

**4.4.1** `infrastructure/notifications/firebase_push_messaging_service.dart` — única clase
de todo el proyecto que importa `firebase_messaging`. Implementa `PushMessagingService`
mapeando `RemoteMessage` a `PushMessage`.

> NO implementar background handler. El backend envía payload `notification`, por lo que
> Android muestra la notificación por sí solo con la app en background o cerrada. Solo haría
> falta si en el futuro se pasara a mensajes data-only.

**4.4.2** `infrastructure/models/dispositivo/` +
`infrastructure/datasources/api/api_dispositivo_datasource.dart`, siguiendo el patrón de
`ApiSummaryDatasource` (try/catch de `DioException` y `ApiExceptionMapper.map`).

**4.4.3** `infrastructure/repositories/dispositivo_repository_impl.dart` (delegación directa).

**4.4.4** `infrastructure/datasources/api/api_emergency_datasource.dart`, reemplazando al demo:

- `activarEmergencia` -> POST a `activarEmergenciaPath` con `personaID` y `descripcion`.
- `getEmergenciasByPersona` -> POST a `obtenerEmergenciasPath` con `personaID` y `cantidad`.

**4.4.5** `infrastructure/mappers/emergency_mapper.dart` y
`infrastructure/models/emergency/emergencia_model.dart`: agregar `activador`, quitar `atendida`.

**4.4.6** En `infrastructure/http/api_config.dart`:

```dart
static const registrarDispositivoPath = '/api/Dispositivo/registrar';
static const eliminarDispositivoPath  = '/api/Dispositivo/eliminar';
static const activarEmergenciaPath    = '/api/Emergencia/activar';
static const obtenerEmergenciasPath   = '/api/Emergencia/obtener';
```

**4.4.7** Actualizar `DemoEmergencyDatasource` para que compile con el contrato nuevo, o
eliminarlo si ya no se usa.

---

### 4.5 Providers (DI)

En `presentation/providers/di_providers.dart`, respetando las regiones existentes:

```dart
// region Notificaciones
final pushMessagingServiceProvider = Provider<PushMessagingService>(
  (ref) => FirebasePushMessagingService(),
);

// region Datasources
final dispositivoDatasourceProvider = Provider<DispositivoDatasource>(
  (ref) => ApiDispositivoDatasource(ref.watch(dioClientProvider)),
);

// region Repositories
final dispositivoRepositoryProvider = Provider<DispositivoRepository>(
  (ref) => DispositivoRepositoryImpl(ref.watch(dispositivoDatasourceProvider)),
);
```

Y cambiar `emergencyDatasourceProvider` de `DemoEmergencyDatasource()` a
`ApiEmergencyDatasource(ref.watch(dioClientProvider))`.

---

### 4.6 Ciclo de vida del token

**4.6.1 Registro tras login.** Nuevo
`presentation/providers/notifications/push_token_providers.dart`.

Un provider que observe `authStateProvider` y, cuando haya usuario autenticado:

1. `requestPermission()`
2. `obtenerToken()`
3. `dispositivoRepository.registrar(token, PlataformasDispositivoConst.android)`
4. Suscribirse a `onTokenRefresh` y re-registrar en cada emisión.

Activarlo con `ref.listen` desde `CareWellApp` o `app_shell`, NO desde una pantalla suelta.

**4.6.2 Baja en logout — CRÍTICO.**

El endpoint `eliminar` requiere JWT. Si se llama DESPUÉS de limpiar la sesión devuelve 401
y el dispositivo queda activo: el usuario seguiría recibiendo emergencias del equipo del que
se desconectó.

Crear una acción que orqueste el orden correcto:

```dart
final cerrarSesionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // 1) Dar de baja el dispositivo MIENTRAS la sesión sigue viva.
    try {
      final token = await ref.read(pushMessagingServiceProvider).obtenerToken();
      if (token != null) {
        await ref.read(dispositivoRepositoryProvider).eliminar(token);
      }
    } catch (_) {
      // Nunca impedir el cierre de sesión por una falla de red.
    }

    // 2) Recién ahora, limpiar la sesión.
    await ref.read(authProvider.notifier).logout();
  };
});
```

Actualizar las pantallas que hoy llaman a `logout()` directamente (Configuración) para que
usen `cerrarSesionProvider`.

> NO hace falta tocar nada en "eliminar cuenta": el backend ya purga los dispositivos del
> usuario en esa operación.

---

### 4.7 Recepción de notificaciones

**4.7.1 Foreground.** Android NO muestra notificaciones push con la app en primer plano.
Suscribirse a `onMessage` y renderizarla con el `NotificationScheduler` existente:

```dart
scheduler.showImmediateNotification(
  notificationId: ...,   // derivar de emergenciaId
  titulo: message.titulo ?? 'Emergencia',
  cuerpo: message.cuerpo ?? '',
  payload: ...,
);
```

> `showImmediateNotification` usa hoy el canal de agenda. Extenderlo para aceptar el canal
> como parámetro, o agregar un método específico para emergencias.

**4.7.2 Deep link.** Con `onMessageOpenedApp` y `getInitialMessage`:

1. Leer `personaId` del payload.
2. Seleccionar esa persona como persona de contexto.
3. Navegar a `AppRoutes.homeName` con `context.goNamed`.

> No crear pantalla de detalle de emergencia: quedó fuera de alcance por decisión de producto.

---

### 4.8 Limpieza

**4.8.1** Eliminar de `main.dart` el andamiaje temporal de captura de token (`getToken`,
`Clipboard`, `debugPrint`), dejando solo `await Firebase.initializeApp();`.

**4.8.2** En `activarEmergenciaProvider`: eliminar el bucle de notificaciones locales a los
miembros del equipo y su comentario TODO(backend). Ahora solo llama al repositorio; el aviso
al equipo lo resuelve el backend.

**4.8.3** Quitar toda referencia a `marcarAtendida` y a `emergencia.atendida` en widgets
(revisar `notification_status_chip.dart` y `emergency_tile.dart`).

---

### 4.9 Copy de la pantalla de emergencia enviada

**Principio:** la pantalla describe la ACCIÓN EJECUTADA, no el resultado de la entrega.
El cliente no puede verificar recepción, así que no debe afirmarla.

**4.9.1** `presentation/screens/emergency/emergency_sent_screen.dart`

| Ubicación | Antes | Después |
|---|---|---|
| Título (~línea 72) | "Alerta enviada" | sin cambios (es verdadero) |
| Cuerpo (~línea 84) | "N personas fueron notificadas. Permanecé donde estás..." | "Se envió la alerta a tu equipo de cuidado. Permanecé donde estás si es seguro hacerlo." |
| Timestamp (~línea 123) | "Alerta enviada a las HH:mm:ss" | sin cambios |

Al eliminarse la interpolación, la cantidad de miembros deja de usarse en el texto. La lista
del equipo SE MANTIENE, pero con un encabezado que aclare qué es: agregar el label
"Equipo de cuidado" encima del Container de la card, alineado a la izquierda.

**4.9.2** `presentation/widgets/emergency/notified_members_card.dart`

| Ubicación | Antes | Después |
|---|---|---|
| Ícono (~línea 61) | `Icons.check_circle` en `AppColors.success` | `Icons.notifications_active_outlined` en `AppColors.textSecondary` |
| Semantics (~línea 24) | "...rolLabel, notificado" | "nombre apellido, rolLabel" |

> El check verde es el problema central: comunica "confirmado" de forma inequívoca. Un ícono
> de campana outline en color neutro comunica "destinatario" sin prometer nada.

**4.9.3** Renombrar `NotifiedMembersCard` a `EmergencyTeamMemberCard`
(archivo `emergency_team_member_card.dart`), actualizando el barrel `widgets.dart` y sus usos.
El nombre actual afirma justamente lo que se está corrigiendo.

---

## 5. Criterios de aceptación

| # | Verificación |
|---|---|
| 1 | `flutter analyze` sin errores; `flutter test` en verde |
| 2 | Tras login, aparece fila en `t_DispositivoUsuario` con `Activo = 1` |
| 3 | Tras logout, esa fila queda `Activo = 0` |
| 4 | Login con OTRO usuario en el mismo dispositivo -> UNA SOLA fila, con `ID_Usuario` actualizado |
| 5 | Emergencia activada desde el dispositivo A -> llega notificación al dispositivo B del equipo |
| 6 | El activador NO recibe notificación |
| 7 | Llega con la app en foreground, en background y cerrada |
| 8 | Al tocar la notificación, abre la app con la persona de contexto correcta |
| 9 | Ningún import de `firebase_messaging` fuera de `infrastructure/notifications/` |

---

## 6. División sugerida en dos entregas

### Entrega A — Ciclo de vida del token

Puntos 4.1, 4.2.4, 4.2.5, 4.4.2, 4.4.3, 4.4.6, 4.5 y 4.6.

Se valida con un solo dispositivo mirando `t_DispositivoUsuario`: alta en login, baja en
logout, reasignación al cambiar de usuario. Es plumbing puro y de bajo riesgo.
Cubre los criterios de aceptación 1 a 4.

### Entrega B — Emergencia y recepción

Puntos 4.2.1 a 4.2.3, 4.3, 4.4.1, 4.4.4, 4.4.5, 4.4.7, 4.7, 4.8 y 4.9.

Incluye el cambio de contrato de la entidad, el deep link y el copy.
Cubre los criterios de aceptación 5 a 9.

> Si A falla, B no puede probarse. El orden no es arbitrario.

---

## 7. Notas de entorno para las pruebas

- Se requieren DOS dispositivos (o dispositivo físico + emulador con imagen Google Play)
  con USUARIOS DISTINTOS DEL MISMO EQUIPO DE CUIDADO para validar los criterios 5 a 7.
- Un emulador con imagen AOSP no sirve: sin Google Play Services el token FCM vuelve null.
- NO probar en el teléfono de Esteban vía adb. Las pruebas en dispositivo físico las ejecuta
  él manualmente.
- El backend debe estar corriendo y accesible desde el dispositivo (IP de LAN, no localhost).

### Gotchas ya conocidos (aprendidos durante las fases previas)

1. Un FID no es un token de registro. El token tiene formato `<FID>:<token>`. Enviar un token
   en el campo de FIDs produce `UNREGISTERED`, indistinguible de un token vencido.
2. Reinstalar la app NO limpia los datos: si hace falta forzar un token nuevo, hay que
   DESINSTALAR por completo.
3. El token rota. Capturarlo y probarlo en la misma sesión, sin rebuildear en el medio.

---

## 8. Antes de codificar

Presentá el plan numerado y esperá confirmación, según tu flujo de trabajo habitual.

Si algo de esta spec choca con el estado real del código, NO la sigas a ciegas: reportalo y
se ajusta.
