# US-03 Recuperación de contraseña — Sistema de diseño

> **v2 (OTP)** — Reemplaza el diseño original basado en link/deep-link. El backend implementa
> recuperación de contraseña por **código OTP de 6 dígitos** (no por link), con el mismo mecanismo
> ya usado en la verificación de email del registro (US-01). Ver `01-flujo-navegacion.md` para el
> mapa completo y el historial de qué cambió.
>
> Este flujo **hereda en su totalidad** el sistema de diseño definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Esa es la fuente de verdad de paleta, tipografía, espaciado, radios, componentes y motion.
> Acá solo se documentan las **decisiones específicas del flujo de recuperación de contraseña**.
>
> Implementación de referencia (código real, más precisa que un mockup estático):
> `care_well_app/lib/presentation/screens/auth/recover_password_screen.dart`,
> `reset_password_screen.dart`, `reset_password_success_screen.dart`.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Advertencia | `warning #E0A100` · `warningContainer #FBF0CF` |
| Información | `info #2E77C2` · `infoContainer #DBE9FB` |
| Éxito | `success #2E9E5B` · `successContainer #D8F0E1` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` · `outlineStrong #9AA5A5` |
| Radios | inputs/banners `radiusMd 12` · botones `radiusLg 16` |
| Alturas | input 56 dp · botón 56 dp · objetivo táctil mín. 48 dp |
| Tipografía | familia `Inter` (fallback Roboto). En HTML de mockup: `'Segoe UI', Arial, sans-serif`. |

---

## 2. Por qué OTP y no link (contexto de la decisión)

El diseño original (v1) enviaba un link de restablecimiento por email que abría un deep link
dentro de la app. El backend finalmente implementó el mismo mecanismo que ya usa la verificación
de email del registro (US-01): un **código de 6 dígitos** que el usuario copia del email y
escribe dentro de la app. Motivos por los que esto es, además, la mejor decisión de UX para el
público de CareWell:

- **No depende de deep links ni de qué cliente de email abre el link** (a menudo un problema en
  Android con apps de correo corporativo, Gmail vs. cliente nativo, etc.). Copiar 6 dígitos es
  una interacción más robusta y ya validada con el flujo de registro.
- **Un solo patrón mental para dos flujos.** El usuario ya vio esta interacción al verificar su
  email; reutilizarla reduce la curva de aprendizaje, clave para el público de cuidadores mayores
  o poco familiarizados con la tecnología.
- **Reduce el número de pantallas.** No hace falta una pantalla intermedia de "revisá tu email":
  se pasa directo del pedido del código a la pantalla donde se lo ingresa.

---

## 3. Flujo — 3 pantallas (antes eran 5)

1. **`02-solicitar-email`** — pedir el código (email).
2. **`03-confirmar-codigo`** — ingresar el código OTP **y** la nueva contraseña en la misma
   pantalla (ver §4.2 por qué van juntos).
3. **`06-cambio-exitoso`** — confirmación final (mismo componente que usa US-09 para el cambio de
   contraseña desde Configuración).

Los archivos `03-email-enviado.md`, `04-nueva-contrasena.md` y `05-error-email-no-registrado.md`
quedaron **deprecados**: sus responsabilidades se repartieron entre `02-solicitar-email` (el caso
de cuenta no habilitada, antes en `05`) y `03-confirmar-codigo` (antes `04`, ahora sin depender de
un deep link). No existe más una pantalla separada de "email enviado": al pedir el código se
navega directo a ingresarlo.

---

## 4. Decisiones específicas de esta versión

### 4.1 Cuenta existente pero no activa: se informa, con tono no alarmante

El backend distingue dos casos al pedir el código (`POST solicitar-reset-contrasena`):

- **Email no encontrado:** responde 200 igual, sin enviar nada. Anti-enumeración estándar.
- **Email encontrado pero la cuenta no está activa** (típicamente: registro pendiente de
  verificar el email; también puede ser una cuenta suspendida o eliminada): responde con un error
  400 explícito. Fue una decisión de producto consciente **priorizar dar feedback claro por sobre
  ocultar la existencia de la cuenta** en este caso puntual.

Decisión de diseño para ese caso: **banner de tono `warning` (ámbar), no `error` (rojo)**, con un
ícono de email y una acción concreta ("Verificar mi email") en vez de un callejón sin salida.
Justificación:

- Un banner rojo comunica "hiciste algo mal"; acá el usuario no se equivocó, es un estado
  intermedio de su cuenta. El tono ámbar existe en el sistema de diseño justamente para esto
  (`AppColors.warning`/`warningContainer`, ya usado en `HealthDisclaimerBanner`).
- El copy usa condicional ("es posible que falte verificar tu email") en vez de una afirmación,
  porque el backend no distingue *por qué* la cuenta no está activa (pendiente de validación,
  suspendida o eliminada son los tres estados posibles); el caso pendiente de validación es, por
  lejos, el más común, así que se lo sugiere sin prometerlo como certeza.
- La acción "Verificar mi email" lleva directo a `VerifyEmailScreen` (la misma pantalla de US-01),
  reutilizando el flujo existente en vez de dejar al usuario sin próximo paso.
- El campo de email **no se marca como inválido** y conserva el valor: el formato es correcto, el
  problema es de estado de cuenta, no de dato mal escrito.

Ver el widget `InlineErrorBanner` (ahora con parámetro `tone`: `error` / `warning` / `info`, y
acción secundaria opcional) en
`care_well_app/lib/presentation/widgets/shared/inline_error_banner.dart`.

### 4.2 Código OTP y nueva contraseña van en la misma pantalla

