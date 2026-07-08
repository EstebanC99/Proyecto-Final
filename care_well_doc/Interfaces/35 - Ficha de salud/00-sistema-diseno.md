# US-35 Ficha de salud — Sistema de diseño

> Reemplaza por completo a "Recomendaciones médicas" (US-29, eliminada del alcance y del menú).
> Hereda el sistema de diseño global de CareWell definido en
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Este archivo documenta únicamente las decisiones específicas del sub-módulo Ficha de salud
> dentro de Mi salud.

---

## 1. Continuidad con el hub de Mi salud

La card "Recomendaciones" del hub (`medical_services_outlined`, acento `healthAccent #E11D48`,
contenedor `#FFF1F2`) se **renombra** a "Ficha de salud" **conservando el mismo ícono y el mismo
acento de color**. No es una card nueva visualmente: es un reemplazo 1:1 de destino/etiqueta.
Esto minimiza el trabajo de `dev-flutter` en el hub (`health_screen.dart`): solo cambia el label,
la descripción y la ruta de destino de esa card puntual; el resto del hub (Hábitos, Eventos,
Estado de ánimo, Línea de tiempo) no se modifica.

| Concepto                  | Token / valor                                |
|----------------------------|-----------------------------------------------|
| Acento del módulo Ficha    | `healthAccent #E11D48` / contenedor `#FFF1F2` |
| Ícono de la card en el hub | `medical_services_outlined` (sin cambios)     |

## 2. Acentos de las 3 listas (diferenciación visual entre secciones)

El pedido funcional exige que Antecedentes, Alergias y Enfermedades se vean "claramente
diferenciadas, no mezcladas". En vez de inventar 3 colores nuevos, se **reutilizan tokens
semánticos ya existentes** en el sistema de diseño global (sección 2.4 de la identidad visual),
elegidos por afinidad de significado. Esto evita inflar la paleta y mantiene coherencia con el
resto de la app:

| Lista          | Ícono                  | Color                          | Justificación                                          |
|----------------|------------------------|---------------------------------|---------------------------------------------------------|
| Antecedentes   | `history`              | `healthAccent #E11D48` / `#FFF1F2` | Es el acento propio del módulo Ficha de salud (dato clínico central). |
| Alergias       | `healing` (venda)      | `warning #E0A100` / `warningContainer #FBF0CF` | Semántica de "precaución" — encaja naturalmente con alergias. |
| Enfermedades   | `local_hospital`       | `info #2E77C2` / `infoContainer #DBE9FB`       | Semántica "informativa/clínica neutra", sin alarmar.   |

Regla: el color de cada sección se aplica solo a elementos decorativos (ícono de sección, borde
izquierdo de las cards de esa lista, botón "+ Agregar" de esa sección). **Nunca** se usa como
color del botón primario global (ver sección 6).

## 3. Componentes específicos

### 3.1 `PersonaContextHeaderCard` (encabezado de solo lectura)
Tarjeta compacta, no interactiva, que ubica al usuario sobre a quién pertenece la ficha. No lleva
botones de edición (a diferencia del `DataRow` de US-14): estos datos ya se editan desde
"Personas a cargo", aquí son solo contexto.

- Fondo `surface #FFFFFF`, radio `radiusLg 16`, padding 16px, sombra `elev0`/borde 1px `outline`.
- Fila superior: avatar circular 48dp, `primaryContainer #C9EDE8`, inicial 18px/700 `onPrimaryContainer #0A3D38`
  (mismo esquema de color que el avatar de persona a cargo en toda la app — reconocible, no se
  mezcla con el acento del módulo). A la derecha, nombre completo 16px/700 `textPrimary`.
- Dos filas secundarias debajo, 13px `textSecondary`, con ícono 16dp a la izquierda:
  - `badge` + "DNI 23.456.789"
  - `calendar_month` + "Nacida el 15/03/1942"
- Sin chevron, sin acción táctil: tap en la card no hace nada.

### 3.2 `BloodTypeChipGrid` (selector de Factor sanguíneo)
Selector de catálogo cerrado (8 valores fijos), visible en todo momento (sin abrir picker
adicional) para minimizar fricción — coherente con el principio de "flujos cortos".

