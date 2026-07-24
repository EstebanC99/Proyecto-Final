namespace CareWell.Global.Exceptions
{
    public class CuentaExistenteException : DomainException
    {
        public CuentaExistenteException(string mensaje) : base(mensaje) { }
    }
}
