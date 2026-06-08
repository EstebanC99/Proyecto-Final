# US-02 Inicio de sesión — Sistema de diseño

> Este flujo **hereda en su totalidad** el sistema de diseño definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Esa es la fuente de verdad de paleta, tipografía, espaciado, radios, componentes y motion.
> Acá solo se documentan las **decisiones específicas del flujo de inicio de sesión**.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Sin conexión / info neutra | `info #2E77C2` · `infoContainer #DBE9FB` (banner de red) |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` · `outlineStrong #9AA5A5` |
| Radios | inputs/banners `radiusMd 12` · botones `radiusLg 16` |
| Alturas | input 56 dp · botón 56 dp · objetivo táctil mín. 48 dp |
| Tipografía | familia `Inter` (fallback Roboto). En los HTML de mockup, font stack sin internet: `'Segoe UI', Arial, sans-serif`. |

---

## 2. Componentes reutilizados

- **`AppTextField`** (US-01 §5.3): label externo superior, alto 56 dp, prefijo de 20 dp.
  Estados reposo / foco / error / disabled idénticos.
- **`PrimaryButton`** (US-01 §5.1): full-width, 56 dp, radio 16, estados reposo / pressed /
  loading. En este flujo el botón se usa con estado **loading** (spinner) en `06`.
- **`SecondaryTextButton`** (US-01 §5.2): para "¿Olvidaste tu contraseña?" y "Crear cuenta".
- **`InlineErrorBanner`** (US-01 §5.7): para el error de credenciales (401).

---

## 3. Decisiones específicas de US-02

1. **Validación al pulsar, no al blur.** A diferencia del registro (que valida campo por campo
   al perder foco), el login es un formulario corto y de baja fricción: el botón "Ingresar" está
   **siempre habilitado** y la validación local (campos vacíos) ocurre **al pulsar**. Razón: el
   usuario que vuelve a entrar suele saber sus datos; no conviene molestarlo con errores de blur.

2. **Dos niveles de error, claramente separados:**
   - **Error de campo (validación local):** campo vacío → borde 2 dp `error` + mensaje inline
     bajo el campo específico. Le dice al usuario *qué* corregir.
   - **Error de pantalla (servidor 401):** credenciales no coinciden → **banner superior**
     `InlineErrorBanner`. **No se marca ningún campo** ni se indica cuál de los dos está mal
     (decisión de seguridad: no revelar si el email existe). El mensaje es genérico:
     "El email o la contraseña son incorrectos."

3. **Banner de sin conexión con color `info`, no `error`.** La falta de internet no es culpa de
   las credenciales: se usa el container `info` (#DBE9FB) con ícono `wifi_off` y una acción
   "Reintentar". Esto evita que el usuario crea que sus datos están mal cuando el problema es la red.

4. **Estado de carga sin scrim oscuro.** A diferencia del registro (overlay con scrim), el login
   usa un estado de carga **suave**: el botón pasa a `loading` (spinner) y los inputs quedan
   `disabled` (fondo `surfaceVariant`, no editables). No se oscurece la pantalla. Razón: el login
   es rápido; un overlay completo se percibe pesado para una espera de ~1 s.

5. **Logo prominente.** Esta es la **primera pantalla de la app**. El bloque de marca (ícono 72 dp
   + wordmark bicolor + tagline) domina el tercio superior. En los estados de error, el logo se
   mantiene pero el banner se inserta encima del formulario sin empujar el logo fuera de vista.

6. **El campo identificador es "Email"** (decisión heredada de US-01; el enunciado original decía
   "Usuario").

---

## 4. Mapa de estados de la pantalla de login

| Estado | Disparador | Componente clave |
|---|---|---|
| Vacío (inicial) | arranque de app / logout | formulario en reposo |
| Con datos | usuario escribió email + contraseña | inputs con valor, botón listo |
| Campo vacío | "Ingresar" con un campo vacío | error inline en el campo |
| Credenciales incorrectas | respuesta 401 | `InlineErrorBanner` (error) |
| Sin conexión | fallo de red | banner `info` + "Reintentar" |
| Cargando | "Ingresar" (validación local OK) | botón loading + inputs disabled |
