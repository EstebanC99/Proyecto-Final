# 04 · Registro · Paso 1 — Estado de error (validación al blur)

> Variante de estado de [03]. Tokens en `00-identidad-visual.md`.

## Propósito
Mostrar cómo comunica el sistema los errores de validación field-by-field al perder el foco.

## Wireframe (email inválido + nombre vacío tras intentar "Continuar")

```
┌──────────────────────────────────────────────┐
│ ┌──┐                                           │
│ │← │                                           │
│ └──┘                                           │
│  ▰▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱▱▱        Paso 1 de 2        │
│                                                │
│  Creá tu cuenta                                │
│  Empecemos con tus datos personales.           │
│                                                │
│  Nombre                                        │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │   ← borde 2dp ERROR (#D14343)
│  ┃ 👤  Ej. María                           ┃   │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│  ⚠ Ingresá tu nombre.                          │   labelSmall, error, ícono 16dp
│                                                │
│  Apellido                                      │
│  ┌────────────────────────────────────────┐   │   ← reposo (válido: "González")
│  │ 👤  González                            │   │
│  └────────────────────────────────────────┘   │
│  ·                                             │
│                                                │
│  Email                                         │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │   ← borde 2dp ERROR
│  ┃ ✉  maria@correo                        ┃   │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│  ⚠ Ingresá un email válido.                    │   labelSmall, error
│                                                │
│  Teléfono                                      │
│  ┌────────────────────────────────────────┐   │   ← reposo (válido)
│  │ 📞  +54 9 11 1234 5678                  │   │
│  └────────────────────────────────────────┘   │
│  ·                                             │
│                                                │
│  ┌────────────────────────────────────────┐   │
│  │               Continuar                  │   │
│  └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones (deltas respecto a [03])

| Elemento | Estado error | Detalle |
|---|---|---|
| Campo inválido (caja) | Error | Borde **2 dp** color `error` (#D14343). Fondo sigue `surface`. El ícono prefijo NO cambia de color (mantener legibilidad); se evita teñir todo de rojo. |
| Texto de error | Visible | Aparece en la línea reservada bajo el campo: ícono ⚠ (`error_outline`) 16 dp color `error` + texto `labelSmall` color `error`. Animación fade + slide-down 4 dp, 150 ms. |
| Campo válido | Reposo | Sin marca verde de "ok" (se evita ruido visual); simplemente vuelve a borde `outline`. |
| Botón "Continuar" | Sin cambio visual | Permanece habilitado; al pulsarlo con errores, hace foco al **primer** campo inválido (Nombre en el ejemplo) y revela todos los errores existentes. |

## Interacciones y comportamiento
- **Disparo del error:** al hacer **blur** sobre un campo cuyo valor no cumple la regla.
  También al pulsar "Continuar" con campos inválidos/vacíos (validación global del paso).
- **Resolución en vivo:** una vez que un campo está en error, su validación pasa a ser **reactiva
  al escribir** (on-change): apenas el valor se vuelve válido, el error desaparece y el borde
  vuelve a `outline`. Esto da feedback inmediato de corrección sin esperar otro blur.
- **Accesibilidad:**
  - El campo en error expone `errorText` semántico → el lector de pantalla anuncia el mensaje.
  - El estado no se comunica solo por color (borde rojo): siempre hay ícono ⚠ + texto.
  - Al pulsar "Continuar" con errores, se mueve el foco al primer campo inválido y se anuncia
    su mensaje.
- **No avance:** mientras exista al menos un error, "Continuar" no navega a Paso 2.

## Estados alternativos
- Reposo / con datos válidos → [03].
- Múltiples campos en error simultáneo: cada uno muestra su propia línea de error; el layout no
  salta porque la línea ya está reservada (18 dp).

## Navegación
- Igual que [03]. No hay navegación de salida mientras haya errores no resueltos al intentar avanzar.
