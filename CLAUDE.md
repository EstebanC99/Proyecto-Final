# CareWell — Guía del proyecto (CLAUDE.md)

> Memoria de proyecto para Claude Code. Se lee automáticamente al inicio de cada sesión.
> La raíz del repositorio (PROYECTO-FINAL) contiene el frontend móvil (Flutter, en
> `care_well_app/`) y la documentación del proyecto (`care_well_doc/`). El backend vive en
> un repositorio separado y se desarrolla de forma desacoplada; no es alcance de este repo.

## 1. Qué es este proyecto
CareWell es una aplicación móvil que ayuda a personas cuidadoras de adultos mayores, personas
con discapacidad o dependientes a centralizar la información de la persona bajo cuidado y a
coordinar la red de colaboradores (responsables y cuidadores) que participan en el cuidado.
Proyecto final de la carrera de Ingeniería en Sistemas de Información (UTN FRR).

## 2. Estructura del repositorio
```
PROYECTO-FINAL/                  # raíz del repo (Claude Code corre acá)
├── .claude/agents/              # agentes de Claude Code
├── care_well_app/               # app Flutter (frontend) — ver sección 5
│   └── lib/ ...
├── care_well_doc/
│   ├── Diagramas/               # diagramas (modelo de dominio .drawio, etc.)
│   └── LATEX/                   # documentación en LaTeX
│       ├── Imagenes/  Recursos/  build/
│       ├── CuidadoPersonas.tex  # fuente editable (la mantiene analista-funcional)
│       └── CuidadoPersonas.pdf  # documento compilado (referencia de los agentes)
├── CLAUDE.md
└── README.md
```

## 3. Documentación y fuentes de referencia
Cuando cualquier agente necesite información sobre la aplicación (requisitos, alcance, reglas
de negocio, módulos, análisis funcional, decisiones de diseño), debe consultar las fuentes del
proyecto antes de asumir:
- **Documento del proyecto:** `care_well_doc/LATEX/CuidadoPersonas.pdf` (fuente editable:
  `care_well_doc/LATEX/CuidadoPersonas.tex`). Es la fuente de verdad sobre la aplicación.
- **Modelo de dominio (ER):** `care_well_doc/Diagramas/CareWell-modelo-dominio.drawio`.

`arquitecto-software` y `dev-flutter` deben **tener presente el diagrama de modelo de dominio**
al tomar decisiones, modelar o implementar. `analista-funcional` es el único agente que
modifica la documentación en LaTeX.

## 4. Stack (frontend)
- **Framework:** Flutter / Dart.
- **Gestión de estado:** Riverpod.
- **Ruteo / navegación:** `go_router` (rutas centralizadas en `lib/config/routers/app_router.dart`).
- **Animaciones:** paquete `animate_do`.
- **Inyección de dependencias:** mediante providers de Riverpod (no get_it).
- **Plataforma objetivo:** Android primero; iOS se evaluará a futuro.
- **Relación con el backend:** el frontend se desarrolla desacoplado. Las datasources
  arrancan con implementaciones de demo/mock (`infrastructure/datasources/demo`) y luego
  se reemplazan por implementaciones contra la API, sin tocar domain ni presentation.

## 5. Arquitectura (app Flutter)
Arquitectura limpia (*Clean Architecture*) organizada **por capa (layer-first)**, dentro de
`care_well_app/lib/`. La capa `domain` NO depende de Flutter ni de paquetes externos. La capa
de datos se llama `infrastructure`.

```
care_well_app/lib/
├── main.dart
├── config/                 # configuración transversal de la app
│   ├── constraints/        # constantes y restricciones
│   ├── menu/               # ítems de menú / navegación
│   ├── routers/            # go_router → app_router.dart
│   └── theme/              # app_theme.dart
├── domain/                 # contratos puros (sin Flutter ni paquetes externos)
│   ├── datasources/        # interfaces de datasources
│   ├── entities/           # entidades agrupadas por concepto + barrel entities.dart
│   └── repositories/       # interfaces de repositorios
├── infrastructure/         # implementaciones concretas de los contratos de domain
│   ├── datasources/        # implementaciones; /demo para mocks, luego /api
│   ├── mappers/            # mapeo modelo <-> entidad
│   ├── models/             # DTOs (serialización)
│   └── repositories/       # implementaciones de repositorios (..._impl.dart)
└── presentation/
    ├── providers/          # providers de Riverpod (incl. providers de repositorio = DI),
    │                       #   agrupados por concepto + barrel providers.dart
    ├── screens/            # pantallas + app_shell.dart, agrupadas por concepto + barrel screens.dart
    └── widgets/            # widgets; /shared para reutilizables + barrel widgets.dart
```

