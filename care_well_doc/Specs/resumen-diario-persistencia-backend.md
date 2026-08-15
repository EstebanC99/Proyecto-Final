# Persistencia del Resumen inteligente (US 9.16) — Backend

> **Destinatario:** desarrollador backend (.NET)
> **Autor:** `arquitecto-software`
> **Estado:** **IMPLEMENTADO** (2026-08-13) — build limpio y tests en verde.
> **Desvíos respecto de esta spec, ya aplicados y revisados:** (a) el flag del query se llama
> `Actualizar`, **no** `ForzarActualizacion`, por lo que la clave JSON del body es `"actualizar"`;
> (b) el fallo de deserialización del contenido persistido se trata como *cache miss* y regenera;
> (c) la carrera contra el índice único se resuelve con `catch (DbUpdateException) { }` sin log
> (decisión del cliente: no se implementa el logueo sugerido en la revisión).
> **Alcance:** `care_well_backend/CareWell/` — `Global`, `Domain`, `Repository`, `Queries`, `BusinessService(.Abstractions)`, tests y migración.
> **Specs hermanas:** `resumen-diario-persistencia-frontend.md` (dev-flutter) · `resumen-diario-persistencia-modelo-doc.md` (analista-funcional)

---

## 1. Requerimiento

Hoy cada consulta del resumen diario invoca al modelo de Gemini: `ResumenDiarioBusinessService.Generar`
valida permisos y delega siempre en `ArmarResumenDiarioBusinessService.Armar`. El read-model es
efímero y no se persiste.

Se pide **cachear el resumen en base de datos por persona cuidada**:

1. Al consultar el resumen de una persona, buscar el **resumen persistido** de esa persona.
2. Si existe y su fecha de generación está **dentro de las últimas 3 horas**, responder con ese
   (sin llamar al modelo).
3. Si no existe o está vencido, generar uno nuevo y persistirlo (**sobrescribiendo** el anterior).
4. Si el front pide explícitamente una regeneración (botón "Actualizar" o pull-to-refresh),
   se regenera sí o sí.

Objetivo: evitar una inferencia paga por cada apertura de pantalla cuando la información del día
no cambió.

---

## 2. Decisiones de diseño (y sus trade-offs)

| # | Decisión | Alternativa descartada | Justificación |
|---|---|---|---|
| D1 | Persistir el resumen como **snapshot JSON** en una entidad `ResumenDiario` (Persona, FechaHoraGeneracion, Contenido) | Modelo relacional completo (`ResumenDiario` + hábitos + eventos + recomendaciones = 5 tablas) | Es un **read-model derivado**: nadie lo consulta por partes ni lo edita. Relacional obligaría a migrar el esquema cada vez que cambie la forma de la salida de la IA, sin ganancia de consulta. Costo: no es queryable y hay que tolerar snapshots de formatos viejos (mitigado en D7). |
| D2 | La **regla de vigencia vive en la entidad** (`ResumenDiario.EstaVigente(ahora)`); el repositorio sólo trae "el resumen de la persona" | Filtrar por fecha en el `Where` del repositorio | Es una regla de negocio: así queda testeable en `CareWell.Domain.Test` sin BD y explícita en el dominio. La consulta es puntual por índice único. |
| D3 | Vigencia = **mismo día calendario Y menos de 3 h** | Sólo "menos de 3 h" | Sin la condición de fecha, un resumen generado a las 23:30 se serviría a las 00:30 como "resumen de hoy", cuando el texto habla del "hoy" y el "mañana" del día anterior. |
| D4 | **No persistir resúmenes sin datos** (`TieneDatos == false`) | Persistir todo | Ese camino ni siquiera llama a Gemini (`ArmarResumenDiarioBusinessService`, corte por `eventosRegistrados == default`): cachearlo no ahorra nada y **congelaría 3 h un "sin registros"** aunque se cargue un evento un minuto después. |
| D5 | **Una fila por persona (upsert)**: si ya existe un resumen de esa persona se **actualizan** su contenido y su fecha de generación; índice **único** sobre `ID_Persona` | Guardar histórico (una fila por generación) | La caché es literalmente una caché: la tabla tiene tantas filas como personas cuidadas, sin política de retención que mantener y sin acumular textos con datos de salud que nadie consulta (minimización de datos, argumento fuerte en la sección de privacidad). Se pierde la traza de generaciones anteriores; si hiciera falta, ya está cubierta por `t_LogServicioExterno`, que guarda request y response de cada llamada a Gemini. |
| D6 | Cachear **por persona cuidada**, no por (persona, usuario) | Caché por usuario consultante | El contenido no depende del usuario: `Armar` sólo recibe `personaCuidadaID` y el nombre. El permiso se valida **antes** de leer la caché, así que no cambia lo que cada usuario puede ver. |
| D7 | Snapshot ilegible ⇒ se trata como "no hay caché" y se regenera | Propagar la excepción de deserialización | Un cambio de contrato del `ResumenDiarioDataView` no debe romper la pantalla: degrada a regenerar. |
| D8 | **Piso anti-rebote** también para el forzado: `PermiteRegenerar`, 1 minuto | Forzar = siempre regenerar | Sin piso, un doble tap o un pull-to-refresh compulsivo son N llamadas pagas. El usuario no percibe nada raro: recibe un resumen de hace segundos. El valor se ajusta por constante (`MinutosMinimosEntreRegeneraciones`); ponerlo en `0` desactiva el mecanismo sin tocar código. |

