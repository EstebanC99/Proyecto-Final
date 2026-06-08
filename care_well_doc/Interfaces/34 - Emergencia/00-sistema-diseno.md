# US-34 Emergencia — Sistema de diseño

> Hereda la paleta base del sistema de diseño global (US-01 / US-02).
> Este documento registra las **extensiones y decisiones específicas del módulo de emergencia**.
> La pantalla de emergencia es la más crítica de toda la app: debe ser inconfundible,
> accionable bajo estrés y libre de ambigüedad.

---

## 1. Tokens heredados del sistema base

| Concepto | Token / valor |
|---|---|
| Primario teal | `primary #1A8C82` · `primaryContainer #C9EDE8` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Radios | `radiusMd 12` · `radiusLg 16` |
| Alturas mínimas táctiles | 48 dp |

---

## 2. Tokens de extensión — módulo de emergencia

| Concepto | Token / valor | Uso |
|---|---|---|
| Coral (secondary) | `secondary #F2785C` | Acentos y chips de contexto secundarios |
| Rojo de emergencia | `emergency #D14343` | Color dominante de toda la pantalla de emergencia |
| Rojo hover | `emergencyDark #B02F2F` | Estado pressed del botón de emergencia |
| Container rojo claro | `errorContainer #FBE3E3` | Fondo de banners de error |
| Fondo emergencia | gradiente `#FFF1F0 → #FFFFFF` | Fondo de la pantalla principal, tinte coral muy sutil |
| Chip contexto | bg `#FFF1F2` · text `#E11D48` | Chip "persona a cargo" en pantalla de emergencia |
| Verde confirmación | `success #2E9E5B` · `successContainer #D8F0E1` | Pantalla de alerta enviada |

---

## 3. Tipografía de emergencia

La escala tipográfica general se mantiene (Inter / Segoe UI). Las excepciones para el módulo:

| Rol | Tamaño | Peso | Color | Uso |
|---|---|---|---|---|
| Título de emergencia | 22 px | 800 | `#D14343` | Encabezado "Emergencia" en AppBar |
| Label del botón circular | 11 px | 700 | `#FFFFFF` | Texto dentro del botón rojo |
| Título de confirmación | 24 px | 700 | `#16201F` | "Alerta enviada" |
| Body de confirmación | 16 px | 400 | `#566060` | Texto explicativo post-envío |

---

## 4. Componentes exclusivos de este módulo

### 4.1 EmergencyButton (botón circular pulsante)

- Forma: círculo de 120 dp de diámetro
- Color de fondo: `#D14343`
- Sombra: `0 4px 20px rgba(209,67,67,0.4)`
- Contenido: ícono `error_outline` 48 dp blanco + label "EMERGENCIA" 11 px bold blanco
- Anillos concéntricos:
  - Anillo exterior: 160 dp, `rgba(209,67,67,0.10)`, animación `pulse-ring` 2 s infinite
  - Anillo medio: 140 dp, `rgba(209,67,67,0.15)`, estático
- Objetivo táctil efectivo: 160 dp (incluye anillo exterior)
- Anti-accidental: el toque no activa la alerta directamente; abre un dialog de confirmación

### 4.2 EmergencyConfirmDialog (dialog M3 urgente)

- Fondo: `#FFFFFF`, radio 28 px, padding 24 px, margin horizontal 24 px
- Franja roja superior: 6 px de alto, `#D14343`, radio 28 28 0 0 px
- Overlay de fondo: `rgba(0,0,0,0.5)`
- Botón primario: `#D14343`, blanco, alto 48 dp, radio 14 px, full-width
- Botón cancelar: texto teal `#1A8C82`, alto 44 dp
- Propósito anti-accidental: segundo paso explícito antes del envío

### 4.3 NotifiedPersonRow (fila de persona notificada)

- Ícono `person` 20 dp (color según estado: `#566060` antes, `#2E9E5B` después)
- Nombre + rol (texto secundario 14 px)
- En estado "enviada": indicador de check verde derecho
- Agrupados en card con radio 12 px

### 4.4 SuccessIcon (confirmación circular)

- Círculo 88 dp, fondo `#D8F0E1`
- Ícono `check_circle` 48 dp, color `#2E9E5B`

---

## 5. Motion / animaciones

| Nombre | Descripción | Uso |
|---|---|---|
| `pulse-ring` | `scale(1→1.1)` + `opacity(0.6→0)` en 2 s, ease-in-out, infinite | Anillo exterior del botón de emergencia |
| `sending-spin` | Rotación de spinner 360° en 0.8 s linear infinite | Estado "Enviando alerta..." |
| `fade-in-up` | `opacity 0→1` + `translateY 20px→0` en 0.4 s ease-out | Aparición de la pantalla de éxito |

---

## 6. Principios de diseño para este módulo

1. **Color como señal inequívoca.** El rojo `#D14343` domina la pantalla entera para que el usuario
   identifique el contexto sin leer. No se usa este color en ninguna otra pantalla de la app.

2. **Anti-accidental obligatorio.** Cualquier activación de emergencia requiere exactamente dos
   gestos deliberados: toque del botón + confirmación en dialog. Sin excepciones.

3. **Claridad sobre densidad.** La pantalla tiene pocos elementos, grandes y separados.
   No hay menús, tabs ni información secundaria que distraiga.

4. **Feedback nominado.** Tanto en el dialog ("3 miembros del equipo") como en la confirmación
   (lista con nombres reales) el usuario sabe exactamente quién será notificado y quién fue
   notificado. Esto reduce la ansiedad y las falsas alarmas.

5. **Sin botón de re-envío.** La pantalla de confirmación post-envío no tiene acción primaria
   que invite a enviar otra alerta. Solo permite "Volver al inicio".

6. **Accesibilidad prioritaria.** Contraste mínimo 4.5:1 en todo el texto. Objetivos táctiles
   mínimos 48 dp. Texto nunca por debajo de 13 px.
