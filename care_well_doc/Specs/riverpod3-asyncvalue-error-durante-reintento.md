# Riverpod 3 — un provider que falló se ve como "cargando", no como "con error"

**Estado:** abierto · **Prioridad:** Media · **Alcance:** frontend Flutter, transversal
**Detectado en:** Fase 3 del rediseño visual de Perfil y Configuración (rama
`feature/redisenio-perfil-config`).

## Qué pasa

En Riverpod 3 los providers asíncronos que fallan **se reintentan solos**: el contenedor
aplica una política de reintento por defecto (`ProviderContainer.defaultRetry`, aplicada en
`element.dart:764`) sin que el código de la app pida nada.

Ese reintento deja el `AsyncValue` en estados que no son los que uno espera:

- **Durante cada intento:** el estado es `AsyncLoading` **con `hasError` en `true`** (conserva
  el error anterior mientras recarga).
- **Entre intento e intento:** `isLoading` vuelve a `false`, pero el error sigue presente
  (`async_value.dart:61-63`).

Es decir: después de la primera falla, el provider **nunca vuelve a ser un `AsyncError`
"quieto"**. Alterna entre cargando-con-error y error-sin-cargar, indefinidamente.

## Por qué importa

`AsyncValue.when()` evalúa **`isLoading` ANTES que `hasError`** (`async_value.dart:250-263`).
La consecuencia directa es que **un provider que falló renderiza la rama `loading()` mientras
reintenta**.

En una pantalla que muestra un banner de "Reintentar" ante el error, el usuario puede quedar
viendo un spinner intermitente —aparece y desaparece al ritmo de los reintentos— en lugar de
la opción de reintentar que la pantalla creía estar mostrando. La rama `error()` puede no
llegar a verse nunca.

## Dónde apareció

En el rediseño del hero de Perfil. La zona del chip de rol reserva altura mientras
`rolEnSistemaProvider` carga, para que el hero no crezca —empujando la tarjeta de cifras y los
grupos de abajo— cuando el rol llega. Preguntando primero por `isLoading`, un usuario sin
asignaciones cuyo provider fallara se quedaba con **la reserva de altura puesta para siempre**:
exactamente el hueco eterno que la reserva quería evitar.

Corregido en `care_well_app/lib/presentation/widgets/profile/profile_hero.dart`, widget
`_ZonaRol` (líneas 192-215), evaluando `hasError` **antes** que `isLoading`:

```dart
if (rol.hasError) return const SizedBox.shrink();
if (rol.isLoading) { /* reserva de altura */ }
```

## Alcance pendiente

La corrección de arriba es puntual: resuelve el síntoma en un widget. El patrón está en toda
la app.

- **35 ocurrencias de `.when(` en `lib`, repartidas en 24 archivos** (medido sobre la rama
  `feature/redisenio-perfil-config`).
- **No todas están afectadas: hay que clasificarlas.** Al menos dos —`register_screen.dart:294`
  y `create_credentials_screen.dart:120`— operan sobre un `AsyncValue` construido a mano a
  partir del resultado de una operación, no sobre un provider observado, así que la política de
  reintento no interviene. El número real de casos afectados sale de auditar las 35, no de
  asumirlas.

Al auditar hay que fijar **una convención única** para toda la app, en vez de corregir caso por
caso. Las dos opciones sobre la mesa:

1. Una extensión compartida sobre `AsyncValue` que evalúe `hasError` primero, y usarla en lugar
   de `.when()` en las pantallas.
2. El uso consistente de `skipLoadingOnReload` / `skipLoadingOnRefresh` en los `.when()`
   existentes.

## Lección de testing

Este defecto **no se detecta con un `AsyncValue.error(...)` construido a mano en un test**: ese
objeto tiene `isLoading` en `false`, que es un estado que el framework **no produce** en la
situación real (provider observado que falló y está reintentando). El test pasa en verde
mientras la app falla en el dispositivo.

Para cubrir estos casos hay que hacer **fallar al provider de verdad** —override que lanza— y
dejar que la política de reintento haga su trabajo.

## Prioridad

**Media.** No bloquea el ciclo de rediseño de Perfil y Configuración: el único punto conocido
donde se manifestaba visualmente ya está corregido. Es deuda técnica transversal y merece su propia
iteración, con la auditoría de las 35 ocurrencias y la convención elegida.