### Riesgos asumidos (no bloqueantes)

- **Datos que cambian dentro de la ventana:** si se carga un evento a los 10 minutos, el usuario ve
  el resumen anterior hasta que toque "Actualizar". Es el trade-off pedido. *Mejora futura:* guardar
  un fingerprint de las fuentes (cantidad + `max(FechaHora)` de cada origen) y regenerar si cambió.
- **Concurrencia (relevante por D5):** la generación tarda 10-20 s, así que dos usuarios del mismo
  dependiente que abran la pantalla a la vez pueden generar en paralelo. Mitigación incorporada al
  diseño: `Persistir` **relee** el resumen de la persona justo antes de guardar (Paso 9), de modo que
  el segundo en terminar actualiza la fila del primero en lugar de insertar una segunda. Queda una
  ventana residual de milisegundos entre el `SELECT` y el `INSERT` en la que el índice único podría
  rechazar el alta: por eso `Persistir` atrapa `DbUpdateException` y devuelve el resumen igual — la
  persistencia es una optimización de costo, nunca debe tumbar una respuesta ya calculada.
- **Zona horaria:** se usa `DateTime.Now` del servidor, igual que el resto del backend. Si el VPS
  corriera en UTC, el "mismo día" es el del servidor. Consistente con lo existente, pero tenerlo
  presente en el deploy.

---

## 3. Pasos de implementación

### Paso 1 — Constantes

**Nuevo:** `CareWell.Global/Constantes/General/ParametrosResumenDiario.cs`

```csharp
namespace CareWell.Global.Constantes.General
{
    public abstract class ParametrosResumenDiario
    {
        /// <summary>Ventana durante la cual un resumen ya generado se reutiliza sin volver a llamar al modelo.</summary>
        public const int HorasVigencia = 3;

        /// <summary>Piso entre regeneraciones forzadas: evita que un doble tap dispare dos inferencias.</summary>
        public const int MinutosMinimosEntreRegeneraciones = 1;
    }
}
```

### Paso 2 — Mensajes

**Editar:** `CareWell.Global/Mensajes/Mensajes.cs`

```csharp
public const string ResumenDiarioContenidoRequerido = "El contenido del resumen diario es requerido.";
public const string ResumenDiarioFechaGeneracionRequerida = "La fecha de generación del resumen diario es requerida.";
```

### Paso 3 — Value Object

**Nuevo:** `CareWell.Domain/ValueObjects/General/GenerarResumenDiario.cs`

```csharp
using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.General
{
    public record GenerarResumenDiario
    (
        Persona Persona,
        string Contenido,
        DateTime FechaHoraGeneracion
    );
}
```

