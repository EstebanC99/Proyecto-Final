# US-26 — Pantalla: Confirmar eliminación de evento

## Objetivo
Solicitar confirmación explícita antes de eliminar un evento futuro de la agenda.
Evitar eliminaciones accidentales, especialmente considerando usuarios apurados o
con menor familiaridad tecnológica.

## Layout (jerarquía de componentes)

```
[Fondo: pantalla de agenda atenuada con overlay rgba(0,0,0,0.4)]
  └── EventCard resaltada (sin opacity, borde #0284C7 2px)

Dialog M3 (centrado vertical y horizontal)
  bg #FFFFFF, radius 28px, padding 24px, margin 24px horizontal
  ├── WARNING icon 24px, color #E0A100 (centrado)
  ├── Título "¿Eliminar este evento?" (18px bold #16201F, centrado)
  ├── Cuerpo 14px #566060 centrado:
  │     "Toma de medicación · 10 jun · 09:00
  │      El evento y su recordatorio se eliminarán.
  │      Esta acción no se puede deshacer."
  ├── gap 20px
  ├── Botón "Eliminar evento"
  │     (bg #D14343, text #FFFFFF, radius 12px, height 44px, full-width)
  └── Botón "Cancelar"
        (bg #FFFFFF, border 1px #C5CECE, text #16201F, radius 12px, height 44px, full-width)
        margin-top 8px
```

## Estados

| Estado | Descripción |
|--------|-------------|
| Default | Dialog visible con ambos botones activos |
| Cargando (eliminar) | Botón "Eliminar evento" muestra spinner inline; "Cancelar" deshabilitado |

## Interacciones

- Tap "Eliminar evento": inicia eliminación → estado cargando → cierra dialog → SnackBar → lista actualizada
- Tap "Cancelar": cierra dialog sin cambios → vuelve a la lista tal como estaba
- Tap fuera del dialog (en el scrim): equivale a "Cancelar"
- Back del sistema: equivale a "Cancelar"

## Anotaciones de diseño

1. El ícono WARNING en amarillo (#E0A100) señala destructividad sin generar alarma excesiva.
   El rojo queda reservado solo para el botón de acción, donde el costo real ocurre.
2. El cuerpo del dialog repite nombre, fecha y hora del evento: el usuario confirma que es
   el correcto, especialmente si llegó por un long press accidental.
3. Los botones están ordenados: destructivo arriba, cancelar abajo. El botón arriba tiene
   mayor jerarquía visual; el orden coincide con el patrón M3 para dialogs de confirmación.
4. Solo eventos futuros son eliminables; los vencidos se mantienen en el histórico.
