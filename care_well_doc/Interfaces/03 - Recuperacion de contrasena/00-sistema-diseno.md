# US-03 Recuperación de contraseña — Sistema de diseño

> Este flujo **hereda en su totalidad** el sistema de diseño definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Esa es la fuente de verdad de paleta, tipografía, espaciado, radios, componentes y motion.
> Acá solo se documentan las **decisiones específicas del flujo de recuperación de contraseña**.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Exito | `success #2E9E5B` · `successContainer #D8F0E1` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` · `outlineStrong #9AA5A5` |
| Radios | inputs/banners `radiusMd 12` · botones `radiusLg 16` |
| Alturas | input 56 dp · botón 56 dp · objetivo táctil mín. 48 dp |
| Tipografía | familia `Inter` (fallback Roboto). En HTML de mockup: `'Segoe UI', Arial, sans-serif`. |

---

## 2. Flujo compartido con US-09

El flujo de establecer nueva contraseña (pantallas `03-nueva-contrasena` y `05-cambio-exitoso`)
es **idéntico** al procedimiento de cambio de contraseña de la sección Configuración (US-09).
Ambos flujos reutilizan los mismos widgets:

- `NewPasswordForm` — formulario con dos campos de contraseña y `PasswordStrengthMeter`.
- `PasswordSuccessScreen` — pantalla de confirmación de cambio exitoso.

La diferencia es únicamente de **contexto de navegación**:
- En US-03: se accede vía deep link desde el email; al finalizar hace `pushReplacement` a Login.
- En US-09: se accede desde la pantalla de Configuración; al finalizar vuelve a Configuración.

---

## 3. Componentes reutilizados

- **`AppTextField`** (US-01 §5.3): label externo superior, alto 56 dp, prefijo de 20 dp.
  Estados reposo / foco / error / disabled idénticos.
- **`PrimaryButton`** (US-01 §5.1): full-width, 56 dp, radio 16, estados reposo / pressed / loading.
- **`SecondaryTextButton`** (US-01 §5.2): para "Volver al inicio de sesión" y "Reenviar".
- **`InlineErrorBanner`** (US-01 §5.7): para el error de email no registrado (respuesta del servidor).
- **`PasswordStrengthMeter`** (US-01 §5.5): 3 segmentos de indicador de fortaleza, bajo el campo de contraseña.
- **`AppBar`** simple: flecha de retroceso (ARROW_BACK 24 dp) + título centrado. Sin acciones secundarias.

---

## 4. Decisiones específicas de US-03

1. **Sin logo prominente en las pantallas internas del flujo.** Solo la pantalla de deep link
   (`03-nueva-contrasena`) y la de éxito (`05-cambio-exitoso`) muestran el logo CareWell (64 dp),
   dado que no tienen AppBar y representan puntos de entrada externos. Las pantallas con AppBar
   (`01-solicitar-email`, `02-email-enviado`) omiten el logo; la AppBar provee el contexto.

2. **Error de email no registrado como banner, no como error de campo.** El sistema no puede
   saber si el email existe hasta consultar el servidor. El error se muestra en un
   `InlineErrorBanner` sobre el formulario. El campo en sí no se marca como inválido (formato
   correcto) y no revela si el email existe para otros usuarios.

3. **Confirmación del destinatario en la pantalla de email enviado.** Se muestra el email ingresado
   en negrita para que el usuario confirme que el link fue al destino correcto. Si se equivocó, puede
   volver y corregirlo.

4. **Password strength meter en estado "Media" (2/3) como estado de referencia del mockup.**
   Las reglas de fortaleza son idénticas a las de US-01 (registro): mínimo 8 caracteres,
   combinación de letras y números para "Media", mayúsculas y caracteres especiales para "Alta".

5. **Deep link sin AppBar.** La pantalla `03-nueva-contrasena` se abre desde un link de email
   externo a la app. Al no tener una pantalla anterior dentro del flujo de la app, no tiene AppBar
   ni botón de retroceso. El usuario solo puede "Guardar" o abandonar la app.

6. **`pushReplacement` al finalizar.** La pantalla `05-cambio-exitoso` reemplaza el stack completo
   de recuperación y lleva al Login. Esto evita que el usuario pueda volver a la pantalla de nueva
   contraseña con el back del sistema (el link ya fue consumido).

---

## 5. Mapa de estados

| Pantalla | Estado | Disparador |
|---|---|---|
| `01-solicitar-email` | Vacío (inicial) | acceso desde "¿Olvidaste tu contraseña?" en Login |
| `01-solicitar-email` | Con email escrito | usuario completa el campo |
| `02-email-enviado` | Normal | servidor confirma envío del link |
| `03-nueva-contrasena` | Contraseña vacía | acceso desde deep link del email |
| `03-nueva-contrasena` | Contraseña con fortaleza media | usuario escribe contraseña válida |
| `04-error-email-no-registrado` | Error de servidor | email no existe en el sistema |
| `05-cambio-exitoso` | Exitoso | servidor confirma cambio de contraseña |
