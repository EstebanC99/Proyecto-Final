# US-20 — Pantalla: Cuidador agregado exitosamente

## Objetivo
Confirmar al responsable que el cuidador fue agregado al equipo y tiene acceso a las funciones autorizadas, con un mensaje claro antes de volver a la lista del equipo.

## Layout (jerarquía de componentes)
```
StatusBar (28px, dark)
AppBar (sin ARROW_BACK en esta pantalla — navegacion solo por boton)
  └─ (sin titulo, pantalla de exito no necesita AppBar con back)

Content (centrado vertical y horizontalmente en el area disponible)
  ├─ SuccessCircle
  │    └─ Circulo 112px bg #D8F0E1
  │         └─ CHECK_CIRCLE 80px color #2E9E5B (centrado)
  │
  ├─ Título "Cuidador agregado" (22px bold #16201F, text-align center, mt 24px)
  │
  └─ Cuerpo
       "Laura Méndez ya puede acceder a las funciones autorizadas
        para el cuidado de Alicia."
       (15px #566060, text-align center, mt 12px, padding 0 24px)
       "Laura Méndez" en bold #16201F

PrimaryButton "Volver al equipo" (fijo al fondo, margin 16px, height 56px)
```

## Especificacion del SuccessCircle
- Contenedor: width 112px, height 112px, border-radius 50%, background #D8F0E1
- Icono: CHECK_CIRCLE 80px, color #2E9E5B, centrado
- Margin-bottom: 0 (el titulo lleva margin-top)

## Especificacion tipografica
- Titulo: font-size 22px, font-weight 700, color #16201F
- Cuerpo: font-size 15px, font-weight 400, color #566060, line-height 1.5
- Nombre resaltado en el cuerpo: font-weight 700, color #16201F (inline)

## Navegacion
- Boton "Volver al equipo": navega a la lista "Mi equipo" usando `go_router` con `goNamed` (replace, no push). No se puede volver a esta pantalla con el boton fisico de Android.
- No hay ARROW_BACK en el AppBar para evitar que el usuario vuelva al formulario ya enviado.

## Interacciones
- La pantalla no tiene elementos interactivos salvo el boton.
- No hay auto-redirect: el usuario controla cuando volver.

## Notas de diseno
- La pantalla de exito es de celebracion leve (no confeti ni animaciones excesivas): el contexto de cuidado requiere sobriedad.
- El nombre del cuidador en el cuerpo personaliza el mensaje y confirma que se agrego la persona correcta.
- El nombre de la persona a cargo ("Alicia") cierra el ciclo de contexto iniciado en el formulario.
