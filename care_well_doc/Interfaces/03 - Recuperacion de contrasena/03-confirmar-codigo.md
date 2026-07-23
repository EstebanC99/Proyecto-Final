# 03 · Confirmar código y nueva contraseña

> **v2 (OTP).** Segunda y última pantalla de datos de US-03 — reemplaza a las antiguas
> `03-email-enviado`, `04-nueva-contrasena` y `05-error-email-no-registrado` (deprecadas, ver esos
> archivos). Tokens en `00-sistema-diseno.md`.
> Implementación: `care_well_app/lib/presentation/screens/auth/reset_password_screen.dart`.
> Ruta: `/auth/reset-password` (`resetPasswordName`), recibe `email` por `extra` de go_router.

## Objetivo

Permitir que el usuario ingrese el código de 6 dígitos recibido por email **y** defina su nueva
contraseña, en un único paso. Van juntos porque el backend expone un solo endpoint
(`confirmar-reset-contrasena`) que recibe ambos datos a la vez — separarlos en dos pantallas
agregaría fricción sin ninguna validación intermedia real que lo justifique.

## Layout — jerarquía de componentes

```
Scaffold
├─ AppBar: ARROW_BACK + título "Recuperar contraseña"
└─ SafeArea → SingleChildScrollView (padding horizontal 24 dp)
   └─ Column (stretch)
      ├─ StepProgressBar(currentStep: 2, totalSteps: 2)
      ├─ Título "Ingresá el código y tu nueva contraseña" (headlineMedium)
      ├─ Texto: "Te enviamos un código de 6 dígitos a **{email}**."
      ├─ AppTextField "Código de verificación"
      │    · teclado numérico, 6 dígitos, helper "Vence a los 10 minutos de haberlo pedido."
      ├─ Label de sección "Nueva contraseña" (labelLarge, bold)
      ├─ AppTextField "Nueva contraseña" (obscure + toggle 👁) + PasswordStrengthMeter
      ├─ AppTextField "Confirmar nueva contraseña" (obscure + toggle 👁)
      ├─ [condicional] InlineErrorBanner (tone error) — errores generales no asociados a un campo
      ├─ PrimaryButton "Restablecer contraseña" (loading state)
      └─ Reenviar código: texto "Podés reenviar en Ns" (cooldown) o
         SecondaryTextButton "¿No lo recibiste? Reenviar código" (cooldown vencido)
```

## Estados

| Estado | Disparador | Qué se ve |
|---|---|---|
| Inicial (cooldown activo) | llega desde `02-solicitar-email` | campos vacíos; el link de reenvío arranca en cooldown de 60 s (recién se pidió un código) |
| Errores de validación local | "Restablecer contraseña" con campos incompletos/inválidos | error inline en el/los campo(s) correspondientes (código, contraseña, o confirmación) |
| Cargando (confirmar) | envío válido en curso | botón con spinner, resto de la interacción bloqueada |
| Error: código inválido / vencido / intentos agotados | servidor responde 400 | error inline en el campo "Código de verificación" con el mensaje del backend |
| Error: regla de contraseña (edge case) | servidor responde 400 sobre la contraseña | error inline en el campo "Nueva contraseña" |
| Error general (otro 400 / sin conexión) | servidor responde otro error | `InlineErrorBanner(tone: error)` |
| Reenviando | tap "Reenviar código" (cooldown vencido) | link en estado "Enviando…", luego snackbar de confirmación y cooldown reiniciado |
| Error al reenviar | límite de envíos superado o sin conexión | `InlineErrorBanner(tone: error)` con el mensaje del backend (ej. "Superó el máximo de 5 envíos…") |
| Éxito | servidor confirma el cambio (200) | navega a `06-cambio-exitoso` |

## Reglas de validación (cliente)

- **Código:** requerido, exactamente 6 dígitos numéricos (`FilteringTextInputFormatter.digitsOnly`
  + `LengthLimitingTextInputFormatter(6)`).
- **Nueva contraseña:** mínimo 8 caracteres (`validatePassword`). `PasswordStrengthMeter` visible
  siempre que el campo no esté vacío.
- **Confirmar contraseña:** debe coincidir exactamente con la nueva (`validatePasswordMatch`).
- **Validación al pulsar "Restablecer contraseña".** No se valida al perder foco, para reducir
  fricción (mismo criterio que el resto de los formularios de auth de la app).

## Interacciones y comportamiento

- **Toggle 👁:** alterna ver/ocultar cada campo de contraseña de forma independiente.
- **Editar un campo con error:** limpia el error de ese campo específico.
- **"Restablecer contraseña" con errores locales:** errores inline, sin llamar al servidor.
- **"Restablecer contraseña" válido:** loading → llamada al servidor con `{email, codigo,
  contrasenaNueva}`.
- **Éxito (200):** `goNamed('reset-password-success')` — reemplaza el stack (ver
  `01-flujo-navegacion.md` §3).
- **Error de servidor:** el mensaje se rutea al campo correspondiente según contenga la palabra
  "código" o "contraseña"; si no matchea ninguno, banner general. Mismo criterio pragmático que ya
  usa `ChangePasswordScreen` (US-09).
- **"Reenviar código" con cooldown activo:** deshabilitado, se muestra el conteo regresivo en
  texto ("Podés reenviar el código en 42s").
- **"Reenviar código" con cooldown vencido:** reenvía la solicitud (mismo endpoint que el paso 1);
  al confirmar, limpia el campo de código (el anterior ya no sirve) y reinicia el cooldown.
- **ARROW_BACK:** `context.pop()` → vuelve a `02-solicitar-email`, que conserva el email cargado
  (no se pierde el dato al volver).

## Navegación

- **Entrada:** `02-solicitar-email` → `pushNamed(resetPasswordName, extra: email)`.
- **Entrada inválida (sin `extra`):** redirect de router a `02-solicitar-email` (no a Login: el
  paso lógico anterior es pedir el email, no autenticarse).
- **Salida exitosa:** `06-cambio-exitoso` → `goNamed(resetPasswordSuccessName)`.
- **Salida por corrección:** ARROW_BACK → `pop` a `02-solicitar-email`.
