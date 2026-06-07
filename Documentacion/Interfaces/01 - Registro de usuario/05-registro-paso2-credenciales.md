# 05 · Registro · Paso 2 — Credenciales + T&C

> Tokens en `00-identidad-visual.md`. Indicador de fortaleza detallado en [06].

## Propósito
Definir la contraseña de acceso, confirmarla, aceptar los Términos y Condiciones y crear la cuenta.

## Wireframe (estado base, contraseña vacía)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ ┌──┐                                           │   FlowAppBar 56 dp
│ │← │                                           │   back → Paso 1 (conserva datos)
│ └──┘                                           │
│  ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰        Paso 2 de 2        │   StepProgressBar 100%
│                                                │
│  Creá tu contraseña                            │   headlineMedium textPrimary
│  Vas a usarla junto con tu email para entrar.  │   bodyMedium textSecondary
│                                                │
│  Contraseña                                    │   labelMedium textSecondary
│  ┌────────────────────────────────────────┐   │
│  │ 🔒  ••••••••                        👁  │   │   AppTextField + toggle ver
│  └────────────────────────────────────────┘   │
│  ▱▱▱  Mínimo 8 caracteres                     │   meter (vacío) + helper labelSmall
│                                                │
│  Confirmar contraseña                          │
│  ┌────────────────────────────────────────┐   │
│  │ 🔒  ••••••••                        👁  │   │
│  └────────────────────────────────────────┘   │
│  ·línea helper reservada·                      │
│                                                │
│  ┌──┐                                          │
│  │  │ Acepto los Términos y Condiciones        │   AppCheckbox + texto + link
│  └──┘ y la Política de Privacidad.             │   "Términos…" = link primary
│                                                │
│                ( espacio flexible )            │
│  ┌────────────────────────────────────────┐   │
│  │              Crear cuenta                │   │   PrimaryButton full-width
│  └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | `FlowAppBar` | Leading "atrás" → vuelve a Paso 1 conservando datos. |
| 2 | `StepProgressBar` | Relleno `primary` al **100%** (animación de 50%→100% al entrar). "Paso 2 de 2". |
| 3 | Título / subtítulo | "Creá tu contraseña" `headlineMedium`; subtítulo `bodyMedium` `textSecondary`. |
| 4 | Campo **Contraseña** | `AppTextField`, prefijo 🔒, `obscureText: true` por defecto. Sufijo: ícono toggle 👁 (`visibility` / `visibility_off`, 22 dp, color `textSecondary`, objetivo táctil 48 dp). |
| 5 | `PasswordStrengthMeter` | 3 segmentos bajo el campo contraseña. En vacío: 3 segmentos `surfaceVariant` + helper "Mínimo 8 caracteres" `labelSmall` `textSecondary`. Ver [06]. |
| 6 | Campo **Confirmar contraseña** | igual al de contraseña, con su propio toggle independiente. |
| 7 | `AppCheckbox` T&C | Caja 22 dp + texto en `bodyMedium` `textPrimary`. Las palabras **"Términos y Condiciones"** y **"Política de Privacidad"** son links `primary` (bold, subrayado opcional). El resto del texto NO es link. Objetivo táctil de la fila >= 48 dp. |
| 8 | `PrimaryButton` "Crear cuenta" | full-width 56 dp. Habilitado siempre; valida al pulsar (incl. T&C). |

Separaciones: campos `lg (16)`; bloque checkbox separado `xl (24)` del campo anterior y del botón.
Padding horizontal `xl (24)`. Cuerpo scrolleable.

## Reglas de validación (al blur)

| Campo | Regla | Mensaje |
|---|---|---|
| Contraseña | No vacía; **mínimo 8 caracteres**. (La fortaleza es informativa, no bloqueante salvo el mínimo.) | "La contraseña debe tener al menos 8 caracteres." |
| Confirmar | No vacía; **idéntica** a Contraseña. | "Las contraseñas no coinciden." |
| T&C | Debe estar **marcado** para crear la cuenta. | Inline bajo el checkbox: "Tenés que aceptar los Términos y Condiciones." |

> Política de fortaleza: se exige el **mínimo de 8 caracteres** para proceder. La fortaleza
> ("Débil/Media/Fuerte") es una guía visual; una contraseña "Débil" de 8+ caracteres es válida
> pero se recomienda visualmente reforzarla (no se bloquea, para no frustrar a usuarios con baja
> afinidad tecnológica). Decisión documentada; si el cliente quisiera exigir "Media+", basta con
> condicionar el submit a `score >= medium`.

## Interacciones y comportamiento
- **Toggle 👁 (mostrar/ocultar):** alterna `obscureText`. El ícono cambia a `visibility_off`
  cuando el texto está visible. Cada campo tiene su toggle independiente. Anunciar a lector de
  pantalla: "Mostrar contraseña" / "Ocultar contraseña".
- **Mientras se escribe la contraseña:** el `PasswordStrengthMeter` se actualiza on-change (ver [06]).
- **Blur en Contraseña:** valida mínimo 8; si falla, error. Si el usuario ya escribió "Confirmar",
  re-valida la coincidencia.
- **Blur en Confirmar:** valida coincidencia exacta.
- **Tap en "Términos y Condiciones" / "Política de Privacidad":** abre el **Bottom Sheet de T&C [07]**
  (no marca el checkbox automáticamente). Al cerrar, vuelve al Paso 2 en el mismo estado.
- **Tap en el checkbox / fila:** alterna el estado marcado; al marcarlo, limpia el error de T&C si existía.
- **Tap "Crear cuenta":**
  - Valida contraseña (>=8), coincidencia y T&C marcado.
  - Si falta T&C → muestra error inline en el checkbox y hace foco ahí (no abre el sheet).
  - Si hay error de contraseña/confirmación → foco al primer campo inválido.
  - Si todo OK → pasa a **Estado de carga [08]** (overlay) y dispara la creación de cuenta.
- **Back (←):** vuelve a Paso 1 [03] conservando todos los datos (incluida la contraseña en memoria
  durante la sesión del flujo). El progreso vuelve a 50%.

## Estados alternativos
- **Fortaleza media / fuerte:** ver [06].
- **Bottom sheet T&C abierto:** ver [07].
- **Carga:** ver [08].
- **Error email ya registrado** (respuesta del submit): ver [10] — se renderiza sobre este Paso 2.
- **Error de contraseña/confirmación:** misma mecánica de error que [04] (borde `error` + texto ⚠).

## Navegación
- **Entrada:** desde Paso 1 [03] ("Continuar"); o retroceso desde [10] tras error.
- **Salida:** "Crear cuenta" → Carga [08]; back → Paso 1 [03]; link T&C → Bottom Sheet [07].
