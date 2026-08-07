using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Global.Constantes.Auditoria;
using CareWell.Global.Extensions;

namespace CareWell.Domain.Auditoria
{
    public class LogServicioExterno : BaseEntity
    {
        public virtual string NombreServicioExterno { get; private set; }
        public virtual string Request { get; private set; }
        public virtual string Response { get; private set; }
        public virtual DateTime FechaHora { get; private set; }

        public virtual void Registrar(RegistrarLogServicioExterno registrarLogServicioExterno)
        {
            this.NombreServicioExterno = registrarLogServicioExterno.NombreServicioExterno.Truncate(ParametrosLogServicioExterno.LongitudMaximaNombreServicioExterno);
            this.Request = registrarLogServicioExterno.Request;
            this.Response = registrarLogServicioExterno.Response;
            this.FechaHora = DateTime.Now;
        }
    }
}
