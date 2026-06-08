# US-34 Emergencia — Pantalla de alerta enviada

## 1. Objetivo

Confirmar al usuario que la alerta fue enviada exitosamente, mostrando de forma nominal quién
fue notificado y el timestamp del envío. No ofrecer acción primaria que invite al reenvío.

---

## 2. Archivo HTML de referencia

`html/03-alerta-enviada.html`

---

## 3. Layout

```
StatusBar (28 dp, fondo #16201F)
(Sin AppBar — pantalla de confirmación terminal)

Fondo: #FFFFFF

CuerpocentradoCentral (padding 32px, column, centrado horizontal)
  ├─ SuccessIcon
  │   └─ Círculo 88dp (bg #D8F0E1)
  │       └─ CHECK_CIRCLE 48dp #2E9E5B
  ├─ Título "Alerta enviada" (24px 700 #16201F, margin-top 20px)
  ├─ BodyText (16px #566060, centrado, margin-top 8px)
  │   "3 personas fueron notificadas. Permanecé donde estás
  │    si es seguro hacerlo."
  ├─ NotificadosCard (bg #F6F8F8, radius 12px, padding 16px, margin 16px 0)
  │   ├─ PersonRow: PERSON 16px #2E9E5B · "María García" · "Responsable" + CHECK 16px #2E9E5B
  │   ├─ PersonRow: PERSON 16px #2E9E5B · "Carlos Pérez" · "Responsable" + CHECK 16px #2E9E5B
  │   └─ PersonRow: PERSON 16px #2E9E5B · "Laura Méndez" · "Cuidadora" + CHECK 16px #2E9E5B
  └─ Timestamp "Alerta enviada a las 14:32:07" (12px #9AA5A5, centrado, margin-top 8px)

Bottom (padding-bottom 32px, alineado al fondo)
  └─ BtnVolverInicio (outline teal, texto "Volver al inicio", alto 52dp, radius 16px, full-width)
```

---

## 4. Estado único

Esta pantalla tiene un solo estado: la alerta fue enviada. No hay estado de error aquí porque
el error se maneja en el dialog de confirmación. Si hubo error de red, el usuario nunca llega
a esta pantalla.

---

## 5. Interacciones

| Elemento | Acción | Resultado |
|---|---|---|
| BtnVolverInicio | tap | Navega a Menú principal (limpia el stack de navegación con `go()`) |
| Gesto back del sistema | swipe / botón | Igual que BtnVolverInicio (va al Menú principal, no a la pantalla de emergencia) |

---

## 6. Especificaciones de componentes

### SuccessIcon
- El círculo usa `#D8F0E1` como fondo (token `successContainer`)
- El ícono CHECK_CIRCLE usa `#2E9E5B` (token `success`)
- Entrada con animación `fade-in-up` 0.4 s ease-out al montar la pantalla

### BtnVolverInicio
- Tipo: outlined button (borde 2px `#1A8C82`, texto `#1A8C82`, fondo transparente)
- Alto: 52 dp (ligeramente mayor que el mínimo para facilitar el toque post-stress)
- No hay botón primario en esta pantalla (decisión deliberada anti-reenvío)

### NotificadosCard
- Los checks verdes confirman que cada persona recibió la notificación
- Divisor entre filas: 1px `#EDF1F1` (excepto última fila)
- Cada fila: altura mínima 40 dp

### Timestamp
- Muestra la hora exacta del servidor (no del dispositivo) en formato HH:mm:ss
- Sirve como registro informal para el usuario (puede usar para comunicarlo al equipo de salud)

---

## 7. Navegación

- Esta pantalla se monta con `context.go('/home')` equivalente: reemplaza el stack completo.
- No existe un "back" que lleve a la pantalla de emergencia desde aquí.
- Razón: evitar que el usuario reenvíe la alerta por error al usar el botón de back del sistema.

---

## 8. Accesibilidad

- Al montar esta pantalla, el foco va automáticamente al título "Alerta enviada"
- Semantics del SuccessIcon: "Alerta enviada exitosamente"
- Semantics de BtnVolverInicio: "Volver al menú principal"
- La lista de notificados usa un `Semantics` con label compuesto por nombre y rol de cada persona
- Contraste de texto sobre #F6F8F8: todos los colores cumplen ratio mínimo 4.5:1
