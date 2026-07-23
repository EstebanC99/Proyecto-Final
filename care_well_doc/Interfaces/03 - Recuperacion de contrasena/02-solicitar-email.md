# 02 · Solicitar código — pantalla de entrada al flujo

> **v2 (OTP).** Primera pantalla de US-03. Tokens en `00-sistema-diseno.md`.
> Implementación: `care_well_app/lib/presentation/screens/auth/recover_password_screen.dart`.
> Ruta: `/auth/recover-password` (`recoverPasswordName`).

## Objetivo

Permitir que el usuario ingrese su email para recibir un código de 6 dígitos con el que va a
poder establecer una nueva contraseña. Es la puerta de entrada al flujo desde Login. Diseño
deliberadamente simple: un campo, un botón, un link de retorno — y un manejo cuidadoso del único
caso en el que el sistema sí necesita comunicar algo más (cuenta no activa).

## Layout — jerarquía de componentes

```
Scaffold
├─ AppBar: ARROW_BACK + título "Recuperar contraseña"
└─ SafeArea → SingleChildScrollView (padding horizontal 24 dp)
   └─ Column (stretch)
      ├─ StepProgressBar(currentStep: 1, totalSteps: 2)
      ├─ Título "Recuperar contraseña" (headlineMedium)
      ├─ Subtítulo (bodyMedium, textSecondary):
      │  "Ingresá el email asociado a tu cuenta. Si está activa, te vamos a
      │   enviar un código de 6 dígitos para restablecer tu contraseña."
      ├─ AppTextField "Email" (prefijo mail_outline, teclado email, autofill)
      ├─ [condicional] InlineErrorBanner (warning o error, ver Estados)
      ├─ PrimaryButton "Enviar código" (loading state)
      └─ SecondaryTextButton "Volver al inicio de sesión" (centrado)
```

## Estados

| Estado | Disparador | Qué se ve |
|---|---|---|
| Vacío / inicial | acceso desde Login | campo vacío, botón habilitado, sin banner |
| Error de formato | "Enviar código" con email vacío/inválido | error inline en el campo, sin llamar al servidor |
| Cargando | "Enviar código" con email válido | botón con spinner, campo deshabilitado |
| Cuenta no habilitada | servidor responde 400 "no habilitada" | `InlineErrorBanner(tone: warning)` + acción "Verificar mi email" (ver detalle abajo). El campo **no** se marca inválido y conserva el valor. |
| Error de límite o red | servidor responde 400 (límite de envíos) o falla de conexión | `InlineErrorBanner(tone: error)` con el mensaje correspondiente |
| Éxito | servidor responde 200 (exista o no la cuenta) | navega a `03-confirmar-codigo`, no hay estado visual propio |

### Detalle del banner de "cuenta no habilitada" (decisión de UX clave de este rediseño)

- **Tono `warning` (ámbar), no `error` (rojo).** El usuario no cometió un error de formato; es un
  estado de su cuenta. Un banner rojo comunicaría culpa donde no la hay.
- **Ícono:** `mark_email_unread_outlined` (en vez del genérico de warning), para anclar visualmente
  la sugerencia más probable (falta verificar el email).
- **Copy:** "Todavía no pudimos habilitar el restablecimiento para esta cuenta. Si te registraste
  hace poco, es posible que falte verificar tu email." — condicional, no acusatorio, no
  determinista (el backend no distingue entre pendiente de validación / suspendida / eliminada).
- **Acción:** botón de texto "Verificar mi email" dentro del propio banner → navega a
  `VerifyEmailScreen` (US-01) con el mismo email. Convierte un posible callejón sin salida en un
  próximo paso accionable.
- **El campo Email no cambia de estado:** sigue mostrando el valor ingresado, sin borde de error.

## Interacciones y comportamiento

- **Tap en Email:** foco → borde 2 dp `primary`; abre teclado email.
- **Editar el campo tras un error:** limpia tanto el error de campo como el banner general
  (`onChanged`), para que el reintento parta limpio.
- **"Enviar código" con campo vacío o formato inválido:** error inline bajo el campo, nunca llega
  al servidor.
- **"Enviar código" válido:** loading (botón + campo disabled) → llamada al servidor.
- **Éxito (200):** `pushNamed('reset-password', extra: email)` → `03-confirmar-codigo`.
- **ARROW_BACK / "Volver al inicio de sesión":** `context.pop()` → Login.

## Navegación

- **Entrada:** Login · tap "¿Olvidaste tu contraseña?" → `pushNamed(recoverPasswordName)`.
- **Salida exitosa:** `03-confirmar-codigo` → `pushNamed(resetPasswordName, extra: email)`.
- **Salida por cuenta no activa:** permanece en esta pantalla, con salida opcional hacia
  `VerifyEmailScreen` (US-01) vía la acción del banner.
- **Salida cancelar:** Login → `pop`.
