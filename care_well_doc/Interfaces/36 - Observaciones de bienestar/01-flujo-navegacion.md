# US-36 Observaciones de bienestar — Flujo de navegación

> Este componente **no es una pantalla propia**: es una tarjeta condicional dentro del hub Mi
> salud (`/health`, `health_screen.dart`). No tiene ruta propia de `go_router`.
> Pantalla contenedora: Hub Mi salud.
>
> **Revisión de interacción:** la tarjeta ahora aparece **colapsada por defecto** (banner
> compacto con contador) y se expande/colapsa **in-place**, sin navegar. El detalle visual de
> este cambio está en `02-tarjeta-observaciones-bienestar.md`; este archivo documenta dónde vive
> el componente y cómo se combina con la navegación real (push/pop) del hub.

---

## 1. Vista general

```
  Hub Mi salud (/health)
       │
       ├── [si hay >= 1 observación] WellbeingObservationsCard visible,
       │    ubicada justo debajo del ContextSelector y antes del grid 2×2
       │        │
       │        ├── Estado por defecto: COLAPSADO (banner compacto, solo contador + severidad)
       │        │        └── tap en el banner ──► se EXPANDE in-place (misma pantalla, sin push,
       │        │                                  sin bottom sheet — ver §4 y 02-...md §Interacciones)
       │        │
       │        └── Estado EXPANDIDO (lista completa de filas visible)
       │                 ├── tap en el header ──────────► se vuelve a COLAPSAR in-place
       │                 ├── tap fila categoría Ánimo   ──► /health/mood/history  (name: health-mood-history)
       │                 └── tap fila categoría Hábito  ──► /health/habit/:id    (name: health-habit-detail)
       │
       └── [si hay 0 observaciones, o error/carga] WellbeingObservationsCard NO se renderiza
                (el hub se ve exactamente igual que hoy)
```

Expandir/colapsar **no es navegación**: no agrega ni quita nada del stack de `go_router`, es un
`bool` local que reordena qué se dibuja dentro del mismo frame del hub (ver detalle de
implementación en `02-tarjeta-observaciones-bienestar.md` §Interacciones). La única navegación
real de este componente sigue siendo el tap en una fila ya expandida, que navega directamente a
la pantalla de dominio existente (detalle de hábito o historial de ánimo) — no hay pantalla de
"ver todas las observaciones" ni de "detalle de una observación" como pantallas propias.

---

## 2. Pantallas / mockups de este componente

| ID  | Archivo HTML                              | Descripción                                                                 |
|-----|---------------------------------------------|-------------------------------------------------------------------------------|
| O01 | 01-hub-con-observaciones.html               | Hub Mi salud completo, tarjeta en estado **colapsado** (default), banner con tinte de "Atención" (2 Atención + 1 Informativa presentes) |
| O02 | 02-tarjeta-variantes-tipos.html             | Hoja de referencia (zoom del componente aislado) con los 4 tipos de alerta posibles dentro de la **lista expandida**, para que `dev-flutter` vea cada combinación severidad × categoría. Sin cambios respecto a la versión anterior. |
| O03 | 03-hub-observaciones-expandido.html         | Mismo hub que O01, pero con la tarjeta **expandida** (header neutro + lista completa visible, grid empujado hacia abajo) |
| O04 | 04-indicador-colapsado-variantes.html       | Hoja de referencia (zoom) que compara lado a lado los **dos tratamientos del banner colapsado**: con "Atención" presente (tinte ámbar, dos líneas) vs. solo "Informativa" (neutro/blanco, una sola línea) |

No se incluye un mockup de "estado vacío": cuando no hay observaciones, la tarjeta simplemente
no existe en el árbol de widgets y el hub queda **idéntico** al ya documentado en
`28 - Registro de habitos/html/00-mi-salud-hub.html` (grid 2×2 + tile de Línea de tiempo, sin
tarjeta arriba). No hace falta un artefacto nuevo para ese caso porque no hay nada que dibujar.

---

## 3. Ubicación dentro del hub existente

Referencia de código real: `care_well_app/lib/presentation/screens/health/health_screen.dart`
(leído al momento de este diseño; se cita literalmente para que la spec no quede desalineada
con la implementación vigente).

Estructura actual del `body` (fuera del scroll, el `ContextSelector` va con su propio padding
fijo, y el contenido scrolleable arranca en `SingleChildScrollView`):

