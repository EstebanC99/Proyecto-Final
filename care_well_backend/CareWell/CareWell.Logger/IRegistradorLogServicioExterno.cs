namespace CareWell.Logger
{
    public interface IRegistradorLogServicioExterno
    {
        void Registrar(string nombreServicioExterno, string request, string response);
    }
}
