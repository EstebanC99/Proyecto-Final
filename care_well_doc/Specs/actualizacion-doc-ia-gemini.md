# Actualización de la documentación — migración de IA (Ollama self-hosted → Gemini pago vía Vertex AI)

> **Destinatario:** `analista-funcional`
> **Autor:** asistente (a partir de la sesión de deploy a producción del 2026-08-06)
> **Estado:** pendiente de aplicar al `.tex`
> **Origen:** durante el deploy a producción, el componente de IA (`CareWell.DocumentIntelligence`) se migró de Ollama (self-hosted, gratis) a Google Gemini vía Vertex AI (proveedor externo, pago). El documento `CuidadoPersonas.tex` describe la arquitectura anterior en varias secciones y quedó desactualizado.
> **Alcance:** `care_well_doc/LATEX/CuidadoPersonas.tex` — 6 secciones afectadas, detalladas abajo. Incluye 2 decisiones de producto/privacidad que no son solo redacción.

---

## 1. Qué cambió técnicamente (contexto para redactar)

- El backend **ya no usa Ollama ni infraestructura propia** para los modelos de IA.
- Usa **Google Gemini (`gemini-2.5-flash-lite`)**, a través de **Vertex AI / Agent Platform** de Google Cloud — un proveedor externo, con facturación por uso (aunque con cuota gratuita mensual).
- Se usa el **mismo modelo** tanto para la validación de identidad (OCR de DNI) como para el resumen diario — ya no son "dos modelos distintos" (uno de visión + uno de texto liviano `qwen2.5:3b-instruct`).
- La imagen del DNI, y los datos de salud/hábitos/ánimo que se procesan para el resumen diario, **ahora sí se envían a un proveedor externo** (Google). Ya no se procesan "sobre infraestructura propia".
- Motivo del cambio: Ollama en el VPS no entraba en RAM junto con SQL Server (el modelo de visión solo, cargado, dejaba menos de 2GB libres de 7.8GB totales), y la latencia de un modelo self-hosted sobre CPU compartida era inviable para producción. No fue una decisión de diseño premeditada — fue una limitación de infraestructura descubierta durante el deploy.

---

## 2. Secciones del PDF que quedaron desactualizadas

### 2.1 — 🔴 CRÍTICO: Política de privacidad (línea 781)

> *"...El procesamiento se realiza sobre infraestructura propia, sin remitir la imagen a proveedores terceros."*