```dart
body: Column(
  children: [
    // Fijo, fuera del scroll — NO SE TOCA
    personaAsync.when(
      data: (persona) => persona != null
          ? const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,  // 16
                AppSpacing.md,  // 8
                AppSpacing.lg,  // 16
                0,              // sin padding inferior
              ),
              child: ContextSelector(),
            )
          : const SizedBox.shrink(),
      ...
    ),
    Expanded(
      child: personaAsync.when(
        data: (persona) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg), // 16 en los 4 lados
          child: Column(
            children: [
              GridView.count(...),   // ← no se toca
              SizedBox(...),
              FullWidthActionTile(...), // ← no se toca
            ],
          ),
        ),
        ...
      ),
    ),
  ],
)
```

**Cambio propuesto (único):**

```dart
data: (persona) => SingleChildScrollView(
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: Column(
    children: [
      // [NUEVO]
      if (observaciones.isNotEmpty) ...[
        WellbeingObservationsCard(...),
        const SizedBox(height: AppSpacing.xl), // 24, separación antes del grid
      ],
      GridView.count(...),   // sin cambios
      SizedBox(...),
      FullWidthActionTile(...), // sin cambios
    ],
  ),
),
```

**Spacing resultante entre el `ContextSelector` y la tarjeta (confirmado, sin tocar
`health_screen.dart` fuera de este único cambio):** el `ContextSelector` termina con padding
inferior `0`, y el `SingleChildScrollView` arranca con padding superior `AppSpacing.lg` (16dp).
Como `WellbeingObservationsCard` es el primer hijo de ese `Column`, el espacio visual entre el
borde inferior del `ContextSelector` y el borde superior de la tarjeta (colapsada o expandida)
es de **16dp** — el mismo gap que ya existe hoy entre el `ContextSelector` y el grid cuando no
hay observaciones. No se requiere ningún spacing adicional ni un valor nuevo: la tarjeta
simplemente pasa a ser el primer elemento del `Column` que ya vive dentro del scroll,
exactamente en el lugar donde hoy arranca el grid.

**Por qué sigue yendo dentro del scroll (y no en la zona fija junto al `ContextSelector`):**
- La zona fija está reservada a un solo propósito (selección de persona) y no debe competir por
  espacio garantizado en pantalla con contenido variable. Aunque ahora la tarjeta colapsada mide
  poco (una tira de ~48-64dp), sigue siendo condicional y de alto variable (crece al expandirse),
  por lo que corresponde que viva en el área de scroll, no en el `Column` fijo de arriba.
  Colocarla en la zona fija forzaría a que la fila 2 del banner (cuando hay "Atención") o el
  contenido expandido empujen literalmente al `ContextSelector` o reduzcan el espacio del resto
  del hub — algo que el `ContextSelector` no debería tener que absorber.
- Al vivir en el scroll, visualmente sigue quedando "pegada" justo debajo del selector (ver
  cálculo de spacing arriba) — cumple el pedido de ubicación sin sacrificar la robustez de
  layout del resto de la pantalla.

**Por qué sigue yendo antes del grid (no después, ni entre grid y Línea de tiempo):** sin
cambios respecto a la versión anterior — es información potencialmente accionable y reciente
sobre la persona ("¿pasa algo que debería mirar hoy?"), con más prioridad de lectura que el
acceso a los sub-módulos que el usuario ya conoce y usa de forma rutinaria. Ahora, además, al
estar colapsada por defecto, ese orden de prioridad se comunica sin "gastar" espacio de pantalla
de entrada — el usuario decide cuánto quiere profundizar.

---

## 4. Transiciones

| Origen                          | Destino                     | Disparador                                  | Animación |
|-----------------------------------|--------------------------------|------------------------------------------------|-----------|
| (aparición de la tarjeta)         | —                              | Se resuelven las observaciones junto con el resto de la data del hub, **siempre en estado colapsado** | `FadeInDown` 350 ms (ver §4.1 de `00-sistema-diseno.md`) |
| Banner colapsado                  | Tarjeta expandida (misma pantalla, sin push) | tap en el header                     | `AnimatedSize` 220 ms `easeInOut` (mismo primitivo que `HealthEventsMonthList`, sin cambio de ruta) |
| Tarjeta expandida                 | Banner colapsado (misma pantalla, sin pop)   | tap en el header                     | `AnimatedSize` 220 ms `easeInOut` (idéntico, reversible) |
| Hub Mi salud (tarjeta expandida)  | Historial de ánimo             | tap en fila de categoría Ánimo                  | slide-right + fade 250 ms (mismo criterio que Hub → Ficha de salud) |
| Hub Mi salud (tarjeta expandida)  | Detalle de hábito              | tap en fila de categoría Hábito                 | slide-right + fade 250 ms |
| Historial de ánimo / Detalle de hábito | Hub Mi salud             | ARROW_BACK                                      | pop, slide-left (la tarjeta conserva el estado expandido/colapsado que tenía antes de navegar) |

