# 03 · Dialog — Confirmar eliminacion de cuenta

> Dialog de confirmacion modal sobre la pantalla de Configuracion.
> Tokens en `00-sistema-diseno.md`. HTML: `html/02-confirmar-eliminacion.html`.

## Proposito

Solicitar confirmacion explicita e informada antes de ejecutar la eliminacion de cuenta.
El patron de tipeo de "DELETE" crea friccion intencional proporcional a la irreversibilidad
de la accion. Cumple el principio de consentimiento activo requerido por la
Ley 25.326 de Proteccion de Datos Personales (Argentina).

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐
│ (Configuracion atenuada — overlay rgba 0.4)  │
│                                              │
│         ┌──────────────────────────┐         │
│         │                          │         │
│         │     [!] WARNING 24dp     │         │   icono warning #E0A100
│         │                          │         │
│         │  ¿Eliminar tu cuenta?    │         │   18px 700
│         │                          │         │
│         │  Esta accion es          │         │   14px #566060
│         │  irreversible. Se        │         │
│         │  eliminaran todos tus    │         │
│         │  datos, personas a cargo │         │
│         │  y membresias en equipos │         │
│         │  de cuidado. No podras   │         │
│         │  recuperar tu cuenta.    │         │
│         │                          │         │
│         │  ┌──────────────────┐    │         │
│         │  │ Escribi DELETE   │    │         │   AppTextField, placeholder
│         │  └──────────────────┘    │         │   borde outline #C5CECE
│         │                          │         │
│         │  ┌──────────────────┐    │         │
│         │  │ Eliminar mi cta  │    │         │   disabled: bg #C5CECE / activo: #D14343
│         │  └──────────────────┘    │         │
│         │                          │         │
│         │       Cancelar           │         │   texto simple, 48dp tactil
│         │                          │         │
│         └──────────────────────────┘         │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Scrim | `rgba(0,0,0,0.4)` cubriendo toda la pantalla de Configuracion. No es tappable para descartar. |
| 2 | Dialog container | Fondo `surface #FFFFFF`. Border-radius 28 dp. Margin horizontal 24 dp. Padding 24 dp. Elevacion M3 nivel 3 (sombra leve). |
| 3 | Icono WARNING | SVG Material inline, 24 dp, color `warning #E0A100`, alineado centrado. |
| 4 | Titulo | "¿Eliminar tu cuenta?" · 18 px · 700 · `textPrimary #16201F` · centrado. |
| 5 | Cuerpo | 14 px · 400 · `textSecondary #566060` · interlineado 1.5. La palabra "irreversible" aparece en bold. |
| 6 | Campo DELETE | AppTextField con placeholder "DELETE". Alto 56 dp. Borde outline 1 dp `outline`. Border-radius 12 dp. Fuente monospace o sans-serif standard. Validacion on-change. |
| 7 | Boton destructivo (disabled) | "Eliminar mi cuenta" · alto 56 dp · bg `outline #C5CECE` · texto `textDisabled #9AA5A5` · border-radius 16 dp. |
| 8 | Boton destructivo (activo) | "Eliminar mi cuenta" · alto 56 dp · bg `error #D14343` · texto blanco · border-radius 16 dp. Solo visible cuando campo == "DELETE". |
| 9 | Boton cancelar | "Cancelar" · alto 48 dp · sin fondo · texto `textSecondary #566060` · centrado · full width. |

## Logica de habilitacion del boton

```
campo.text.trim() == "DELETE"
  ? boton.enabled = true  (bg #D14343)
  : boton.enabled = false (bg #C5CECE)
```

La comparacion es case-sensitive. Espacios al inicio o al final no se aceptan.
No hay mensaje de error inline; la habilitacion del boton es el unico feedback.

## Estados del dialog

| Estado | Campo | Boton destructivo | Notas |
|---|---|---|---|
| Inicial | vacio, placeholder visible | disabled (#C5CECE) | Solo "Cancelar" activo |
| Escribiendo incompleto | texto parcial | disabled (#C5CECE) | Sin feedback adicional |
| Listo para confirmar | "DELETE" exacto | activo (#D14343) | Ambos botones disponibles |
| Cargando | bloqueado, readonly | spinner blanco sobre #D14343 | Cancelar tambien deshabilitado |
| Error de red | desbloqueado, texto conservado | activo (#D14343) | Toast: "No se pudo eliminar" |

## Navegacion

- **Entrada:** showDialog desde Configuracion al tap "Eliminar cuenta".
- **Salida positiva:** tap "Eliminar mi cuenta" (campo correcto) → loading → go('/login') + SnackBar.
- **Salida negativa:** tap "Cancelar" → dismiss dialog, Configuracion sin cambios.
- **Salida back:** gesto/boton back del sistema → dismiss dialog, Configuracion sin cambios.
