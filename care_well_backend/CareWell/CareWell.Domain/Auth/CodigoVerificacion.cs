using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Auth
{
    public class CodigoVerificacion : BaseEntity
    {
        public virtual Usuario Usuario { get; private set; }

        public virtual TipoCodigoVerificacionEnum Tipo { get; private set; }

        public virtual string CodigoHash { get; private set; }

        public virtual DateTime Expiracion { get; private set; }

        public virtual bool Consumido { get; private set; }

        public virtual int IntentosFallidos { get; private set; }

        public virtual DateTime FechaCreacion { get; private set; }

        public virtual void Crear(CrearCodigoVerificacion crearCodigo)
        {
            this.Usuario = crearCodigo.Usuario;
            this.Tipo = crearCodigo.Tipo;
            this.CodigoHash = crearCodigo.CodigoHash;
            this.Expiracion = crearCodigo.Expiracion;
            this.Consumido = false;
            this.IntentosFallidos = default;
            this.FechaCreacion = DateTime.Now;
        }

        public virtual bool EstaVigente()
        {
            return !this.Consumido
                && this.Expiracion > DateTime.Now
                && this.IntentosFallidos < ParametrosVerificacionCodigo.MaximoIntentosVerificacion;
        }

        public virtual void Verificar(string codigoIngresado, IPasswordHasherDomainService passwordHasherDomainService)
        {
            if (!this.EstaVigente())
                throw new ValidacionDominioException(Mensajes.CodigoVerificacionInvalido);

            if (!passwordHasherDomainService.Verificar(codigoIngresado, this.CodigoHash))
            {
                this.IntentosFallidos++;

                if (this.IntentosFallidos >= ParametrosVerificacionCodigo.MaximoIntentosVerificacion)
                {
                    this.Consumir();
                    throw new ValidacionDominioException(Mensajes.CodigoVerificacionVencido);
                }

                throw new ValidacionDominioException(Mensajes.CodigoVerificacionInvalido);
            }

            this.Consumir();
        }

        public virtual void Consumir()
        {
            this.Consumido = true;
        }
    }
}
