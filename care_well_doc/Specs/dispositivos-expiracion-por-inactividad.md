# Dispositivos push — Expiración por inactividad

> **Destinatario:** Esteban (implementación propia)
> **Autor:** `arquitecto-software`
> **Estado:** especificación cerrada
> **Origen:** hallazgo 1 (crítico/importante) de la code-review de la Fase 5
> **Alcance:** solo backend. **Sin cambios en Flutter. Sin migración de esquema.**

---

## 1. El problema

`AuthInterceptor.onError` (`care_well_app/lib/infrastructure/http/auth_interceptor.dart:50`)
limpia la sesión por su cuenta cuando el refresh token falla:

```dart
await _tokenStorage.clear();
```

Ese camino **nunca pasa por `cerrarSesionProvider`**, que es el único lugar que da de baja el
dispositivo. Resultado: la fila de `t_DispositivoUsuario` queda `Activo = 1` apuntando al usuario
anterior, y el teléfono **sigue recibiendo las emergencias de ese equipo**.

Android muestra esos avisos en la pantalla de bloqueo, sin desbloquear. El cuerpo que arma el
backend es:

```
"{Activador} activó una alerta de emergencia para {Persona}."
```

Nombre y apellido de la persona bajo cuidado, legibles por cualquiera que mire el teléfono, sobre
una sesión que el propio sistema ya invalidó.

### Por qué no se arregla desde el cliente

La opción intuitiva —que el interceptor dé de baja el dispositivo antes del `clear()`— **no
funciona**: en ese punto el JWT ya venció y el refresh ya falló, así que `POST /api/Dispositivo/eliminar`
devolvería 401. No hay credencial con la cual autenticar la baja.

Lo dejo escrito para que no se intente más adelante.

### Casos que YA están cubiertos (no hay que hacer nada)

| Caso | Cómo se resuelve hoy |
|---|---|
| Logout explícito | `cerrarSesionProvider` da de baja antes de limpiar la sesión |
| App desinstalada | FCM responde `UNREGISTERED` y `NotificarEmergenciaBusinessService` desactiva el token |
| Otro usuario entra en el mismo teléfono | `Reasignar()` reapunta la fila al nuevo usuario |
| Colaborador sacado del equipo | Los destinatarios se filtran por asignación activa **al momento del envío** |
| Cuenta eliminada | `EliminarCuentaBusinessService` llama a `DesactivarTodosDelUsuario` |

El único agujero es **sesión vencida sin logout y sin que nadie vuelva a entrar**. Angosto, pero
de duración indefinida.

---

## 2. La corrección a mi propia propuesta

En la code-review sugerí llamar a un `RegistrarUso()` **en cada envío push exitoso**. Estaba mal
y hubiera dejado la funcionalidad inservible.

Razón: un dispositivo con sesión muerta **sigue recibiendo** las emergencias. Si cada recepción
refrescara `FechaUltimoUso`, el dispositivo se auto-renovaría para siempre y jamás expiraría —
exactamente el caso que queremos cortar. La señal se retroalimentaría a sí misma.

**El heartbeat correcto es el re-registro del cliente con un JWT válido**, porque eso sí prueba
que hay una sesión autenticada viva detrás.

Y la buena noticia es que **ya está ocurriendo**:

```
Flutter: pushTokenRegistrationProvider (se ejecuta en cada arranque con sesión activa)
      -> POST /api/Dispositivo/registrar
      -> AdministrarDispositivoBusinessService.Registrar
      -> dispositivo.Reasignar(usuario)
      -> this.FechaUltimoUso = DateTime.Now;   // DispositivoUsuario.cs:48
```

O sea: **la fecha ya se escribe en cada apertura de la app. Lo único que falta es leerla.**

Por eso esta tarea no necesita migración de esquema, ni job de fondo, ni tocar el cliente.

---

## 3. El umbral no se elige: se deriva

En vez de inventar un "90 días" arbitrario, el número sale del propio sistema.

