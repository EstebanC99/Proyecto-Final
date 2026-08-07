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
(ver `lib/infrastructure/http/api_config.dart`). Por defecto (`flutter run` sin flags)
apunta al dev tunnel de desarrollo. Hay dos archivos de ambiente:

- `.env` — desarrollo (dev tunnel). Es el default, no hace falta pasar ningún flag.
- `.env.production` — producción (`https://api.estecarsoft.com.ar`).

```bash
# Desarrollo (equivalente al default)
flutter run --dart-define-from-file=.env

# Producción
flutter run --dart-define-from-file=.env.production
```

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
