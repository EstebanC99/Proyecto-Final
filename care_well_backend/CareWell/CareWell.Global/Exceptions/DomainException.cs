namespace CareWell.Global.Exceptions
{
    public abstract class DomainException : Exception
    {
        protected DomainException(string mensaje) : base(mensaje) { }
    }
}
