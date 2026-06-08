# 05 · Error — email no registrado

> Estado de error de `01-solicitar-email` cuando el servidor no encuentra el email.
> Tokens en `00-sistema-diseno.md`. HTML: `html/04-error-email-no-registrado.html`.

## Propósito

Informar al usuario que el email ingresado no está asociado a ninguna cuenta en CareWell, sin
revelar información sensible sobre si el email existe en el sistema para otros usuarios.
El diseño mantiene la misma pantalla `01-solicitar-email` con un banner de error agregado.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ← Recuperar contraseña                        │   AppBar surface (#FFFFFF)
│                                                │
│ ┌────────────────────────────────────────────┐│   InlineErrorBanner
│ │ [!] No encontramos una cuenta con ese      ││   fondo errorContainer (#FBE3E3)
│ │     email. Verificá que sea el correcto.   ││   borde error (#D14343) 1 dp
│ └────────────────────────────────────────────┘│   ícono ERROR 20 dp
│                                                │
│   Recuperar contraseña                         │   headlineMedium · textPrimary
│   Ingresá el email asociado a tu cuenta        │
│   y te enviaremos un link para restablecer     │   bodyMedium · textSecondary
│   tu contraseña.                               │
│                                                │
│   Email                                        │
│   ┌────────────────────────────────────────┐  │
│   │ ✉  notiene@cuenta.com                  │  │   AppTextField con valor · sin error de campo
│   └────────────────────────────────────────┘  │
│   (helper reservado 18 dp — vacío)             │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │              Enviar link               │  │   PrimaryButton · habilitado
│   └────────────────────────────────────────┘  │
│                                                │
│              Volver al inicio de sesión         │   SecondaryTextButton · centrado
│                                                │
└──────────────────────────────────────────────┘
```

## Diferencias respecto a `01-solicitar-email`

| Elemento | Estado normal | Estado error |
|---|---|---|
| Banner | ausente | `InlineErrorBanner` con ícono ERROR 20 dp y mensaje |
| Campo Email | placeholder gris | valor del email ingresado, borde normal (sin error de campo) |
| Helper del campo | reservado/vacío | reservado/vacío (el error es de banner, no de campo) |
| Botón | habilitado | habilitado (el usuario puede corregir y reintentar) |

## Componentes y especificaciones del banner

| Propiedad | Valor |
|---|---|
| Fondo | `errorContainer` #FBE3E3 |
| Borde | 1 dp `error` #D14343, radio 12 dp |
| Ícono | ERROR 20 dp, color `error` #D14343 |
| Texto | `bodyMedium` (14 sp), color `error` #D14343. "No encontramos una cuenta con ese email. Verificá que sea el correcto." |
| Posición | Insertado entre la AppBar y el título, margen 16 dp horizontal, margen superior 12 dp |
| Animacion | fade + slide-down 150 ms al aparecer |

## Decisiones de diseño

- **Error en banner, no en campo.** El campo tiene formato de email válido técnicamente; el
  error es del servidor (no hay cuenta). Marcar el campo como inválido confundiría al usuario
  haciéndole pensar que el formato es incorrecto.

- **El campo conserva el valor ingresado.** El usuario puede ver qué email usó y corregirlo
  si fue un typo, sin tener que escribirlo de nuevo.

- **Mensaje genérico, sin revelar datos.** No se distingue entre "email con formato incorrecto"
  y "email no registrado" desde el punto de vista del servidor. La decisión de usar
  "Verificá que sea el correcto" es intencional para no confirmar si el email existe o no.

- **El banner desaparece al editar el campo.** On-change en el campo Email, el banner se
  oculta (fade-out 150 ms) para que el reintento parta limpio.

## Interacciones y comportamiento

- **Editar el campo Email:** el banner de error desaparece on-change.
- **"Enviar link" con el mismo email corregido:** repite el ciclo de validación → carga → respuesta.
- **ARROW_BACK / "Volver al inicio de sesión":** pop → Login.

## Navegacion (de donde viene / a donde va)

- **Entrada:** `01-solicitar-email` → servidor responde email no encontrado (estado de la pantalla).
- **Salida:** el usuario corrige el email y reintenta (misma pantalla) o vuelve a Login.
