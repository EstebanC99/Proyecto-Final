using CareWell.BusinessService.Abstractions.General;
using CareWell.BusinessService.Helpers;
using CareWell.Commands.General;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.General;
using CareWell.Repository;
using CareWell.Repository.General;
using CareWell.Security;

namespace CareWell.BusinessService.General
{
    public class AdministrarPersonaBusinessService : BusinessService, IAdministrarPersonaBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }
        private IPersonaRepository PersonaRepository { get; set; }

        public AdministrarPersonaBusinessService(IUnitOfWork unitOfWork,
                                                 IUserContext userContext,
                                                 IEntityLoaderDomainService entityLoaderDomainService,
                                                 IValidadorPermisoAccion validadorPermisoAccion,
                                                 IPersonaRepository personaRepository)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
            this.PersonaRepository = personaRepository;
        }

        public void ModificarPerfil(ModificarPerfilCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.PersonaRepository.GetByID(command.ID);

            this.ValidadorPermisoAccion.ValidarPuedeModificarPerfil(persona, usuario.Persona);

            var modificarPerfil = new ModificarPerfil(
                Nombre: command.Nombre,
                Apellido: command.Apellido,
                Documento: command.Documento,
                FechaNacimiento: command.FechaNacimiento,
                Telefono: command.Telefono,
                Imagen: ImageProcessorHelper.GetImage(command.Imagen)
            );

            persona.ModificarPerfil(modificarPerfil);

            this.UnitOfWork.SaveChanges();
        }

        public PersonaImagenDataView ObtenerImagenPerfil(int personaID)
        {
            var persona = this.PersonaRepository.GetByID(personaID);

            return new PersonaImagenDataView
            {
                Contenido = persona.Imagen,
            };
        }
    }
}
