# US-10 Cierre de sesion — Sistema de diseno

> Este flujo hereda el sistema de diseno base de CareWell definido en
> `01 - Registro de usuario/00-identidad-visual.md` y los componentes de Configuracion
> definidos en `08 - Consulta de TyC/00-sistema-diseno.md`.
> Aca se documentan las decisiones especificas del flujo de cierre de sesion.

---

## 1. Tokens heredados (recordatorio)

| Concepto | Token / valor |
|---|---|
| Error / destructivo | `error #D14343` · `errorContainer #FBE3E3` |
| Warning | `warning #E0A100` |
| Superficies | `background #F6F8F8` · `surface #FFFFFF` |
| Texto | `textPrimary #16201F` · `textSecondary #566060` |
| Bordes | `outline #C5CECE` |
| Radios | dialog `radiusXl 28` · botones secundario `radiusMd 12` |
| Alturas | boton 44 dp minimo en dialog |
| Tipografia | familia `Inter` (fallback `'Segoe UI', Arial, sans-serif`) |

---

## 2. Componentes especificos de US-10

### 2.1 ConfirmationDialog (patron M3)
Dialog centrado sobre la pantalla con overlay oscuro. Especificaciones:

- **Overlay:** `rgba(0,0,0,0.4)` sobre toda la pantalla. Tap fuera del dialog = cancelar.
- **Contenedor del dialog:** fondo `surface` (#FFF), radio 28 dp, padding 24 dp,
  margen horizontal 24 dp. Ancho = pantalla menos 48 dp de margen total.
- **Ícono:** WARNING 20 dp, color `warning` (#E0A100). Alineado a la izquierda o centrado.
- **Titulo:** 18 px 700 `textPrimary`. Margen superior 12 dp, inferior 8 dp.
- **Cuerpo:** 14 px 400 `textSecondary`. Margen inferior 20 dp.
- **Botones:** fila horizontal con gap 12 dp.
  - Boton cancelar: flex 1, alto 44 dp, radio 12 dp, borde 1 dp `outline`, fondo `surface`,
    texto 14 px 700 `textPrimary`.
  - Boton confirmar (destructivo): flex 1, alto 44 dp, radio 12 dp, sin borde,
    fondo `error` (#D14343), texto 14 px 700 blanco.

### 2.2 SettingsItem — estado activo destructivo
Para el item "Cerrar sesion" cuando el flujo esta activo:
- Fondo `errorContainer` (#FBE3E3)
- Borde izquierdo 3 dp `error` (#D14343)
- Icono, label y chevron en color `error` (#D14343)

---

## 3. Decisiones especificas de US-10

1. **Confirmacion obligatoria antes de cerrar sesion.** Cerrar sesion es una accion
   destructiva del contexto de trabajo (el usuario pierde acceso inmediato). Por eso se
   requiere confirmacion explicita mediante un dialog. No se ejecuta con un solo tap.

2. **Dialog, no pantalla separada.** La confirmacion es un dialog (overlay) sobre la
   pantalla de Configuracion, no una pantalla nueva. Razon: el dialog es mas rapido,
   menos intrusivo, y el patron M3 lo prescribe para acciones de confirmacion breves.

3. **Mensaje del dialog: sin alarmismo, con claridad.** "Vas a salir de tu cuenta.
   Podes volver a ingresar cuando quieras." El texto tranquiliza al usuario: no perdera
   datos, solo cierra la sesion actual.

4. **Boton destructivo en rojo a la derecha.** El CTA principal (destructivo) va a la
   derecha, en rojo `error`. El CTA secundario (cancelar) va a la izquierda, en neutro.
   Este orden sigue la convencion de Android y M3.

5. **Tap fuera del dialog = cancelar.** El scrim (overlay oscuro) es tappable: tocarlo
   descarta el dialog sin cerrar sesion. Comportamiento estandar de M3.

6. **Despues del cierre: ir a Login.** Al confirmar, se invalida el token de sesion en
   el backend, se limpian los datos locales y se navega a `/login` con
   `go('/login')` (reemplaza el stack completo). El usuario no puede volver atras con
   el gesto de back.

7. **El item "Cerrar sesion" usa errorContainer como fondo activo.** A diferencia de
   los otros items que usan `primaryContainer`, los items destructivos activos usan
   `errorContainer` (#FBE3E3) para mantener coherencia con su naturaleza de riesgo.

---

## 4. Mapa de estados

| Estado | Disparador | Componente clave |
|---|---|---|
| Configuracion (item activo) | usuario llega al flujo | item "Cerrar sesion" con fondo errorContainer |
| Dialog visible | tap "Cerrar sesion" | ConfirmationDialog + overlay sobre Configuracion |
| Cerrando sesion | tap "Cerrar sesion" en dialog | boton en loading (spinner breve) |
| Login | confirmacion exitosa | go('/login'), stack limpiado |
| Cancelado | tap "Cancelar" o tap fuera del dialog | dialog se cierra, vuelve a Configuracion normal |
