# US-34 Emergencia — Pantalla principal de emergencia

## 1. Objetivo

Presentar al usuario el botón de activación de emergencia de forma inconfundible, con contexto
de quién será notificado y el mecanismo anti-accidental.

---

## 2. Archivo HTML de referencia

`html/01-pantalla-emergencia.html`

---

## 3. Layout (jerarquía de componentes)

```
StatusBar (28 dp, fondo #16201F)
AppBar (56 dp)
  ├─ IconButton ARROW_BACK (color #D14343)
  └─ Title "Emergencia" (22px bold #D14343)

Fondo: gradiente #FFF1F0 → #FFFFFF (vertical)

ScrollContent (padding horizontal 24px)
  ├─ ContextChip "Alicia Rodríguez" (bg #FFF1F2, text #E11D48, centrado)
  ├─ BodyText (16px #566060, margin-top 12px, centrado)
  │   "Al activar la emergencia, todos los miembros del equipo
  │    recibirán una notificación inmediata."
  ├─ NotificadosCard (bg #FFF, radius 10px, margin 0 16px, padding 12px)
  │   ├─ HeaderRow: ícono GROUPS 24px #D14343 + "Se notificará a (3 personas):"
  │   ├─ PersonRow: PERSON 16px #566060 · "María García" · "(Responsable)"
  │   ├─ PersonRow: PERSON 16px #566060 · "Carlos Pérez" · "(Responsable)"
  │   └─ PersonRow: PERSON 16px #566060 · "Laura Méndez" · "(Cuidadora)"
  └─ EmergencyButtonZone (centrada, margin 24px 0)
      ├─ PulseRingOuter (160dp, rgba(209,67,67,0.10), animación pulse-ring)
      ├─ PulseRingInner (140dp, rgba(209,67,67,0.15), estático)
      ├─ EmergencyButton (120dp circular, #D14343, sombra 0 4px 20px rgba(209,67,67,0.4))
      │   ├─ Ícono error_outline 48dp blanco
      │   └─ Label "EMERGENCIA" 11px 700 blanco
      └─ HintText "Tocá el botón para enviar la alerta" (13px #9AA5A5, centrado, margin-top 20px)
```

---

## 4. Estados de la pantalla

| Estado | Descripción |
|---|---|
| Normal | Botón pulsante disponible, anillos animados, lista de notificados visible |
| Vacío (sin equipo) | NotificadosCard muestra "No hay miembros en el equipo de cuidado" en textDisabled; botón deshabilitado (opacidad 0.4) |
| Sin conexión | Banner info en la parte superior: "Sin conexión. Verificá tu red antes de activar la emergencia." Botón deshabilitado |
| Cargando equipo | Skeleton en la NotificadosCard mientras se obtiene la lista de miembros |

---

## 5. Interacciones

| Elemento | Acción | Resultado |
|---|---|---|
| ARROW_BACK | tap | Navega hacia atrás (Menú principal) |
| EmergencyButton (anillo + botón) | tap | Abre EmergencyConfirmDialog (modal, no ruta) |
| EmergencyButton | long-press | Sin efecto (no hay atajo) |

---

## 6. Especificaciones de componentes

### AppBar
- Altura: 56 dp
- Fondo: blanco (`#FFFFFF`) con sombra sutil `0 1px 0 #C5CECE`
- Color de ícono back y título: `#D14343` (señal de alerta desde el primer elemento visible)

### ContextChip
- Padding: 6px 16px
- Border-radius: 20px (pill)
- Borde: 1px solid `#FECDD3`
- Tipografía: 13px 600

### NotificadosCard
- Sombra: `0 1px 4px rgba(22,32,31,0.06)`
- Divisor entre filas de personas: 1px `#EDF1F1` (excepto la última fila)
- Cada PersonRow: altura mínima 40 dp, padding vertical 8px

### EmergencyButton
- Objetivo táctil: el área tappable incluye los anillos (160dp total)
- Estado pressed: fondo cambia a `#B02F2F` con transición 80 ms
- Sombra en pressed: reducida a `0 2px 8px rgba(209,67,67,0.3)`

---

## 7. Accesibilidad

- Semantics label del botón circular: "Activar emergencia. Abre diálogo de confirmación."
- El ContextChip tiene role de texto, no de botón
- Contraste de "EMERGENCIA" (blanco sobre #D14343): ratio 4.6:1 — cumple AA
- Contraste de label del AppBar (#D14343 sobre #FFFFFF): ratio 4.7:1 — cumple AA