- Grilla 4 columnas × 2 filas, gap 8px. Orden: A+, A-, B+, B-, AB+, AB-, O+, O-.
- Chip: 100% del ancho de columna, alto 44dp, radio `radiusMd 12`, borde 1.5px.
  - **Inactivo:** fondo `surface`, borde `outline #C5CECE`, texto `textPrimary` 15px/600.
  - **Seleccionado:** fondo `healthAccent` contenedor `#FFF1F2`, borde 2px `healthAccent #E11D48`,
    texto `#E11D48` 15px/700.
- Es **obligatorio**: si el usuario intenta "Guardar ficha" sin seleccionar, el grid muestra un
  borde de error (`error #D14343`, 2px, en todos los chips) y aparece debajo un texto de ayuda de
  error `labelSmall` "Seleccioná el factor sanguíneo" — mismo patrón que el error de campo de
  `AppTextField` (sección 5.3 de la identidad visual), aplicado a un grupo en vez de a un input.

### 3.3 `HealthListSection` (contenedor de cada una de las 3 listas)
- Encabezado de sección: ícono 20dp (color de la lista, ver §2) + título 15px/700 `textPrimary` +
  badge de contador (ej. "2") en `surfaceVariant`/`textSecondary` + botón "+ Agregar" alineado a
  la derecha (chip de acción, borde 1.5px del color de la lista, texto del color de la lista,
  12px/700, radio `radiusFull`, padding 6px 12px, altura 32dp).
- Debajo, lista vertical de `HealthListItemCard` (gap 8px) o, si está vacía, el estado vacío
  (§3.5).
- Separación entre secciones: `xxl 24dp`. Borde/superficie propios (fondo `surface`, radio
  `radiusLg 16`, padding 16px) para que cada sección se perciba como una tarjeta independiente,
  no una lista continua — refuerza la separación visual pedida.

### 3.4 `HealthListItemCard` (fila de ítem, con edición y borrado)
- Fondo `surface`, radio `radiusMd 12`, padding 12px, borde izquierdo 3px del color de la lista
  (§2). Objetivo táctil total >= 48dp de alto.
- Tap en el cuerpo de la card (todo excepto el ícono de borrar) → abre `ItemFormBottomSheet` en
  modo edición, precargado.
- Contenido (varía por tipo, ver `03-formulario-item.md`): título 15px/700 `textPrimary` +
  1-2 líneas secundarias 13px `textSecondary`. Enfermedades además muestra un `StatusChip`
  (§3.6) alineado a la derecha del título.
- Extremo derecho: `IconButton` de borrado (`delete_outline`, 20dp, color `textSecondary`,
  objetivo táctil 40×40dp). Es la única acción visible además del tap-to-edit, para no saturar
  la fila con múltiples íconos.
- **Interacción de borrado:** tap en el ícono de borrar quita el ítem de la lista local
  **inmediatamente** (sin dialog de confirmación) y muestra un `Snackbar` con acción "Deshacer"
  (ver §3.7). Se elige este patrón — y no un dialog modal como en US-19 (baja de responsable) —
  porque acá el borrado es una edición **local y reversible** hasta que se presiona "Guardar
  ficha"; un dialog por cada tap sería fricción innecesaria para una acción de bajo riesgo y
  fácilmente deshacible.

### 3.5 Estado vacío de una lista individual
Dentro de la `HealthListSection`, cuando no hay ítems:
- Ícono de la lista, 32dp, color de la lista a 100% pero sobre fondo contenedor tenue (círculo
  48dp, fondo `container` de esa lista).
- Texto 14px `textSecondary`, centrado: "Todavía no registraste {antecedentes/alergias/
  enfermedades}."
- Botón de texto "+ Agregar el primero", color de la lista, 14px/700, debajo del texto — mismo
  destino que el botón "+ Agregar" del encabezado de sección (evita que el usuario tenga que
  "buscar" el botón chico de arriba si no lo vio).

### 3.6 `StatusChip` (vigente/resuelta — solo Enfermedades)
- "Activa": fondo `warningContainer #FBF0CF`, texto `warning #E0A100`... con **excepción de
  contraste**: se usa el texto en `#8A6400` (variante oscurecida del warning) para cumplir AA
  sobre el contenedor claro, siguiendo la regla general de la identidad visual de no bajar de
  4.5:1 en texto informativo. 12px/700, radio `radiusFull`, padding 4px 10px.