---

## 5. Reglas de gobierno

- **Persona de contexto:** las observaciones son siempre relativas a la persona a cargo
  seleccionada en el `ContextSelector` global (mismo mecanismo que Hábitos/Eventos/Estado de
  ánimo/Ficha de salud). Cambiar de persona recalcula/reconsulta el set de observaciones desde
  cero **y reinicia la tarjeta a estado colapsado**; no hay confirmación de descarte porque el
  componente no tiene estado editable propio (el estado de expansión no se considera "trabajo
  del usuario" que deba preservarse al cambiar de persona).
- **Condición de aparición:** la tarjeta se renderiza si y solo si la lista de observaciones
  tiene 1 o más elementos. Con 0 elementos, no se renderiza nada (ni un estado vacío, ni un
  placeholder) — decisión ya confirmada, no es un olvido de diseño.
- **Estado colapsado/expandido es presentación local, no persistida:** vive en el `State` del
  widget (mismo patrón que `_expandedDias` en `HealthEventsMonthList`), no en un provider de
  Riverpod ni en backend. Por defecto siempre arranca colapsado. Puede sobrevivir a un
  push/pop hacia una pantalla de detalle (si el hub no se destruye en el stack), pero se
  reinicia si el widget vuelve a construirse desde cero (recarga de la pantalla, cambio de
  persona, reingreso al hub luego de que fue destruido).
- **Carga y error se tratan como "sin observaciones" (invisibilidad silenciosa):** a diferencia
  de Ficha de salud o los otros sub-módulos, este componente es un valor agregado no crítico
  sobre el hub. Si la consulta de observaciones está en curso o falla, la tarjeta **no muestra
  skeleton ni banner de error** — simplemente no aparece, igual que el caso de "0 observaciones".
  Esto evita agregar fricción visual (spinners, banners de error) a una pantalla de navegación
  por una funcionalidad secundaria. Es una decisión de UX a validar con `arquitecto-software` si
  la estrategia de datos elegida hace que esta simplificación no sea viable (ej. si el fetch de
  observaciones tarda sensiblemente más que el resto de la data del hub).
- **Sin salto de layout perceptible en la aparición inicial (recomendado):** idealmente, las
  observaciones se resuelven como parte del mismo `AsyncValue`/cadena de carga que ya resuelve
  `personaVisualizacionSeleccionadaProvider` para que el grid y la tarjeta (colapsada) aparezcan
  juntos en el mismo frame. Si técnicamente se resuelven por una vía separada (provider
  independiente), debe usarse la animación `FadeInDown` (§4.1 de `00-sistema-diseno.md`) para
  suavizar la aparición tardía en vez de un salto brusco de layout. El salto de layout **al
  expandir/colapsar**, en cambio, es intencional y esperado — se suaviza con `AnimatedSize`
  (220ms), no se busca evitarlo (el usuario lo disparó a propósito).
- **Orden de las filas (dentro de la lista expandida):** Atención siempre antes que Informativa.
  Dentro de la misma severidad, se respeta el orden en que el backend las devuelve (la UI no
  reordena ni agrupa por categoría).
- **Severidad agregada del banner colapsado:** se calcula en la capa de presentación a partir de
  la misma lista ya resuelta (no requiere un endpoint ni un dato adicional del backend): si
  existe al menos una observación con `severidad == atencion`, el banner usa el tratamiento
  "Atención"; si todas son `informativa`, usa el tratamiento "Informativa". Ver
  `02-tarjeta-observaciones-bienestar.md` para el detalle visual completo de ambos tratamientos.
- **Sin acción de descarte:** no existe ningún flujo de "cerrar"/"marcar como visto" una
  observación individual ni la tarjeta completa — reafirmación de la decisión de producto ya
  confirmada. Colapsar el banner no es "descartar": las observaciones siguen existiendo y el
  contador se sigue mostrando; es solo una forma de ocultar temporalmente el detalle.