> **Por qué la fecha entra por el VO** en vez de resolverse con `DateTime.Now` dentro de la entidad:
> tiene que ser **la misma** que el `GeneradoEn` del DataView serializado. Si la generación tarda
> 25 s, la fila y el contenido dirían horas distintas, y el chip "generado hace…" no coincidiría con
> la ventana de vigencia.

### Paso 4 — Entidad

**Nuevo:** `CareWell.Domain/General/ResumenDiario.cs`

```csharp
using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Constantes.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.General
{
    /// <summary>
    /// Snapshot del resumen inteligente generado por IA para una persona cuidada (US 9.16).
    /// Se conserva un único resumen por persona: cada generación sobrescribe al anterior.
    /// El contenido es opaco para el dominio (JSON del read-model): acá sólo viven la identidad,
    /// el momento de generación y la regla de vigencia.
    /// </summary>
    public class ResumenDiario : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual DateTime FechaHoraGeneracion { get; private set; }

        public virtual string Contenido { get; private set; }

        /// <summary>
        /// Fija el contenido generado. Se usa tanto para el alta como para la regeneración:
        /// reasigna todos los datos, de modo que invocarlo sobre una instancia ya persistida
        /// equivale a sobrescribir el resumen de esa persona.
        /// </summary>
        public virtual void Generar(GenerarResumenDiario generarResumenDiario)
        {
            if (generarResumenDiario.Persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            if (string.IsNullOrWhiteSpace(generarResumenDiario.Contenido))
                throw new ValidacionDominioException(Mensajes.ResumenDiarioContenidoRequerido);

            if (generarResumenDiario.FechaHoraGeneracion == default)
                throw new ValidacionDominioException(Mensajes.ResumenDiarioFechaGeneracionRequerida);

            this.Persona = generarResumenDiario.Persona;
            this.Contenido = generarResumenDiario.Contenido;
            this.FechaHoraGeneracion = generarResumenDiario.FechaHoraGeneracion;
        }

        /// <summary>
        /// El resumen se reutiliza sólo si es del mismo día calendario que la consulta
        /// y todavía está dentro de la ventana de vigencia.
        /// </summary>
        public virtual bool EstaVigente(DateTime fechaHoraReferencia)
        {
            if (this.FechaHoraGeneracion > fechaHoraReferencia)
                return false;

            if (this.FechaHoraGeneracion.Date != fechaHoraReferencia.Date)
                return false;

            return this.FechaHoraGeneracion.AddHours(ParametrosResumenDiario.HorasVigencia) > fechaHoraReferencia;
        }

        /// <summary>Piso anti-rebote para las regeneraciones pedidas explícitamente.</summary>
        public virtual bool PermiteRegenerar(DateTime fechaHoraReferencia)
        {
            return this.FechaHoraGeneracion.AddMinutes(ParametrosResumenDiario.MinutosMinimosEntreRegeneraciones) <= fechaHoraReferencia;
        }
    }
}
```

### Paso 5 — Configuración EF Core (Fluent API)

**Nuevo:** `CareWell.Repository/Config/General/ResumenDiarioConfig.cs`

```csharp
using CareWell.Domain.General;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.General
{
    public class ResumenDiarioConfig : IEntityTypeConfiguration<ResumenDiario>
    {
        public void Configure(EntityTypeBuilder<ResumenDiario> builder)
        {
            builder.ToTable("t_ResumenDiario");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_ResumenDiario").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Cascade);
            builder.Property(e => e.FechaHoraGeneracion).IsRequired();
            builder.Property(e => e.Contenido).IsRequired();   // nvarchar(max) a propósito: JSON del read-model

            // Un único resumen por persona (D5): la fila se sobrescribe en cada generación.
            builder.HasIndex("ID_Persona").IsUnique();
        }
    }
}
```

> Se mantiene `WithMany()` (la `Persona` no expone navegación hacia sus resúmenes) más el índice
> único, en lugar de `WithOne()`: la relación 1—0..1 queda garantizada por la restricción de BD sin
> agregar una propiedad de navegación al agregado `Persona`, que no la necesita.

