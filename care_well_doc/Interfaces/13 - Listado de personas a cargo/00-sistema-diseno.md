# US-13 Listado de personas a cargo — Sistema de diseno

> Este flujo hereda en su totalidad el sistema de diseno definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Aca solo se documentan las decisiones especificas del flujo de listado.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Secundario | `secondaryContainer #FCE2DA` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Success | `success #2E9E5B` · `successContainer #D8F0E1` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Radios | cards `radiusMd 16` · botones `radiusLg 16` · chips `radiusFull 999` |
| Alturas | boton 56 dp · objetivo tactil min. 48 dp · FAB 56 dp |
| Tipografia | familia `Inter` (fallback `'Segoe UI', Arial, sans-serif`) |

---

## 2. Componentes especificos de US-13

### 2.1 PersonCard

Tarjeta de persona a cargo en la lista. Especificaciones:

| Propiedad | Valor |
|---|---|
| Fondo | `surface #FFFFFF` |
| Border-radius | 16 dp |
| Margin | 0 16px 10px |
| Padding | 16 dp |
| Sombra | `0 1px 4px rgba(0,0,0,0.08)` |
| Layout | flex row, gap 12 dp, align-items center |
| Avatar | circulo 52 dp, bg `primaryContainer #C9EDE8`, inicial 22px bold `#0A3D38` |
| Nombre | 16 px, 700, `textPrimary #16201F` |
| Edad | 13 px, 400, `textSecondary #566060` |
| CHEVRON_RIGHT | 20 dp, color `#9AA5A5`, margen izquierdo auto |

Tap en la tarjeta navega al perfil de la persona (US-14).

### 2.2 RoleBadge

Chip de rol dentro de la tarjeta:

| Variante | Fondo | Texto | Uso |
|---|---|---|---|
| Responsable | `primaryContainer #C9EDE8` | `#0A3D38` | Usuario es responsable de esa persona |
| Cuidador | `secondaryContainer #FCE2DA` | `#7A2E1A` | Usuario es cuidador de esa persona |

Especificaciones comunes: font-size 11 px, font-weight 600, border-radius 999 px, padding 3px 9px.

### 2.3 SectionLabel

Encabezado de seccion que separa grupos por rol:
- Font-size: 12 px
- Font-weight: 600
- Letter-spacing: 0.8 px
- Color: `textSecondary #566060`
- Text-transform: uppercase
- Padding: 12px 20px 8px

### 2.4 FAB (Floating Action Button)

Boton de accion flotante para agregar nueva persona:
| Propiedad | Valor |
|---|---|
| Tamano | 56 x 56 dp |
| Border-radius | 16 dp (FAB M3 extended shape) |
| Background | `primary #1A8C82` |
| Icono ADD | 24 dp, blanco |
| Posicion | absoluto, bottom 24 dp, right 20 dp |
| Sombra | `0 4px 12px rgba(26,140,130,0.35)` |
| Tap target | 56 dp >= 48 dp minimo |

### 2.5 EmptyState (estado vacio)

| Propiedad | Valor |
|---|---|
| Contenedor icono | circulo 80 dp, bg `primaryContainer #C9EDE8` |
| Icono PERSON | 48 dp, color `primary #1A8C82` |
| Titulo | 18 px, 700, `textPrimary #16201F` |
| Cuerpo | 14 px, 400, `textSecondary #566060`, centrado, max-width 260 dp |
| Boton | PrimaryButton estandar, 56 dp, texto "Agregar persona" |

---

## 3. Decisiones especificas de US-13

1. **Separacion por rol con SectionLabels.** El mismo usuario puede ser Responsable de
   algunas personas y Cuidador de otras. Las secciones separan visualmente estos contextos
   y anticipan que las acciones disponibles (ver US-14, US-15) dependen del rol (RBAC).
   Si el usuario solo tiene personas en uno de los roles, se muestra unicamente esa seccion.

2. **Badge de rol dentro de la tarjeta, no en el titulo.** El badge es pequeno y esta
   dentro del bloque de nombre/edad para no fragmentar la lectura. El contraste cromatico
   (teal para Responsable, salmon/naranja para Cuidador) permite distinguir roles de un vistazo.

3. **FAB como unica entrada al alta (US-12).** No hay boton en AppBar. El FAB M3 es el
   patron estandar para acciones de creacion en listas. Solo se muestra si el usuario tiene
   el permiso de agregar personas (Responsable). Un Cuidador sin permiso no ve el FAB.

4. **Estado vacio sin FAB reducido.** Cuando la lista esta vacia, el estado vacio incluye
   un boton primario "Agregar persona" en el centro. El FAB desaparece para reducir
   redundancia visual y guiar la atencion al CTA principal.

5. **CHEVRON_RIGHT indica navegacion.** El chevron en cada tarjeta comunica que la tarjeta
   es navegable, no solo informativa. El objetivo tactil es la tarjeta completa (no solo el chevron).

6. **No hay swipe-to-delete en la lista.** La eliminacion (US-15) es una accion de alto
   impacto y se realiza desde el perfil de la persona (US-14 -> menu contextual). Evitar
   swipe-to-delete previene eliminaciones accidentales en una poblacion que puede no
   estar familiarizada con ese gesto.

---

## 4. Mapa de estados

| Estado | Archivo HTML | Disparador |
|---|---|---|
| Lista con personas | `01-listado.html` | usuario tiene personas a cargo registradas |
| Lista vacia | `02-listado-vacio.html` | usuario sin personas a cargo registradas |
