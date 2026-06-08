# US-12 Alta de persona a cargo — Sistema de diseño

> Este flujo **hereda en su totalidad** el sistema de diseño definido en US-01:
> `care_well_doc/Interfaces/01 - Registro de usuario/00-identidad-visual.md`.
> Esa es la fuente de verdad de paleta, tipografía, espaciado, radios, componentes y motion.
> Acá solo se documentan las **decisiones específicas del flujo de alta de persona a cargo**.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryHover #157469` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Success | `success #2E9E5B` · `successContainer #D8F0E1` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` · `outlineStrong #9AA5A5` |
| Radios | inputs/cards `radiusMd 12` · botones `radiusLg 16` |
| Alturas | input 56 dp · botón 56 dp · objetivo táctil mín. 48 dp |
| Tipografía | familia `Inter` (fallback Roboto). En HTML de mockup: `'Segoe UI', Arial, sans-serif`. |

---

## 2. Componentes reutilizados

- **`AppTextField`** (US-01 §5.3): label externo superior, alto 56 dp, prefijo de 20 dp.
  Estados reposo / foco / error / disabled idénticos.
- **`PrimaryButton`** (US-01 §5.1): full-width, 56 dp, radio 16, estados reposo / pressed /
  loading. En este flujo el botón muestra spinner con "Registrando..." en estado [04].
- **`AppBar`** interna (no Material nativa): fila 56 dp, fondo `surface #FFFFFF`, sombra
  `0 1px 0 #C5CECE`. Contiene ARROW_BACK izquierda y título "Nueva persona a cargo" centrado.
- **Bloque de foto** (nuevo en esta US): avatar circular 80 dp, borde dashed `outline`,
  fondo `surfaceVariant`. Tap abre selector (galería / cámara).
- **Checkbox T&C** (US-01 §5.6): fila 48 dp, ícono 22 dp, texto 14 dp con link tappable.

---

## 3. Decisiones específicas de US-12

1. **La persona NO es un usuario.** El formulario no solicita contraseña. El Responsable
   es quien inicia la sesión; la persona a cargo queda en el sistema sin credenciales de
   acceso. Esto se comunica con el subtítulo "Completá los datos de la persona que vas a
   registrar." y con la anotación de diseño correspondiente.

2. **Foto es opcional, pero se presenta primero.** El bloque de avatar precede a los campos
   de texto. Razón: en el módulo de personas a cargo, la foto es la referencia visual más
   rápida en listas y tarjetas. Ponerla al inicio de la pantalla jerarquiza su importancia
   sin hacerla obligatoria.

3. **Email es opcional y se indica explícitamente.** La etiqueta dice "Email (opcional)"
   para no generar fricción con cuidadores de adultos mayores que quizás no tienen correo.

4. **Fecha de nacimiento como texto, no date-picker.** El campo muestra placeholder
   "DD/MM/AAAA" y abre un picker de fecha nativo al hacer foco. En el mockup HTML se
   representa como input de texto para fidelidad visual; la implementación Flutter usa
   `showDatePicker`.

5. **Checkbox T&C heredado de US-01.** Confirma que los datos sensibles del adulto mayor
   se almacenan bajo los términos de privacidad del servicio. El botón "Registrar persona"
   se habilita solo cuando está marcado.

6. **Validación al pulsar, con excepciones al blur para DNI.** El DNI se valida formato
   (solo dígitos, 7-8 caracteres) al perder foco, porque es un error que el usuario
   necesita corregir antes de seguir. El resto de los requeridos se valida al submit.

7. **Pantalla de éxito sin AppBar.** Al igual que US-01 §09, el estado de éxito es una
   pantalla completa con jerarquía emocional (ícono grande, nombre en negrita) y dos
   acciones: ir a la lista o registrar otra. No hay forma de "volver" al formulario desde
   este estado: el formulario ya fue procesado.

---

## 4. Mapa de estados

| Estado | Archivo HTML | Disparador |
|---|---|---|
| Formulario vacío (inicial) | `01-formulario-alta.html` | tap "+" en lista de personas a cargo |
| Formulario con error | `02-formulario-error.html` | tap "Registrar persona" con campos inválidos |
| Cargando | `03-cargando.html` | validación local OK + petición en vuelo |
| Exito | `04-exito.html` | respuesta exitosa del servidor |
