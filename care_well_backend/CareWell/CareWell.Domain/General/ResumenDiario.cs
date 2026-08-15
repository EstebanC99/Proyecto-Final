using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Constantes.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.General
{
    public class ResumenDiario : BaseEntity
    {
        public virtual Persona Persona { get; private set; }
        public virtual DateTime FechaHoraGeneracion { get; private set; }
        public virtual string Contenido { get; private set; }

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

        public virtual bool EsReutilizable(bool forzarActualizacion)
        {
            var fechaHoraReferencia = DateTime.Now;

            if (forzarActualizacion)
                return this.FechaHoraGeneracion.AddMinutes(ParametrosResumenDiario.MinutosMinimosEntreRegeneraciones) > fechaHoraReferencia;

            if (this.FechaHoraGeneracion > fechaHoraReferencia)
                return false;

            if (this.FechaHoraGeneracion.Date != fechaHoraReferencia.Date)
                return false;

            return this.FechaHoraGeneracion.AddHours(ParametrosResumenDiario.HorasVigencia) > fechaHoraReferencia;
        }
    }
}
