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
        private IBaseFactory Factory { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IArmarResumenDiarioBusinessService ArmarResumenDiarioBusinessService { get; set; }
        private ISerializadorResumenDiario SerializadorResumenDiarioBusinessService { get; set; }
        private IResumenDiarioRepository ResumenDiarioRepository { get; set; }

        public ResumenDiarioBusinessService(IUnitOfWork unitOfWork,
                                            IUserContext userContext,
                                            IBaseFactory baseFactory,
                                            IEntityLoaderDomainService entityLoaderDomainService,
                                            IValidadorPermisoAccion validadorPermisoAccion,
                                            IArmarResumenDiarioBusinessService armarResumenDiarioBusinessService,
                                            ISerializadorResumenDiario serializadorResumenDiarioBusinessService,
                                            IResumenDiarioRepository resumenDiarioRepository)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.Factory = baseFactory;
            this.EntityLoaderDomainService = entityLoaderDomainService;
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

            var resumenDiario = this.ResumenDiarioRepository.GetByPersona(personaCuidada.ID);

            if (resumenDiario is not null && resumenDiario.EsReutilizable(query.Actualizar))
            {
                var resumenPersistidoDataView = this.SerializadorResumenDiarioBusinessService.Deserializar(resumenDiario.Contenido);

                if (resumenPersistidoDataView is not null)
                    return resumenPersistidoDataView;
            }

            var resumenDiarioDataView = await this.ArmarResumenDiarioBusinessService.Armar(personaCuidada.ID, personaCuidada.Nombre, cancellationToken);

            if (resumenDiarioDataView.TieneDatos)
            {
                if (resumenDiario is null)
                    resumenDiario = this.Factory.Crear<ResumenDiario>();

                resumenDiario.Generar(new GenerarResumenDiario(
                    Persona: personaCuidada,
                    Contenido: this.SerializadorResumenDiarioBusinessService.Serializar(resumenDiarioDataView),
                    FechaHoraGeneracion: resumenDiarioDataView.GeneradoEn
                ));

                if (resumenDiario.IsTransient())
                    this.ResumenDiarioRepository.Add(resumenDiario);

                try
                {
                    this.UnitOfWork.SaveChanges();
                }
                catch (DbUpdateException) { }
            }

            return resumenDiarioDataView;
        }
    }
}
