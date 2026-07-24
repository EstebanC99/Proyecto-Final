namespace CareWell.Global.Exceptions
{
    public class ServicioNoDisponibleException : DomainException
    {
        public ServicioNoDisponibleException(string mensaje) : base(mensaje) { }
    }
}
