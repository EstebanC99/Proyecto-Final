# US-11 Eliminacion de cuenta — Sistema de diseno

> Este flujo hereda el sistema de diseno base de CareWell definido en
> `01 - Registro de usuario/00-identidad-visual.md` y los componentes de Configuracion
> definidos en `08 - Consulta de TyC/00-sistema-diseno.md`.
> Aca se documentan las decisiones especificas del flujo de eliminacion de cuenta.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Primario | `primary #1A8C82` · `primaryContainer #C9EDE8` |
| Error | `error #D14343` · `errorContainer #FBE3E3` |
| Warning | `warning #E0A100` · `warningContainer #FFF3CD` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` · `surfaceVariant #EDF1F1` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` · `textDisabled #9AA5A5` |
| Bordes | `outline #C5CECE` |
| Radios | inputs `radiusMd 12` · botones `radiusLg 16` · card `radiusMd 12` · dialog `radiusXl 28` |
| Alturas | input 56 dp · boton 56 dp · objetivo tactil min. 48 dp |
| Tipografia | familia `Inter` (fallback `'Segoe UI', Arial, sans-serif`) |

---

## 2. Componentes especificos de US-11

### 2.1 SettingsItem — estado error activo (US-11)

El item "Eliminar cuenta" en la pantalla Configuracion se resalta cuando este flujo esta activo:
  - Fondo `errorContainer` (#FBE3E3)
  - Borde izquierdo 3 dp `error` (#D14343)
  - Icono DELETE_FOREVER color `error` (#D14343)
  - Label color `error` (#D14343), peso 600
  - CHEVRON_RIGHT color `error` (#D14343)

Difiere del estado destructivo neutro (sin fondo, sin borde) usado en el resto de las US.
Esta variante comunica: "estas en la zona de peligro, el flujo activo es destructivo".

### 2.2 DestructiveConfirmDialog

Dialog de confirmacion para acciones irreversibles. Especificaciones M3 adaptadas:

| Propiedad | Valor |
|---|---|
| Fondo | `surface #FFFFFF` |
| Border-radius | 28 dp (`radiusXl`) |
| Margin horizontal | 24 dp |
| Padding interior | 24 dp |
| Icono superior | WARNING 24 dp, color `warning #E0A100`, centrado |
| Titulo | 18 px, 700, `textPrimary #16201F`, centrado |
| Cuerpo | 14 px, 400, `textSecondary #566060`, alineado izquierda, interlineado 1.5 |
| Campo de confirmacion | AppTextField standard, placeholder "DELETE", alto 56 dp |
| Boton primario (activo) | alto 56 dp, bg `error #D14343`, texto blanco, `radiusLg 16` |
| Boton primario (disabled) | bg `outline #C5CECE`, texto `textDisabled #9AA5A5` |
| Boton cancelar | alto 48 dp, sin fondo, texto `textSecondary #566060`, subrayado leve |
| Scrim (overlay) | `rgba(0, 0, 0, 0.4)` sobre la pantalla de Configuracion |

### 2.3 Patron de confirmacion explicita

El campo de texto dentro del dialog requiere que el usuario escriba la palabra "DELETE"
(en mayusculas, exacto) para habilitar el boton "Eliminar mi cuenta". La validacion es
case-sensitive. Mientras el campo no coincida, el boton permanece disabled (#C5CECE).

Racional: accion irreversible con consecuencias maximas (perdida total de datos).
El patron de tipeo explicito — popularizado por GitHub para eliminar repositorios —
crea friccion intencional y reduce eliminaciones accidentales, especialmente en
dispositivos con toques involuntarios. Cumple ademas con el principio de consentimiento
informado requerido por la Ley 25.326 (Proteccion de Datos Personales, Argentina).

---

## 3. Decisiones especificas de US-11

1. **El dialog se muestra sobre la pantalla de Configuracion (no hay navegacion push).**
   La eliminacion de cuenta no es un flujo de varias pantallas; es una confirmacion modal.
   Usar un dialog en lugar de una nueva pantalla evita que el usuario quede "atrapado"
   en un camino sin salida y simplifica la pila de navegacion.

2. **Campo "DELETE" case-sensitive.** Se muestra en mayusculas en el placeholder y en la
   descripcion. Si el usuario escribe "delete" o "Delete", el boton no se habilita.
   Razon: el esfuerzo de escribir en mayusculas es intencional y distingue el gesto
   deliberado de una pulsacion accidental.

3. **El boton destructivo solo aparece habilitado cuando el campo es exacto.**
   No hay estado de "casi correcto": o es "DELETE" exacto o esta disabled. No se muestra
   error inline en el campo; la habilitacion/deshabilitacion del boton es feedback suficiente.

4. **Botón "Cancelar" siempre disponible y prominente.**
   Debe ser igual de facil o mas facil salir que confirmar. "Cancelar" tiene objetivo
   tactil completo (48 dp) y no compite visualmente con el boton destructivo.

5. **Texto del cuerpo menciona consecuencias especificas.**
   "Se eliminaran todos tus datos, personas a cargo y membresias en equipos de cuidado."
   El usuario debe entender que la accion afecta no solo su cuenta sino a las personas
   bajo su cuidado y a su equipo. Esto es especialmente importante en el contexto de
   cuidadores que son los unicos responsables de ciertas personas a cargo.

6. **Estado loading al confirmar.**
   Al pulsar "Eliminar mi cuenta" (con DELETE correcto), el boton muestra un spinner y
   los controles se deshabilitan. La operacion puede tardar (baja del servidor).

7. **Tras el exito: logout y navegacion a Login.**
   La cuenta ya no existe; no tiene sentido volver a ningun estado autenticado. Se navega
   a la pantalla de login con `go('/login')` mostrando un mensaje de confirmacion tipo
   SnackBar: "Tu cuenta fue eliminada correctamente."

---

## 4. Mapa de estados del dialog de confirmacion

| Estado | Campo DELETE | Boton destructivo | Accion posible |
|---|---|---|---|
| Inicial | vacio | Disabled (#C5CECE) | Solo cancelar |
| Escribiendo (incompleto) | parcial / incorrecto | Disabled (#C5CECE) | Solo cancelar |
| Correcto | "DELETE" exacto | Activo (#D14343) | Confirmar o cancelar |
| Enviando | bloqueado | Loading spinner | Ninguna |
| Error de red | desbloqueado | Activo (#D14343) | Reintentar o cancelar |
