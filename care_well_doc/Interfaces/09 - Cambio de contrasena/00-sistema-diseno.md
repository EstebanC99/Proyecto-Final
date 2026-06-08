# US-09 Cambio de contraseña — Sistema de diseño

> Este flujo hereda el sistema de diseño base de CareWell definido en
> `01 - Registro de usuario/00-identidad-visual.md` y los componentes de Configuración
> definidos en `08 - Consulta de TyC/00-sistema-diseno.md`.
> Acá se documentan las decisiones específicas del flujo de cambio de contraseña.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryContainer #C9EDE8` |
| Success | `success #2E9E5B` · `successContainer #D8F0E1` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Warning | `warning #E0A100` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Alturas | input 56 dp · botón 56 dp · objetivo táctil mín. 48 dp |
| Radios | inputs `radiusMd 12` · botones `radiusLg 16` · card `radiusMd 12` |
| Tipografía | familia `Inter` (fallback `'Segoe UI', Arial, sans-serif`) |

---

## 2. Componentes específicos de US-09

### 2.1 PasswordStrengthMeter
Indicador de fortaleza de contraseña. Tres segmentos de 4 dp de alto, separados 4 dp,
ancho total proporcional al campo (menos padding).

| Fortaleza | Segmentos activos | Color |
|---|---|---|
| Débil | 1/3 | `error #D14343` |
| Media | 2/3 | `warning #E0A100` |
| Fuerte | 3/3 | `success #2E9E5B` |

Etiqueta de texto a la derecha del medidor: "Débil", "Media" o "Fuerte".
12 px, color del estado correspondiente.
El medidor aparece solo al escribir en el campo "Nueva contraseña"; está oculto si el
campo está vacío.

### 2.2 SuccessScreen (pantalla de confirmación)
Pantalla de éxito sin AppBar. Estructura centrada verticalmente:
  1. Logo CareWell (ícono SVG 64 dp + wordmark bicolor 22 px).
  2. Ícono CHECK_CIRCLE 80 dp en un círculo contenedor 112 dp, fondo `successContainer`
     (#D8F0E1), color ícono `success` (#2E9E5B).
  3. Título `headlineMedium` (24 px 700) `textPrimary`: el texto de celebración.
  4. Cuerpo `bodyLarge` (16 px 400) `textSecondary`: descripción breve del resultado.
  5. Botón primario full-width 56 dp `primary`.

### 2.3 AppTextField con helper reservado
Variante del `AppTextField` que reserva 18 dp de espacio bajo el campo para el mensaje
de helper/error, aunque esté vacío. Evita que el layout salte al aparecer mensajes de error.

---

## 3. Decisiones específicas de US-09

1. **Se requiere la contraseña actual para verificar identidad.** Antes de establecer
   la nueva contraseña, el usuario debe ingresar la actual. Esto protege contra accesos
   no autorizados en sesiones abiertas (ej. alguien que toma el celular desbloqueado).
   Mismo mecanismo que la recuperación de US-03, pero sin código de email: la verificación
   es directa porque el usuario ya está autenticado.

2. **PasswordStrengthMeter en "Nueva contraseña".** El medidor de fortaleza aparece al
   tipear en el campo "Nueva contraseña" (igual que en US-01 Paso 2). No aparece en
   "Contraseña actual" ni en "Confirmar nueva contraseña".

3. **Validación en orden.** Al pulsar "Guardar cambios":
   - Primero: contraseña actual incorrecta → error inline en ese campo.
   - Segundo: nueva contraseña no cumple mínimo → error inline en campo nueva contraseña.
   - Tercero: confirmación no coincide → error inline en campo confirmar.
   Los tres no se muestran simultáneamente; se valida en cascada.

4. **La sesión NO se cierra tras el cambio.** El usuario sigue autenticado. A diferencia
   del flujo de recuperación (US-03), donde se crea una nueva sesión desde cero, acá el
   cambio ocurre dentro de una sesión activa. Navegar de vuelta a Configuración no implica
   re-login. Este comportamiento es distinto al de algunas apps que fuerzan re-login;
   se elige NO forzarlo para reducir fricción en cuidadores que usan la app frecuentemente.

5. **Pantalla de éxito sin AppBar.** La confirmación usa el mismo patrón de pantalla
   completa que el registro exitoso (US-01): branding prominente, ícono de check grande,
   texto claro y un único CTA. No hay distracciones.

6. **CTA del éxito: "Volver a Configuración".** El usuario regresa a `/settings` con
   `go('/settings')` (no push), para que el back del sistema no vuelva a la pantalla de
   cambio de contraseña.

7. **Ítem activo en Configuración.** "Cambio de contraseña" se resalta con
   `primaryContainer` como feedback contextual al entrar al flujo.

---

## 4. Mapa de estados del formulario de cambio

| Estado | Campo afectado | Componente clave |
|---|---|---|
| Reposo | todos | campos en estado neutro, medidor oculto |
| Escribiendo nueva contraseña | "Nueva contraseña" | medidor visible (Débil/Media/Fuerte) |
| Error: contraseña actual incorrecta | "Contraseña actual" | borde error, helper "Contraseña incorrecta" |
| Error: nueva contraseña débil | "Nueva contraseña" | borde error, helper, medidor Débil |
| Error: confirmación no coincide | "Confirmar nueva contraseña" | borde error, helper "Las contraseñas no coinciden" |
| Enviando | todos | botón loading, campos disabled |
| Éxito | — | pantalla `03-cambio-exitoso` |