El refresh token vive **30 días** (`TokenAutorizacionBusinessService.cs:68`,
`DateTime.Now.AddDays(30)`). De ahí se sigue una implicación fuerte:

> Un dispositivo que no se re-registró en más de 30 días **no puede** tener una sesión válida,
> porque su refresh token ya venció. Su sesión está probadamente muerta.

Entonces la regla es: **un dispositivo no puede seguir siendo destinatario por más tiempo del que
puede sobrevivir la sesión que lo registró.** El umbral queda atado a la vigencia del refresh
token, y si mañana se cambia una, la otra lo sigue sola.

Efecto secundario positivo: hoy el `30` está hardcodeado como número mágico. Esta tarea lo
extrae a una constante con nombre.

---

## 4. La decisión de diseño que hay que cuidar

`GetActivosPorUsuario` tiene **dos consumidores con necesidades opuestas**:

| Consumidor | Qué necesita |
|---|---|
| `NotificarEmergenciaBusinessService.Notificar` | Solo los **vigentes**. Es el que hay que filtrar. |
| `AdministrarDispositivoBusinessService.DesactivarTodosDelUsuario` (eliminar cuenta) | **Todos**, incluidos los vencidos. |

Si se filtra dentro de `GetActivosPorUsuario`, se rompe la purga de la cuenta: los dispositivos
vencidos quedarían con `Activo = 1` para siempre, huérfanos de un usuario borrado.

**Por eso va un método nuevo, y `GetActivosPorUsuario` no se toca.**

Es el error más fácil de cometer acá, así que lo dejo señalado antes del paso a paso.

---

## 5. Estrategia: filtrar al leer, no barrer al escribir

Se aplica el corte **en la consulta de destinatarios**, no con un proceso que recorra la tabla
marcando filas.

**Por qué:**
- Es *fail-safe*: no depende de que algo se haya ejecutado. Si el filtro está, la regla se cumple
  siempre, incluso sobre datos viejos ya existentes en la base.
- No introduce un `IHostedService`, ni Hangfire, ni una tarea programada. Cero infraestructura
  nueva en un MVP de tesis.
- Es reversible: si el umbral resulta molesto, se cambia una constante. No hay que revertir filas
  que un job ya pisó.

**Trade-off que se acepta:** las filas vencidas quedan con `Activo = 1` en la tabla, aunque no
reciban nada. El flag pasa a significar "no dado de baja explícitamente", no "notificable". Se
documenta en el código para que nadie lo lea mal desde SQL.

**Alternativa descartada:** un job nocturno que desactive los vencidos. Deja la tabla más prolija,
pero agrega infraestructura y una ventana de exposición entre corridas, sin ningún beneficio de
seguridad sobre el filtro. Si algún día molesta el ruido en la tabla, se agrega **además** del
filtro, nunca en su lugar.

---

## 6. Paso a paso

### Paso 1 — Constante de sesión

**Archivo nuevo:** `CareWell.Global/Constantes/Auth/ParametrosSesion.cs`

```csharp
namespace CareWell.Global.Constantes.Auth
{
    public abstract class ParametrosSesion
    {
        /// <summary>Vigencia del refresh token emitido en el login.</summary>
        public const int DiasVigenciaRefreshToken = 30;

        /// <summary>
        /// Días sin re-registro tras los cuales un dispositivo deja de ser destinatario de push.
        /// Se ata a la vigencia del refresh token: pasado ese plazo el dispositivo no puede tener
        /// una sesión válida, así que no debe seguir recibiendo datos de la persona cuidada.
        /// </summary>
        public const int DiasInactividadDispositivo = DiasVigenciaRefreshToken;
    }
}
```

Sigue el patrón de `ParametrosVerificacionCodigo` y `ParametrosContrasena`.

### Paso 2 — Sacar el número mágico del refresh token

**Archivo:** `CareWell.BusinessService/Auth/TokenAutorizacionBusinessService.cs:68`

```csharp
// Antes
DateTime.Now.AddDays(30));

// Después
DateTime.Now.AddDays(ParametrosSesion.DiasVigenciaRefreshToken));
```