### Paso 6 — Repositorio

**Nuevo:** `CareWell.Repository/General/IResumenDiarioRepository.cs`

```csharp
using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public interface IResumenDiarioRepository : IRepository<ResumenDiario>
    {
        /// <summary>Resumen persistido de la persona, o null si todavía no se generó ninguno.</summary>
        ResumenDiario ObtenerPorPersona(int personaID);
    }
}
```

**Nuevo:** `CareWell.Repository/General/ResumenDiarioRepository.cs`

```csharp
using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public class ResumenDiarioRepository : Repository<ResumenDiario>, IResumenDiarioRepository
    {
        public ResumenDiarioRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public ResumenDiario ObtenerPorPersona(int personaID)
        {
            return this.DbSet.FirstOrDefault(r => r.Persona.ID == personaID);
        }
    }
}
```

**Editar:** `CareWell.Repository/RepositoryServiceExtensions.cs` — en `#region Business Repos`,
después de `IPersonaRepository` (orden alfabético):

```csharp
services.AddScoped<IResumenDiarioRepository, ResumenDiarioRepository>();
```

### Paso 7 — Query

**Editar:** `CareWell.Queries/General/GenerarResumenDiarioQuery.cs`

```csharp
namespace CareWell.Queries.General
{
    public class GenerarResumenDiarioQuery
    {
        public int PersonaCuidadaID { get; set; }

        /// <summary>Pedido explícito del usuario ("Actualizar" / pull-to-refresh): ignora el resumen vigente.</summary>
        public bool ForzarActualizacion { get; set; }
    }
}
```

> El controller (`ResumenDiarioController.Generar`) **no cambia**: el binding del body absorbe la
> propiedad nueva. El contrato es aditivo y opcional (default `false`).

### Paso 8 — Serializador del read-model

**Nuevo:** `CareWell.BusinessService.Abstractions/General/ISerializadorResumenDiarioBusinessService.cs`

```csharp
using CareWell.DataViews.General;

namespace CareWell.BusinessService.Abstractions.General
{
    public interface ISerializadorResumenDiarioBusinessService
    {
        string Serializar(ResumenDiarioDataView resumenDiario);

        /// <summary>Devuelve null si el contenido persistido no es interpretable (formato viejo o corrupto).</summary>
        ResumenDiarioDataView Deserializar(string contenido);
    }
}
```

**Nuevo:** `CareWell.BusinessService/General/SerializadorResumenDiarioBusinessService.cs`

```csharp
using System.Text.Json;
using System.Text.Json.Serialization;
using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;

namespace CareWell.BusinessService.General
{
    public class SerializadorResumenDiarioBusinessService : ISerializadorResumenDiarioBusinessService
    {
        private static readonly JsonSerializerOptions Opciones = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            PropertyNameCaseInsensitive = true,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
        };

        public string Serializar(ResumenDiarioDataView resumenDiario)
        {
            return JsonSerializer.Serialize(resumenDiario, Opciones);
        }

        public ResumenDiarioDataView Deserializar(string contenido)
        {
            if (string.IsNullOrWhiteSpace(contenido))
                return null;

            try
            {
                return JsonSerializer.Deserialize<ResumenDiarioDataView>(contenido, Opciones);
            }
            catch (JsonException)
            {
                // Snapshot ilegible (p. ej. contrato viejo): se trata como "no hay caché" y se regenera.
                return null;
            }
        }
    }
}
```

> - `ResumenDiarioDataView.TieneDatos` es `get`-only: se escribe en el JSON y al deserializar se
>   ignora (se recalcula solo). No hay que tocarlo.
> - **Por qué un servicio y no un método privado:** permite mockear la serialización en los tests del
>   business service, en lugar de acoplarlos al formato exacto del JSON.

### Paso 9 — Orquestación (núcleo del cambio)

**Editar (reemplazar):** `CareWell.BusinessService/General/ResumenDiarioBusinessService.cs`

