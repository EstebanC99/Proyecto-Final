# US-04 Creacion de credenciales — Sistema de diseño

> Este flujo **hereda en su totalidad** el sistema de diseño definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Esa es la fuente de verdad de paleta, tipografía, espaciado, radios, componentes y motion.
> Acá solo se documentan las **decisiones específicas de este flujo**.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Success | `success #2E9E5B` · `successContainer #D8F0E1` |
| Warning | `warning #E0A100` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` · `outlineStrong #9AA5A5` |
| Radios | inputs/banners `radiusMd 12` · botones `radiusLg 16` |
| Alturas | input 56 dp · botón 56 dp · objetivo táctil mín. 48 dp |
| Tipografía | familia `Inter` (fallback Roboto). En los HTML de mockup: `'Segoe UI', Arial, sans-serif`. |

---

## 2. Concepto de dominio clave: Persona sin credenciales

En CareWell una **Persona** puede existir en el sistema sin tener credenciales de acceso.
Esto ocurre cuando un Responsable la carga manualmente — por ejemplo, cuando la persona
bajo cuidado no puede operar la app por sí misma al momento del registro.

Cuando esa persona decide acceder a la app por primera vez, el flujo es:

1. Va a la pantalla de Login e ingresa su email.
2. El backend detecta que existe un registro de Persona con ese email pero sin contraseña asignada.
3. El sistema redirige a este flujo (US-04) para que cree sus credenciales.

Esto implica que en toda la UI de este flujo el email **ya es conocido** (viene del intento de
login previo) y **no se puede modificar en este paso**: el usuario solo debe elegir su contraseña.

---

## 3. Componentes reutilizados

- **`AppTextField`** (US-01 §5.3): label externo, 56 dp, prefijo 20 dp. Estados reposo / foco / disabled.
- **`PasswordStrengthMeter`** (US-01 §5.5): 3 segmentos. Aparece debajo del campo "Nueva contraseña".
- **`PrimaryButton`** (US-01 §5.1): full-width, 56 dp, radio 16, estados reposo / loading.
- **`SecondaryTextButton`** (US-01 §5.2): para el link "No soy yo · Ir al inicio".
- **`CheckboxTyC`** (US-01 §5.6): checkbox + texto de T&C; debe estar marcado para habilitar el botón.

---

## 4. Componente nuevo: IllustrationHero

Para las pantallas de deteccion (sin AppBar) y de exito se usa un bloque ilustrativo
centrado verticalmente con:

- Logo CareWell (icono 64 dp + wordmark): identico al del Login pero ligeramente mas pequeno.
- Circulo de icono contextual (96 dp de diámetro): fondo `primaryContainer` (#C9EDE8) en
  deteccion; fondo `successContainer` (#D8F0E1) en exito.
- Icono dentro del circulo: `person_add` 48 dp en deteccion; `check_circle` 80 dp en exito.
- Bloque de texto: titulo `headlineMedium` (24 px bold) + body `bodyLarge` (16 px) color
  `textSecondary`.

Este patron de "pantalla de encrucijada sin AppBar + icono central + CTA" es coherente con
la pantalla de exito del registro (US-01 [08]) y la pantalla de exito de recuperacion de
contraseña (US-03).

---

## 5. Decisiones especificas de US-04

1. **Email de solo lectura.** El campo de email no aparece como `AppTextField` editable
   en la pantalla de formulario: se muestra como texto estatico (label + valor en negrita).
   El usuario no puede cambiarlo en este paso. Si quiere usar otro email debe volver al Login.

2. **Sin indicador de progreso de pasos.** El flujo es corto (deteccion → formulario → exito)
   y el usuario ya sabe lo que tiene que hacer; agregar un stepper aumentaria la carga cognitiva
   sin beneficio real.

3. **Boton "Crear acceso" deshabilitado hasta que T&C este marcado.** A diferencia del login
   (donde el boton esta siempre habilitado), aqui crear credenciales implica aceptar los terminos;
   por lo tanto el boton esta `disabled` (fondo `outline #C5CECE`, texto `textDisabled`) mientras
   el checkbox no este marcado.

4. **PasswordStrengthMeter obligatorio, no opcional.** Crear una contraseña es una accion de
   alta importancia. El medidor ayuda a personas poco familiarizadas con la tecnologia a elegir
   una contraseña segura sin leer un listado de reglas.

5. **Pantalla de exito con `pushReplacement` al Login.** Tras crear las credenciales el usuario
   no vuelve a este flujo; la pantalla de exito reemplaza el stack de navegacion y lleva al Login
   con el email precargado para que la primera sesion sea sin friccion.

6. **"No soy yo · Ir al inicio" siempre visible.** Si el email precargado no corresponde a quien
   tiene el dispositivo, existe una salida clara. Esto es importante para contextos donde varios
   miembros de la familia comparten un dispositivo.

---

## 6. Mapa de estados del flujo

| Pantalla | Estado | Descripcion |
|---|---|---|
| [01] Deteccion | unico | pantalla de bienvenida; email detectado; CTA para crear contraseña |
| [02] Formulario | reposo / foco | campos activos, medidor de fortaleza, checkbox T&C |
| [02] Formulario | invalido | contraseñas no coinciden o campo vacio — error inline |
| [03] Cargando | loading | campos disabled, boton con spinner, peticion en curso |
| [04] Exito | unico | confirmacion; CTA para ir al login |
