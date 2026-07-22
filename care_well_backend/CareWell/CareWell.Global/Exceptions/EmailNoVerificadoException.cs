namespace CareWell.Global.Exceptions
{
    public class EmailNoVerificadoException : DomainException
    {
        public EmailNoVerificadoException(string mensaje) : base(mensaje)
        {

        }
    }
}