```csharp
using CareWell.BusinessService.Abstractions.General;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Queries.General;
using CareWell.Repository;
using CareWell.Repository.General;
using CareWell.Security;
using Microsoft.EntityFrameworkCore;

namespace CareWell.BusinessService.General
{
    public class ResumenDiarioBusinessService : BusinessService, IResumenDiarioBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IBaseFactory Factory { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IArmarResumenDiarioBusinessService ArmarResumenDiarioBusinessService { get; set; }
        private ISerializadorResumenDiarioBusinessService SerializadorResumenDiarioBusinessService { get; set; }
        private IResumenDiarioRepository ResumenDiarioRepository { get; set; }

        public ResumenDiarioBusinessService(IUnitOfWork unitOfWork,
                                            IUserContext userContext,
                                            IEntityLoaderDomainService entityLoaderDomainService,
                                            IBaseFactory baseFactory,
                                            IValidadorPermisoAccion validadorPermisoAccion,
                                            IArmarResumenDiarioBusinessService armarResumenDiarioBusinessService,
                                            ISerializadorResumenDiarioBusinessService serializadorResumenDiarioBusinessService,
                                            IResumenDiarioRepository resumenDiarioRepository)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.Factory = baseFactory;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.ArmarResumenDiarioBusinessService = armarResumenDiarioBusinessService;
            this.SerializadorResumenDiarioBusinessService = serializadorResumenDiarioBusinessService;
            this.ResumenDiarioRepository = resumenDiarioRepository;
        }

        public async Task<ResumenDiarioDataView> Generar(GenerarResumenDiarioQuery query, CancellationToken cancellationToken)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var personaCuidada = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaCuidadaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(personaCuidada, usuario.Persona);

            var fechaHoraConsulta = DateTime.Now;
            var resumenPersistido = this.ResumenDiarioRepository.ObtenerPorPersona(personaCuidada.ID);

            var resumenReutilizable = this.ObtenerResumenReutilizable(resumenPersistido, query.ForzarActualizacion, fechaHoraConsulta);

            if (resumenReutilizable is not null)
                return resumenReutilizable;

            var resumenDiario = await this.ArmarResumenDiarioBusinessService.Armar(personaCuidada.ID, personaCuidada.Nombre, cancellationToken);

            this.Persistir(personaCuidada, resumenDiario);

            return resumenDiario;
        }

        #region Metodos Privados

        /// <summary>
        /// Decide si se puede responder con el resumen persistido:
        /// - consulta normal: sólo si sigue vigente;
        /// - regeneración forzada: sólo si el persistido es demasiado reciente (anti-rebote).
        /// Devuelve null si hay que regenerar o si el snapshot no es interpretable.
        /// </summary>
        private ResumenDiarioDataView ObtenerResumenReutilizable(ResumenDiario resumenPersistido, bool forzarActualizacion, DateTime fechaHoraConsulta)
        {
            if (resumenPersistido is null)
                return null;

            var reutilizable = forzarActualizacion
                ? !resumenPersistido.PermiteRegenerar(fechaHoraConsulta)
                : resumenPersistido.EstaVigente(fechaHoraConsulta);

            if (!reutilizable)
                return null;

            return this.SerializadorResumenDiarioBusinessService.Deserializar(resumenPersistido.Contenido);
        }

        /// <summary>
        /// Guarda el snapshot: se conserva un único resumen por persona, así que si ya existe uno
        /// se sobrescribe en lugar de insertar. Se relee el resumen (y no se reutiliza el leído al
        /// inicio) porque entre medio pasaron los segundos que tardó el modelo y otro request pudo
        /// haber creado el registro.
        ///
        /// Los resúmenes sin datos no se persisten: no consumieron una llamada al modelo y
        /// cachearlos congelaría un "sin registros" por horas. En ese caso el resumen anterior queda
        /// intacto, pero ya vencido, así que nunca se sirve.
        /// </summary>
        private void Persistir(Persona personaCuidada, ResumenDiarioDataView resumenDiario)
        {
            if (!resumenDiario.TieneDatos)
                return;

            var resumen = this.ResumenDiarioRepository.ObtenerPorPersona(personaCuidada.ID);
            var esNuevo = resumen is null;

            if (esNuevo)
                resumen = this.Factory.Crear<ResumenDiario>();

            resumen.Generar(new GenerarResumenDiario(
                Persona: personaCuidada,
                Contenido: this.SerializadorResumenDiarioBusinessService.Serializar(resumenDiario),
                FechaHoraGeneracion: resumenDiario.GeneradoEn));

            if (esNuevo)
                this.ResumenDiarioRepository.Add(resumen);

            try
            {
                this.UnitOfWork.SaveChanges();
            }
            catch (DbUpdateException)
            {
                // Carrera con otra generación simultánea de la misma persona (índice único).
                // El resumen ya está calculado y se devuelve igual: la persistencia es una
                // optimización de costo, no puede tumbar la respuesta.
            }
        }

        #endregion
    }
}
```