Agregar el `using CareWell.Global.Constantes.Auth;`.

> Sin esto, el paso 1 crea una constante que dice representar algo que en realidad sigue definido
> en otro lado. Quedarían dos fuentes de verdad para el mismo número.

### Paso 3 — Renombrar `Reasignar` a `RegistrarUso`

**Archivo:** `CareWell.Domain/Auth/DispositivoUsuario.cs:41`

Este paso es opcional en lo funcional, pero **lo recomiendo con fuerza** por una razón concreta.

Con este cambio, ese método pasa a ser el **heartbeat del que depende toda la expiración**. Su
nombre actual dice "reasignar el dueño", que es lo que hace en el caso *minoritario* (cambio de
usuario en el mismo teléfono). En el caso mayoritario —el mismo usuario abriendo la app— no
reasigna nada: solo registra que el dispositivo sigue vivo.

El riesgo es concreto y clásico: alguien lee el método, ve que "reasigna" al mismo usuario que ya
estaba, lo considera una escritura inútil y lo optimiza con un `if (this.Usuario.ID != usuario.ID)`.
Eso **rompe silenciosamente la expiración** y nadie se entera hasta que un dispositivo sigue
recibiendo emergencias meses después.

```csharp
/// <summary>
/// Registra que <paramref name="usuario"/> está usando este dispositivo AHORA.
/// </summary>
/// <remarks>
/// Es el heartbeat de la expiración por inactividad: lo invoca el cliente en cada arranque
/// con sesión activa, y <see cref="FechaUltimoUso"/> es lo que decide si el dispositivo sigue
/// siendo destinatario de notificaciones (ver IDispositivoUsuarioRepository.GetVigentesPorUsuario).
///
/// NO condicionar la escritura de FechaUltimoUso a que el usuario haya cambiado: la actualización
/// incondicional es justamente el mecanismo, no una redundancia.
/// </remarks>
public virtual void RegistrarUso(Usuario usuario)
{
    if (usuario is null)
        throw new ValidacionDominioException(Mensajes.UsuarioNoExiste);

    this.Usuario = usuario;
    this.Activo = true;
    this.FechaUltimoUso = DateTime.Now;
}
```

El cuerpo no cambia: solo el nombre y el comentario.

**Arrastra dos archivos:**
- `CareWell.BusinessService/Auth/AdministrarDispositivoBusinessService.cs:55` — la llamada.
- `CareWell.Domain.Test/Auth/DispositivoUsuarioTest.cs` — la clase anidada `ElMetodo_Reasignar`
  y sus llamadas a `this.Target.Reasignar(...)`.
- `CareWell.BusinessService.Test/Auth/AdministrarDispositivoBusinessTest.cs` — los `Verify(...)`
  sobre `Reasignar`.

Si preferís no mover nombres, **como mínimo agregá el bloque `<remarks>`** sobre el método actual.
La trampa que describe es real y el comentario es lo que la desactiva.

### Paso 4 — Método nuevo en el repositorio

**Archivo:** `CareWell.Repository/Auth/IDispositivoUsuarioRepository.cs`

```csharp
public interface IDispositivoUsuarioRepository : IRepository<DispositivoUsuario>
{
    DispositivoUsuario GetByToken(string token);

    /// <summary>
    /// Todos los dispositivos activos del usuario, sin importar su antigüedad.
    /// Para la purga al eliminar la cuenta: ahí hay que alcanzar también a los vencidos.
    /// </summary>
    List<DispositivoUsuario> GetActivosPorUsuario(Usuario usuario);

    /// <summary>
    /// Dispositivos activos del usuario que además se re-registraron después de
    /// <paramref name="fechaLimiteActividad"/>. Es la consulta de destinatarios de push.
    /// </summary>
    List<DispositivoUsuario> GetVigentesPorUsuario(Usuario usuario, DateTime fechaLimiteActividad);
}
```

**Archivo:** `CareWell.Repository/Auth/DispositivoUsuarioRepository.cs`

