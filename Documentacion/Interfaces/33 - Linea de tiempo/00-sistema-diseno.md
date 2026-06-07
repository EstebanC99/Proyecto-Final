# US-33 Linea de tiempo de eventos — Sistema de diseño

> Este flujo hereda la paleta base y los tokens del sistema de diseño global de CareWell
> (`01 - Registro de usuario/00-identidad-visual.md`) y aplica el **color de módulo Mi salud**:
> rosa `#E11D48` / container `#FFF1F2`. La línea de tiempo introduce una paleta semántica de
> categorías para los distintos tipos de evento de salud.

---

## 1. Tokens del módulo Mi salud (heredados de US-32)

| Concepto | Token / valor |
|---|---|
| Acento módulo | `healthPrimary #E11D48` |
| Container módulo | `healthContainer #FFF1F2` |
| Primario global | `primary #1A8C82` |
| Background | `background #F6F8F8` |
| Surface | `surface #FFFFFF` |
| SurfaceVariant | `surfaceVariant #EDF1F1` |
| textPrimary | `#16201F` |
| textSecondary | `#566060` |
| textDisabled | `#9AA5A5` |
| outline | `#C5CECE` |

---

## 2. Paleta semántica de categorías de evento

Cada categoría de evento tiene un color propio que se usa en el dot de la timeline y en el chip.

| Categoria | Dot / text | Container chip |
|---|---|---|
| Cita medica | `#E11D48` | `#FFF1F2` |
| Hospitalizacion | `#E11D48` | `#FFF1F2` |
| Medicacion | `#2563EB` | `#EFF6FF` |
| Bienestar | `#16A34A` | `#F0FDF4` |
| Tratamiento | `#7C3AED` | `#F5F3FF` |
| Control | `#EA580C` | `#FFF7ED` |
| Estudio / analisis | `#0891B2` | `#ECFEFF` |

Regla: el color del dot siempre coincide con el color del texto del chip de esa categoria.

---

## 3. Componentes propios del flujo

### 3.1 Dot de timeline
- Circulo `22 dp`, relleno con el color de categoria.
- Sin icono (el color y el chip ya identifican la categoria).
- Alineado al centro vertical de la primera linea del titulo del evento.

### 3.2 Linea conectora (tl-line)
- Ancho `2 dp`, color `#EDF1F1` (surfaceVariant).
- Conecta el dot del evento con el del siguiente. El ultimo evento no tiene linea.
- La linea visualmente comunica continuidad cronologica.

### 3.3 Tarjeta de evento en timeline (tl-card)
- Bg `surface #FFF`, radius `12 dp`, padding `12 dp 14 dp`.
- Sombra `0 1px 4px rgba(0,0,0,0.06)`.
- Margen inferior `12 dp` (espacio entre tarjetas).
- Estructura interna: chip categoria → fecha discreta → titulo bold → descripcion.

### 3.4 Chip de categoria (inline)
- Identico al de US-32: colores por categoria (tabla anterior).
- Tamaño `10 dp`, peso 600, radio `999 dp`, padding `2px 8px`.
- Margen inferior `6 dp` dentro de la tarjeta.

### 3.5 Chip de persona (AppBar)
- Identifica la persona bajo cuidado cuya historia clinica se esta viendo.
- Bg `#FFF1F2`, texto `#E11D48`, mismo radio `999 dp`.
- No interactivo en esta pantalla (en MVP).

---

## 4. Decisiones de diseño

1. **Mas reciente arriba.** El orden cronologico descendente (mas reciente al tope) responde al
   modelo mental del usuario cuidador: lo que importa saber primero es lo mas reciente. La
   historia mas antigua requiere scroll hacia abajo.

2. **Color como lenguaje semantico.** La paleta de categorias permite al usuario identificar
   el tipo de evento de un vistazo, sin leer el chip. Citas/hospitalizaciones en rosa,
   medicacion en azul, bienestar en verde, tratamientos en violeta.

3. **Linea conectora neutra.** La linea `#EDF1F1` es intencionalmente discreta: sirve de guia
   visual sin competir con el color de los dots ni el contenido de las tarjetas.

4. **Tap en tarjeta navega al detalle.** Cada tarjeta es tappable (objetivo tactil >= 48 dp
   de alto) y navega al detalle del evento (US-32). El indicador CHEVRON_RIGHT puede sumarse
   en iteraciones futuras; en MVP no es necesario dado que toda la superficie de la tarjeta
   es tappable.

5. **Chip de persona en AppBar.** La linea de tiempo es un recurso compartido por el equipo;
   mostrar el nombre de la persona bajo cuidado en el AppBar elimina ambiguedad cuando el
   cuidador gestiona mas de una persona.

---

## 5. Mapa de estados

| Estado | Disparador |
|---|---|
| Con datos | historia clinica con al menos 1 evento |
| Vacio | persona sin eventos registrados |
| Cargando | primera carga o pull-to-refresh |
| Error de carga | fallo de red |