> **Sobre el `catch (DbUpdateException)`:** es la única concesión a la concurrencia del proyecto y
> está acotada a la persistencia de la caché. Si preferís no atrapar excepciones de EF en el business
> service, la alternativa es quitar `IsUnique()` del índice (Paso 5) y aceptar que una carrera deje
> una fila duplicada; en ese caso `ObtenerPorPersona` debe ordenar por `FechaHoraGeneracion`
> descendente. Trade-off: se pierde la garantía dura de "un resumen por persona" en la BD.

### Paso 10 — Inyección de dependencias

**Editar:** `CareWell.BusinessService/BusinessServiceExtensions.cs` — en `#region Business Services`
(orden alfabético):

```csharp
services.AddScoped<ISerializadorResumenDiarioBusinessService, SerializadorResumenDiarioBusinessService>();
```

### Paso 11 — Migración

```bash
cd care_well_backend/CareWell
dotnet build
dotnet ef migrations add PersistenciaResumenDiario --project CareWell.Repository --startup-project CareWell.API
# Revisar el Up(): tabla t_ResumenDiario, FK ID_Persona (cascade),
# Contenido nvarchar(max) (sin HasMaxLength, es intencional)
# e índice ÚNICO sobre ID_Persona.
dotnet ef database update --project CareWell.Repository --startup-project CareWell.API
```

### Paso 12 — Tests

**Nuevo:** `CareWell.Domain.Test/General/ResumenDiarioTest.cs`

- `Generar`: setea `Persona`, `Contenido` y `FechaHoraGeneracion`; **reasigna** los tres al invocarlo
  por segunda vez sobre la misma instancia (caso regeneración); lanza `ValidacionDominioException`
  con persona `null`, contenido vacío/whitespace y fecha `default`.
- `EstaVigente`: `true` a los 5 min y a las 2 h 59 min del mismo día; `false` a las 3 h 1 min;
  `false` si la generación fue ayer aunque hayan pasado 30 min (caso 23:50 → 00:20);
  `false` si la generación es futura.
- `PermiteRegenerar`: `false` a los 30 s; `true` a los 2 min.

**Editar:** `CareWell.BusinessService.Test/General/ResumenDiarioBusinessTest.cs` — sumar al
constructor los mocks de `IBaseFactory`, `ISerializadorResumenDiarioBusinessService` e
`IResumenDiarioRepository`, y cubrir:

