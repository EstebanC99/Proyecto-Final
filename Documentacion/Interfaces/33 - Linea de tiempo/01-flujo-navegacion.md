# US-33 Linea de tiempo de eventos — Flujo de navegación

> Mapa de navegación del flujo. Tokens en `00-sistema-diseno.md`.
> Ruta base sugerida en `go_router`: `/health/timeline/:personId`.

---

## 1. Vista general

```
   Mi salud / menu o seccion
              │
              │ tap "Ver linea de tiempo"
              ▼
   ┌──────────────────────────────────────────┐
   │   LINEA DE TIEMPO  [01]                   │
   │                                           │
   │  AppBar: [←] "Linea de tiempo"            │
   │               [Alicia Rodriguez]          │
   │                                           │
   │  Jun 2026  [Cita medica]                  │
   │  o Control cardiologico                   │
   │  |  Dr. Martin Sosa                       │
   │  |                                        │
   │  o May 2026 [Medicacion]                  │
   │  |  Ajuste de dosis — Atenolol            │
   │  |  Indicado por el cardiologo            │
   │  |                                        │
   │  o Abr 2026 [Bienestar]                   │
   │  |  Alta psicologica                      │
   │  |  Finalizo ciclo de 12 sesiones         │
   │  |                                        │
   │  o Mar 2026 [Hospitalizacion]             │
   │  |  Internacion 3 dias                    │
   │  |  Clinica Santa Isabel · UCI            │
   │  |                                        │
   │  o Feb 2026 [Tratamiento]                 │
   │     Inicio fisioterapia                   │
   │     Sesiones martes y jueves              │
   └──────────────────────────────────────────┘
              │
              │ tap en tarjeta de evento
              ▼
   Detalle del evento (US-32 [01])
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| Mi salud | Linea de tiempo [01] | tap en acceso | push, slide-left + fade 250 ms |
| Linea de tiempo [01] | Detalle evento (US-32) | tap en tarjeta | push, slide-left + fade 250 ms |
| Detalle evento (US-32) | Linea de tiempo [01] | ARROW_BACK | pop, slide-right + fade 250 ms |
| Linea de tiempo [01] | Mi salud | ARROW_BACK | pop, slide-right + fade 250 ms |
| Linea de tiempo | Cargando | pull-to-refresh | indicador nativo de refresh en top |

---

## 3. Reglas de gobierno del flujo

- **Contexto de persona siempre visible.** El chip con el nombre de la persona bajo cuidado
  aparece en el AppBar durante toda la navegacion del flujo. En MVP no es tappable.

- **Solo lectura en esta pantalla.** La linea de tiempo no permite agregar ni editar eventos
  directamente; es una vista de consulta. El acceso a notas y detalle se realiza desde el
  detalle del evento (US-32).

- **Pull-to-refresh:** un gesto pull hacia abajo desde el tope de la lista dispara la recarga
  de eventos. El indicador de progreso usa el color `#E11D48`.

- **Scroll infinito (post-MVP):** en MVP se muestran todos los eventos disponibles sin
  paginacion (se asume un volumen manejable). Paginacion con "Cargar mas" se planifica para
  la siguiente iteracion.

- **Orden:** descendente por fecha (mas reciente arriba). Los eventos del mismo mes se ordenan
  por fecha exacta descendente entre si.

- **Back de Android:** pop hacia Mi salud (pantalla de origen).
