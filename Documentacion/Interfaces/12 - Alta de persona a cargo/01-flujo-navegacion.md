# US-12 Alta de persona a cargo — Flujo de navegación

> Mapa de navegación del flujo de alta. Referencia los tokens de `00-sistema-diseno.md`.
> Ruta sugerida en `go_router`: `/dependents/new` (push sobre la lista de personas a cargo).

---

## 1. Vista general (happy path + ramas de error)

```
   lista de personas a cargo ──► tap "+"
                    │
                    ▼
   ┌──────────────────────────────────────┐
   │   FORMULARIO — VACÍO  [01]            │
   │   AppBar: ← · "Nueva persona a cargo"│
   │   Bloque foto (opcional)              │
   │   Nombre *  Apellido *                │
   │   Documento (DNI) *                   │
   │   Fecha de nacimiento *               │
   │   Email (opcional)                    │
   │   [ ] Acepto Términos y Condiciones   │
   │   [ Registrar persona — DISABLED ]    │
   └──────────────────┬───────────────────┘
          usuario completa campos + marca T&C
                      ▼
   ┌──────────────────────────────────────┐
   │   FORMULARIO — LISTO  (botón activo)  │
   └──────────────────┬───────────────────┘
                      │ tap "Registrar persona"
                      ▼
           ┌──────────────────────┐
           │  ¿Campos válidos?     │
           └───┬──────────────┬───┘
          no   │              │ sí
               ▼              ▼
   ┌──────────────────┐   ┌──────────────────────────────┐
   │  ERROR  [02]      │   │     CARGANDO  [03]            │
   │  borde error +    │   │  Campos disabled + spinner   │
   │  helper inline    │   │  "Registrando..."            │
   │  en cada campo    │   └───┬──────────┬──────────┬────┘
   │  inválido         │       │ 201      │ 4xx/5xx  │ sin red
   └────────┬──────────┘       ▼          ▼          ▼
            │ corregir  ┌──────────┐ ┌──────────┐ ┌────────────────┐
            └──► [01]   │ EXITO    │ │ ERROR     │ │ SIN CONEXION   │
                        │ [04]     │ │ servidor  │ │ banner info    │
                        └──────────┘ │ banner    │ │ + Reintentar   │
                                     │ error     │ └───────┬────────┘
                                     └─────┬─────┘         │ Reintentar
                                           │ corregir       └──► [03]
                                           └──► [01]
```

---

## 2. Transiciones

| Origen | Destino | Disparador | Animación |
|---|---|---|---|
| Lista personas a cargo | Formulario vacío [01] | tap "+" | push, slide-up + fade 250 ms |
| Formulario [01] | Lista (sin cambios) | tap ARROW_BACK | pop, slide-down + fade 250 ms |
| Formulario [01] | Cargando [03] | "Registrar persona" (validación OK) | botón→loading, inputs disable, fade 150 ms (misma ruta) |
| Formulario [01] | Error [02] | "Registrar persona" con campos inválidos | error inline fade + slide-down 4 dp, 150 ms (misma ruta) |
| Error [02] | Formulario [01] | usuario corrige campo | error se limpia on-change |
| Cargando [03] | Exito [04] | respuesta 201 | `pushReplacement`, fade 300 ms |
| Cargando [03] | Banner error servidor | respuesta 4xx/5xx | botón vuelve de loading, banner error fade + slide-down |
| Cargando [03] | Banner sin conexion | fallo de red | botón vuelve de loading, banner info slide-down |
| Exito [04] | Lista personas a cargo | tap "Ver personas a cargo" | `pushReplacement`, pop al stack anterior |
| Exito [04] | Formulario nuevo [01] | tap "Agregar otra persona" | `pushReplacement` por nuevo formulario vacío |

---

## 3. Reglas de gobierno del flujo

- **Botón deshabilitado hasta que T&C esté marcado.** A diferencia del login, acá el botón
  arranca disabled (fondo `outline #C5CECE`, texto `textDisabled`). Se habilita solo cuando
  el checkbox T&C está marcado. Razón: el Responsable está registrando datos de un tercero
  (la persona a cargo); el consentimiento es obligatorio antes de habilitar el envío.

- **Validación mixta: blur para DNI, submit para el resto.** El DNI tiene formato fijo
  (solo dígitos, 7-8 caracteres); se valida al blur para que el usuario lo vea antes de
  continuar. Nombre, Apellido y Fecha se validan al pulsar "Registrar persona".

- **El email vacío no es error.** Si el campo Email queda vacío se envía null al servidor
  (campo nullable en el dominio). No se muestra ningún error ni helper.

- **ARROW_BACK limpia el formulario.** Al volver atrás con datos incompletos se descarta el
  formulario sin confirmacion (no hay nada guardado aun). Si hubiera datos críticos cargados
  se puede agregar un dialogo de confirmacion en iteraciones futuras.

- **Pantalla de exito reemplaza el formulario en el stack.** Usar `pushReplacement` evita que
  el back del sistema vuelva al formulario ya procesado.

- **La foto se sube junto con el resto del formulario.** No es un paso separado. Si la
  subida de foto falla, el servidor devuelve error generico; el formulario permanece con
  la foto seleccionada para reintentar.
