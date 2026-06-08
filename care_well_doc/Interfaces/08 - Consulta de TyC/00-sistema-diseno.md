# US-08 Consulta de Términos y Condiciones — Sistema de diseño

> Este flujo hereda el sistema de diseño base de CareWell definido en
> `01 - Registro de usuario/00-identidad-visual.md`.
> Acá se documentan únicamente las decisiones específicas del módulo Configuración
> y de la pantalla de Términos y Condiciones.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` · `outlineStrong #9AA5A5` |
| Radios | card `radiusMd 12` · dialog `radiusXl 28` |
| Alturas | ítem de lista 56 dp mín. · objetivo táctil mín. 48 dp |
| Tipografía | familia `Inter` (fallback `'Segoe UI', Arial, sans-serif`) |

---

## 2. Componentes propios del módulo Configuración

### 2.1 SettingsAppBar
AppBar con fondo `surface` (#FFF), elevación 0, borde inferior 1 dp `outline`.
Contenido: ícono ARROW_BACK 24 dp (`textPrimary`) + título "Configuración" `titleLarge` (18 px, 700).
Altura total (incluye status bar): 28 dp status + 56 dp app bar = 84 dp.

### 2.2 SectionHeader
Separador de grupo. Texto `labelMedium` (13 px, 500) color `textSecondary` (#566060).
Padding: 8 dp arriba, 24 dp horizontal, 4 dp abajo.
Sin borde ni fondo propio; el contraste lo da el `background` (#F6F8F8) debajo del ítem.

### 2.3 SettingsItem
Fila de la lista de configuración. Alto mínimo 56 dp, fondo `surface` (#FFF).
Estructura horizontal:
  - Ícono 24 dp, color `textSecondary` (#566060) · margen izquierdo 24 dp
  - Label `bodyLarge` (16 px, 400) color `textPrimary` · flex 1 · margen izquierdo 16 dp
  - CHEVRON_RIGHT 20 dp, color `textSecondary` · margen derecho 16 dp
Separador inferior: 1 dp `outline` (#C5CECE), inset 64 dp desde el borde izquierdo
(alineado al texto, no al ícono).

### 2.4 SettingsItem — estado activo (ítem relevante)
El ítem que corresponde a la US en pantalla se resalta con:
  - Fondo `primaryContainer` (#C9EDE8)
  - Ícono y CHEVRON_RIGHT toman color `primary` (#1A8C82)
  - Label color `primary` (#1A8C82), peso 600
  - Borde izquierdo 3 dp `primary` (indicador de selección)

### 2.5 SettingsItem — variante destructiva
Para ítems de sesión (Cerrar sesión, Eliminar cuenta):
  - Ícono color `error` (#D14343)
  - Label color `error` (#D14343)
  - CHEVRON_RIGHT color `error` (#D14343)

### 2.6 TyCContentArea
Área de texto con el contenido de los T&C. Fondo `surface`, padding 24 dp horizontal,
16 dp vertical. Texto `bodyMedium` (14 px, 400) color `textPrimary`, interlineado 1.6.
Encabezados de sección: `titleSmall` (14 px, 700) color `textPrimary`, margen superior 20 dp.
La altura del área es fija (viewport menos AppBar y status bar); el contenido desborda
visualmente para indicar que hay más texto abajo.

### 2.7 ScrollHint
Indicador de scroll al pie del contenido. Texto "Deslizá para leer mas" (sin tilde en "mas"
para evitar problemas de encoding en algunos entornos), centrado, `labelSmall` (12 px),
color `textDisabled` (#9AA5A5). Margen inferior 12 dp.

---

## 3. Decisiones específicas de US-08

1. **Solo lectura, sin acciones.** La pantalla de T&C en Configuración es idéntica
   en contenido a la que aparece en el registro (US-01, paso 2), pero sin botón
   "Acepto" ni checkbox. El usuario ya aceptó al registrarse; acá solo consulta.

2. **Scroll nativo sin paginación.** El texto puede ser largo. Se usa scroll simple
   (sin tabs ni acordeones) para que el usuario lea de corrido sin interrupciones.
   El indicador de scroll es visual, no interactivo.

3. **AppBar fija.** La AppBar no se colapsa al hacer scroll. Razón: el botón ARROW_BACK
   debe estar siempre accesible, especialmente para usuarios mayores o menos familiarizados
   con los gestos de navegación.

4. **Sin botón al pie.** No hay CTA al terminar de leer. El usuario vuelve con ARROW_BACK
   o con el gesto de back del sistema. Agregar un botón "Cerrar" al pie sería redundante
   y añadiría ruido visual.

5. **Ítem activo en la pantalla de Configuración.** Al navegar desde Configuración hacia T&C,
   el ítem "Términos y condiciones" queda resaltado con `primaryContainer` como feedback
   contextual.

---

## 4. Mapa de estados de la pantalla T&C

| Estado | Disparador | Componente clave |
|---|---|---|
| Cargando (local) | apertura de la pantalla | skeleton de texto (3 bloques gris claro) |
| Con contenido | texto cargado (local, no hay API) | `TyCContentArea` con scroll |

> El contenido de los T&C es estático y se entrega con la app (no requiere llamada de red).
> Por eso no existe estado de error de red en esta pantalla. Si en iteraciones futuras se
> sirve desde la API, se agrega el estado de error correspondiente.
