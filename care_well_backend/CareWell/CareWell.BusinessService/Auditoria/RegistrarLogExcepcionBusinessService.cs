using CareWell.BusinessService.Abstractions.Auditoria;
using CareWell.Commands.Auditoria;
using CareWell.Domain.Auditoria;
using CareWell.Domain.Factories;
using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Repository.Auditoria;
using Microsoft.Extensions.Logging;

namespace CareWell.BusinessService.Auditoria
{
    public class RegistrarLogExcepcionBusinessService : IRegistrarLogExcepcionBusinessService
    {
        private ILogUnitOfWork LogUnitOfWork { get; set; }
        private ILogExcepcionRepository LogExcepcionRepository { get; set; }
        private IBaseFactory BaseFactory { get; set; }
        private ILogger<RegistrarLogExcepcionBusinessService> Logger { get; set; }

        public RegistrarLogExcepcionBusinessService(ILogUnitOfWork logUnitOfWork,
                                                    ILogExcepcionRepository logExcepcionRepository,
                                                    IBaseFactory baseFactory,
                                                    ILogger<RegistrarLogExcepcionBusinessService> logger)
        {
            this.LogUnitOfWork = logUnitOfWork;
            this.LogExcepcionRepository = logExcepcionRepository;
            this.BaseFactory = baseFactory;
            this.Logger = logger;
        }

        public void Registrar(RegistrarLogExcepcionCommand command)
        {
            try
            {
                var logExcepcion = this.BaseFactory.Crear<LogExcepcion>();

                logExcepcion.Registrar(new RegistrarLogExcepcion(
                    Tipo: command.Tipo,
                    Controlada: command.Controlada,
                    Mensaje: command.Mensaje,
                    StackTrace: command.StackTrace,
                    Ruta: command.Ruta,
                    Verbo: command.Verbo,
                    TraceIdentifier: command.TraceIdentifier,
                    UsuarioID: command.UsuarioID
                ));

                this.LogExcepcionRepository.Add(logExcepcion);

                this.LogUnitOfWork.SaveChanges();
            }
            catch (Exception ex)
            {
                this.Logger.LogError(ex, "No se pudo registrar el log de la excepción {Tipo}.", command?.Tipo);
            }
        }
    }
}
