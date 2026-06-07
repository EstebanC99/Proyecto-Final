# 10 · Error — el email ya está registrado

> Estado de error del Paso 2 [05] tras respuesta 409 del servidor. Tokens en `00-identidad-visual.md`.

## Propósito
Comunicar que ya existe una cuenta con ese email y ofrecer la acción más útil: iniciar sesión
(o cambiar el email).

## Contexto
El email duplicado NO se detecta localmente; es una validación del servidor que se conoce recién
al hacer submit. Por eso el error se renderiza al **volver del estado de carga [08]** sobre el
Paso 2, no en el Paso 1. El campo email vive en el Paso 1, así que el error se muestra de dos
formas complementarias: (a) un **banner superior accionable** en el Paso 2, y (b) marca persistente
para cuando el usuario vuelva al Paso 1 a corregirlo.

## Wireframe (Paso 2 con banner de error de email)

```
┌──────────────────────────────────────────────┐
│ ┌──┐                                           │
│ │← │                                           │   back → Paso 1 (a corregir email)
│ └──┘                                           │
│  ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰        Paso 2 de 2        │
│                                                │
│  ┌──────────────────────────────────────────┐ │   InlineErrorBanner
│  │ ⚠  Ya existe una cuenta con              │ │   fondo errorContainer(#FBE3E3)
│  │    tucorreo@ejemplo.com.                 │ │   ícono+texto error(#D14343)
│  │                                          │ │
│  │    [ Iniciar sesión ]  [ Cambiar email ] │ │   2 acciones
│  └──────────────────────────────────────────┘ │
│                                                │
│  Creá tu contraseña                            │
│  Vas a usarla junto con tu email para entrar.  │
│                                                │
│  Contraseña                                    │
│  ┌────────────────────────────────────────┐   │
│  │ 🔒  ••••••••                        👁  │   │   (valores conservados)
│  └────────────────────────────────────────┘   │
│  ▰▰▰▰▰▰▰  ▰▰▰▰▰▰▰  ▰▰▰▰▰▰▰     Fuerte ✓        │
│                                                │
│  Confirmar contraseña                          │
│  ┌────────────────────────────────────────┐   │
│  │ 🔒  ••••••••                        👁  │   │
│  └────────────────────────────────────────┘   │
│                                                │
│  ┌──┐                                          │
│  │✓ │ Acepto los Términos y Condiciones…       │   (sigue marcado)
│  └──┘                                          │
│                                                │
│  ┌────────────────────────────────────────┐   │
│  │              Crear cuenta                │   │
│  └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

### Variante al volver al Paso 1 (campo email marcado en error)

```
  Email
  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     borde 2dp error
  ┃ ✉  tucorreo@ejemplo.com                ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  ⚠ Este email ya está registrado. Probá con otro
     o iniciá sesión.                              labelSmall error (2 líneas)
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | `InlineErrorBanner` (Paso 2) | Fondo `errorContainer` (#FBE3E3), radio `radiusMd (12)`, padding 16 dp, ubicado arriba del título del Paso 2 con margen inferior `xl`. Ícono `error_outline` 20 dp `error` + texto `bodyMedium` `error`: "Ya existe una cuenta con {email}." |
| 2 | Acción "Iniciar sesión" | `PrimaryButton` compacto (o text button enfático) `primary`. Acción primaria sugerida. |
| 3 | Acción "Cambiar email" | `SecondaryTextButton` `primary`. Lleva al Paso 1 con foco en el campo email. |
| 4 | Campos de credenciales | Conservan los valores ya ingresados (contraseña, confirmación, fortaleza, T&C). No se borran. |
| 5 | Botón "Crear cuenta" | Sigue disponible; reintentar el submit con el mismo email volverá a fallar (banner persiste) hasta que se cambie el email. |
| 6 | Campo email en Paso 1 (variante) | Borde 2 dp `error` + texto ⚠ "Este email ya está registrado. Probá con otro o iniciá sesión." Se limpia al editar el email (on-change). |

## Interacciones y comportamiento
- **Aparición:** tras respuesta 409 desde [08]; el overlay de carga se cierra (fade-out), aparece
  el banner (fade + slide-down) y el foco se mueve al banner (lector lo anuncia).
- **"Iniciar sesión":** navega al Login [02] con `pushReplacement`, pasando el email para
  precargar el campo. Limpia el stack del registro.
- **"Cambiar email":** vuelve al Paso 1 [03] (slide horizontal) con el campo email en estado error
  y foco puesto en él. Los demás datos del Paso 1 y del Paso 2 se conservan.
- **Editar el email (en Paso 1):** al cambiar el valor, el error de "ya registrado" se limpia
  on-change y el banner del Paso 2 desaparece; el usuario puede reintentar.
- **Reintento sin cambiar email:** "Crear cuenta" vuelve a [08] y, si sigue duplicado, vuelve a
  este estado (banner persiste). No se duplican banners.
- **Distinción de errores:** este banner es exclusivo del 409 (email duplicado). Errores de red
  o 5xx usan SnackBar genérico (ver [08]), no este banner.

## Estados alternativos
- Base del Paso 2 → [05]. Fortaleza → [06]. Carga → [08]. Éxito → [09].
- Si coexisten error de email (409) y un error de validación local de contraseña, ambos se muestran:
  el banner arriba y el error de campo en su lugar.

## Navegación
- **Entrada:** desde Estado de carga [08] tras respuesta 409.
- **Salida:** "Iniciar sesión" → Login [02] (email precargado); "Cambiar email" → Paso 1 [03]
  (campo email en error); o reintento → Carga [08].
