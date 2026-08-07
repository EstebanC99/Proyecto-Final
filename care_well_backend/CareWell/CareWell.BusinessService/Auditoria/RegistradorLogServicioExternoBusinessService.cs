using CareWell.Domain.Auditoria;
using CareWell.Domain.Factories;
using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Logger;
using CareWell.Repository.Auditoria;
using Microsoft.Extensions.Logging;

namespace CareWell.BusinessService.Auditoria
{
    public class RegistradorLogServicioExternoBusinessService : IRegistradorLogServicioExterno
    {
        private ILogUnitOfWork LogUnitOfWork { get; set; }
        private ILogServicioExternoRepository LogServicioExternoRepository { get; set; }
        private IBaseFactory BaseFactory { get; set; }
        private ILogger<RegistradorLogServicioExternoBusinessService> Logger { get; set; }

        public RegistradorLogServicioExternoBusinessService(ILogUnitOfWork logUnitOfWork,
                                                             ILogServicioExternoRepository logServicioExternoRepository,
                                                             IBaseFactory baseFactory,
                                                             ILogger<RegistradorLogServicioExternoBusinessService> logger)
        {
            this.LogUnitOfWork = logUnitOfWork;
            this.LogServicioExternoRepository = logServicioExternoRepository;
            this.BaseFactory = baseFactory;
            this.Logger = logger;
        }

        public void Registrar(string nombreServicioExterno, string request, string response)
        {
            try
            {
                var logServicioExterno = this.BaseFactory.Crear<LogServicioExterno>();

                logServicioExterno.Registrar(new RegistrarLogServicioExterno(
                    NombreServicioExterno: nombreServicioExterno,
                    Request: request,
                    Response: response
                ));

                this.LogServicioExternoRepository.Add(logServicioExterno);

                this.LogUnitOfWork.SaveChanges();
            }
            catch (Exception ex)
            {
                this.Logger.LogError(ex, "No se pudo registrar el log del servicio externo {NombreServicioExterno}.", nombreServicioExterno);
            }
        }
    }
}
