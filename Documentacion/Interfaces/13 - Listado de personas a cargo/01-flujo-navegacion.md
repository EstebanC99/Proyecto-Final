# US-13 Listado de personas a cargo — Flujo de navegacion

> Mapa de navegacion del flujo de listado de personas a cargo.
> Ruta sugerida en `go_router`: `/dependents` (dentro del shell de navegacion principal).

---

## 1. Vista general (happy path + estados)

```
   Menu principal ──► tap "Personas a cargo"
                                │
                                ▼
              ┌─────────────────────────────────────┐
              │    LISTADO — CON PERSONAS  [01]      │
              │  AppBar: Personas a cargo + FAB ADD  │
              │                                     │
              │  COMO RESPONSABLE                   │
              │  [Alicia Rodríguez  · Responsable]  │
              │  [Carlos Mendez     · Responsable]  │
              │                                     │
              │  COMO CUIDADOR                      │
              │  [Rosa Fernandez    · Cuidador   ]  │
              │                                     │
              │  FAB: + (agregar)                   │
              └──────────┬──────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │ tap tarjeta   │               │ tap FAB
         ▼               │               ▼
   US-14 (perfil         │          US-12 (alta de
   persona)              │          persona a cargo)
                         │
                         │ lista vacía
                         ▼
              ┌────────────────────────────────────┐
              │    LISTADO — VACÍO  [02]            │
              │  Icono + "Sin personas a cargo"     │
              │  [  Agregar persona  ]  ← PrimaryBtn│
              └──────────┬─────────────────────────┘
                         │ tap "Agregar persona"
                         ▼
                    US-12 (alta de persona a cargo)
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animacion |
|---|---|---|---|
| Menu principal | Listado [01] o [02] | tap "Personas a cargo" | slide-right + fade 250 ms |
| Listado [01] | US-14 perfil persona | tap en tarjeta | push, slide-right + fade 250 ms |
| Listado [01] o [02] | US-12 alta | tap FAB / boton "Agregar" | push, slide-up + fade 250 ms |
| US-12 exito | Listado [01] | navegacion de retorno | pop + fade 200 ms, lista actualizada |
| US-14 eliminacion | Listado [01] o [02] | persona eliminada | pop + fade 200 ms, snackbar |
| Back del sistema | Menu principal | gesture / boton back | pop, slide-left + fade 250 ms |

---

## 3. Reglas de gobierno del flujo

- **El FAB solo aparece si el usuario tiene permiso de alta (Responsable con permisos).**
  Si el rol actual no permite agregar personas, el FAB esta oculto (no disabled, oculto).
  En estado vacio, el boton "Agregar persona" tampoco aparece en ese caso.

- **La lista es solo lectura desde este nivel.** Edicion y eliminacion se acceden desde
  el perfil (US-14). No hay acciones swipe ni long-press en las tarjetas.

- **Ordenamiento:** las personas se muestran por nombre alfabetico dentro de cada seccion.
  La seccion "COMO RESPONSABLE" precede a "COMO CUIDADOR" cuando existen ambas.

- **Actualizacion tras acciones.** Al volver de US-12 (alta exitosa) o de US-15
  (eliminacion), la lista se refresca automaticamente. En mock/demo, esto se simula
  con datos actualizados en el provider de Riverpod.

- **Back del sistema (Android):** vuelve al menu principal. No hay apilamiento dentro
  del listado.

---

## 4. Relacion con otras US

| US relacionada | Relacion |
|---|---|
| US-12 Alta de persona a cargo | Punto de entrada: FAB / boton vacio |
| US-14 Modificacion de persona a cargo | Punto de entrada: tap en tarjeta |
| US-15 Eliminacion de persona a cargo | Flujo secundario desde US-14 |
| US-05 Menu principal | Origen del flujo de Personas a cargo |
