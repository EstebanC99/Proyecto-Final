namespace CareWell.Domain.Auth
{
    public class RefreshToken : BaseEntity
    {
        public virtual string Token { get; private set; }

        public virtual Usuario Usuario { get; private set; }

        public virtual DateTime Expiracion { get; private set; }

        public virtual bool Revocado { get; private set; }

        public virtual void Crear(string token, Usuario usuario, DateTime expiracion)
        {
            this.Token = token;
            this.Usuario = usuario;
            this.Expiracion = expiracion;
            this.Revocado = false;
        }

        public virtual void Revocar()
        {
            this.Revocado = true;
        }

        public virtual bool HabilitadoUso()
        {
            return !this.Revocado && this.Expiracion > DateTime.Now;
        }
    }
}
