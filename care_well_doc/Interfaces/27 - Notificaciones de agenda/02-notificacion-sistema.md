# US-27 — Pantalla: Notificación del sistema (lock screen)

## Objetivo
Documentar y especificar la apariencia de las notificaciones locales de CareWell tal como
las ve el usuario en la pantalla de bloqueo del dispositivo. Esta pantalla es una referencia
de diseño para el developer; no es una pantalla de la app propiamente dicha.

## Layout (jerarquía de componentes)

```
Lock Screen (390x844px)
  bg: gradiente lineal 135deg #16201F → #1E2E2D
  ├── Status bar (28px, iconos blancos)
  ├── Reloj grande "9:41" (48px bold, blanco, centrado)
  ├── Fecha "Jueves 5 de junio" (16px, rgba(255,255,255,0.75), centrado)
  ├── Separador visual (64px de espacio)
  ├── NotificationCard 1 (card flotante)
  │     [logo CareWell 24px]  CareWell  ·  ahora
  │     ─────────────────────────────────────
  │     Recordatorio de salud — Alicia
  │     Toma de medicacion · 09:00 AM
  ├── NotificationCard 2 (card flotante, debajo)
  │     [logo CareWell 24px]  CareWell  ·  hace 4 min
  │     ─────────────────────────────────────
  │     Recordatorio de salud — Alicia
  │     Cita medica · 15:30
  └── Indicador de desbloqueo (barra inferior blanca)
```

## Especificación de la NotificationCard

| Propiedad | Valor |
|-----------|-------|
| Fondo | rgba(255,255,255,0.15) |
| Border radius | 16px |
| Padding | 14px 16px |
| Margen horizontal | 16px |
| Gap entre cards | 8px |

### Fila de cabecera
- Logo CareWell: círculo 24px bg #1A8C82, letra "C" blanca 12px bold
- App name "CareWell": 13px bold, blanco
- Separador " · ": rgba(255,255,255,0.5)
- Timestamp "ahora": 12px, rgba(255,255,255,0.6)
- Todo en flexbox row, align-items: center

### Separador
- 1px, rgba(255,255,255,0.15), margin vertical 8px

### Cuerpo
- Título: 14px bold, color #FFFFFF
  Formato: "Recordatorio de salud — [Nombre persona]"
- Subtítulo: 13px, rgba(255,255,255,0.8)
  Formato: "[Titulo evento] · [hora]"

## Interacciones en lock screen (comportamiento nativo)

- Tap en la card: el sistema desbloquea y abre la app en el evento correspondiente.
- Deslizar izquierda: descarta la notificación.
- Long press: muestra opciones del sistema (gestionar notificaciones de CareWell).

## Anotaciones de diseño

1. Esta pantalla es de referencia/documentación. El developer no implementa la lock screen;
   la controla el SO. Lo que se implementa es el contenido de la notificación via
   `flutter_local_notifications`.
2. Las notificaciones locales no requieren conexión a internet.
3. Se envían a todos los miembros del equipo con permisos (sincronización en MVP solo local).
