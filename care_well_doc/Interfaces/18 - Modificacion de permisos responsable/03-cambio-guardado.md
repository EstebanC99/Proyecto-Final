# US-18 — Pantalla: Permisos guardados (snackbar de confirmación)

## Objetivo
Confirmar visualmente al usuario que los cambios de permisos fueron guardados exitosamente, sin interrumpir el flujo ni cambiar de pantalla.

## Layout
Idéntico a `02-permisos-responsable.md` con el siguiente elemento adicional superpuesto:

```
Snackbar (position: fixed, bottom: 96px, left: 16px, right: 16px)
  ├─ Icono CHECK 20px (color #2E9E5B)
  ├─ Texto "Permisos de Carlos actualizados" (14px, #FFFFFF)
  └─ (sin botón de acción, auto-dismiss 3 s)
```

## Especificación del Snackbar
- Background: #323232
- Border-radius: 12px
- Padding: 14px 16px
- Display: flex, align-items: center, gap: 10px
- Elevación: sombra sutil (box-shadow: 0 4px 12px rgba(0,0,0,0.25))
- Posicionado 16px por encima del botón "Guardar cambios"
- Auto-dismiss: 3 segundos con fade-out
- No desplaza el contenido de la pantalla

## Estados de botón durante el guardado
1. **Guardando**: bg #1A8C82 opacidad 0.7, spinner circular blanco 20px, texto oculto, toggles pointer-events:none.
2. **Guardado** (al recibir 200): botón vuelve al estado normal, snackbar aparece.
3. **Error** (al recibir 4xx/5xx): snackbar rojo "No se pudo guardar. Intentá de nuevo."

## Interacciones
- El snackbar no bloquea interacción con la pantalla.
- El usuario puede seguir modificando toggles mientras el snackbar es visible.
- Tocar el snackbar no hace nada (no es dismissible por tap en este estado de éxito).
