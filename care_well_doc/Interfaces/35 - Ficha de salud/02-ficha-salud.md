# US-35 Ficha de salud — Pantalla: Ficha de salud

## Objetivo
Permitir al Responsable/Cuidador registrar y mantener actualizada la ficha clínica básica de la
persona a cargo (factor sanguíneo, obra social, antecedentes, alergias, enfermedades y
observaciones) en una única pantalla, con una sola acción de guardado.

## Layout (jerarquía de componentes)

```
StatusBar
AppBar (ARROW_BACK + "Ficha de salud")
─ ScrollView vertical (padding 16px, padding-bottom extra para el botón sticky)
    ContextChip (persona a cargo — acento healthAccent, igual criterio que otros sub-módulos)
    PersonaContextHeaderCard (solo lectura)
      ├── Avatar + nombre completo
      ├── DNI
      └── Fecha de nacimiento
    SectionLabel "Datos generales"
    Label "Factor sanguíneo *"
    BloodTypeChipGrid (4×2)
    [texto de error si aplica]
    Label "Obra social (opcional)"
    AppTextField (texto libre)
    HealthListSection — Antecedentes (acento healthAccent)
      ├── Header: ícono + "Antecedentes" + badge contador + chip "+ Agregar"
      └── HealthListItemCard × N  |  Estado vacío
    HealthListSection — Alergias (acento warning)
      ├── Header: ícono + "Alergias" + badge contador + chip "+ Agregar"
      └── HealthListItemCard × N  |  Estado vacío
    HealthListSection — Enfermedades (acento info)
      ├── Header: ícono + "Enfermedades" + badge contador + chip "+ Agregar"
      └── HealthListItemCard × N  |  Estado vacío
    Label "Observaciones (opcional)"
    TextArea
─ Footer fijo (fuera del scroll)
    PrimaryButton "Guardar ficha"
```

## Estados de la pantalla

### Estado de carga (skeleton)
Al entrar a la pantalla, mientras se resuelve si la persona tiene ficha previa: skeleton de la
`PersonaContextHeaderCard` (shimmer) + 2 bloques rectangulares shimmer simulando el formulario de
cabecera + 3 bloques shimmer simulando las secciones de lista (72px cada uno). Botón sticky
oculto hasta que se resuelve la carga.

### Estado de error de carga
`InlineErrorBanner` centrado bajo el AppBar: "No se pudo cargar la ficha de salud. Reintentar".
No se muestra ningún formulario hasta reintentar con éxito (evita mostrar un formulario "vacío"
que en realidad podría tener datos no cargados por error de red).

### Estado vacío / alta (persona sin ficha previa) — ver `Imagenes/01-ficha-vacia.jpg`
- `PersonaContextHeaderCard` con los datos reales de la persona (siempre disponible, viene de
  "Personas a cargo", no depende de que exista ficha de salud).
- Factor sanguíneo: ningún chip seleccionado.
- Obra social y Observaciones: vacíos, con placeholder.
- Las 3 `HealthListSection` en su estado vacío (ver `00-sistema-diseno.md` §3.5): ícono + texto
  "Todavía no registraste {antecedentes/alergias/enfermedades}." + botón "+ Agregar el primero".
- Botón sticky "Guardar ficha" **deshabilitado** (Factor sanguíneo es obligatorio y no hay
  ninguno seleccionado).

### Estado con datos precargados (ficha existente) — ver `Imagenes/02-ficha-con-datos.jpg`
- Factor sanguíneo con un chip seleccionado (ej. "O+").
- Obra social y Observaciones con el texto guardado previamente.
- Las 3 secciones muestran sus `HealthListItemCard` correspondientes (ver ejemplos abajo).
- Botón sticky "Guardar ficha" habilitado desde el inicio (ya hay Factor sanguíneo).

**Ejemplos de datos (mock) para la ficha con datos:**

| Lista          | Ítem 1                                                                 | Ítem 2 |
|----------------|-------------------------------------------------------------------------|--------|
| Antecedentes   | "Hipertensión" — desc. "Diagnosticada en 2015, controlada con medicación" — vínculo "Madre" | "Diabetes tipo 2" — desc. "Diagnosticada en 2019" — vínculo "Propio" |
| Alergias       | "Penicilina" — reacción "Erupción cutánea y dificultad para respirar" — medicamento "Amoxicilina" | — |
| Enfermedades   | "Hipotiroidismo" — vigente: Activa — obs. "Controlada con Levotiroxina 50mcg" | — |

### Estado de un guardado en curso
El resto de la pantalla queda interactuable (no hay overlay bloqueante de pantalla completa); solo
el botón sticky pasa a estado loading (spinner blanco, texto oculto o "Guardando..."), deshabilitado
para evitar doble tap.

### Estado de guardado exitoso
Botón sticky vuelve a reposo. `Snackbar` (fondo `textPrimary`, texto blanco) "Ficha de salud
guardada". La pantalla permanece igual (no navega automáticamente al hub); si la ficha era nueva,
a partir de este momento queda "con datos" (aunque visualmente no cambia nada más que el snackbar).

### Estado de error de guardado
Botón sticky vuelve a reposo. `InlineErrorBanner` aparece pegado encima del botón sticky (dentro
del footer, no dentro del scroll, para que sea visible sin scrollear): "No se pudo guardar la
ficha de salud. Reintentar". Todos los datos ingresados (cabecera + listas) se conservan
intactos para reintentar sin volver a escribir nada.

### Validación de Factor sanguíneo no seleccionado
Si se llega a tocar "Guardar ficha" en un estado en que el botón está habilitado pero la
validación de backend rechaza por falta de Factor sanguíneo (caso borde, ej. se deseleccionó por
algún motivo), el grid de Factor sanguíneo se resalta en `error` (ver §3.2 de
`00-sistema-diseno.md`) y se hace scroll automático hasta ese campo.

## Interacciones
- Tap ARROW_BACK → vuelve al hub de Mi salud. Si hay cambios sin guardar, se pide confirmación
  ("¿Salir sin guardar los cambios de la ficha?" — dialog con "Salir" / "Seguir editando"),
  mismo criterio de protección ya usado en formularios largos de la app.
- Tap en un chip de Factor sanguíneo → lo selecciona (deselecciona el anterior; selección única).
  Feedback háptico ligero, consistente con otros selectores de la app.
- Tap "+ Agregar" de una sección, o "+ Agregar el primero" en el estado vacío → abre el
  `ItemFormBottomSheet` correspondiente en modo alta.
- Tap en el cuerpo de una `HealthListItemCard` → abre el `ItemFormBottomSheet` en modo edición,
  precargado con los datos de ese ítem.
- Tap en el ícono de borrado de una `HealthListItemCard` → quita el ítem de la lista local +
  Snackbar "Deshacer" (ver `00-sistema-diseno.md` §3.7).
- Tap "Guardar ficha" (habilitado) → guarda cabecera + 3 listas en una sola operación.
- Scroll vertical para recorrer todo el formulario; el botón sticky nunca se mueve.

## Navegación de entrada/salida
- Entrada: única, desde el hub de Mi salud (tap card "Ficha de salud").
- Salida: ARROW_BACK (con posible confirmación de descarte) → hub de Mi salud. No hay otra salida
  automática tras guardar: el usuario decide cuándo volver.
