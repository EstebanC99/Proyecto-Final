# 03 · Términos y condiciones — pantalla de lectura

> Pantalla de solo lectura con el contenido completo de los T&C.
> Tokens en `00-sistema-diseno.md`. HTML: `html/02-terminos-condiciones.html`.

## Propósito

Permitir que el usuario consulte los Términos y Condiciones de uso de CareWell en cualquier
momento, sin necesidad de ir al flujo de registro. La pantalla es de solo lectura: no tiene
acciones pendientes ni botones de aceptación. El contenido es idéntico al que aparece en el
bottom sheet de US-01 Paso 2.

## Wireframe (ASCII)

```
┌──────────────────────────────────────────────┐  ← background (#F6F8F8)
│ 9:41                                  5G 100% │   status bar (#16201F)
│ ←  Términos y condiciones                    │   AppBar surface, borde inferior outline
│──────────────────────────────────────────────│
│                                              │
│   Última actualización: enero 2025           │   12px textSecondary, margen sup 16dp
│                                              │
│   1. ACEPTACIÓN DE TÉRMINOS                  │   titleSmall 14px 700
│   Al registrarse y utilizar CareWell,        │   bodyMedium 14px 400, line-height 1.6
│   el Usuario acepta los presentes            │
│   Términos y Condiciones...                  │
│                                              │
│   2. USO DEL SERVICIO                        │
│   CareWell es una herramienta de apoyo       │
│   para la coordinación del cuidado. No       │
│   reemplaza la atención médica...            │
│                                              │
│   3. RESPONSABILIDAD DEL USUARIO             │
│   Los datos personales suministrados         │
│   deben ser verdaderos, completos...         │
│                                              │
│   4. PRIVACIDAD Y DATOS                      │
│   Los datos personales son tratados          │
│   conforme a la Ley 25.326 de...             │
│                                              │
│   [texto continúa por debajo del fold]       │   gradiente sutil al pie para indicar scroll
│                                              │
│──────────────────────────────────────────────│
│        Deslizá para leer mas                 │   ScrollHint 12px textDisabled, centrado
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Status bar | 28 dp, fondo `#16201F`, texto blanco. |
| 2 | AppBar | Fondo `surface` (#FFF). Borde inferior 1 dp `outline`. ARROW_BACK 24 dp `textPrimary`. Título "Términos y condiciones" 18 px 700. Altura 56 dp. AppBar fija (no colapsa al hacer scroll). |
| 3 | Fecha de actualización | "Última actualización: enero 2025". 12 px, color `textSecondary`. Margen superior 16 dp, horizontal 24 dp. |
| 4 | Área de texto (TyCContentArea) | Fondo `surface`. Padding 24 dp horizontal, 16 dp vertical. Scroll vertical nativo. |
| 5 | Encabezado de sección | "1. ACEPTACIÓN DE TÉRMINOS" (y siguientes). 14 px 700 `textPrimary`. Margen superior 20 dp, inferior 8 dp. |
| 6 | Párrafo de contenido | 14 px 400 `textPrimary`, interlineado 1.6. Margen inferior 12 dp. |
| 7 | Gradiente de fade | Degradado vertical `surface → transparent` en los últimos 32 dp del área visible, para indicar que el texto continúa. |
| 8 | ScrollHint | "Deslizá para leer mas". 12 px, color `textDisabled` (#9AA5A5). Centrado. Margen inferior 12 dp. |

## Contenido de los T&C (extracto a mostrar)

```
Última actualización: enero 2025

1. ACEPTACIÓN DE TÉRMINOS
Al registrarse y utilizar CareWell, el Usuario acepta los presentes Términos y Condiciones
en su totalidad. Si no está de acuerdo con alguna de sus disposiciones, deberá abstenerse
de utilizar la aplicación.

2. USO DEL SERVICIO
CareWell es una herramienta de apoyo para la coordinación del cuidado de personas.
No reemplaza la atención médica profesional ni constituye asesoramiento médico, legal
o de otra índole. El uso de la aplicación no exime al Usuario de consultar a los
profesionales correspondientes.

3. RESPONSABILIDAD DEL USUARIO
Los datos personales suministrados deben ser verdaderos, completos y actualizados.
El Usuario es responsable de mantener la confidencialidad de sus credenciales de acceso
y de todas las actividades que ocurran bajo su cuenta.

4. PRIVACIDAD Y DATOS
Los datos personales son tratados conforme a la Ley 25.326 de Protección de Datos
Personales (Argentina) y normativas complementarias. CareWell no vende ni cede datos
personales a terceros sin consentimiento expreso del titular.

5. PROPIEDAD INTELECTUAL
Todos los derechos sobre la aplicación, su diseño, código y contenido son propiedad
de los desarrolladores de CareWell. Queda prohibida su reproducción total o parcial
sin autorización escrita.

6. MODIFICACIONES
CareWell se reserva el derecho de modificar estos Términos en cualquier momento.
Los cambios se comunicarán a través de la aplicación. El uso continuado implica
la aceptación de los nuevos términos.

[continúa...]
```

## Interacciones y comportamiento

- **Scroll vertical:** el usuario puede leer todo el contenido deslizando hacia abajo. La AppBar permanece fija.
- **ARROW_BACK:** hace `pop()` y regresa a Configuración.
- **Back del sistema (Android):** idéntico a ARROW_BACK.
- **Sin acciones adicionales:** no hay botones ni interacciones dentro del contenido (links deshabilitados en la versión MVP).

## Estados

| Estado | Disparador | Comportamiento |
|---|---|---|
| Con contenido | apertura de la pantalla (contenido local) | muestra el texto completo con scroll |

> No hay estado de error de red ni de carga asíncrona en el MVP: el contenido es local.

## Navegación

- **Entrada:** desde Configuración [01], tap ítem "Términos y condiciones".
- **Salida:** ARROW_BACK o gesto back → regresa a Configuración [01].
