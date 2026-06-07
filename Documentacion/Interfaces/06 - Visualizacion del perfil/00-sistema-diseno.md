# US-06 Visualización del perfil — Sistema de diseño

> Este flujo **hereda en su totalidad** el sistema de diseño definido en US-01:
> `Documentacion/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Esa es la fuente de verdad de paleta, tipografía, espaciado, radios, componentes y motion.
> Acá solo se documentan las **decisiones específicas del flujo de visualización de perfil**.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryContainer #C9EDE8` · `onPrimaryContainer #0A3D38` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `disabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Éxito | `success #2E9E5B` · `successContainer #D8F0E1` |
| Radios | card/avatar `radiusFull` · chip de rol `radius 999` |
| Alturas | fila de dato mín. 64 dp (objetivo táctil compliant) · objetivo táctil mín. 48 dp |
| Tipografía | familia `Inter` (fallback: `'Segoe UI', Arial, sans-serif`) |

---

## 2. Nuevos componentes introducidos en US-06

### 2.1 Avatar de inicial (`ProfileAvatar`)

Componente exclusivo del perfil; no existía en flujos anteriores (autenticación no lo requería).

| Propiedad | Valor |
|---|---|
| Forma | círculo, 80 dp de diámetro |
| Fondo | `primaryContainer #C9EDE8` |
| Inicial | primera letra del nombre, 36 px bold, color `onPrimaryContainer #0A3D38` |
| Justificación | En el MVP no se admite carga de foto. El avatar de inicial es una convención Material 3 reconocible y accesible, con buen contraste (ratio > 4.5:1). |

### 2.2 Chip de rol (`RoleBadge`)

| Propiedad | Valor |
|---|---|
| Fondo | `primaryContainer #C9EDE8` |
| Texto | `onPrimaryContainer #0A3D38`, 12 px, weight 600 |
| Padding | 4 px vertical · 12 px horizontal |
| Border-radius | 999 px (píldora) |
| Posición | debajo del nombre completo, centrado |
| Comportamiento | solo lectura; no tappable; el rol lo asigna el sistema |

### 2.3 Fila de dato (`ProfileDataRow`)

| Propiedad | Valor |
|---|---|
| Altura mín. | 64 dp (cumple objetivo táctil aunque en esta pantalla no sea interactiva) |
| Padding vertical | 12 px |
| Padding horizontal | 24 px (hereda el padding de sección) |
| Ícono prefijo | 20 dp, color `textSecondary #566060` |
| Label | 13 px, color `textSecondary #566060` |
| Valor | 16 px, color `textPrimary #16201F`, weight 500 |
| Separador | `divider` 1 dp `outline #C5CECE` entre filas |
| Comportamiento | solo lectura en US-06; no responde a tap (la edición es exclusiva de US-07) |

---

## 3. Estructura de la pantalla

| Zona | Fondo | Descripción |
|---|---|---|
| Status bar | `#16201F` | 28 dp, hora + íconos de sistema |
| AppBar | `surface #FFFFFF` | 56 dp, ARROW_BACK + título "Mi Perfil" |
| Encabezado de perfil | `surface #FFFFFF` | Avatar + nombre + chip de rol, centrado, padding 24 dp, border-bottom |
| Sección de datos | `background #F6F8F8` | Lista de `ProfileDataRow`, padding horizontal 24 dp |

---

## 4. Decisiones de diseño específicas

1. **Solo lectura estricta.** Ninguna fila de dato es tappable en esta pantalla. El usuario que
   quiera editar debe llegar a US-07 (pantalla separada, accesible desde el menú o desde un
   botón de acción si lo requiere el flujo principal). Esto evita activaciones accidentales en
   pantallas de consulta rápida.

2. **Avatar con inicial, sin foto en MVP.** Cargar, recortar y gestionar fotos de perfil implica
   infraestructura adicional (storage, compresión, permisos de cámara). Se difiere a iteración
   futura. El avatar de inicial cubre la necesidad de reconocimiento visual con cero fricción.

3. **Rol no editable por el usuario.** El rol (`Responsable` / `Cuidador`) lo asigna el sistema
   o el responsable del equipo. Se muestra como información de contexto, no como campo editable.
   El chip de rol usa el mismo `primaryContainer` que el avatar para coherencia visual.

4. **Jerarquía de tipografía clara.** Nombre completo 20 px bold domina el encabezado; el chip
   de rol a 12 px es subordinado. En las filas de dato, label a 13 px y valor a 16 px mantienen
   la relación figura/fondo de los tokens del sistema.

5. **Padding consistente con US-01/02.** El `padding: 0 24px` de la sección de datos replica el
   `screen padding` de los flujos de autenticación para mantener alineación visual global.

---

## 5. Mapa de estados

| Estado | Descripción |
|---|---|
| Cargando | Skeleton placeholders en avatar y filas de dato (shimmer); AppBar visible. Se muestra brevemente mientras se resuelve el request. |
| Con datos | Estado normal documentado en `02-mi-perfil.md`. |
| Error de carga | Banner de error inline bajo la AppBar con opción "Reintentar". Los datos anteriores (si los hay en caché) se muestran atenuados. |

> El estado de carga y error no tienen HTML propio en esta iteración; se reservan para cuando
> el datasource real reemplace al mock (que siempre resuelve con datos).
