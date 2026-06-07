# 32 · Agregar nota [02]

> Pantalla modal para redactar y guardar una nota en un evento de salud.
> Tokens en `00-sistema-diseno.md`. HTML: `html/02-agregar-nota.html`.

## Propósito
Permitir a un miembro del equipo de cuidado escribir y guardar una nota de texto libre
sobre un evento de salud específico. El autor y el timestamp se asignan automáticamente
por el servidor; el usuario solo escribe el contenido.

## Wireframe (ASCII)

```
┌────────────────────────────────────────────┐  ← background #F6F8F8
│ 9:41                               5G 100% │   status bar #16201F
│ [←]  Nueva nota                            │   AppBar
│──────────────────────────────────────────  │
│ ┌──────────────────────────────────────┐   │
│ │ [doc] Agregando nota a:              │   │   card contexto bg #FFF1F2
│ │       Control cardiológico           │   │   icono DESCRIPTION #E11D48
│ │       · 2 jun 2026                   │   │   texto 13dp textSecondary
│ └──────────────────────────────────────┘   │
│                                             │
│  Nota *                                     │   label 13dp + asterisco #E11D48
│ ┌──────────────────────────────────────┐   │
│ │ Escribí tu observación sobre este    │   │   textarea outline
│ │ evento...                            │   │   h min 120dp radius 12
│ │                                      │   │   borde #C5CECE
│ │                                      │   │
│ └──────────────────────────────────────┘   │
│                                             │
│ ┌──────────────────────────────────────┐   │
│ │          Guardar nota                │   │   PrimaryButton bg #E11D48
│ └──────────────────────────────────────┘   │   56dp radius 16
└────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | AppBar | Bg `surface #FFF`, height `56 dp`. Ícono ARROW_BACK 24 dp izquierda. Título "Nueva nota" `16 dp bold textPrimary`. |
| 2 | Card de contexto | Bg `#FFF1F2`, radius `8 dp`, padding `12 dp`, margin `16 dp`. Fila: ícono DESCRIPTION `16 dp #E11D48` + texto "Agregando nota a: **[nombre evento]** · [fecha]" `13 dp textSecondary`. |
| 3 | Label del campo | "Nota" `13 dp` peso 500 `textSecondary` + asterisco `#E11D48`. Margen inferior `6 dp`. |
| 4 | Textarea | Bg `surface #FFF`, borde `1 dp #C5CECE`, radius `12 dp`, padding `12 dp 16 dp`. Alto mínimo `120 dp`, crece con el contenido. Placeholder "Escribí tu observación sobre este evento..." `textDisabled`. Focus: borde `2 dp #E11D48`. |
| 5 | Contador de caracteres | Aparece bajo el textarea (alineado derecha, `11 dp textDisabled`) cuando el texto supera los 400 caracteres. Formato: "420/500". Al alcanzar 500: contador rojo `#E11D48`. |
| 6 | Botón "Guardar nota" | Full-width, `56 dp`, radius `16 dp`, bg `#E11D48`, texto blanco `16 dp bold`. Margin-top `20 dp`. Estado loading: spinner blanco centrado, textarea disabled. |

## Estados

| Estado | Descripción | Diferencia visual |
|---|---|---|
| Inicial vacío | Campo sin texto | Placeholder visible, botón activo (color) |
| Redactando | Campo con texto | Placeholder oculto, texto `textPrimary` |
| Error vacío | "Guardar" con campo vacío | Borde textarea `2 dp #E11D48` + mensaje "La nota no puede estar vacía." `12 dp #E11D48` bajo el campo |
| Guardando | Petición en curso | Botón → spinner, textarea disabled, card contexto sin cambios |
| Error de guardado | Fallo de red o 5xx | Banner `InlineErrorBanner` con "No se pudo guardar la nota." + botón "Reintentar" |

## Interacciones y comportamiento

- **ARROW_BACK con campo con texto:** diálogo de confirmación modal "Tenés cambios sin guardar.
  ¿Salir de todas formas?" con opciones "Cancelar" y "Salir". Si el campo está vacío, vuelve
  directamente sin diálogo.
- **Tap fuera del textarea:** cierra el teclado. El contenido se preserva.
- **"Guardar nota" con campo vacío:** error inline, sin petición al servidor.
- **"Guardar nota" con texto:** inicia estado Guardando. Al recibir 201, hace pop y muestra
  un `SnackBar` de confirmación "Nota guardada" en la pantalla de detalle del evento.
- **Límite de 500 caracteres:** el campo bloquea la entrada al llegar al máximo.

## Navegación

- **Entrada:** desde Detalle de evento [01] mediante tap en FAB "+". Presentado como sheet modal
  (slide-up desde el borde inferior, 300 ms).
- **Salida:** ARROW_BACK o guardado exitoso → Detalle de evento [01] con la nueva nota visible.