A diferencia del v1 (que separaba "nueva contraseña" en una pantalla propia abierta por deep
link), acá **el código y la nueva contraseña se piden juntos** en `03-confirmar-codigo`. Motivo:
el backend expone un único endpoint (`confirmar-reset-contrasena`) que recibe `email`, `codigo` y
`contrasenaNueva` en la misma request. Separarlos en dos pantallas agregaría un paso de fricción
sin ningún beneficio real (no hay nada que validar del lado del servidor solo con el código antes
de tener la contraseña nueva). Esto también acorta el flujo total a 3 pantallas.

### 4.3 Reenvío de código con cooldown visual, arrancando ya en cooldown

El botón "¿No lo recibiste? Reenviar código" sigue el mismo patrón que `VerifyEmailScreen`
(US-01): cooldown local optimista de 60 s tras cada envío, con el mensaje del backend mostrado
tal cual si se excede el límite real (cooldown servidor o tope de 5 envíos/hora). A diferencia de
`VerifyEmailScreen`, acá el cooldown **arranca activo apenas se entra a la pantalla** (no en
reposo), porque el código recién se pidió en el paso anterior — mostrar "reenviar" ya habilitado
invitaría a un reenvío innecesario que además puede fallar contra el límite del backend.

> Nota importante para `dev-flutter`: el límite de envíos por hora (5) es **compartido** entre el
> código de verificación de email y el de recuperación de contraseña (mismo contador del lado del
> backend). Pedir muchos códigos de un tipo puede bloquear temporalmente el otro. Esto no cambia
> el diseño de esta pantalla (el mensaje de error ya viene armado por el backend), pero es
> relevante si en el futuro se agrega alguna indicación proactiva de cupo restante.

### 4.4 Errores del paso de confirmación, ruteados por campo

`ConfirmarReset` puede fallar por: código inválido, código vencido, intentos agotados (todos
mensajes que contienen la palabra "código") o, en un caso límite, por una regla de contraseña que
el cliente ya valida antes de enviar (mensaje que contiene "contraseña"). La pantalla rutea el
mensaje del backend al campo correspondiente por esas palabras clave — mismo criterio pragmático
que ya usa `ChangePasswordScreen` (US-09) para distinguir "contraseña actual incorrecta". Si el
mensaje no matchea ninguno de los dos, se muestra como banner general.

### 4.5 Pantalla de éxito reutilizada de US-09

`06-cambio-exitoso` es el mismo componente (`SuccessView`) que usa el cambio de contraseña desde
Configuración (US-09), con el CTA apuntando a Login en vez de a Configuración. Detalle importante
del copy: se aclara que **se cerró la sesión en otros dispositivos** (comportamiento real del
backend al confirmar el reset), para que no sea una sorpresa si el usuario tenía sesión abierta en
otro equipo.

### 4.6 `StepProgressBar` en los 2 primeros pasos

Se agregó el indicador "Paso 1 de 2" / "Paso 2 de 2" (mismo componente que usa el registro,
US-01) en `02-solicitar-email` y `03-confirmar-codigo`. No estaba en el diseño v1. Para el público
de CareWell (usuarios apurados, estresados o poco tecnológicos) es valioso comunicar que el flujo
es corto y en qué punto están, especialmente porque `03-confirmar-codigo` pide 3 campos y podría
percibirse como largo sin ese contexto.

### 4.7 Sin logo en las pantallas internas

Se mantiene la decisión del v1: las pantallas con `AppBar` (`02`, `03`) omiten el logo — el
`AppBar` ya da contexto de marca/navegación. La pantalla de éxito (`06`), al no tener `AppBar`, sí
podría llevar logo si se desea reforzar marca en el cierre del flujo (opcional, no implementado
en la versión actual de `SuccessView`).

---

## 5. Componentes reutilizados

- **`AppTextField`** (US-01 §5.3): label externo superior, alto 56 dp, prefijo de 20 dp.
- **`PrimaryButton`** (US-01 §5.1): full-width, 56 dp, radio 16, estados reposo / pressed / loading.
- **`SecondaryTextButton`** (US-01 §5.2): "Volver al inicio de sesión", "Reenviar código".
- **`InlineErrorBanner`** (extendido en esta versión con `tone` y acción secundaria opcional):
  error de límite/red (tono `error`), cuenta no habilitada (tono `warning`).
- **`PasswordStrengthMeter`** (US-01 §5.5): bajo el campo de nueva contraseña.
- **`StepProgressBar`**: "Paso N de 2", reutilizado del registro (US-01).
- **`SuccessView`**: pantalla de éxito genérica, compartida con US-09.
- **`AppBar`** simple: flecha de retroceso + título "Recuperar contraseña" en ambos pasos.

---

## 6. Mapa de estados

| Pantalla | Estado | Disparador |
|---|---|---|
| `02-solicitar-email` | Vacío (inicial) | acceso desde "¿Olvidaste tu contraseña?" en Login |
| `02-solicitar-email` | Cargando | tap "Enviar código" con email válido |
| `02-solicitar-email` | Error de formato | email vacío o formato inválido (inline en el campo) |
| `02-solicitar-email` | Cuenta no habilitada | banner `warning` con acción "Verificar mi email" |
| `02-solicitar-email` | Error de límite / red | banner `error` con el mensaje del backend |
| `03-confirmar-codigo` | Inicial (cooldown activo) | llega desde `02` tras pedir el código |
| `03-confirmar-codigo` | Errores de campo | código/contraseña/confirmación inválidos (client-side) |
| `03-confirmar-codigo` | Error de código (servidor) | inválido / vencido / intentos agotados |
| `03-confirmar-codigo` | Reenviando | tap "Reenviar código" (cooldown vencido) |
| `03-confirmar-codigo` | Cargando (confirmar) | tap "Restablecer contraseña" con datos válidos |
| `06-cambio-exitoso` | Éxito | servidor confirma el cambio de contraseña |
