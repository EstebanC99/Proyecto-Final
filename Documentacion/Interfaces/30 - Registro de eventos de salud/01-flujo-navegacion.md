# US-30 Registro de eventos de salud — Flujo de navegación

> Ruta go_router sugerida: `/health/events`
> Pantalla anterior: Hub Mi salud (`/health`)

---

## 1. Vista general

```
  Hub Mi salud ─► /health/events (Lista de eventos)
                        │
                        ├── tap card ─► /health/events/:id (detalle + notas — US-32 futuro)
                        │
                        └── tap FAB ─► /health/events/new (nuevo evento)
                                            │
                                            └── guardar ─► Lista (snackbar OK)
```

---

## 2. Pantallas del flujo

| ID  | Archivo HTML          | Descripción                                                 |
|-----|-----------------------|-------------------------------------------------------------|
| E01 | 01-eventos-lista.html | Lista cronológica de eventos con chips de tipo              |
| E02 | 02-nuevo-evento.html  | Formulario de registro de nuevo evento de salud             |

---

## 3. Transiciones

| Origen         | Destino         | Disparador                  | Animación                          |
|----------------|-----------------|-----------------------------|------------------------------------|
| Hub Mi salud   | Lista eventos   | tap tile "Eventos de salud" | slide-right + fade 250 ms          |
| Lista eventos  | Nuevo evento    | tap FAB                     | slide-up (modal) 300 ms            |
| Lista eventos  | Detalle evento  | tap card                    | slide-right + fade 250 ms          |
| Nuevo evento   | Lista eventos   | guardar exitoso             | pop + snackbar "Evento registrado" |
| Nuevo evento   | Lista eventos   | tap ARROW_BACK              | pop sin snackbar                   |
| Cualquiera     | Hub Mi salud    | tap ARROW_BACK              | pop, slide-left                    |

---

## 4. Reglas de gobierno

- La lista se ordena cronológicamente descendente (más reciente primero).
- El tipo de evento seleccionado en el formulario determina el color del chip en la lista.
- Descripción y fecha son obligatorios; observaciones es opcional.
- El botón "Registrar evento" se habilita solo cuando descripción y fecha están completos.
- Al guardar, la lista se refresca mostrando el nuevo evento en primer lugar.
- Los tipos de evento son extensibles en el backend sin necesidad de rediseño gracias a los
  chips scrollables horizontales.
