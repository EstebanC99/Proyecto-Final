# 08 · Estado de carga — creando la cuenta

> Overlay sobre el Paso 2 [05] mientras se procesa el registro. Tokens en `00-identidad-visual.md`.

## Propósito
Comunicar que la creación de la cuenta está en curso, bloqueando interacciones para evitar dobles
envíos, sin perder el contexto del formulario.

## Wireframe (overlay sobre Paso 2)

```
┌──────────────────────────────────────────────┐
│░░░░░░░░░ Paso 2 atenuado (scrim @ 30%) ░░░░░░░│
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│░░░░░░░░░░┌──────────────────────┐░░░░░░░░░░░░░│
│░░░░░░░░░░│                      │░░░░░░░░░░░░░│   card surface, radiusLg(16),
│░░░░░░░░░░│         ◜◝            │░░░░░░░░░░░░░│   elev2, padding 24
│░░░░░░░░░░│        ( ⟳ )         │░░░░░░░░░░░░░│   CircularProgressIndicator
│░░░░░░░░░░│         ◟◞            │░░░░░░░░░░░░░│   48dp, color primary
│░░░░░░░░░░│                      │░░░░░░░░░░░░░│
│░░░░░░░░░░│  Creando tu cuenta…  │░░░░░░░░░░░░░│   titleMedium textPrimary
│░░░░░░░░░░│  Esto toma un momento │░░░░░░░░░░░░│   bodyMedium textSecondary
│░░░░░░░░░░└──────────────────────┘░░░░░░░░░░░░░│
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
└──────────────────────────────────────────────┘
```

## Componentes y especificaciones

| # | Componente | Detalle |
|---|---|---|
| 1 | Scrim de bloqueo | Capa sobre el Paso 2: negro @ 30% (`barrierDismissible: false`). Bloquea todo tap y el back mientras dura. |
| 2 | Card de progreso | Centrada. Fondo `surface`, radio `radiusLg (16)`, `elev2`, padding 24 dp, ancho mínimo ~200 dp / máx ~280 dp. |
| 3 | Spinner | `CircularProgressIndicator` 48 dp, color `primary`, stroke 4 dp. |
| 4 | Texto principal | "Creando tu cuenta…" `titleMedium` `textPrimary`, centrado, margen superior 16 dp. |
| 5 | Texto secundario | "Esto toma un momento." `bodyMedium` `textSecondary`, centrado. |

> Alternativa de diseño (documentada): si la app prefiere un loading **a pantalla completa** en
> vez de overlay, usar fondo `background` con la misma card centrada y sin scrim. Se elige overlay
> para conservar el contexto del formulario por si hay que volver a él en caso de error.

## Interacciones y comportamiento
- **Disparo:** al pulsar "Crear cuenta" con validación local OK. Aparece con fade-in 150 ms.
- **Bloqueo:** durante la carga, el botón ya no puede re-dispararse (evita doble submit). El back
  del sistema queda inhibido.
- **Timeout / sin red:** si la petición falla por red/timeout (no por email duplicado), el overlay
  se cierra y se muestra un `SnackBar`/banner: "No pudimos conectar. Revisá tu conexión e intentá
  de nuevo." con acción "Reintentar". El formulario queda intacto.
- **Resultado:**
  - **Éxito (201):** transición a **Pantalla de éxito [09]** (fade 250 ms).
  - **Email ya registrado (409):** overlay se cierra → **Error email registrado [10]** sobre el Paso 2.
  - **Otro error de servidor (5xx):** overlay se cierra → banner genérico "Algo salió mal. Intentá
    de nuevo en unos minutos." con "Reintentar".
- **Accesibilidad:** anunciar "Creando tu cuenta, por favor esperá" como `liveRegion`. El foco se
  retiene en el overlay.

## Estados alternativos
- Este documento ES el estado de carga. Sus salidas (éxito/errores) se especifican en [09] y [10].

## Navegación
- **Entrada:** desde Paso 2 [05] al confirmar "Crear cuenta".
- **Salida:** Éxito [09] · Error email [10] · regreso a Paso 2 con banner (red/5xx).
