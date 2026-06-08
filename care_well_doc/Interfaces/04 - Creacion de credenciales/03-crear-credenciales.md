# 03 · Creacion de credenciales — Formulario

> Pantalla de ingreso de contraseña. Tokens en `00-sistema-diseno.md`.
> HTML: `html/02-crear-credenciales.html`.

## Proposito
Permitir que el usuario elija una contraseña segura para su cuenta, confirmarla y aceptar
los Terminos y Condiciones, con el menor numero de pasos posible y con ayuda visual (medidor
de fortaleza) para personas poco familiarizadas con requisitos de seguridad.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ←  Creá tu contraseña                         │   AppBar minimal: ARROW_BACK + titulo
├──────────────────────────────────────────────┤
│                                               │
│  Tu email de acceso sera                      │   labelSmall textSecondary
│  maria@ejemplo.com                            │   bodyMedium bold textPrimary
│                                               │
│  Nueva contraseña                             │   field-label
│  ┌──────────────────────────────────────────┐ │
│  │ LOCK  ••••••••••••             VISIBILITY │ │   AppTextField foco · 56 dp
│  └──────────────────────────────────────────┘ │
│  [███████████████████████] Fuerte             │   PasswordStrengthMeter 3/3 verde
│                                               │
│  Confirmar contraseña                         │   field-label
│  ┌──────────────────────────────────────────┐ │
│  │ LOCK  ••••••••••••                        │ │   AppTextField reposo · 56 dp
│  └──────────────────────────────────────────┘ │
│                                               │
│  [ ] Acepto los Terminos y Condiciones        │   Checkbox + link
│                                               │
│  ┌──────────────────────────────────────────┐ │
│  │            Crear acceso                   │ │   PrimaryButton (disabled si T&C no marcado)
│  └──────────────────────────────────────────┘ │
│                                               │
└───────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | AppBar | Altura 56 dp. Fondo `surface` (#FFF). ARROW_BACK 24 dp a la izquierda (objetivo tactil 48 dp). Titulo "Creá tu contraseña" `titleMedium` (18 px, 600) color `textPrimary`. Sin acciones a la derecha. |
| 2 | Email de solo lectura | Grupo de dos lineas: "Tu email de acceso sera" (`labelSmall` 12 px `textSecondary`) + valor del email (`bodyMedium` 14 px bold `textPrimary`). Margen top 24 dp desde AppBar. No es un campo editable. |
| 3 | Campo "Nueva contraseña" | `AppTextField` foco inicial. Prefijo LOCK 20 dp. Sufijo VISIBILITY 20 dp (toggle ver/ocultar). Tipo password. Placeholder "Ingresá tu contraseña". |
| 4 | PasswordStrengthMeter | 3 segmentos de color progresivo debajo del campo "Nueva contraseña": Debil (1/3, `error` #D14343) · Media (2/3, `warning` #E0A100) · Fuerte (3/3, `success` #2E9E5B). Label de texto a la derecha del medidor ("Debil" / "Media" / "Fuerte"). Aparece al escribir el primer caracter. |
| 5 | Campo "Confirmar contraseña" | `AppTextField` reposo. Prefijo LOCK 20 dp. Sin sufijo de visibilidad (oculto siempre; el usuario ya vio la contraseña en el campo anterior). Placeholder "Repetí tu contraseña". |
| 6 | Checkbox T&C | Fila horizontal: checkbox SVG 22×22 dp + texto "Acepto los **Terminos y Condiciones**" (`bodyMedium` 14 px). "Terminos y Condiciones" en bold color `primary`, tappable (abre bottom-sheet). Objetivo tactil de toda la fila >= 48 dp. |
| 7 | Boton "Crear acceso" | `PrimaryButton` full-width 56 dp radio 16. Estado **disabled** (fondo `outline` #C5CECE, texto `textDisabled`) si el checkbox T&C no esta marcado. Estado reposo (fondo `primary`) cuando T&C esta marcado. |

## Interacciones y comportamiento

### Validaciones al pulsar "Crear acceso"
1. "Nueva contraseña" vacio → error inline debajo del campo: "Ingresá una contraseña".
2. "Confirmar contraseña" vacio → error inline: "Confirmá tu contraseña".
3. Las contraseñas no coinciden → error inline debajo de "Confirmar contraseña":
   "Las contraseñas no coinciden". El campo se marca con borde `error`.
4. T&C no marcado → boton esta `disabled`, no llega a esta validacion.
5. Todo OK → pasa a estado Cargando [03].

### Comportamiento de campos
- **Toggle VISIBILITY:** alterna mostrar/ocultar en "Nueva contraseña". El icono cambia
  a `visibility_off` cuando la contraseña es visible. "Confirmar contraseña" permanece
  siempre oculto para forzar la confirmacion manual.
- **PasswordStrengthMeter:** se actualiza en tiempo real mientras el usuario escribe.
  No bloquea el envio aunque la fortaleza sea baja (es informativo, no restrictivo).
- **Checkbox T&C:** al marcarlo, el boton "Crear acceso" transiciona de disabled a enabled
  con fade 150 ms.
- **Tap en "Terminos y Condiciones":** abre un bottom-sheet (heredado de US-01 §5.6) con
  el texto completo. No cierra el formulario.
- **Limpieza de errores:** los errores inline desaparecen al editar el campo correspondiente
  (on-change, no al blur).

### Accesibilidad
- Campos con `textInputAction: next` (teclado muestra "Siguiente" entre campos; en el ultimo
  campo muestra "Listo").
- El email de solo lectura tiene `semanticsLabel` explicito para lectores de pantalla.
- El checkbox es tappable en toda la fila (no solo el cuadro).

## Estados alternativos

| Estado | Descripcion |
|---|---|
| Reposo inicial | Campos vacios, checkbox desmarcado, boton disabled. |
| Escribiendo | PasswordStrengthMeter visible, boton aun disabled hasta marcar T&C. |
| T&C marcado | Boton pasa a enabled (`primary`). |
| Error de validacion | Borde `error` en campo(s) invalidos + mensaje inline. |
| Cargando | Ver pantalla [03]. |

## Navegacion (de donde viene / a donde va)
- **Entrada:** desde Deteccion [01] via tap "Crear mi contraseña" (push).
- **Salida:** Cargando [03] (validacion OK) o Deteccion [01] (ARROW_BACK / back del sistema).
