# US-29 Recomendaciones médicas — Flujo de navegación

> Ruta go_router sugerida: `/health/recommendations`
> Pantalla anterior: Hub Mi salud (`/health`)

---

## 1. Vista general

```
  Hub Mi salud ─► /health/recommendations (Lista de recomendaciones)
                        │
                        └── tap card ─► [futuro: detalle de recomendación]
```

En MVP la pantalla es de solo lectura. No hay formulario de creación manual de recomendaciones
por parte del usuario; se generan a partir de los datos del sistema.

---

## 2. Pantallas del flujo

| ID  | Archivo HTML           | Descripción                                           |
|-----|------------------------|-------------------------------------------------------|
| R01 | 01-recomendaciones.html| Lista de recomendaciones con disclaimer               |

---

## 3. Transiciones

| Origen        | Destino              | Disparador              | Animación                  |
|---------------|----------------------|-------------------------|----------------------------|
| Hub Mi salud  | Recomendaciones      | tap tile "Recomendaciones"| slide-right + fade 250 ms  |
| Recomendaciones| Hub Mi salud        | tap ARROW_BACK          | pop, slide-left            |

---

## 4. Reglas de gobierno

- Las recomendaciones se calculan en el backend a partir de los registros de hábitos,
  eventos de salud y datos del perfil de la persona a cargo.
- En demo/mock se muestran recomendaciones estáticas representativas.
- El disclaimer de "no reemplaza la consulta médica" es obligatorio; no puede ocultarse.
- La pantalla no tiene FAB ni acciones de escritura en MVP.
- Estado vacío: se muestra si no hay suficientes datos para generar recomendaciones.
