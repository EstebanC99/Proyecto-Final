# US-21 — Especificacion: Estado guardado con snackbar

## Objetivo
Confirmar visualmente al Responsable que los cambios de permisos del Cuidador
fueron persistidos con exito.

## Layout
Identico a 02-permisos-cuidador con la adicion del snackbar de exito.

## Snackbar de exito
- Posicion: bottom, margin 16px horizontal y 88px desde el fondo (por encima del boton)
- Bg: #323232
- Texto: "Permisos de Sandra actualizados" — 14px/500 blanco
- Icono: CHECK 20px en #2E9E5B a la izquierda del texto
- Border-radius: 8px
- Padding: 14px 16px
- Duracion: 3 segundos, luego fade out
- Animacion: slide-up desde el borde inferior

## Comportamiento del boton al guardar
1. Al tap: texto reemplazado por CircularProgressIndicator blanco 20px
2. Al exito: boton vuelve a texto normal, snackbar aparece
3. Al error: boton vuelve a texto normal, snackbar de error (bg #D14343)

## Accesibilidad
- El snackbar anuncia su contenido con role="status" (aria-live="polite")
- El icono CHECK tiene aria-hidden="true"
