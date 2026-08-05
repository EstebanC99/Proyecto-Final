using CareWell.BusinessService.Abstractions.Auth;
using CareWell.Commands.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Repository;
using CareWell.Repository.Auth;
using CareWell.Security;

namespace CareWell.BusinessService.Auth
{
    public class AdministrarDispositivoBusinessService : BusinessService, IAdministrarDispositivoBusinessService, IAdministrarDispositivoDomainService
    {
        private IUserContext UserContext { get; set; }
        private IUsuarioRepository UsuarioRepository { get; set; }
        private IDispositivoUsuarioRepository DispositivoUsuarioRepository { get; set; }
        private IBaseFactory Factory { get; set; }

        public AdministrarDispositivoBusinessService(IUnitOfWork unitOfWork,
                                                     IUserContext userContext,
                                                     IUsuarioRepository usuarioRepository,
                                                     IDispositivoUsuarioRepository dispositivoUsuarioRepository,
                                                     IBaseFactory baseFactory)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.UsuarioRepository = usuarioRepository;
            this.DispositivoUsuarioRepository = dispositivoUsuarioRepository;
            this.Factory = baseFactory;
        }

        public void Registrar(RegistrarDispositivoCommand command)
        {
            var usuario = this.UsuarioRepository.GetByID(this.UserContext.UsuarioID);
            var dispositivo = this.DispositivoUsuarioRepository.GetByToken(command.Token);

            if (dispositivo is null)
            {
                dispositivo = this.Factory.Crear<DispositivoUsuario>();

                dispositivo.Registrar(new RegistrarDispositivo(
                    Usuario: usuario,
                    Token: command.Token,
                    Plataforma: (DispositivoPlataformasEnum)command.Plataforma
                ));

                this.DispositivoUsuarioRepository.Add(dispositivo);
            }
            else
            {
                dispositivo.RegistrarUso(usuario);
            }

            this.UnitOfWork.SaveChanges();
        }

        public void Eliminar(EliminarDispositivoCommand command)
        {
            var usuario = this.UsuarioRepository.GetByID(this.UserContext.UsuarioID);
            var dispositivo = this.DispositivoUsuarioRepository.GetByToken(command.Token);

            if (dispositivo is null)
                throw new RecursoNoEncontradoException(Mensajes.DispositivoNoExiste);

            if (!dispositivo.PerteneceA(usuario))
                throw new UnauthorizedAccessException(Mensajes.UsuarioNoHabilitadoParaEjecutarAccion);

            dispositivo.Desactivar();

            this.UnitOfWork.SaveChanges();
        }

        public void DesactivarTodosDelUsuario(Usuario usuario)
        {
            var dispositivos = this.DispositivoUsuarioRepository.GetActivosPorUsuario(usuario);

            dispositivos.ForEach(d => d.Desactivar());
        }
    }
}
