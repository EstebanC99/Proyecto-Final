using CareWell.DataViews;
using CareWell.DataViews.EquipoCuidado;
using CareWell.Domain.Auth;
using CareWell.Domain.EquipoCuidado;
using CareWell.Global.Constantes.EquipoCuidado;

namespace CareWell.Repository.EquipoCuidado
{
    public class AsignacionCuidadoRepository : Repository<AsignacionCuidado>, IAsignacionCuidadoRepository
    {
        public AsignacionCuidadoRepository(CareWellDbContext dbContext) : base(dbContext)
        {
        }

        public List<AsignacionCuidadoDataView> ObtenerAsignacionesPorUsuario(int usuarioID)
        {
            var usuarioLogueado = this.DbContext.Set<Usuario>().Find(usuarioID);

            if (usuarioLogueado is null)
                return new List<AsignacionCuidadoDataView>();

            return this.DbSet
                .Where(a => a.Colaborador.ID == usuarioLogueado.Persona.ID
                         && a.Estado.ID != EstadosAsignacionCuidado.Inactiva)
                .Select(a => new AsignacionCuidadoDataView
                {
                    ID = a.ID,
                    Persona = new DataViews.General.PersonaDataView
                    {
                        ID = a.PersonaCuidada.ID,
                        Nombre = a.PersonaCuidada.Nombre,
                        Apellido = a.PersonaCuidada.Apellido,
                        Documento = a.PersonaCuidada.Documento,
                        FechaNacimiento = a.PersonaCuidada.FechaNacimiento,
                        Email = a.PersonaCuidada.Email,
                        Telefono = a.PersonaCuidada.Telefono
                    },
                    Colaborador = new DataViews.General.PersonaDataView
                    {
                        ID = a.Colaborador.ID,
                        Nombre = a.Colaborador.Nombre,
                        Apellido = a.Colaborador.Apellido,
                        Documento = a.Colaborador.Documento,
                        FechaNacimiento = a.Colaborador.FechaNacimiento,
                        Email = a.Colaborador.Email,
                        Telefono = a.Colaborador.Telefono
                    },
                    Rol = new BaseEntityDataView
                    {
                        ID = a.Rol.ID,
                        Descripcion = a.Rol.Descripcion
                    },
                    Estado = new BaseEntityDataView
                    {
                        ID = a.Estado.ID,
                        Descripcion = a.Estado.Descripcion
                    },
                    FechaAlta = a.FechaAlta,
                    Permisos = a.Permisos.Select(p => new BaseEntityDataView
                    {
                        ID = p.ID,
                        Descripcion = p.Descripcion
                    }).ToList()
                }).ToList();
        }
    }
}
