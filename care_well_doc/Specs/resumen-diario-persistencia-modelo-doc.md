# Persistencia del Resumen inteligente (US 9.16) — Modelo de dominio y documentación

> **Destinatario:** `analista-funcional` (documentación LaTeX) y `arquitecto-software` (diagrama)
> **Autor:** `arquitecto-software`
> **Estado:** **§2 (diagrama de dominio) APLICADO** el 2026-08-13 por `arquitecto-software` —
> `ResumenDiario` ya está en `CareWell-modelo-dominio.drawio` (XML validado).
> **§3 (LaTeX) y §4 (CLAUDE.md) siguen pendientes**, a cargo de `analista-funcional`.
> **Alcance:** `care_well_doc/Diagramas/CareWell-modelo-dominio.drawio`, `care_well_doc/LATEX/CuidadoPersonas.tex` y `CLAUDE.md`.
> **Specs hermanas:** `resumen-diario-persistencia-backend.md` · `resumen-diario-persistencia-frontend.md`

---

## 1. Qué cambió (contexto para redactar)

Hasta ahora el **Resumen inteligente** (US 9.16) era un read-model **efímero**: cada vez que un
usuario abría la pantalla, el backend invocaba al modelo de IA (Gemini) y descartaba el resultado.
Documentación vigente que lo afirma: `CLAUDE.md` §9 ("sin caché en el MVP: cada apertura de pantalla
o 'Actualizar' invoca al modelo") y los pasajes de la US 9.16 en el `.tex`.

A partir de este cambio, el resumen **se persiste** en la base de datos:

- Se guarda **un único resumen por persona cuidada**, con la **fecha y hora de generación** y el
  **contenido** del resumen (serializado como JSON). Cada nueva generación **sobrescribe** al
  anterior: el sistema no acumula historial de resúmenes.
- Al consultar el resumen, si el guardado fue generado **el mismo día y hace menos de 3 horas**, se
  devuelve ese, **sin invocar al modelo**.
- Si no hay uno vigente, se genera uno nuevo y reemplaza al anterior.
- Si el usuario pide explícitamente actualizar (botón "Actualizar" o pull-to-refresh), se regenera
  igual, con un piso técnico de 1 minuto entre regeneraciones forzadas para evitar pedidos repetidos
  accidentales.
- Los resúmenes **sin datos** ("no hay registros del día") no se guardan: ese caso no llega al modelo
  y guardarlo congelaría un "sin información" durante horas.

**Motivación:** cada generación es una llamada paga a un proveedor externo y demora varios segundos.
Dentro de una misma franja de horas la información del día no cambia sustancialmente, de modo que
regenerar en cada apertura era costo y latencia sin valor agregado.

**Contrapartida a documentar con honestidad:** si se registra un dato nuevo (evento de salud, hábito,
estado de ánimo) dentro de la ventana de 3 horas, el resumen mostrado **no lo incluye** hasta que el
usuario lo actualice manualmente o venza la ventana.

---

## 2. Modelo de dominio — nueva entidad `ResumenDiario`

**Archivo:** `care_well_doc/Diagramas/CareWell-modelo-dominio.drawio`

### 2.1 Definición

| Atributo | Tipo | Comentario |
|---|---|---|
| `id` | PK | identidad propia |
| `personaId` | FK → `Persona`, **único** | persona cuidada a la que refiere el resumen |
| `fechaHoraGeneracion` | fecha y hora | momento en que se generó (define la vigencia) |
| `contenido` | texto largo | snapshot del resumen generado por IA, serializado en JSON |

**Relación:** `Persona 1 — 0..1 ResumenDiario`. Una persona cuidada tiene, a lo sumo, un resumen
guardado (el último generado); si nunca se generó ninguno, no tiene ninguno. Baja en cascada: al
eliminar la persona se elimina su resumen.

**Notas de modelado (importantes para la defensa):**

1. `ResumenDiario` **no** es una entidad de negocio con reglas propias sobre su contenido: es un
   *snapshot de un read-model derivado*. Por eso el contenido se guarda serializado y no descompuesto
   en tablas de hábitos, eventos y recomendaciones: nunca se consulta por partes ni se edita, y un
   modelo relacional obligaría a migrar el esquema cada vez que cambie la forma de la salida del
   modelo de IA.
2. La cardinalidad `0..1` es deliberada: la tabla funciona como **caché**, no como historial. Se
   evita así acumular indefinidamente textos con información de salud que nadie consulta, y no hace
   falta definir una política de retención. La trazabilidad de las invocaciones al modelo, si se
   necesita, ya está cubierta por el registro de servicios externos (`t_LogServicioExterno`).
3. La única regla de negocio que vive en la entidad es la **vigencia**: mismo día calendario y menos
   de 3 horas desde la generación.

### 2.2 XML a insertar

Agregar antes de `</root>` (la zona `x≈1060, y≈690` está libre; reubicar a gusto en draw.io):

```xml
<mxCell id="resumendiario" parent="1" style="rounded=0;whiteSpace=wrap;html=1;verticalAlign=top;fillColor=#dae8fc;strokeColor=#6c8ebf;fontSize=12;spacingTop=2;spacingLeft=6;spacingRight=6;" value="&lt;b&gt;ResumenDiario&lt;/b&gt;&lt;hr size=&#39;1&#39;&gt;&lt;div style=&#39;text-align:left;line-height:1.3&#39;&gt;PK id&lt;br&gt;FK personaId (unico)&lt;br&gt;fechaHoraGeneracion&lt;br&gt;contenido (JSON del resumen IA)&lt;/div&gt;" vertex="1">
  <mxGeometry height="102" width="230" x="1060" y="690" as="geometry" />
</mxCell>
<mxCell id="edge-persona-resumendiario" parent="1" source="persona" target="resumendiario" edge="1" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;" value="tiene resumen">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

Agregar además las dos etiquetas de cardinalidad con el mismo estilo que usan las demás aristas del
diagrama: **`1`** del lado de `Persona` y **`0..1`** del lado de `ResumenDiario` (mismo criterio que
las relaciones `Persona — Usuario` y `Persona — FichaSalud`, que ya usan `1` / `0..1`).

> **Aplicado con dos ajustes sobre el XML propuesto arriba** (2026-08-13):
> 1. La entidad se dibuja con **borde punteado** (`dashed=1;dashPattern=8 4`) para distinguir
>    visualmente que no es fuente de verdad sino una caché de un read-model derivado. El relleno se
>    mantiene en el azul de `Persona` (`#dae8fc`/`#6c8ebf`), que es su dueña.
> 2. Se agregó una nota `nota_resumendiario` (mismo estilo que `nota_emergencia` y `nota_dispositivo`)
>    explicando: caché y no historial, contenido serializado, cardinalidad `0..1`, regla de vigencia y
>    baja en cascada. Los ids reales son `resumendiario`, `e_resumendiario`, `e_resumendiario_s`,
>    `e_resumendiario_t` y `nota_resumendiario`.

### 2.3 Verificación

- Abrir el `.drawio` en draw.io y confirmar que la arista queda anclada a `persona` y no cruza otras
  entidades.
- El nombre de la entidad del diagrama (`ResumenDiario`) debe coincidir con el de la clase del
  backend (`CareWell.Domain.General.ResumenDiario`) y el de la tabla (`t_ResumenDiario`).
- La marca "(unico)" en `personaId` debe leerse igual que en `Usuario.personaId (unico)`, que ya usa
  esa convención en el diagrama.

---

## 3. Documentación LaTeX (`care_well_doc/LATEX/CuidadoPersonas.tex`)

> Responsable: `analista-funcional` (único agente que edita el `.tex`).

### 3.1 Secciones a revisar

Buscar en el `.tex` las menciones al **Resumen inteligente / resumen diario** (US 9.16) y a la
generación por IA, y ajustar donde se afirme que el resumen se genera en cada consulta o que no se
almacena. Puntos a cubrir:

1. **Descripción de la funcionalidad (US 9.16):** agregar que el resumen generado **se almacena** y
   se reutiliza durante un lapso acotado, y que el usuario puede pedir una actualización manual.
2. **Reglas de negocio:** incorporar
   - la regla de vigencia: "el resumen se reutiliza si fue generado el mismo día y hace menos de
     3 horas; en caso contrario se genera uno nuevo";
   - que se conserva **un único resumen por persona**, que se reemplaza en cada generación;
   - la excepción del pedido explícito de actualización.
3. **Criterios de aceptación de la US 9.16:** agregar
   - "Al reabrir la pantalla dentro de las 3 horas, se muestra el mismo resumen sin una nueva
     invocación al modelo de IA."
   - "Al pulsar 'Actualizar' o hacer pull-to-refresh, se genera un resumen nuevo que reemplaza al
     anterior."
   - "El resumen indica el momento en que fue generado."
4. **Modelo de datos / diagrama:** incluir `ResumenDiario` (ver sección 2) en el capítulo donde se
   describe el modelo, con la aclaración de por qué el contenido se almacena serializado y por qué la
   cardinalidad es `0..1` (caché, no historial).
5. **Privacidad y tratamiento de datos:** el contenido generado por IA —que incluye datos de salud
   redactados— **ahora se almacena en la base de datos del sistema**, además de enviarse al proveedor
   externo (Google) para su generación. Es un cambio material respecto de lo documentado (antes el
   resultado no se guardaba). A favor del criterio de **minimización de datos**, corresponde destacar
   que:
   - se conserva **únicamente el último resumen** de cada persona, a modo de caché, y no un historial;
   - el registro se elimina en cascada al eliminar a la persona (derecho de supresión).
6. **Limitación conocida:** documentar explícitamente que los registros cargados dentro de la ventana
   de vigencia no se reflejan hasta actualizar manualmente o hasta que la ventana venza. Conviene
   presentarlo como decisión de diseño (costo/latencia vs. inmediatez) y mencionar la mejora futura
   posible: detectar cambios en las fuentes para invalidar el resumen automáticamente.

### 3.2 Justificación a incluir (resumen redactable)

> La generación del resumen implica una llamada a un modelo de IA de un proveedor externo, con costo
> por uso y una latencia de varios segundos. Como la información de un día no varía sustancialmente
> en el corto plazo, el sistema conserva el último resumen generado para cada persona cuidada y lo
> reutiliza durante tres horas del mismo día, dejando siempre disponible la actualización manual. Se
> almacena un único resumen por persona —el más reciente—, de modo que el registro funciona como una
> caché y no como un historial de información de salud. Así se reduce el consumo del servicio externo
> y el tiempo de espera del usuario, sin perder la posibilidad de obtener información actualizada
> cuando el cuidador lo necesita.

### 3.3 Compilación

```bash
cd care_well_doc/LATEX
latexmk -pdf CuidadoPersonas.tex
```

---

## 4. Memoria del proyecto (`CLAUDE.md`)

**Editar:** §9 "Conceptos / features", entrada `summary`. Reemplazar la descripción actual
("read model efímero… sin caché en el MVP: cada apertura de pantalla o 'Actualizar' invoca al
modelo") por una equivalente a:

> `summary` (resumen inteligente de la persona a cargo — read model generado por IA, US-9.16;
> compila 3 fuentes: eventos de salud, hábitos de vida y estados de ánimo —la Agenda queda para una
> mejora futura—). **Se persiste** en `t_ResumenDiario` (entidad `ResumenDiario`: persona, fecha y
> hora de generación, contenido JSON), **un único registro por persona que se sobrescribe en cada
> generación**: una consulta reutiliza el resumen si fue generado el mismo día y hace menos de
> 3 horas; el botón "Actualizar" y el pull-to-refresh fuerzan la regeneración (con un piso de 1
> minuto). Los resúmenes sin datos no se cachean.

Si en §4a se describe `CareWell.DocumentIntelligence`, no hace falta tocarlo: el agente resumidor no
cambia; lo que cambia es quién y cuándo lo invoca (`ResumenDiarioBusinessService`).

---

## 5. Criterios de aceptación de esta spec

1. El `.drawio` abre sin errores, incluye `ResumenDiario` con sus cuatro atributos (con `personaId`
   marcado como único) y la relación `1 — 0..1` con `Persona`.
2. El `.tex` compila y ya no contiene afirmaciones de que el resumen se genera en cada consulta o
   que no se almacena.
3. Los criterios de aceptación de la US 9.16 incluyen los tres puntos de 3.1.3.
4. La sección de privacidad menciona el almacenamiento del contenido generado, que se conserva sólo
   el último resumen por persona y su borrado en cascada.
5. `CLAUDE.md` §9 refleja la regla de vigencia y el reemplazo del resumen anterior.

## 6. Commit sugerido

`docs: documentar persistencia del resumen diario y agregar ResumenDiario al modelo de dominio`
