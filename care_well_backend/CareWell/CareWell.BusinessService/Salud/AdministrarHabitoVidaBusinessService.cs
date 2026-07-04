using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Queries.Salud;
using CareWell.Repository;
using CareWell.Repository.Salud;
using CareWell.Security;

namespace CareWell.BusinessService.Salud
{
    public class AdministrarHabitoVidaBusinessService : BusinessService, IAdministrarHabitoVidaBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IHabitoVidaRepository HabitoVidaRepository { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IBaseFactory Factory { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }

        public AdministrarHabitoVidaBusinessService(IUnitOfWork unitOfWork,
                                                     IUserContext userContext,
                                                     IHabitoVidaRepository habitoVidaRepository,
                                                     IEntityLoaderDomainService entityLoaderDomainService,
                                                     IBaseFactory baseFactory,
                                                     IValidadorPermisoAccion validadorPermisoAccion)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.HabitoVidaRepository = habitoVidaRepository;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.Factory = baseFactory;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
        }

        public List<HabitoVidaDataView> ObtenerTodos(HabitoVidaQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.HabitoVidaRepository.ObtenerTodos(query);
        }

        public List<HabitoVidaRealizacionDataView> ObtenerRealizacionesPorFecha(HabitoVidaQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(persona, usuario.Persona);

            return this.HabitoVidaRepository.ObtenerRealizacionesPorFecha(query);
        }

        public void Crear(CrearHabitoVidaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var crearHabitoVida = new CrearHabitoVida(
                Persona: this.EntityLoaderDomainService.GetByID<Persona>(command.PersonaID),
                Colaborador: usuario.Persona,
                TipoHabito: this.EntityLoaderDomainService.GetByID<TipoHabitoVida>(command.TipoHabitoID),
                Descripcion: command.Descripcion
            );

            var habitoVida = this.Factory.Crear<HabitoVida>();

            habitoVida.Crear(crearHabitoVida,
                             this.ValidadorPermisoAccion);

            this.HabitoVidaRepository.Add(habitoVida);

            this.UnitOfWork.SaveChanges();
        }

        public void Modificar(ModificarHabitoVidaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var habitoVida = this.HabitoVidaRepository.GetByID(command.HabitoVidaID);

            var modificarHabitoVida = new ModificarHabitoVida(
                Colaborador: usuario.Persona,
                TipoHabito: this.EntityLoaderDomainService.GetByID<TipoHabitoVida>(command.TipoHabitoID),
                Descripcion: command.Descripcion
            );

            habitoVida.Modificar(modificarHabitoVida,
                                 this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }

        public void Eliminar(int habitoVidaID)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var habitoVida = this.HabitoVidaRepository.GetByID(habitoVidaID);

            habitoVida.Eliminar(usuario.Persona,
                                this.ValidadorPermisoAccion);

            this.UnitOfWork.SaveChanges();
        }

        public void CrearRealizacion(CrearRealizacionHabitoVidaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var habitoVida = this.HabitoVidaRepository.GetByID(command.HabitoVidaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(habitoVida.Persona, usuario.Persona);

            habitoVida.CrearRealizacion(command.Comentarios,
                                        this.Factory);

            this.UnitOfWork.SaveChanges();
        }

        public void ModificarRealizacion(ModificarRealizacionHabitoVidaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var habitoVida = this.HabitoVidaRepository.GetByID(command.HabitoVidaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(habitoVida.Persona, usuario.Persona);

            habitoVida.ModificarRealizacion(command.RealizacionID,
                                            command.Comentarios);

            this.UnitOfWork.SaveChanges();
        }

        public void EliminarRealizacion(EliminarRealizacionHabitoVidaCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var habitoVida = this.HabitoVidaRepository.GetByID(command.HabitoVidaID);

            this.ValidadorPermisoAccion.ValidarVisualizacion(habitoVida.Persona, usuario.Persona);

            habitoVida.EliminarRealizacion(command.RealizacionID);

            this.UnitOfWork.SaveChanges();
        }
    }
}
