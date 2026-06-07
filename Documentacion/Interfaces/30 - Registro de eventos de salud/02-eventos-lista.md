# US-30 Eventos de salud — Pantalla: Lista de eventos

## Objetivo
Mostrar el historial de eventos de salud de la persona a cargo en orden cronológico
descendente, con diferenciación visual por tipo de evento y acceso rápido al registro.

## Layout (jerarquía de componentes)

```
StatusBar
AppBar (ARROW_BACK + "Eventos de salud" + chip contexto "Alicia Rodríguez")
─ ScrollView vertical (padding top 12px)
    EventCard × N
      ├── Fila superior: chip tipo (izq) + fecha (der, textSecondary, 12px)
      ├── Título (700, 15px)
      └── Cuerpo truncado (1 línea, 13px, textSecondary)
FAB (ADD, bg #E11D48, posición fixed bottom-right)
```

## Eventos de ejemplo (mock)

| Tipo        | Fecha       | Título                        | Cuerpo                                     |
|-------------|-------------|-------------------------------|--------------------------------------------|
| Cita médica | 2 jun 2026  | Control cardiológico          | Dr. Martín Sosa · Hospital Italiano...     |
| Medicación  | 28 may 2026 | Ajuste de dosis — Atenolol    | Nueva dosis: 50 mg/día por indicación...   |
| Bienestar   | 20 may 2026 | Alta de psicología            | Fin del tratamiento. Seguimiento mensual...  |

## Estados

### Estado con datos
Lista de EventCards ordenadas por fecha descendente.

### Estado vacío
Ícono FAVORITE 64 dp en `#C5CECE` centrado. Texto: "No hay eventos registrados aún.
Usá el botón + para registrar el primer evento de salud." FAB visible.

### Estado de carga
Skeleton de 3 cards con shimmer. FAB oculto durante carga.

### Estado de error
Banner de error (bg `#FBE3E3`): "No se pudieron cargar los eventos. Reintentar".

## Interacciones
- Tap en card → navega a detalle del evento (US-32 futuro; en MVP puede mostrar un
  bottom-sheet con los datos completos).
- Tap en FAB → abre formulario de nuevo evento.
- Scroll infinito o paginación al llegar al final de la lista (MVP: carga todo).

## Navegación de entrada/salida
- Entrada: Hub Mi salud (tap tile "Eventos de salud").
- Salida: ARROW_BACK → Hub. Tap card → detalle. Tap FAB → nuevo evento.