```csharp
public List<DispositivoUsuario> GetVigentesPorUsuario(Usuario usuario, DateTime fechaLimiteActividad)
{
    return this.DbSet
        .Where(d => d.Usuario.ID == usuario.ID
                 && d.Activo
                 && d.FechaUltimoUso >= fechaLimiteActividad)
        .ToList();
}
```

> **La fecha límite entra por parámetro, no se calcula acá.** Así el repositorio no toma
> decisiones de negocio y el método se puede testear con una fecha fija, sin depender de
> `DateTime.Now`. La política vive en quien llama.
>
> El nombre `GetVigentesPorUsuario` no es nuevo en el proyecto: `IRefreshTokenRepository` ya usa
> exactamente ese verbo para la misma idea.

### Paso 5 — Aplicar el filtro en el envío

**Archivo:** `CareWell.BusinessService/Emergencias/NotificarEmergenciaBusinessService.cs`

```csharp
var fechaLimiteActividad = DateTime.Now.AddDays(-ParametrosSesion.DiasInactividadDispositivo);

foreach (var usuario in usuariosDestinatarios)
{
    dispositivos.AddRange(this.DispositivoUsuarioRepository.GetVigentesPorUsuario(usuario, fechaLimiteActividad));
}
```

Calculalo **una sola vez fuera del `foreach`**: dentro, cada iteración tendría un `DateTime.Now`
apenas distinto y el corte dejaría de ser uniforme entre destinatarios de la misma emergencia.

Agregar el `using CareWell.Global.Constantes.Auth;`.

**No tocar** `AdministrarDispositivoBusinessService.DesactivarTodosDelUsuario`: sigue usando
`GetActivosPorUsuario` sin filtro, que es lo correcto para la purga de cuenta.

### Paso 6 — De paso, mientras estás en ese archivo

Dos cosas que salieron en la code-review y viven en el mismo código:

**a)** `NotificarEmergenciaBusinessService.cs:57` — borrar la variable muerta:

```csharp
var destinatariosNoAlcanzados = new List<Usuario>();   // se declara y nunca se usa
```

Es un resto del fallback por email que descartamos.

**b)** `ActivarEmergenciaBusinessService.cs:77` — el `catch { }` silencioso:

```csharp
catch { }
```

El comportamiento es correcto (un fallo de push nunca debe voltear el request) pero **sin log no
hay diagnóstico**: si FCM se cae, nadie se entera jamás. Es la misma clase de problema que nos
costó la saga del `Fids`. Inyectar `ILogger<ActivarEmergenciaBusinessService>` y dejar:

```csharp
catch (Exception ex)
{
    this.Logger.LogWarning(ex, "Falló el envío de la notificación de emergencia {EmergenciaID}.", emergencia.ID);
}
```

No cambia el flujo: la emergencia ya se persistió antes del `try`.

### Paso 7 (opcional) — Índice

El filtro nuevo consulta por `ID_Usuario + Activo + FechaUltimoUso`. El índice actual
(`DispositivoUsuarioConfig.cs:25`) cubre las dos primeras:

```csharp
builder.HasIndex("ID_Usuario", nameof(DispositivoUsuario.Activo));
```

Extenderlo con `FechaUltimoUso` lo dejaría cubriendo la consulta entera. **A la escala de este
proyecto no hace ninguna diferencia medible** —son pocas filas por usuario— y sí obliga a generar
una migración. Lo dejo anotado como mejora, no como paso necesario.

Si lo hacés igual:

```bash
dotnet ef migrations add IndiceDispositivoUsuarioPorActividad --project CareWell.Repository --startup-project CareWell.API
```

---

## 7. Tests

### 7.1 Dominio — `CareWell.Domain.Test/Auth/DispositivoUsuarioTest.cs`

Si hiciste el paso 3, renombrar la clase anidada a `ElMetodo_RegistrarUso` y agregar:

```
Actualiza_la_FechaUltimoUso_aunque_el_Usuario_sea_el_mismo()
```

