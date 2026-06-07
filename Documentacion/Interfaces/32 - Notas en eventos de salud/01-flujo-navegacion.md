# US-32 Notas en eventos de salud — Flujo de navegación

> Mapa de navegación del flujo. Tokens en `00-sistema-diseno.md`.
> Ruta base en `go_router`: `/health/events/:eventId` y `/health/events/:eventId/notes/new`.

---

## 1. Vista general (happy path + ramas de error)

```
   Mi salud / lista de eventos
              │
              │ tap en evento
              ▼
   ┌──────────────────────────────────────────┐
   │   DETALLE DE EVENTO CON NOTAS  [01]       │
   │                                           │
   │  AppBar: [←] "Control cardiológico" [chip]│
   │                                           │
   │  Card del evento                          │
   │    Fecha · Médico · Observación           │
   │                                           │
   │  NOTAS DEL EQUIPO                         │
   │    Nota 1 (autor + timestamp + cuerpo)    │
   │    Nota 2 (autor + timestamp + cuerpo)    │
   │    ...                                    │
   │                                 [FAB +]   │
   └───────────────────┬───────────────────────┘
                       │ tap FAB "+"
                       ▼
   ┌──────────────────────────────────────────┐
   │   NUEVA NOTA  [02]                        │
   │                                           │
   │  AppBar: [←] "Nueva nota"                 │
   │                                           │
   │  Card contexto (evento + fecha)            │
   │                                           │
   │  Campo "Nota *"                           │
   │    textarea libre                         │
   │                                           │
   │  [       Guardar nota       ]             │
   └───────────────────┬───────────────────────┘
                       │
           ┌───────────┴──────────┐
           │ texto vacío          │ texto presente
           ▼                      ▼
   Campo error inline      ┌──────────────────┐
   (sin enviar)            │     GUARDANDO     │
                           │  botón spinner    │
                           └───────┬──────────┘
                                   │
                       ┌───────────┴──────────┐
                       │ éxito                │ error
                       ▼                      ▼
             vuelve a [01]             banner error
             nota nueva                + "Reintentar"
             visible arriba
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Mi salud / lista | Detalle evento [01] | tap en evento | push, slide-left + fade 250 ms |
| Detalle evento [01] | Nueva nota [02] | tap FAB "+" | push, slide-up 300 ms (modal bottom) |
| Nueva nota [02] | Detalle evento [01] | ARROW_BACK | pop, slide-down 250 ms |
| Nueva nota [02] | Guardando | tap "Guardar nota" (texto presente) | botón → loading, textarea disabled |
| Guardando | Detalle evento [01] | respuesta 201 | pop + refresh lista notas, fade 250 ms |
| Guardando | Nueva nota (error) | fallo de red o 5xx | botón vuelve a activo, banner error fade-in |
| Error banner | Guardando | tap "Reintentar" | reenvía petición, mismo estado de carga |

---

## 3. Reglas de gobierno del flujo

- **Acceso al flujo:** solo usuarios con rol Responsable o Cuidador con permiso de escritura
  en el evento pueden agregar notas. El FAB no aparece si el usuario es de solo lectura.

- **Validación al submit.** El campo de nota se valida al pulsar "Guardar nota". Si está vacío,
  muestra error inline bajo el campo y hace foco; no envía la petición.

- **Autor y timestamp automáticos.** El frontend no envía autor ni timestamp; el servidor los
  resuelve con la sesión activa. El campo autor no es editable por el usuario.

- **Orden de notas:** más reciente al final dentro de la lista (orden cronológico ascendente).
  Al guardar una nota nueva, se agrega al final y la pantalla hace scroll hasta ella.

- **Back de Android en Nueva nota:** pop hacia Detalle del evento. Si el campo tiene texto,
  muestra un diálogo de confirmación ("Tenés cambios sin guardar. ¿Salir de todas formas?").

- **Longitud máxima de nota:** 500 caracteres. El campo muestra contador `actual/500`
  en la esquina inferior derecha cuando supera los 400 caracteres.
