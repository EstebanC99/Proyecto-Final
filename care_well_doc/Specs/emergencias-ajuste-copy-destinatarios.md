# Emergencias — Ajuste de copy: no afirmar destinatarios ni entrega

> **Destinatario:** `dev-flutter`
> **Autor:** `arquitecto-software`
> **Estado:** especificación cerrada, lista para implementar
> **Origen:** hallazgos 2 y 3 de la code-review de la Fase 5
> **Tamaño estimado:** chico (solo copy y borrado de un parámetro). Sin cambios de arquitectura.

---

## 1. Por qué

En la Fase 5 corregimos la pantalla de alerta enviada (punto 4.9) para que **describa la acción
ejecutada y no el resultado de la entrega**. El cliente no puede verificar la recepción, así que
no debe afirmarla.

Ese cambio quedó aplicado en **una** de las tres pantallas del flujo. Las otras dos siguen
prometiendo lo mismo que sacamos, y una de ellas además muestra un número incorrecto.

### El número está mal, no solo el verbo

`equipoEmergenciaProvider` devuelve **todas** las asignaciones activas de la persona de contexto.
El backend, en cambio, excluye al activador al elegir destinatarios:

```csharp
// EmergenciaRepository.cs:33
a.Colaborador.ID != emergencia.Activador.ID
```

Como quien activa la emergencia casi siempre integra el equipo, **el número que ve el usuario está
inflado en 1 de forma sistemática**. Y la brecha es mayor todavía: solo reciben el aviso los
colaboradores que además tengan usuario con al menos un dispositivo activo.

Esto importa más de lo que parece porque el diálogo de confirmación es la última pantalla que el
usuario ve antes de decidir en una emergencia real. "Se enviará a 4 miembros" cuando van a llegar
2 no es un detalle de redacción: es la única información con la que cuenta para decidir si además
levanta el teléfono y llama.

### Criterio: eliminar el número, no corregirlo

Restar 1 al contador sería peor que dejarlo. Seguiría siendo falso —no contempla quién tiene la
app instalada ni el dispositivo activo— pero ahora con apariencia de precisión. Un número exacto
comunica certeza; acá no hay certeza que comunicar.

Es el mismo criterio con el que sacamos el check verde del listado de miembros.

---

## 2. Cambios

### 2.1 Diálogo de confirmación

**Archivo:** `lib/presentation/widgets/emergency/emergency_confirm_dialog.dart`

**a)** Cuerpo del diálogo (líneas 121-126). Reemplazar:

```dart
Text(
  'Se enviará una notificación urgente a '
  '${widget.cantidadMiembros} miembro${widget.cantidadMiembros != 1 ? 's' : ''} '
  'del equipo de cuidado de ${widget.nombrePersona}. '
  'Usá esto solo ante una situación real.',
```

por:

```dart
Text(
  'Se enviará una alerta urgente al equipo de cuidado de '
  '${widget.nombrePersona}. '
  'Usá esto solo ante una situación real.',
```

**b)** Etiqueta de accesibilidad del botón de confirmación (línea ~142). Reemplazar:

```dart
'Confirmar. Enviar alerta de emergencia a ${widget.cantidadMiembros} personas.',
```

por:

```dart
'Confirmar. Enviar alerta de emergencia al equipo de cuidado.',
```

> El `Semantics` tenía el mismo número inflado. Un lector de pantalla no debe anunciar un dato
> que la pantalla ya no muestra.

**c)** Eliminar el parámetro `cantidadMiembros`, que queda sin uso: líneas 13 (ejemplo del
docstring), 21 (parámetro del constructor), 26 (campo), 33 (parámetro de `show`) y 41 (paso al
constructor).

**d)** En `lib/presentation/screens/emergency/emergency_screen.dart:195`, quitar el argumento
`cantidadMiembros: equipo.length` de la llamada a `EmergencyConfirmDialog.show`.

> Con eso, `final equipo = ref.read(equipoEmergenciaProvider).value ?? [];` (línea 189) queda sin
> uso dentro de `_handleTap`. Borralo también: si no, `flutter analyze` lo marca.

---

### 2.2 Pantalla de emergencia

**Archivo:** `lib/presentation/screens/emergency/emergency_screen.dart`

**a)** Texto explicativo (líneas 66-68). Reemplazar:

```dart
'Al activar la emergencia, todos los miembros del equipo '
'recibirán una notificación inmediata.',
```

por:

```dart
'Al activar la emergencia, se enviará un aviso inmediato '
'a tu equipo de cuidado.',
```

> `recibirán` afirma la entrega; `se enviará` describe la acción. Es la misma sustitución que
> hicimos en la pantalla de alerta enviada.

**b)** Encabezado del listado del equipo (línea 111). Reemplazar:

```dart
miembros.isEmpty
    ? 'Sin miembros en el equipo'
    : 'Se notificará a (${miembros.length} personas):',
```

por:

```dart
miembros.isEmpty
    ? 'Sin miembros en el equipo'
    : 'Equipo de cuidado:',
```

> Mismo encabezado que ya usa la pantalla de alerta enviada. El listado no cambia: sigue siendo
> útil que el usuario vea a quiénes involucra la alerta. Lo que se elimina es la afirmación de
> que a todos ellos se les va a notificar.

`miembros` se sigue usando para renderizar la lista, así que **no** queda sin uso en esta pantalla.

---

## 3. Qué NO hay que tocar

- **`equipoEmergenciaProvider`**: queda como está. Sigue siendo correcto como "equipo de cuidado
  de la persona de contexto"; el problema nunca fue el provider sino la etiqueta que le pusimos
  a su resultado.
- **No filtrar al activador en el cliente.** Sería replicar en Flutter una regla que ya vive en el
  backend, y quedarían dos fuentes de verdad para la misma decisión. Además seguiría sin poder
  saber quién tiene dispositivo activo, así que ni siquiera resolvería el problema.
- **El listado de miembros**, en ninguna de las dos pantallas.
- La pantalla `emergency_sent_screen.dart`, ya corregida en la Fase 5.

---

## 4. Criterios de aceptación

| # | Verificación |
|---|---|
| 1 | `flutter analyze` sin errores ni warnings de variables sin uso |
| 2 | `flutter test` en verde |
| 3 | Ningún texto del módulo de emergencias contiene un número de destinatarios |
| 4 | Ningún texto del módulo afirma que el equipo *recibió* o *recibirá* el aviso |
| 5 | `grep -rn "cantidadMiembros" lib/` no devuelve resultados |
| 6 | Las tres pantallas del flujo usan el mismo encabezado "Equipo de cuidado" |

Para el criterio 4, un chequeo rápido:

```bash
grep -rn "notificad\|recibirán\|Se notificará" lib/presentation/screens/emergency lib/presentation/widgets/emergency
```

Debe volver vacío.

---

## 5. Nota sobre tests

No hay tests que cubran estos textos hoy. **No hace falta agregarlos**: son literales de UI sin
lógica, y un test que afirme un string exacto se rompe con cada ajuste de redacción sin aportar
señal. Si en algún momento el texto pasa a depender de una condición, ahí sí vale un test.

---

## 6. Antes de codificar

Presentá el plan numerado y esperá confirmación, según tu flujo habitual.

Si algún número de línea no coincide con el estado real del código, guiate por el contenido
citado, no por la línea.