Ese test es el que **fija la regla** del `<remarks>`: si alguien agrega el `if` que optimiza la
escritura, este test se pone en rojo. Es la parte más valiosa de todo el set.

### 7.2 BusinessService — `CareWell.BusinessService.Test/Emergencias/`

Sobre `NotificarEmergenciaBusinessService`, con `IDispositivoUsuarioRepository` mockeado:

```
Consulta_los_dispositivos_con_la_fecha_limite_derivada_de_ParametrosSesion()
Usa_la_misma_fecha_limite_para_todos_los_destinatarios()
No_envia_nada_si_ningun_destinatario_tiene_dispositivos_vigentes()
```

Para el primero, verificá con un `It.Is<DateTime>(f => ...)` sobre una ventana de tolerancia (por
ejemplo ±5 segundos respecto del valor esperado), no con igualdad exacta: adentro hay un
`DateTime.Now`.

El segundo se cubre capturando la fecha de cada invocación con un `Callback` y comparando que
todas sean idénticas. Es el que protege contra mover el cálculo dentro del `foreach`.

### 7.3 El que NO hay que olvidarse

```
DesactivarTodosDelUsuario_alcanza_tambien_a_los_dispositivos_vencidos()
```

En `AdministrarDispositivoBusinessTest`. Verifica que se sigue llamando a `GetActivosPorUsuario`
y **no** al método filtrado. Es la regresión que protege contra el error del punto 4.

---

## 8. Verificación manual

Sin esperar 30 días: envejecé una fila a mano.

```sql
-- Estado inicial
SELECT ID_DispositivoUsuario, ID_Usuario, Activo, FechaAlta, FechaUltimoUso
FROM t_DispositivoUsuario;

-- Envejecer el dispositivo 31 días
UPDATE t_DispositivoUsuario
SET FechaUltimoUso = DATEADD(DAY, -31, GETDATE())
WHERE ID_DispositivoUsuario = <id>;
```

| # | Acción | Resultado esperado |
|---|---|---|
| 1 | Activar una emergencia desde otro dispositivo del equipo | El teléfono envejecido **no** recibe nada |
| 2 | Abrir la app en el teléfono envejecido (con sesión viva) | `FechaUltimoUso` vuelve a `GETDATE()` |
| 3 | Activar otra emergencia | Ahora **sí** llega |
| 4 | Envejecer de nuevo y eliminar la cuenta | Todas las filas del usuario quedan `Activo = 0`, incluida la vencida |

El paso 4 es el que valida la decisión del punto 4. Si esa fila queda en `Activo = 1`, el filtro
se coló dentro de `GetActivosPorUsuario`.

---

## 9. Resumen de archivos

| Archivo | Acción |
|---|---|
| `Global/Constantes/Auth/ParametrosSesion.cs` | **nuevo** |
| `BusinessService/Auth/TokenAutorizacionBusinessService.cs` | usar la constante (línea 68) |
| `Domain/Auth/DispositivoUsuario.cs` | renombrar `Reasignar` + `<remarks>` |
| `Repository/Auth/IDispositivoUsuarioRepository.cs` | agregar `GetVigentesPorUsuario` |
| `Repository/Auth/DispositivoUsuarioRepository.cs` | implementarlo |
| `BusinessService/Emergencias/NotificarEmergenciaBusinessService.cs` | usar el método nuevo + limpieza |
| `BusinessService/Emergencias/ActivarEmergenciaBusinessService.cs` | log en el catch |
| `BusinessService/Auth/AdministrarDispositivoBusinessService.cs` | solo el rename |
| Tests de dominio y business | ajustar y agregar |

**Sin migración. Sin cambios en Flutter. Sin infraestructura nueva.**

---

## 10. Para el analista funcional

Cuando esto esté, corresponde documentar en `CuidadoPersonas.tex` que un dispositivo deja de
recibir avisos si la app no se abre con sesión activa durante 30 días, y que vuelve a habilitarse
solo con abrir la app. Te lo dejo redactado junto con el resto del módulo.
