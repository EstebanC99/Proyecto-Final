# US-27 — Sistema de diseño: Notificaciones de la agenda

> Este flujo hereda el sistema de diseño del módulo Agenda definido en
> `care_well_doc/Interfaces/23 - Visualizacion de la agenda/00-sistema-diseno.md`.
> Acá se documentan las decisiones específicas del sistema de notificaciones locales.

---

## 1. Tokens heredados (módulo Agenda)

| Token           | Valor     | Uso en notificaciones                          |
|-----------------|-----------|------------------------------------------------|
| moduleColor     | #0284C7   | Chip "Recordatorio activo", ícono activo       |
| moduleContainer | #E0F2FE   | Fondo chip "Recordatorio activo"               |
| bg              | #F6F8F8   | Fondo de la pantalla de agenda                 |
| surface         | #FFFFFF   | Tarjetas de evento                             |
| textSecondary   | #566060   | Texto chips, metadatos                         |
| outline         | #C5CECE   | (usado en separadores)                         |

## 2. Tokens específicos de notificaciones

| Token                  | Valor            | Uso                                           |
|------------------------|------------------|-----------------------------------------------|
| chipActiveColor        | #0284C7          | Ícono y texto del chip con recordatorio activo|
| chipActiveBg           | #E0F2FE          | Fondo del chip con recordatorio activo        |
| chipInactiveColor      | #9AA5A5          | Ícono y texto del chip sin recordatorio       |
| chipInactiveBg         | #EDF1F1          | Fondo del chip sin recordatorio               |
| chipRadius             | 999px            | Pill shape para chips                         |
| chipPadding            | 4px 10px         | Interno del chip                              |
| chipFontSize           | 11px             | Texto del chip                                |
| notifCardBg            | rgba(255,255,255,0.15) | Card de notificación en lock screen      |
| notifCardRadius        | 16px             | Radio de la card de notificación              |
| notifCardPadding       | 14px 16px        | Padding de la card                            |
| notifCardMargin        | 16px             | Margen horizontal en lock screen              |
| lockScreenBg           | #16201F          | Color base del gradiente del lock screen      |

## 3. Componentes específicos de US-27

### NotificationStatusChip
Chip inline dentro de la EventCard que muestra el estado de la notificación.

```
Estado activo:
  bg: #E0F2FE, color: #0284C7
  [NOTIFICATIONS 14px] "Recordatorio activo"

Estado inactivo:
  bg: #EDF1F1, color: #9AA5A5
  [NOTIFICATIONS 14px] "Sin recordatorio"
```

- Tap en el chip navega a la pantalla de gestión del recordatorio de ese evento.
- Solo se muestra en eventos futuros. Los eventos vencidos no muestran chip de notificación.

### NotificationCard (Lock Screen)
Card flotante que simula la apariencia de una notificación del sistema en la pantalla de bloqueo.

```
bg: rgba(255,255,255,0.15)
border-radius: 16px
padding: 14px 16px
margin: 16px

Fila cabecera:
  [logo CareWell 24px] "CareWell" 13px bold  ·  "ahora" 12px
Separador 1px rgba(255,255,255,0.15)
Título notificación: 14px bold, color: #FFFFFF
Cuerpo: 13px rgba(255,255,255,0.8)
```

Logo CareWell inline: círculo 24px bg #1A8C82, letra "C" blanca 12px bold.

## 4. Mecanismo de notificaciones (especificación técnica para dev-flutter)

- Paquete: `flutter_local_notifications`
- Las notificaciones son **locales** (no push); se programan en el dispositivo al crear o
  editar un evento con recordatorio.
- Se envían a **todos los miembros del equipo con permisos** sobre la persona a cargo.
- Formato del título: "Recordatorio de salud — [Nombre de la persona]"
- Formato del cuerpo: "[Título del evento] · [hora]"
- Canal Android: ID `carewell_agenda`, importancia HIGH, sin sonido personalizado (usa el
  del sistema).
- Si el evento se elimina (US-26), la notificación programada debe cancelarse usando su ID.

## 5. Reglas de UX para notificaciones

1. Un usuario puede activar o desactivar el recordatorio de un evento individual
   sin eliminar el evento.
2. Los chips en la lista de agenda dan visibilidad inmediata del estado sin abrir el evento.
3. Tap en chip de "Sin recordatorio" lleva a activar el recordatorio (flujo de edición
   del evento, sección recordatorio pre-seleccionada).
4. Tap en chip de "Recordatorio activo" lleva a gestionar / desactivar el recordatorio.
