using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Auth
{
    public class DispositivoUsuario : BaseEntity
    {
        public virtual Usuario Usuario { get; private set; }

        public virtual string Token { get; private set; }

        public virtual DispositivoPlataformasEnum Plataforma { get; private set; }

        public virtual bool Activo { get; private set; }

        public virtual DateTime FechaAlta { get; private set; }

        public virtual DateTime FechaUltimoUso { get; private set; }

        public virtual void Registrar(RegistrarDispositivo registrarDispositivo)
        {
            if (registrarDispositivo.Usuario is null)
                throw new ValidacionDominioException(Mensajes.UsuarioNoExiste);

            if (string.IsNullOrWhiteSpace(registrarDispositivo.Token))
                throw new ValidacionDominioException(Mensajes.TokenDispositivoRequerido);

            if (!Enum.IsDefined(registrarDispositivo.Plataforma))
                throw new ValidacionDominioException(Mensajes.PlataformaDispositivoInvalida);

            this.Usuario = registrarDispositivo.Usuario;
            this.Token = registrarDispositivo.Token;
            this.Plataforma = registrarDispositivo.Plataforma;
            this.Activo = true;
            this.FechaAlta = DateTime.Now;
            this.FechaUltimoUso = DateTime.Now;
        }

        public virtual void RegistrarUso(Usuario usuario)
        {
            if (usuario is null)
                throw new ValidacionDominioException(Mensajes.UsuarioNoExiste);

            this.Usuario = usuario;
            this.Activo = true;
            this.FechaUltimoUso = DateTime.Now;
        }

        public virtual void Desactivar()
        {
            this.Activo = false;
        }

        public virtual bool PerteneceA(Usuario usuario)
        {
            return usuario is not null && this.Usuario.ID == usuario.ID;
        }
    }
}
