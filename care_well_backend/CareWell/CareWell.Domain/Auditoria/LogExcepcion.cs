using CareWell.Domain.ValueObjects.Auditoria;
using CareWell.Global.Constantes.Auditoria;
using CareWell.Global.Extensions;

namespace CareWell.Domain.Auditoria
{
    public class LogExcepcion : BaseEntity
    {
        public virtual string Tipo { get; private set; }
        public virtual bool Controlada { get; private set; }
        public virtual string Mensaje { get; private set; }
        public virtual string StackTrace { get; private set; }
        public virtual string Ruta { get; private set; }
        public virtual string Verbo { get; private set; }
        public virtual string TraceIdentifier { get; private set; }
        public virtual int? UsuarioID { get; private set; }
        public virtual DateTime FechaHora { get; private set; }

        public virtual void Registrar(RegistrarLogExcepcion registrarLogExcepcion)
        {
            this.Tipo = registrarLogExcepcion.Tipo.Truncate(ParametrosLogExcepcion.LongitudMaximaTipo);
            this.Controlada = registrarLogExcepcion.Controlada;
            this.Mensaje = registrarLogExcepcion.Mensaje.Truncate(ParametrosLogExcepcion.LongitudMaximaMensaje);
            this.StackTrace = registrarLogExcepcion.StackTrace;
            this.Ruta = registrarLogExcepcion.Ruta.Truncate(ParametrosLogExcepcion.LongitudMaximaRuta);
            this.Verbo = registrarLogExcepcion.Verbo;
            this.TraceIdentifier = registrarLogExcepcion.TraceIdentifier;
            this.UsuarioID = registrarLogExcepcion.UsuarioID;
            this.FechaHora = DateTime.Now;
        }
    }
}
