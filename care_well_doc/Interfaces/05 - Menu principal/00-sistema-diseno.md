# US-05 Menú principal (Home) — Sistema de diseño

> Esta pantalla **hereda en su totalidad** el sistema de diseño definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Esa es la fuente de verdad de paleta, tipografía, espaciado, radios, componentes y motion.
> Acá solo se documentan las **decisiones específicas del Home**.

---

## 1. Rol de esta pantalla en la app

El Menú principal es la **pantalla raíz post-login**: el destino al que llega el usuario tras
autenticarse correctamente y el punto de retorno cuando presiona Atrás desde cualquier sección
de primer nivel. En `go_router` es la raíz del `ShellRoute`; no tiene botón de retorno propio.

Toda la navegación de la app irradia desde aquí. Su función principal es doble:
1. **Orientar** al usuario: ¿dónde estoy? ¿a qué puedo acceder?
2. **Presentar la acción de emergencia** de forma siempre visible, sin requerir búsqueda.

---

## 2. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Secundario | `secondary #F2785C` · `secondaryContainer #FCE2DA` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` · `outlineStrong #9AA5A5` |
| Radios | cards `16 dp` · botones `16 dp` · chips `8 dp` |
| Elevaciones | card reposo `shadow 0 2px 8px rgba(0,0,0,0.08)` · pressed `sin sombra` |
| Tipografía | familia `Inter` (fallback Roboto). En mockups HTML: `'Segoe UI', Arial, sans-serif`. |

---

## 3. Componentes nuevos definidos en US-05

### 3.1 `HomeHeader`
Barra de identidad + saludo. Altura fija 64 dp. Fondo `surface`. Sin elevación visible.

| Zona | Contenido |
|---|---|
| Izquierda | Ícono de marca CareWell 40 dp + wordmark "**Care**Well" 16 px bold bicolor |
| Derecha | Avatar circular 40 dp (bg `primaryContainer`, inicial en color `onPrimaryContainer #0A3D38`) + nombre "Hola, **María**" 14 px + indicador desplegable `▾` |

El área avatar+saludo es tappable (≥48 dp) y navega a Mi Perfil (US-06).

### 3.2 `QuickAccessRow`
Fila horizontal de accesos rápidos bajo el header. Altura 56 dp. Fondo `background`.

Botones pequeños (icon 20 dp + label 12 px) con fondo `surfaceVariant`, radio 12 dp,
padding 8×12 dp. Mínimo objetivo táctil 48 dp. Estados: reposo / pressed (fondo `primaryContainer`).

En esta versión contiene dos accesos: **Mi Perfil** y **Configuración**.

### 3.3 `NavTile`
Card cuadrada de acceso a sección principal. Fondo `surface`, radio 16 dp, sombra sutil,
padding 20 dp. Disposición centrada vertical: ícono 32 dp en color `primary` + label debajo
`titleMedium` (15 px, 600 weight) en `textPrimary`. Altura ~130 dp.

Estado pressed: sombra eliminada + fondo `primaryContainer`. Duración: 100 ms.

### 3.4 `EmergencyTile`
Tile full-width. Fondo `secondary #F2785C`. Radio 16 dp. Altura 72 dp. Layout horizontal
centrado: ícono SVG 32 dp blanco + label "Emergencia" 18 px bold blanco.

Tap: dispara flujo US-09 (aviso al equipo). Sin estado vacío ni de carga en esta pantalla
(la confirmación ocurre en la pantalla siguiente).

Estado pressed: overlay oscuro 10% sobre el coral.

### 3.5 `EmptyStateTile` (variante de `NavTile`)
Variante del tile para el estado vacío de "Personas a cargo". Mismo tamaño y radio.
Fondo `surfaceVariant`. Ícono 32 dp en `textDisabled`. Texto "Aún no tenés personas a cargo"
en 12 px `textSecondary`, centrado. Botón `+` en la esquina superior derecha (24 dp,
color `primary`).

---

## 4. Decisiones de diseño específicas del Home

1. **Grid 2×2 + tile full-width.** Cuatro secciones de uso frecuente en grilla par favorece
   el escaneo visual. La emergencia fuera del grid impide confundirla con un acceso normal y
   refuerza su peso visual.

2. **Accesos rápidos separados del grid.** Perfil y Configuración son acciones del usuario sobre
   sí mismo, no sobre la persona cuidada. Separarlos en la fila superior reduce la carga cognitiva
   del grid.

3. **Avatar con inicial, no foto.** En el MVP no se soporta carga de foto de perfil. La inicial
   sobre `primaryContainer` mantiene consistencia de identidad sin requerir permiso de cámara.

4. **Sin barra de navegación inferior (BottomNavBar).** El home actúa como menú launcher.
   Cada sección secundaria tiene su propio `AppBar` con botón de retorno al Home. Esta decisión
   evita sobrecargar la UI en la pantalla de inicio y mantiene la jerarquía clara.

5. **Tile de emergencia siempre visible.** No se oculta ni desactiva en ningún estado, incluido
   el estado vacío. Es el acceso de mayor urgencia y no puede quedar subordinado a otro flujo.

6. **Estado vacío localizado.** Cuando no hay personas a cargo, solo ese tile cambia de apariencia;
   los demás permanecen activos. El usuario puede seguir usando el resto de la app.