| Caso | Arrange | Assert |
|---|---|---|
| Resumen vigente, sin forzar | `ObtenerPorPersona` → mock con `EstaVigente == true`; `Deserializar` → dataView | `Armar` **nunca**; `Add` nunca; `SaveChanges` nunca; devuelve el deserializado |
| Resumen vencido (ya existe fila) | `EstaVigente == false` | `Armar` una vez; `Generar` sobre la **instancia existente** una vez; `Add` **nunca**; `SaveChanges` una vez |
| Sin resumen previo | `ObtenerPorPersona` → `null` | `Armar` una vez; `Crear<ResumenDiario>` una vez; `Add` una vez; `SaveChanges` una vez; `Deserializar` nunca |
| Aparece un resumen mientras se generaba | 1.ª llamada a `ObtenerPorPersona` → `null`, 2.ª → una instancia (usar `SetupSequence`) | `Add` **nunca**; se actualiza la instancia hallada; `SaveChanges` una vez |
| Forzado con resumen vigente y `PermiteRegenerar == true` | `ForzarActualizacion = true` | `Armar` una vez; `EstaVigente` **nunca** |
| Forzado con resumen de hace 10 s (`PermiteRegenerar == false`) | `ForzarActualizacion = true` | `Armar` nunca; devuelve el deserializado |
| Snapshot corrupto | `Deserializar` → `null` | `Armar` una vez |
| Resumen sin datos | `Armar` → dataView vacío (`TieneDatos == false`) | `ObtenerPorPersona` una sola vez (no relee); `Add` nunca; `SaveChanges` nunca |
| Carrera al guardar | `SaveChanges` lanza `DbUpdateException` | No propaga la excepción; devuelve el resumen generado |

Se conservan los tests actuales de permisos (`UserContext`, `GetByID`, `ValidarVisualizacion`):
la validación sigue ocurriendo **antes** de mirar la caché.

> `ResumenDiario` tiene todos sus miembros `virtual`: `new Mock<ResumenDiario>()` +
> `Setup(s => s.EstaVigente(It.IsAny<DateTime>()))` funciona igual que con `Usuario`/`Persona`
> en los tests existentes.

```bash
dotnet test
```

---

## 4. Criterios de aceptación (verificación manual)

1. Dos `POST /api/ResumenDiario/generar` seguidos para la misma persona: el segundo responde en
   milisegundos y con **el mismo `generadoEn`**; `t_ResumenDiario` tiene **una sola fila** para esa
   persona.
2. Con `"forzarActualizacion": true` (pasado más de 1 minuto): `generadoEn` cambia, y la fila de esa
   persona sigue siendo **la misma** (`ID_ResumenDiario` no cambia): se actualizaron `Contenido` y
   `FechaHoraGeneracion`.
3. Con `"forzarActualizacion": true` dos veces en menos de 1 minuto: la segunda responde al instante
   con el mismo `generadoEn` (piso anti-rebote, D8).
4. Persona sin ningún registro del día: responde `tieneDatos: false` y **no** inserta ni modifica
   filas.
5. Adulterando manualmente el `Contenido` (JSON inválido): la consulta siguiente regenera y
   sobrescribe la fila, sin error visible para el cliente.
6. Con varias personas cuidadas, `SELECT ID_Persona, COUNT(*) FROM t_ResumenDiario GROUP BY ID_Persona`
   devuelve siempre `1`.
7. Al eliminar una `Persona`, su fila de `t_ResumenDiario` se borra en cascada.
8. Un usuario sin permiso de visualización sobre la persona sigue recibiendo el error de permisos
   (la caché no se lee antes de validar).

---

## 5. Orden de ejecución y commit

1. Pasos 1-10 → `dotnet build`.
2. Paso 11 → revisar el `Up()` → `database update`.
3. Paso 12 → `dotnet test`.
4. Verificación manual (sección 4).
5. Commit sugerido: `feat(backend): persistir resumen diario con vigencia de 3 horas`.

---

## 6. Coordinación con las otras specs

- **Front (`resumen-diario-persistencia-frontend.md`):** el cambio de contrato es aditivo, así que
  la app actual sigue funcionando apenas se despliega el backend: pasa a ver el resumen cacheado,
  pero su botón "Actualizar" **no** forzará regeneración hasta que se aplique la spec del front.
  Conviene desplegar backend primero y front después.
- **Modelo y documentación (`resumen-diario-persistencia-modelo-doc.md`):** la entidad `ResumenDiario`
  debe incorporarse al diagrama de dominio con cardinalidad `Persona 1 — 0..1 ResumenDiario`, y la
  regla de vigencia (más el hecho de que se conserva un único resumen por persona) al documento
  LaTeX de la US 9.16.
