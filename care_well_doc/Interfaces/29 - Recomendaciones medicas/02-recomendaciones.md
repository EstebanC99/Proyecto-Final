# US-29 Recomendaciones médicas — Pantalla: Lista de recomendaciones

## Objetivo
Mostrar al usuario recomendaciones de salud generadas a partir de los datos registrados en
la app, con un disclaimer prominente que aclara que no reemplazan la consulta profesional.

## Layout (jerarquía de componentes)

```
StatusBar
AppBar (ARROW_BACK + "Recomendaciones" + chip contexto "Alicia Rodríguez")
─ ScrollView vertical (padding top 12px)
    DisclaimerBanner (INFO, bg #F0FDF4, borde verde, texto legal)
    RecommendationCard × N
      ├── [ícono 24dp acento] Título (700, 16px)
      └── Cuerpo descriptivo (14px, textSecondary)
```

## Recomendaciones de ejemplo (mock)

| Ícono      | Título                        | Cuerpo                                                                                   |
|------------|-------------------------------|------------------------------------------------------------------------------------------|
| HEALING    | Actividad física moderada     | Según los registros de actividad, se recomienda mantener caminatas de al menos 30 min diarios. |
| RESTAURANT | Control de hidratación        | El registro de hábitos indica baja ingesta de líquidos. Recomendado: 1.5L de agua por día. |
| BEDTIME    | Regularidad del sueño         | El promedio de sueño registrado es de 6h45m. Se recomienda alcanzar las 7–8 horas.       |

## Estados

### Estado con datos
Cards visibles con disclaimer siempre en primer lugar.

### Estado vacío
Sin cards. Debajo del disclaimer, mensaje: "Todavía no hay suficientes datos para generar
recomendaciones. Seguí registrando hábitos y eventos de salud."
Ícono ilustrativo HEALING 48 dp en `#C5CECE`.

### Estado de carga
Skeleton: disclaimer (height 64 px, shimmer) + 3 cards skeleton.

### Estado de error
Banner de error (bg `#FBE3E3`) con "No se pudieron cargar las recomendaciones. Reintentar".

## Interacciones
- Scroll vertical para ver todas las recomendaciones.
- En MVP, tap en card no navega a ningún lugar (solo lectura).
- ARROW_BACK → vuelve al Hub Mi salud.

## Navegación de entrada/salida
- Entrada: Hub Mi salud (tap tile "Recomendaciones").
- Salida: solo ARROW_BACK.
