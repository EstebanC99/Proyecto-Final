# 06 · Cambio exitoso — contraseña actualizada

> **v2 (OTP).** Pantalla final del flujo US-03. Reutilizada en US-09 (cambio de contraseña desde
> Configuración) a través del widget compartido `SuccessView`.
> Tokens en `00-sistema-diseno.md`.
> Implementación: `care_well_app/lib/presentation/screens/auth/reset_password_success_screen.dart`
> (envuelve `presentation/widgets/shared/success_view.dart`).
> Ruta: `/auth/reset-password/success` (`resetPasswordSuccessName`).

## Objetivo

Confirmar al usuario que su contraseña fue actualizada correctamente y guiarlo al inicio de
sesión. Pantalla de cierre del flujo: celebratoria, clara, sin opciones superfluas. Además informa
un efecto colateral real del backend que el usuario debería conocer: se cerraron sus sesiones
activas en otros dispositivos.

## Layout — jerarquía de componentes

```
PopScope(canPop: false)  ← evita volver al formulario con el back del sistema
└─ SuccessView
   ├─ Ícono check_circle_outline, 80 dp, en contenedor circular 112 dp (successContainer)
   ├─ Título "¡Contraseña actualizada!" (28 sp bold, centrado)
   ├─ Subtítulo: "Ya podés iniciar sesión con tu nueva contraseña. Por seguridad,
   │   cerramos tu sesión en otros dispositivos." (centrado, textSecondary)
   └─ PrimaryButton "Ir al inicio de sesión" (full-width)
```

## Estados

Pantalla de un solo estado (éxito). No tiene variantes de carga ni error: se llega acá únicamente
cuando el servidor ya confirmó el cambio.

## Interacciones y comportamiento

- **"Ir al inicio de sesión":** `goNamed('login')`.
- **Back del sistema (Android):** interceptado por `PopScope(canPop: false)`; redirige a Login en
  vez de volver al formulario de `03-confirmar-codigo` (el código ya fue consumido, no tiene
  sentido permitir volver).
- **Sin AppBar:** pantalla terminal, sin navegación interna adicional.

## Reutilización en US-09

Cuando se usa desde Configuración (cambio de contraseña con sesión activa), el `PrimaryButton` y
el subtítulo cambian de destino/copy (vuelve a Configuración en vez de a Login, y no aplica la
mención a "cerramos tu sesión en otros dispositivos" salvo que el backend también invalide otras
sesiones en ese flujo). Ver spec de US-09 para el detalle de esa variante.

## Navegación

- **Entrada:** `03-confirmar-codigo` → servidor confirma el cambio → `goNamed(resetPasswordSuccessName)`.
- **Salida:** Login → `goNamed(loginName)` (tap en el botón o back del sistema).
