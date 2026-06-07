# US-26 — Sistema de diseño: Eliminación de evento de agenda

> Este flujo hereda el sistema de diseño del módulo Agenda definido en
> `Documentacion/Interfaces/23 - Visualizacion de la agenda/00-sistema-diseno.md`.
> Acá se documentan únicamente las decisiones específicas de la eliminación.

---

## 1. Tokens heredados (módulo Agenda)

| Token           | Valor     | Uso en eliminación                         |
|-----------------|-----------|--------------------------------------------|
| moduleColor     | #0284C7   | Color del módulo en pantalla de fondo      |
| moduleContainer | #E0F2FE   | Chip de contexto en fondo atenuado         |
| bg              | #F6F8F8   | Fondo de la pantalla de lista              |
| surface         | #FFFFFF   | Fondo del dialog de confirmación           |
| textPrimary     | #16201F   | Título del dialog                          |
| textSecondary   | #566060   | Cuerpo descriptivo del dialog              |
| outline         | #C5CECE   | Borde del botón "Cancelar"                 |
| error           | #D14343   | Fondo del botón destructivo "Eliminar"     |
| errorContainer  | #FBE3E3   | (reservado; no se usa en este flujo)       |

## 2. Tokens específicos de eliminación

| Token           | Valor     | Uso                                        |
|-----------------|-----------|--------------------------------------------|
| warningIcon     | #E0A100   | Color del ícono WARNING en el dialog       |
| dialogRadius    | 28px      | Border radius del dialog M3                |
| dialogPadding   | 24px      | Padding interno del dialog                 |
| dialogMargin    | 24px      | Margen horizontal respecto al borde        |
| overlayScrim    | rgba(0,0,0,0.4) | Fondo semitransparente sobre la agenda |
| btnDestructive  | #D14343   | Botón "Eliminar evento"                    |
| btnDestructiveText | #FFFFFF | Texto del botón destructivo               |
| btnCancel bg    | #FFFFFF   | Fondo del botón cancelar                   |
| btnCancel border| #C5CECE   | Borde del botón cancelar                   |
| btnCancel text  | #16201F   | Texto del botón cancelar                   |
| btnHeight       | 44px      | Altura de ambos botones del dialog         |
| btnRadius       | 12px      | Radio de los botones del dialog            |

## 3. Componente: ConfirmDeleteDialog

### Estructura
```
Dialog (bg #FFF, radius 28px, padding 24px, margin horizontal 24px)
  ├── Ícono WARNING centrado (24px, color #E0A100)
  ├── Título "¿Eliminar este evento?" (18px bold, centrado)
  ├── Cuerpo de descripción (14px #566060, centrado)
  │     "Nombre del evento · fecha · hora.
  │      El evento y su recordatorio se eliminarán.
  │      Esta acción no se puede deshacer."
  ├── Botón primario destructivo "Eliminar evento"
  │     (bg #D14343, text #FFF, radius 12px, height 44px, full-width)
  └── Botón secundario "Cancelar"
        (bg #FFF, border 1px #C5CECE, text #16201F, radius 12px, height 44px, full-width)
```

### Regla de negocio clave
- Solo eventos **futuros** pueden eliminarse. Los eventos vencidos son readonly y no exponen
  la acción eliminar en ningún punto de la UI (ni long press, ni menú contextual).
- Los eventos pasados se mantienen en el histórico como registro inmutable.

## 4. Overlay / scrim

- La pantalla de lista de agenda permanece visible debajo del scrim.
- El evento que se va a eliminar se muestra **resaltado** (sin opacity, sin blur) para que
  el usuario confirme visualmente qué evento está eliminando.
- El resto de tarjetas queda levemente atenuado por el scrim oscuro.

## 5. Feedback post-eliminación

- Al confirmar: el dialog se cierra, se muestra un `SnackBar` de confirmación:
  "Evento eliminado" (2 s, sin acción de deshacer en MVP).
- La tarjeta eliminada desaparece con animación de fade-out + slide-up (200 ms).
- Si la lista queda vacía, se transiciona al estado vacío de la agenda.
