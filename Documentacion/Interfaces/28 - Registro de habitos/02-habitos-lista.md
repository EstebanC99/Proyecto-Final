# US-28 Hábitos de vida — Pantalla: Lista de hábitos

## Objetivo
Mostrar al usuario el estado semanal de cada categoría de hábito de la persona a cargo,
con acceso rápido al registro histórico y al formulario de nuevo registro.

## Layout (jerarquía de componentes)

```
StatusBar
AppBar (ARROW_BACK + "Hábitos de vida")
─ ScrollView vertical
    CategoryCard × 4
      ├── [ícono 24dp acento] NombreCategoria (700, 16px)
      ├── Chip de frecuencia
      ├── Último registro (textSecondary, 13px)
      └── Chevron (derecha)
FAB (ADD, bg #EA580C, posición fixed bottom-right)
```

## Categorías MVP

| Categoría       | Ícono        | Color ícono | Ejemplo último registro         | Chip              |
|-----------------|--------------|-------------|----------------------------------|-------------------|
| Alimentación    | RESTAURANT   | #EA580C     | "Ayer · Desayuno, almuerzo..."   | 3 registros esta semana |
| Ejercicio       | DIRECTIONS_RUN | #EA580C   | "Hoy · Caminata 30 min"          | 2 veces esta semana     |
| Sueño           | BEDTIME      | #7C3AED     | "Anoche · 7h30m"                 | Promedio 7h esta semana |
| Bienestar general | N/A (texto) | #566060    | —                                | Sin registros hoy       |

## Estados

### Estado con datos (principal)
Cards visibles con último registro y chip de frecuencia poblados.

### Estado vacío (sin ningún registro)
Cada card muestra chip "Sin registros" con bg `#EDF1F1` y texto `#566060`.
Mensaje sutil centrado al final: "Empezá a registrar hábitos con el botón +"

### Estado de carga
Skeleton de 4 cards: rectángulo 72 px de alto con shimmer.

### Estado de error
Banner inline (bg `#FBE3E3`, texto `#D14343`) con mensaje "No se pudieron cargar los hábitos.
Reintentar" y botón de reintento.

## Interacciones
- Tap en card → navega a detalle + histórico de esa categoría.
- Tap en FAB → abre formulario de nuevo hábito (slide-up modal).
- Long-press en card → no implementado en MVP.

## Navegación de entrada/salida
- Entrada: desde Hub Mi salud (tap tile "Hábitos de vida").
- Salida: ARROW_BACK → vuelve al Hub. Tap card → detalle. Tap FAB → nuevo hábito.
