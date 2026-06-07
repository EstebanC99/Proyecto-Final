# US-34 Emergencia — Dialog de confirmación y envío

## 1. Objetivo

Segundo paso anti-accidental: solicitar confirmación explícita antes de enviar la alerta.
El dialog muestra el alcance exacto de la acción (cantidad de personas notificadas y nombre
de la persona a cargo) para que el usuario decida con información completa.

---

## 2. Archivo HTML de referencia

`html/02-confirmacion-dialog.html`

---

## 3. Layout

```
Pantalla de emergencia (fondo atenuado, overlay rgba(0,0,0,0.5), no interactuable)

Dialog M3
  ├─ FranjaRoja (6px, #D14343, radius 28 28 0 0)
  ├─ PaddingContent (24px todos los lados)
  │   ├─ IconoNotification NOTIFICATIONS_ACTIVE 48px #D14343 (centrado)
  │   ├─ Titulo "¿Activar emergencia?" (18px 700 #16201F, centrado, margin-top 12px)
  │   ├─ BodyText (14px #566060, centrado, margin-top 8px)
  │   │   "Se enviará una notificación urgente a 3 miembros del
  │   │    equipo de cuidado de Alicia. Usá esto solo ante una
  │   │    situación real."
  │   ├─ BtnConfirmar "Sí, enviar alerta" (#D14343, blanco, 48dp, radius 14px, full-width, margin-top 20px)
  │   └─ BtnCancelar "Cancelar" (texto, #1A8C82, 44dp, full-width, margin-top 8px)
  └─ radius: 28px
```

---

## 4. Estados del dialog

| Estado | Descripción |
|---|---|
| Normal | Ambos botones habilitados |
| Enviando | BtnConfirmar muestra spinner blanco (24dp) + texto "Enviando..."; BtnCancelar deshabilitado (opacidad 0.4); dialog no se puede cerrar con tap fuera ni con back |
| Error de red | BtnConfirmar vuelve a su estado normal; aparece InlineErrorBanner rojo debajo del body: "No se pudo enviar la alerta. Verificá tu conexión." |

---

## 5. Interacciones

| Elemento | Acción | Resultado |
|---|---|---|
| BtnConfirmar | tap (estado normal) | Dialog pasa a estado "Enviando"; se dispara la llamada de envío |
| BtnCancelar | tap (estado normal) | Dialog se cierra; vuelve a la pantalla de emergencia sin cambios |
| Overlay oscuro | tap | Sin efecto (barrierDismissible: false) — evita cierre accidental |
| Gesto back del sistema | swipe / botón | Sin efecto mientras se envía; en estado normal cierra el dialog (equivale a Cancelar) |
| BtnConfirmar | tap (estado enviando) | Sin efecto (deshabilitado) |

---

## 6. Especificaciones de componentes

### Dialog
- Ancho: `screenWidth - 48px` (margin 24px a cada lado)
- Máximo ancho recomendado en tablet: 340 dp
- `barrierDismissible: false` en el estado "Enviando"
- `barrierDismissible: true` en el estado normal (equivale a Cancelar)

### BtnConfirmar (estado loading)
- Reemplaza el label por `CircularProgressIndicator` 24dp blanco
- El ancho del botón no cambia (evita layout shift)
- Cursor: no interactuable

### Franja roja
- Propósito semiótico: señal de urgencia incluso antes de leer el contenido
- No es interactuable

---

## 7. Accesibilidad

- Al abrir el dialog, el foco se mueve automáticamente al título (semantics)
- Semantics label de BtnConfirmar: "Confirmar. Enviar alerta de emergencia a 3 personas."
- Semantics label de BtnCancelar: "Cancelar. Cerrar sin enviar alerta."
- Rol del dialog: `AlertDialog` de Material (announce en TalkBack/VoiceOver)
- El ícono NOTIFICATIONS_ACTIVE es decorativo (excludeFromSemantics: true)