Regla de dependencias: `presentation → domain ← infrastructure`. El `domain` es el centro
y no conoce a las otras capas.

## 6. Convenciones
- Organización por capa; dentro de cada capa, subcarpetas por concepto de dominio (ver sección 9).
- **Archivos barrel** por carpeta (`entities.dart`, `providers.dart`, `screens.dart`,
  `widgets.dart`) que reexportan su contenido.
- Implementaciones de repositorio con sufijo `_impl.dart`.
- `app_shell.dart` contiene el layout y la navegación principal (shell de go_router).
- Widgets reutilizables en `presentation/widgets/shared/`.
- Identificadores en inglés; comentarios y documentación en español.
- Entidades de dominio en `domain/entities` (sin anotaciones de serialización);
  DTOs en `infrastructure/models`.
- Tests en `test/` espejando la estructura de `lib/`.
- Commits en español, estilo *conventional commits* (`feat:`, `fix:`, `refactor:`...).

## 7. Dominio (glosario)
- **Persona:** individuo registrado en el sistema. Puede existir SIN credenciales de acceso
  (la cargan responsables/cuidadores cuando la persona no puede usar la app).
- **Usuario:** Persona con credenciales (usuario/contraseña) que inicia sesión.
- **Roles y permisos (RBAC):** el acceso a datos y acciones depende del rol.
  - **Responsable:** gestiona los datos de la persona a cargo y administra el equipo y sus permisos.
  - **Cuidador:** realiza tareas de cuidado; accede a funcionalidades según permisos.
- **Equipo de cuidado:** red de responsables y cuidadores asociados a una persona.

> El modelo de dominio vigente está en `care_well_doc/Diagramas/CareWell-modelo-dominio.drawio`
> y lo mantiene el agente `arquitecto-software`.

## 8. Alcance — MVP
Módulos de la primera versión (MVP):
- Autenticación: login, registro y recuperación de contraseña (credenciales propias).
- Perfil de usuario (Mi Perfil).
- Configuración (T&C, cambio de contraseña, cerrar sesión, eliminar cuenta).
- Menú principal (home con accesos).
- Personas a cargo (ABM de personas bajo cuidado).
- Mi equipo (ABM de responsables y cuidadores; gestión de roles y permisos).
- Agenda (calendario y recordatorios; notificaciones locales).
- Mi salud (hábitos, recomendaciones, eventos de salud, estados de ánimo).
- Emergencia (aviso al equipo de cuidado).

Reservado para iteraciones posteriores (no integraciones de terceros):
- Chats / comunicación interna del equipo.
- Análisis de datos (gráficos y reportes).

Reservado a futuro — integraciones con apps de terceros:
- Login con Google / vinculación de Gmail.
- Sincronización de la agenda con Google Calendar.
- Módulo de IA de soporte para consultas de salud (solo como apoyo, nunca diagnóstico).

## 9. Conceptos / features
Subcarpetas por concepto dentro de cada capa, alineadas al MVP (nombres en inglés):
`auth`, `profile`, `settings`, `dependents` (personas a cargo), `care_team` (mi equipo),
`agenda`, `health` (mi salud), `emergency`. Lo común y reutilizable va en `shared/`.

## 10. Flujo de trabajo con los agentes
- `arquitecto-software`: decisiones de arquitectura, modelado de dominio, diagramas ER
  (draw.io) y revisiones de código. Tiene presente el modelo de dominio. **No escribe código
  de producción.**
- `dev-flutter`: implementa features. Tiene presente el modelo de dominio. **Siempre** presenta
  un plan numerado y espera confirmación antes de codificar.
- `disenador-ui`: diseña pantallas, flujos e interacciones; produce specs y widgets de presentación.
- `analista-funcional`: mantiene y modifica la documentación del proyecto en LaTeX
  (`care_well_doc/LATEX/`). Es el único agente que toca la documentación.

## 11. Comandos útiles
- App (en `care_well_app/`): `flutter pub get` · `flutter analyze` · `flutter test` · `dart format .`
- Documentación (en `care_well_doc/LATEX/`): `latexmk -pdf CuidadoPersonas.tex`