Es una afirmación de cara al usuario final, dentro de los Términos que acepta. **Hoy es falsa.** Hay que reescribirla reconociendo que la imagen del DNI se procesa mediante un proveedor externo (Google, vía Vertex AI), manteniendo lo que sigue siendo cierto (no se almacena, se descarta tras el procesamiento) y agregando qué garantías da el proveedor (ver decisión abierta #2 más abajo). **Prioridad más alta de esta lista** — es lo que el usuario lee y acepta.

### 2.2 — Componente de inteligencia artificial (§Factibilidad técnica, líneas 678-687)

Toda la subsección está redactada sobre "no recurrir a un proveedor de IA externo... self-hosted mediante Ollama". Ajustar:
- **Línea 680** (decisión central): ya no es self-hosted, es un proveedor externo (Gemini/Vertex AI).
- **Línea 683** (previsibilidad del costo): el argumento se invierte — ahora el costo SÍ depende del volumen de uso (facturación por token), ya no es fijo y conocido de antemano. Replantear por qué se optó igual por este camino (RAM insuficiente para self-hosted en el VPS contratado, calidad y latencia muy superiores, costo real bajo para el volumen de un proyecto de tesis).
- **Línea 686** ("dos modelos distintos"): ahora es un solo modelo (`gemini-2.5-flash-lite`) para ambos casos de uso.
- **Línea 687** (riesgo de "modelo de menor tamaño con calidad inferior a modelos comerciales"): ya no aplica — ahora se usa directamente un modelo comercial de primer nivel.

### 2.3 — Validación de identidad (línea 933)

> *"El componente de IA... se despliega self-hosted... no se remite a ningún proveedor tercero externo."*

Misma corrección que 2.1.

### 2.4 — Resumen diario de la persona a cargo (líneas 1170-1179)

Varios párrafos asumen que el componente es self-hosted, con implicancias de privacidad reales:
- **Línea 1175-1176:** la justificación para **no anonimizar el nombre de la persona** antes de enviarlo a la IA se apoya explícitamente en que "el componente de IA es self-hosted y no un tercero externo". Esa premisa ya no es cierta — **esto no es solo redacción, es una decisión de producto/privacidad que hay que retomar** (ver decisión abierta #1).
- La misma línea 1176 ya preveía el escenario: *"Si a futuro se evaluara la adopción de un proveedor externo, este pasaría a actuar como encargado del tratamiento y debería existir un acuerdo que prohíba el uso de los datos para fines distintos..."* — ese "a futuro" ya es el presente.
- **Línea 1179:** menciona `qwen2.5:3b-instruct` — actualizar a `gemini-2.5-flash-lite` vía Vertex AI.

### 2.5 — Riesgo 2, Integración de IA (líneas 1501-1502, dentro de "Tratamientos → Controles")

> *"Priorizar el despliegue self-hosted de los componentes de IA (por ejemplo, mediante Ollama), de modo que los datos de salud no se expongan a proveedores terceros externos."*

Este control de mitigación ya no está vigente tal cual. Reemplazarlo por uno real dado el esquema actual — por ejemplo: elegir un proveedor con garantías contractuales de no usar los datos para entrenar sus modelos, minimización de datos enviados (ya está en línea 1174), cifrado en tránsito (ya en línea 1177), revisión del acuerdo de tratamiento de datos del proveedor.

### 2.6 — Factibilidad económico-financiera (línea 856, "Costos de materiales y servicios")

> *"...no se consideran, por el momento, costos adicionales de materiales ni servicios."*

Ya no es del todo exacto: el uso de la API de Gemini/Vertex AI tiene un costo variable por uso (bajo para el volumen actual de un proyecto de tesis, pero existe). Al menos mencionarlo como nota o partida menor estimada.

---

## 3. Decisiones ya resueltas por el usuario (2026-08-06) — usar esto como base para redactar

1. **¿Se sigue enviando el nombre real de la persona a la IA para el resumen diario? → Sí, se mantiene.** Nueva justificación (reemplaza a la de "self-hosted" en línea 1175-1176): se trata de un proveedor de nivel empresarial (Google Cloud / Vertex AI, no un tercero cualquiera), y el usuario acepta expresamente en la Política de privacidad y los Términos y condiciones que sus datos personales se utilizan con este fin al usar la aplicación.

2. **¿Qué garantías da Google sobre el uso de los datos enviados a Vertex AI? → Confirmado.** Documentación oficial de Google Cloud (`docs.cloud.google.com/gemini/docs/discover/data-governance`):
   - *"Gemini doesn't use your prompts or its responses as data to train its models"* — Google **no usa** los prompts (texto, imágenes) ni las respuestas para entrenar sus modelos, a diferencia de algunos tiers de consumo gratuitos.
   - *"Google Cloud handles your prompts in accordance with our terms of service and Cloud Data Processing Addendum"* — existe un **Cloud Data Processing Addendum (CDPA)**, el acuerdo formal de tratamiento de datos para clientes de Google Cloud/Vertex AI. Esto es exactamente lo que la línea 1176 del documento pedía como condición ("debería existir un acuerdo que prohíba el uso de los datos para fines distintos... como reentrenamiento de modelos") — la condición **ya está cumplida** por default al usar Vertex AI, sin trámite adicional.
   - Esta garantía es específica del tier empresarial (Vertex AI); **no aplica igual al tier de consumo gratuito de Google AI Studio**, que sí puede usarse para mejorar productos según otros programas de Google — vale la pena que la Política de privacidad sea precisa en este punto, mencionando que se usa Vertex AI y no AI Studio por este motivo (además del motivo técnico de bloqueo geográfico ya documentado en `care_well_doc/Deploy/administracion.md`).

3. Sigue pendiente confirmar si corresponde reflejar el costo variable de la IA en el presupuesto (punto 2.6), aunque sea como nota al pie — sin resolver, no bloquea el resto de la redacción.
