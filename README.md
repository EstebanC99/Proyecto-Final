# CareWell

Aplicación móvil para acompañar a personas cuidadoras de adultos mayores, personas con
discapacidad o en situación de dependencia. CareWell centraliza la información de la persona
bajo cuidado y coordina la red de colaboradores (responsables y cuidadores) que participan
del cuidado.

Proyecto final de la carrera de Ingeniería en Sistemas de Información (UTN FRR).

## Índice

- [Qué resuelve](#qué-resuelve)
- [Alcance y estado de implementación](#alcance-y-estado-de-implementación)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Stack tecnológico](#stack-tecnológico)
- [Puesta en marcha](#puesta-en-marcha)
  - [1. Base de datos (SQL Server)](#1-base-de-datos-sql-server)
  - [2. Ollama (validación de identidad)](#2-ollama-validación-de-identidad)
  - [3. Backend (.NET 10)](#3-backend-net-10)
  - [4. Frontend (Flutter)](#4-frontend-flutter)
  - [5. Documentación (LaTeX)](#5-documentación-latex)
- [Comandos útiles](#comandos-útiles)
- [Documentación del proyecto](#documentación-del-proyecto)

## Qué resuelve

El cuidado de una persona dependiente rara vez recae en una sola persona: suele involucrar a
familiares, allegados y, a veces, cuidadores profesionales. Esa red enfrenta problemas
recurrentes de organización: información dispersa, falta de coordinación entre quienes
cuidan, dificultad para seguir turnos médicos y medicación, y ausencia de un registro
compartido del estado de salud.

CareWell aborda esas problemáticas ofreciendo:

- Un lugar único donde centralizar los datos de la persona bajo cuidado.
- Una red de cuidado con roles y permisos, para que cada colaborador vea y haga solo lo que
  le corresponde.
- Agenda compartida con recordatorios, historial de salud y registro de hábitos y estados de
  ánimo.

Conceptos base del dominio:

- **Persona**: individuo registrado en el sistema. Puede existir *sin* credenciales de acceso
  (la carga un responsable o cuidador cuando la persona no puede usar la app).
- **Usuario**: una Persona con credenciales propias para iniciar sesión.
- **Equipo de cuidado**: red de responsables y cuidadores asociados a una Persona.
- **Roles (RBAC)**: el *responsable* gestiona los datos de la persona a cargo y administra el
  equipo y sus permisos; el *cuidador* realiza tareas de cuidado según los permisos que se le
  asignen.

## Alcance y estado de implementación

Módulos definidos para el MVP y su estado actual, a grandes rasgos:

| Módulo | Estado |
|---|---|
| Autenticación (login, registro, recuperación de contraseña, verificación de email por OTP) | Implementado |
| Validación de identidad contra documento (OCR/IA en el registro y en la creación de credenciales) | Implementado en backend; frontend en curso |
| Perfil de usuario | Implementado |
| Configuración (T&C, cambio de contraseña, cierre de sesión, eliminación de cuenta) | Implementado |
| Menú principal | Implementado |
| Personas a cargo (ABM) | Implementado |
| Mi equipo (responsables y cuidadores, roles y permisos) | Implementado, con deuda técnica pendiente |
| Agenda (eventos, recurrencia y recordatorios con notificaciones locales) | Implementado |
| Mi salud (hábitos, eventos de salud, estados de ánimo, ficha de salud, línea de tiempo, alertas de bienestar) | Implementado |
| Emergencia (aviso al equipo de cuidado) | Modelado en el dominio; sin exponer aún |

Reservado para iteraciones posteriores:

- Chat / comunicación interna del equipo.
- Análisis de datos (gráficos y reportes).

Reservado a futuro, como integraciones con terceros:

- Login con Google y vinculación de cuentas Gmail.
- Sincronización de la agenda con Google Calendar.
- Módulo de IA de apoyo para consultas de salud (solo orientativo, nunca diagnóstico).

## Estructura del repositorio

```
PROYECTO-FINAL/
├── .claude/agents/              # agentes de Claude Code
├── .github/
├── care_well_app/               # aplicación Flutter (frontend)
│   └── lib/
│       ├── config/              # constraints, routers (go_router), theme
│       ├── domain/              # entities, datasources, repositories, exceptions (contratos puros)
│       ├── infrastructure/      # datasources (api/demo), http, mappers, models, repositories, storage
│       └── presentation/        # providers (Riverpod), screens, widgets
├── care_well_backend/
│   └── CareWell/                # solución .NET 10 (CareWell.slnx)
│       ├── CareWell.API                        # entry point: controllers, Program.cs, filtros
│       ├── CareWell.Domain                     # entidades, value objects, domain services, validadores
│       ├── CareWell.Repository                 # EF Core: DbContext, configuraciones, repos, UoW, migraciones
│       ├── CareWell.BusinessService            # casos de uso (CQRS a mano)
│       ├── CareWell.BusinessService.Abstractions
│       ├── CareWell.Commands                   # DTOs de escritura
│       ├── CareWell.Queries                    # DTOs de lectura
│       ├── CareWell.DataViews                  # DTOs de salida
│       ├── CareWell.Global                     # constantes, enumeraciones, mensajes, excepciones
│       ├── CareWell.Notifications              # envío de emails (SMTP)
│       ├── CareWell.Security                   # contexto del usuario autenticado (JWT)
│       ├── CareWell.DocumentIntelligence       # cliente de IA (Ollama) para lectura de documentos
│       ├── CareWell.Domain.Test
│       └── CareWell.BusinessService.Test
├── care_well_doc/
│   ├── Diagramas/               # modelo de dominio (.drawio) y otros diagramas
│   ├── Interfaces/              # diseño de pantallas por caso de uso
│   ├── User Stories/
│   └── LATEX/                   # documento del proyecto (fuente .tex y PDF compilado)
├── care_well_sql/               # scripts SQL (creación de BD/usuario, datos de tablas fijas)
├── CLAUDE.md                    # guía del proyecto para Claude Code
└── README.md
```

## Stack tecnológico

**Backend**

- ASP.NET Core 10 Web API (.NET 10).
- Entity Framework Core 10 con SQL Server.
- CQRS implementado a mano (sin MediatR ni librerías de mediación externas).
- Autenticación con JWT (`System.IdentityModel.Tokens.Jwt`).
- Arquitectura por capas con el dominio en el centro: `API → Repository → Domain`;
  `BusinessService → Abstractions, Repository, Domain, Notifications, Security,
  DocumentIntelligence`.

**Frontend**

- Flutter / Dart, con arquitectura limpia organizada por capa
  (`presentation → domain ← infrastructure`).
- Riverpod para gestión de estado e inyección de dependencias.
- `go_router` para navegación, `animate_do` para animaciones.
- Plataforma objetivo: Android (iOS se evaluará a futuro).

**Infraestructura de apoyo**

- SQL Server como motor de base de datos.
- Ollama con un modelo de visión, para la validación de identidad contra documento.
- SMTP (Elastic Email) para el envío de códigos de verificación y recuperación.

## Puesta en marcha

Requisitos generales:

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- SQL Server (local o remoto)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) con toolchain de Android
  (Android Studio / SDK + un emulador o dispositivo físico)
- [Ollama](https://ollama.com/)

### 1. Base de datos (SQL Server)

En `care_well_sql/` hay scripts de apoyo:

1. `Creacion de Usuario-Rol-BD.sql`: crea el login, la base `CareWell` y los permisos.
   Ajustá la contraseña del script antes de ejecutarlo en cualquier entorno que no sea tu
   máquina local.
2. `post-deployment/Carga de datos tablas fijas.sql`: carga los catálogos del sistema
   (tipos de evento, roles, estados, permisos, etc.). **Ejecutalo después de aplicar las
   migraciones**, ya que inserta sobre tablas que crea EF Core.

### 2. Ollama (validación de identidad)

El backend usa un modelo de visión servido por Ollama para leer el documento de identidad
durante el registro y la creación de credenciales. **Sin Ollama corriendo, esos dos flujos
responden 503** y no se puede crear una cuenta.

```bash
ollama pull qwen2.5vl     # descarga el modelo de visión utilizado
ollama serve              # levanta el servicio (si no corre como servicio del sistema)
ollama list               # verifica que el modelo esté disponible
```

Verificación rápida de que el servicio responde:

```bash
curl http://localhost:11434/api/tags
```

El modelo, la URL y el timeout se configuran en la sección `ReconocedorTexto` de
`appsettings.json` (ver punto siguiente). Si usás otro modelo de visión, actualizá esa clave.

### 3. Backend (.NET 10)

Desde `care_well_backend/CareWell/`:

```bash
dotnet restore
dotnet build CareWell.slnx
```

**Configuración.** `CareWell.API/appsettings.json` trae los valores de ejemplo. Los datos
sensibles (cadena de conexión, clave JWT, credenciales SMTP) **no deben commitearse**:
usá [User Secrets](https://learn.microsoft.com/aspnet/core/security/app-secrets) sobre el
proyecto `CareWell.API`.

Claves necesarias:

| Clave | Descripción |
|---|---|
| `ConnectionStrings:CareWellDb` | Cadena de conexión a SQL Server |
| `Jwt:Key` | Clave simétrica para firmar los tokens |
| `Jwt:Issuer` / `Jwt:Audience` | Emisor y audiencia de los tokens |
| `Email:*` | Host, puerto, usuario, contraseña y remitente SMTP (Elastic Email) |
| `ReconocedorTexto:OllamaUrl` | URL del servicio Ollama (por defecto `http://localhost:11434`) |
| `ReconocedorTexto:Modelo` | Modelo de visión a utilizar (`qwen2.5vl`) |
| `ReconocedorTexto:TimeoutSegundos` | Timeout de la llamada al modelo |

Ejemplo:

```bash
cd CareWell.API
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:CareWellDb" "Server=localhost;Database=CareWell;User ID=...;Password=...;TrustServerCertificate=True;"
dotnet user-secrets set "Jwt:Key" "..."
```

**Migraciones.** Requiere la herramienta de EF Core (`dotnet tool install --global dotnet-ef`).
Desde `care_well_backend/CareWell/`:

```bash
dotnet ef database update --project CareWell.Repository --startup-project CareWell.API
```

Después de aplicar las migraciones, ejecutá el script de post-deployment mencionado en el
punto 1 para cargar los catálogos.

**Ejecución y pruebas:**

```bash
dotnet run --project CareWell.API
dotnet test CareWell.Domain.Test/CareWell.Domain.Test.csproj
dotnet test CareWell.BusinessService.Test/CareWell.BusinessService.Test.csproj
```

En entorno de desarrollo, la API expone Swagger para explorar los endpoints.

### 4. Frontend (Flutter)

Desde `care_well_app/`:

```bash
flutter pub get
flutter run
```

**URL del backend.** La app toma la URL base desde la variable de compilación
`API_BASE_URL` (definida en `lib/infrastructure/http/api_config.dart`). Para apuntar a tu
backend local o a un túnel de desarrollo:

```bash
flutter run --dart-define=API_BASE_URL=https://tu-backend
```

**Notificaciones push.** Requieren el archivo `android/app/google-services.json`, que **no
está versionado** porque contiene las claves del proyecto Firebase. Sin él la app compila y
corre igual, solo que sin push. En
[`care_well_app/README.md`](care_well_app/README.md#notificaciones-push-google-servicesjson)
está de dónde bajarlo y cómo degrada la app cuando falta.

**Modo demo.** El proyecto incluye datasources de demostración
(`lib/infrastructure/datasources/demo/`) además de las implementaciones contra la API
(`lib/infrastructure/datasources/api/`). Ambas cumplen los mismos contratos definidos en
`lib/domain/datasources/`, y la selección se resuelve mediante los providers de Riverpod en
`lib/presentation/providers/`. Esto permite desarrollar y navegar la app sin levantar el
backend. Tené en cuenta que los flujos que dependen de servicios externos (verificación de
email por OTP y validación de identidad con Ollama) solo funcionan contra la API real.

**Calidad de código:**

```bash
flutter analyze
flutter test
dart format .
```

### 5. Documentación (LaTeX)

El documento del proyecto se mantiene en `care_well_doc/LATEX/`. Para compilarlo hace falta
una distribución de LaTeX con `latexmk`:

```bash
cd care_well_doc/LATEX
latexmk -pdf CuidadoPersonas.tex
```

El PDF compilado (`CuidadoPersonas.pdf`) se versiona en el repositorio, así que solo
necesitás compilarlo si modificás el `.tex`.

## Comandos útiles

| Contexto | Comando |
|---|---|
| Backend: compilar | `dotnet build CareWell.slnx` |
| Backend: ejecutar | `dotnet run --project CareWell.API` |
| Backend: tests | `dotnet test <proyecto de test>` |
| Backend: migraciones | `dotnet ef database update --project CareWell.Repository --startup-project CareWell.API` |
| Frontend: dependencias | `flutter pub get` |
| Frontend: ejecutar | `flutter run` |
| Frontend: análisis estático | `flutter analyze` |
| Frontend: tests | `flutter test` |
| Frontend: formato | `dart format .` |
| Ollama: descargar modelo | `ollama pull qwen2.5vl` |
| Documentación | `latexmk -pdf CuidadoPersonas.tex` |

## Documentación del proyecto

Antes de asumir requisitos, reglas de negocio o decisiones de diseño, consultá las fuentes
del proyecto:

- **Documento del proyecto**: `care_well_doc/LATEX/CuidadoPersonas.pdf` (fuente editable:
  `CuidadoPersonas.tex`). Es la fuente de verdad sobre el alcance y las reglas de negocio.
- **Modelo de dominio**: `care_well_doc/Diagramas/CareWell-modelo-dominio.drawio`.
- **Diseño de interfaces**: `care_well_doc/Interfaces/`, organizado por caso de uso.
- **User stories**: `care_well_doc/User Stories/`.
- **Guía para Claude Code**: `CLAUDE.md`, con las convenciones de arquitectura, nomenclatura
  y flujo de trabajo con agentes.

Convenciones generales: identificadores en inglés en el frontend y en español en el backend;
comentarios y documentación en español; commits en español siguiendo *conventional commits*
(`feat:`, `fix:`, `refactor:`…).
