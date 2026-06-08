# 07 · Bottom Sheet — Términos y Condiciones

> Overlay modal sobre el Paso 2 [05]. Componente `AppBottomSheet`. Tokens en `00-identidad-visual.md`.

## Propósito
Mostrar el texto completo de Términos y Condiciones / Política de Privacidad sin sacar al usuario
del flujo de registro, permitiéndole aceptarlos desde el mismo lugar.

## Wireframe (bottom sheet expandido sobre el Paso 2)

```
┌──────────────────────────────────────────────┐
│░░░░░░░░░░ scrim negro @40% (Paso 2) ░░░░░░░░░░│
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│┌────────────────────────────────────────────┐│  ← AppBottomSheet, surface,
││                 ──────                       ││    esquinas sup. radiusXl(28), elev2
││              (grabber 40x4)                  ││    grabber outline, centrado
││                                              ││
││  Términos y Condiciones                  ✕   ││  titleLarge + botón cerrar 48dp
││ ─────────────────────────────────────────── ││  divider outline 1dp
││                                              ││
││  Última actualización: 04/06/2026            ││  labelSmall textSecondary
││                                              ││
││  1. Aceptación                               ││  titleMedium textPrimary
││  Al crear una cuenta en CareWell aceptás...  ││  bodyLarge textPrimary
││  (texto largo, scrolleable verticalmente)    ││
││                                              ││
││  2. Uso de los datos                         ││  ▲ scroll dentro del sheet
││  CareWell centraliza información sensible...  ││  ┃
││  ...                                         ││  ▼
││                                              ││
││  3. Privacidad                               ││
││  ...                                         ││
││ ─────────────────────────────────────────── ││  divider (zona acciones fija)
││  ┌────────────────────────────────────────┐ ││
││  │          Aceptar y continuar            │ ││  PrimaryButton full-width
││  └────────────────────────────────────────┘ ││
││            Cerrar sin aceptar                ││  SecondaryTextButton centrado
│└────────────────────────────────────────────┘│
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Scrim | Negro @ 40% sobre el Paso 2; tap en el scrim = "Cerrar sin aceptar". |
| 2 | Contenedor sheet | `surface`, esquinas superiores `radiusXl (28)`, `elev2`. Altura inicial ~90% de la pantalla (modal alto, casi full). Arrastrable hacia abajo para cerrar. |
| 3 | Grabber | Barra 40x4 dp `outline`, centrada, margen superior 12 dp. Indica que se puede arrastrar. |
| 4 | Encabezado | Título "Términos y Condiciones" `titleLarge` `textPrimary` a la izquierda; botón ✕ (`close`, 24 dp) a la derecha, objetivo táctil 48 dp. Debajo, divider `outline` 1 dp. |
| 5 | Metadato | "Última actualización: dd/mm/aaaa" `labelSmall` `textSecondary`. |
| 6 | Cuerpo scrolleable | Contenido de T&C: encabezados de sección `titleMedium`, párrafos `bodyLarge` `textPrimary`, interlineado cómodo. Padding horizontal 24 dp. Scroll vertical independiente del fondo. |
| 7 | Zona de acciones (fija) | Anclada al fondo del sheet (no scrollea con el cuerpo), con divider superior. Contiene botón primario + botón texto. |
| 8 | Botón "Aceptar y continuar" | `PrimaryButton` full-width. Al pulsar: **marca el checkbox de T&C** del Paso 2 y cierra el sheet. |
| 9 | "Cerrar sin aceptar" | `SecondaryTextButton`. Cierra el sheet **sin** marcar el checkbox. |

## Interacciones y comportamiento
- **Apertura:** desde el tap en el link "Términos y Condiciones" o "Política de Privacidad" del
  Paso 2 [05]. Animación slide-up M3.
- **"Aceptar y continuar":** cierra el sheet y deja el checkbox de T&C **marcado** en el Paso 2;
  si había un error de T&C, se limpia.
- **"Cerrar sin aceptar" / ✕ / tap en scrim / swipe-down:** cierra el sheet sin cambiar el estado
  del checkbox.
- **Scroll:** el cuerpo es scrolleable; las acciones permanecen visibles siempre (zona fija) para
  que el usuario no tenga que llegar al final para aceptar. (Decisión de accesibilidad: no se exige
  "scroll hasta el fondo" para habilitar Aceptar, porque penaliza a usuarios con baja afinidad
  tecnológica; el contenido queda igualmente accesible.)
- **Foco/accesibilidad:** al abrir, el foco va al título del sheet; al cerrar, vuelve al elemento
  que lo abrió (link T&C). El sheet atrapa el foco (focus trap) mientras está abierto. Anunciado
  como diálogo modal.

## Estados alternativos
- **Carga del contenido:** si el texto de T&C viniera de remoto, mostrar skeleton de 3–4 líneas
  en la zona de cuerpo mientras carga; si falla, mensaje "No pudimos cargar los Términos. Reintentar."
  Para el MVP el texto puede ser local/estático → sin estado de carga.

## Navegación
- **Entrada:** desde Paso 2 [05] (links de T&C / Política).
- **Salida:** siempre vuelve al Paso 2 [05], con o sin checkbox marcado según la acción elegida.
