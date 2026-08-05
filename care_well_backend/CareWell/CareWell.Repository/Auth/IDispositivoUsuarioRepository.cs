using CareWell.Domain.Auth;

namespace CareWell.Repository.Auth
{
    public interface IDispositivoUsuarioRepository : IRepository<DispositivoUsuario>
    {
        DispositivoUsuario GetByToken(string token);
        List<DispositivoUsuario> GetActivosPorUsuario(Usuario usuario);
        List<DispositivoUsuario> GetVigentesPorUsuario(Usuario usuario, DateTime fechaLimiteActividad);
    }
}