namespace CareWell.Domain.DomainServices.Auth
{
    public interface IPasswordHasherDomainService
    {
        string Hashear(string contrasena);
        bool Verificar(string contrasena, string hash);
    }
}