- "Resuelta": fondo `successContainer #D8F0E1`, texto `success #2E9E5B` (cumple AA), mismo
  tamaño/radio.
- Es una representación visual del switch "vigente" (booleano) que se completa en el formulario;
  no es interactivo dentro de la card de lista (la edición del estado se hace abriendo el
  formulario).

### 3.7 `Snackbar` con "Deshacer" (borrado no destructivo)
- Fondo `textPrimary #16201F` (oscuro, estándar M3), texto `#FFFFFF` 14px, acción "DESHACER"
  en `primaryContainer`-tint (`#7FD9CE` aprox. sobre fondo oscuro) 14px/700, mayúsculas.
- Mensaje: "{Nombre del ítem} eliminado" (ej. "Hipertensión eliminado").
- Duración 5 segundos. Si el usuario navega fuera de la pantalla antes de que expire, el borrado
  queda confirmado igual (no bloquea la navegación).

### 3.8 `ItemFormBottomSheet` (alta/edición de ítem — reutilizable)
Un único componente de presentación, parametrizado por tipo de ítem (Antecedente / Alergia /
Enfermedad), reutilizado 3 veces con distinto set de campos. Ver especificación completa y campos
por tipo en `03-formulario-item.md`. Chrome común (igual al `AppBottomSheet` global, sección 5.9
de la identidad visual):
- Grabber 40×4dp `outline`, header con título ("Nuevo antecedente" / "Editar antecedente", etc.)
  + botón de cierre `close` 24dp arriba a la derecha.
- Cuerpo: campos en `AppTextField`/textarea estándar (sección 5.3 de la identidad visual).
- Footer fijo dentro del sheet: botón primario ("Agregar" en alta / "Guardar cambios" en edición),
  y en modo edición, debajo, un botón de texto destructivo "Eliminar {tipo}" (`error #D14343`),
  que dispara el mismo flujo de Snackbar-deshacer que el ícono de borrado de la card (§3.7) y
  cierra el sheet.
- **Importante:** "Agregar"/"Guardar cambios" de este sheet **no persiste nada en el backend**.
  Solo actualiza el estado local (en memoria) de la lista dentro de la pantalla de Ficha de
  salud. La persistencia real ocurre una única vez, al presionar "Guardar ficha" (§3.9).

### 3.9 Botón sticky "Guardar ficha"
- Igual al `PrimaryButton` global (sección 5.1 de la identidad visual): 56dp, ancho completo,
  radio `radiusLg 16`, fondo `primary #1A8C82` (color de marca, **no** el acento rojo del
  módulo — mismo criterio ya documentado para el selector de ánimo: el CTA principal no cambia
  de color según el contexto semántico de la pantalla, para no mezclar "botón de acción" con
  "color de estado").
- Se implementa como `bottomNavigationBar`/footer fijo de la pantalla (no scrollea con el
  contenido).
- Estados: reposo, pressed, **disabled** (mientras Factor sanguíneo no esté seleccionado — fondo
  `outline #C5CECE`), **loading** (spinner blanco, guardando cabecera + 3 listas en una sola
  operación), **error** (vuelve a reposo + `InlineErrorBanner` arriba del botón con "No se pudo
  guardar la ficha. Reintentar" — los datos ingresados no se pierden).

## 4. Notas de accesibilidad
- El borrado de ítems nunca es una acción "silenciosa": siempre hay Snackbar + "Deshacer",
  visible durante 5s, con contraste AA sobre fondo oscuro.
- El estado "obligatorio" de Factor sanguíneo se comunica con texto + borde, nunca solo color.
- Todos los objetivos táctiles (`+ Agregar`, ícono de borrado, chips de factor sanguíneo, filas
  de ítem) respetan el mínimo de 48dp de alto de fila (aunque el ícono visual sea menor).
- El `StatusChip` de Enfermedades nunca es la única señal de estado: el título del ítem y, en el
  formulario, el label del switch ("Activa"/"Resuelta") siempre acompañan en texto.
