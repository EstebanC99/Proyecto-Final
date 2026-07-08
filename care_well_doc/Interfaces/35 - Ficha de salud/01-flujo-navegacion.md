# US-35 Ficha de salud — Flujo de navegación

> Ruta go_router sugerida: `/health/record` (name: `health-record`)
> Pantalla anterior: Hub Mi salud (`/health`)
>
> Reemplaza a US-29 "Recomendaciones médicas": la card del hub con ícono
> `medical_services_outlined` y acento `healthAccent` cambia de destino y de etiqueta
> ("Recomendaciones" → "Ficha de salud"), pero mantiene su posición e ícono en el grid del hub.

---

## 1. Vista general

```
  Hub Mi salud ─► /health/record (Ficha de salud)
                       │
                       ├── tap "+ Agregar" (Antecedentes) ──► bottom sheet alta Antecedente
                       ├── tap card de Antecedente          ──► bottom sheet edición Antecedente
                       ├── tap "+ Agregar" (Alergias)       ──► bottom sheet alta Alergia
                       ├── tap card de Alergia              ──► bottom sheet edición Alergia
                       ├── tap "+ Agregar" (Enfermedades)   ──► bottom sheet alta Enfermedad
                       ├── tap card de Enfermedad           ──► bottom sheet edición Enfermedad
                       │
                       └── tap "Guardar ficha" ──► persiste cabecera + 3 listas en una sola
                                                    operación ──► Snackbar de éxito, se
                                                    permanece en la pantalla (ahora en modo
                                                    "ficha existente")
```

No hay guardado incremental por ítem ni por sección: los bottom sheets de alta/edición de ítem
solo modifican el estado **local** de la pantalla. La única escritura contra el backend ocurre al
presionar "Guardar ficha".

---

## 2. Pantallas del flujo

| ID  | Archivo HTML                  | Descripción                                                   |
|-----|--------------------------------|-----------------------------------------------------------------|
| F01 | 01-ficha-vacia.html            | Ficha de salud — estado vacío (persona sin ficha previa, alta) |
| F02 | 02-ficha-con-datos.html        | Ficha de salud — con datos precargados (edición de ficha existente) |
| F03 | 03-form-antecedente.html       | Bottom sheet alta/edición de Antecedente                       |
| F04 | 04-form-alergia.html           | Bottom sheet alta/edición de Alergia                            |
| F05 | 05-form-enfermedad.html        | Bottom sheet alta/edición de Enfermedad                         |

F01 y F02 son la **misma pantalla** (`02-ficha-salud.md`) en dos estados de datos distintos. F03,
F04 y F05 son 3 instancias del mismo componente `ItemFormBottomSheet` (`03-formulario-item.md`)
configurado con distintos campos.

---

## 3. Transiciones

| Origen                | Destino                        | Disparador                          | Animación                     |
|------------------------|----------------------------------|---------------------------------------|---------------------------------|
| Hub Mi salud           | Ficha de salud                   | tap card "Ficha de salud"             | slide-right + fade 250 ms      |
| Ficha de salud         | Hub Mi salud                     | tap ARROW_BACK                        | pop, slide-left                |
| Ficha de salud         | Sheet alta ítem (tipo X)         | tap "+ Agregar" de la sección X       | slide-up (modal) 300 ms        |
| Ficha de salud         | Sheet edición ítem (tipo X)      | tap en card de un ítem existente de X | slide-up (modal) 300 ms        |
| Sheet alta/edición     | Ficha de salud                   | tap "Agregar"/"Guardar cambios"       | slide-down + la card aparece/actualiza en la lista local |
| Sheet edición          | Ficha de salud                   | tap "Eliminar {tipo}"                 | slide-down + Snackbar "{item} eliminado" con Deshacer |
| Sheet alta/edición     | Ficha de salud                   | tap `close` o swipe-down del sheet    | slide-down, descarta cambios del sheet (no afecta la lista) |
| Ficha de salud         | Ficha de salud (misma pantalla)  | tap "Guardar ficha" (éxito)           | botón: reposo → loading → reposo + Snackbar "Ficha de salud guardada" |

---

## 4. Reglas de gobierno

- **Persona de contexto:** la ficha es siempre relativa a la persona a cargo seleccionada en el
  `ContextSelector` global (mismo mecanismo que Hábitos/Eventos/Estado de ánimo). Si se cambia la
  persona de contexto estando dentro de Ficha de salud con cambios sin guardar, se debe confirmar
  el descarte antes de navegar (mismo criterio que otros formularios largos de la app).
- **Alta vs. edición de ficha:** si la persona no tiene ficha de salud previa, la pantalla arranca
  en blanco (F01) y el botón sticky dice "Guardar ficha" igual que en edición (no hay una
  etiqueta distinta tipo "Crear ficha"; el verbo "Guardar" cubre ambos casos y simplifica la
  implementación — una sola operación upsert).
- **Factor sanguíneo obligatorio:** bloquea el guardado de toda la ficha (cabecera + listas) si
  no está seleccionado, aunque las 3 listas tengan ítems válidos. Es el único campo bloqueante.
- **Guardado atómico:** "Guardar ficha" envía cabecera (Factor sanguíneo, Obra social,
  Observaciones) y las 3 listas completas (altas, ediciones y bajas locales resueltas) en una
  sola operación. No hay estados intermedios persistidos por sección o por ítem.
- **Borrado de ítems es local hasta guardar:** un ítem "eliminado" con Deshacer antes de tocar
  "Guardar ficha" nunca llegó a persistirse como baja; si el usuario deshace, simplemente
  reaparece en la lista local. Esto es responsabilidad de la capa de presentación/estado del
  formulario (a resolver con `arquitecto-software`/`dev-flutter` si conviene un modelo de "borrador"
  en memoria vs. optimista con reconciliación al guardar).
- **Sin guardado parcial por sección:** no debe existir ningún botón "Guardar" a nivel de
  Antecedentes/Alergias/Enfermedades ni de la cabecera; el único punto de persistencia es el
  botón sticky de toda la pantalla.
- **Reemplazo del menú:** en el hub de Mi salud, la card "Recomendaciones" pasa a llamarse
  "Ficha de salud" y navega a `/health/record`. La ruta `/health/recommendations` y su pantalla
  (`recommendations_screen.dart`) quedan fuera de alcance y deben eliminarse del router y del
  menú — a coordinar con `arquitecto-software`/`dev-flutter` al momento de implementar, ya que es
  una decisión de código, no de diseño.
