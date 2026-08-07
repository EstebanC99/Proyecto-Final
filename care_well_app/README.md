# CareWell — App móvil (Flutter)

Frontend de CareWell. Para el contexto del proyecto completo (backend, base de datos,
documentación) ver el [README de la raíz del repositorio](../README.md).

## Requisitos

- Flutter (canal stable) con el toolchain de Android configurado (`flutter doctor`).
- JDK 17.
- Un emulador o dispositivo Android. iOS todavía no está soportado.

## Puesta en marcha

```bash
flutter pub get
flutter run
```

### URL del backend

La app toma la URL base desde la variable de compilación `API_BASE_URL`
(ver `lib/infrastructure/http/api_config.dart`). Es una constante resuelta **en tiempo de
compilación**: queda embebida en el binario, no se lee en runtime.

Si no se pasa ningún flag, el valor por defecto depende del modo de compilación:

| Modo | URL por defecto |
|------|-----------------|
| debug / `flutter run` | dev tunnel de desarrollo |
| `--release` | producción (`https://api.estecarsoft.com.ar/`) |

Así, un APK de release nunca queda apuntando por accidente al dev tunnel, que es efímero.
El valor se puede pisar siempre con `--dart-define`, y hay dos archivos de ambiente:

- `.env` — desarrollo (dev tunnel).
- `.env.production` — producción.

```bash
# Desarrollo (equivalente al default en debug)
flutter run --dart-define-from-file=.env

# Producción
flutter run --dart-define-from-file=.env.production
```

### Generar el APK de release

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=.env.production
```

El artefacto queda en `build/app/outputs/flutter-apk/app-release.apk`. Es un APK **universal**
(incluye todas las arquitecturas), así que se puede compartir tal cual y se instala en
cualquier Android habilitando "Instalar apps de fuentes desconocidas" en el dispositivo destino.

El `--dart-define-from-file` es redundante con el default de release, pero deja el comando
autodocumentado. Para verificar qué URL quedó embebida:

```bash
unzip -p build/app/outputs/flutter-apk/app-release.apk lib/arm64-v8a/libapp.so \
  | grep -a -o "https://api.estecarsoft.com.ar/" | head -1
```

Variante con APKs más chicos, uno por arquitectura (hay que elegir el correcto; casi todos los
celulares actuales son `arm64-v8a`):

```bash
flutter build apk --release --split-per-abi --dart-define-from-file=.env.production
```

`flutter build appbundle` (`.aab`) **no** sirve para compartir directo: es solo para subir a
Google Play.

> **Firma.** Hoy el build de release se firma con la *debug key*
> (`android/app/build.gradle.kts`). El APK se instala y funciona igual, pero esa clave es
> propia de cada máquina: un APK futuro firmado con otra clave no podrá actualizar al
> instalado (habrá que desinstalar, perdiendo los datos locales). Pendiente: keystore propio
> con `key.properties`.

### Notificaciones push: `google-services.json`

Las notificaciones de emergencia usan Firebase Cloud Messaging, que necesita el archivo
de configuración del proyecto Firebase en:

```
android/app/google-services.json
```

**Ese archivo no está versionado** (lleva las claves del proyecto Firebase, y está listado
en el `.gitignore` de la raíz). Para obtenerlo:

1. Entrar a la [consola de Firebase](https://console.firebase.google.com/) y abrir el
   proyecto de CareWell.
2. Ir a *Configuración del proyecto* → pestaña *General* → sección *Tus apps*.
3. Elegir la app Android con package name `com.example.care_well_app` y descargar
   `google-services.json`.
4. Copiarlo en `android/app/`.

**Si el archivo no está, la app compila y corre igual, solo que sin notificaciones push.**
Es una degradación deliberada: el push es *best effort* y no debe impedir usar la app. En
concreto:

- `android/app/build.gradle.kts` aplica el plugin `com.google.gms.google-services` solo si
  el archivo existe (si no, el plugin abortaría el build).
- `main.dart` envuelve `Firebase.initializeApp()` en un `try/catch` y publica el resultado
  en `pushDisponibleProvider`.
- Sin SDK disponible, `pushMessagingServiceProvider` resuelve a `NullPushMessagingService`,
  una implementación inerte: no pide permisos, no obtiene token y no registra el dispositivo
  contra el backend.

Todo el resto de la app (incluidas las notificaciones **locales** de la Agenda) funciona
normalmente.

### Modo demo

El proyecto incluye datasources de demostración (`lib/infrastructure/datasources/demo/`)
además de las implementaciones contra la API (`lib/infrastructure/datasources/api/`). Ambas
cumplen los contratos de `lib/domain/datasources/` y la selección se resuelve en los
providers de Riverpod (`lib/presentation/providers/di_providers.dart`).

## Calidad de código

```bash
flutter analyze
flutter test
dart format .
```

## Arquitectura

Clean Architecture organizada por capa, con `domain` en el centro y sin dependencias de
Flutter. Las convenciones completas están en el [`CLAUDE.md`](../CLAUDE.md) de la raíz.

```
lib/
├── config/           # tema, rutas (go_router), constantes
├── domain/           # entidades, contratos de datasources y repositorios
├── infrastructure/   # implementaciones, modelos (DTOs) y mappers
└── presentation/     # providers (Riverpod), pantallas y widgets
```
