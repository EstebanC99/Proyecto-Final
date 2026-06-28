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
                         && (a.Estado.ID != EstadosAsignacionCuidado.Inactiva || (a.Estado.ID == EstadosAsignacionCuidado.Inactiva && a.FechaEliminacion > DateTime.Now.AddDays(-30))))
                .ToList()
                .Select(MapToDataView)
                .ToList();
        }

        public List<AsignacionCuidadoDataView> ObtenerAsignacionesPorPersonaCuidada(int personaCuidadaID)
        {
            return this.DbSet
                .Where(a => a.PersonaCuidada.ID == personaCuidadaID
                         && a.Estado.ID != EstadosAsignacionCuidado.Inactiva)
                .ToList()
                .Select(MapToDataView)
                .ToList();
        }

        private static AsignacionCuidadoDataView MapToDataView(AsignacionCuidado asignacionCuidado)
        {
            return new AsignacionCuidadoDataView
            {
                ID = asignacionCuidado.ID,
                Persona = new DataViews.General.PersonaDataView
                {
                    ID = asignacionCuidado.PersonaCuidada.ID,
                    Nombre = asignacionCuidado.PersonaCuidada.Nombre,
                    Apellido = asignacionCuidado.PersonaCuidada.Apellido,
                    Documento = asignacionCuidado.PersonaCuidada.Documento,
                    FechaNacimiento = asignacionCuidado.PersonaCuidada.FechaNacimiento,
                    Email = asignacionCuidado.PersonaCuidada.Email,
                    Telefono = asignacionCuidado.PersonaCuidada.Telefono
                },
                Colaborador = new DataViews.General.PersonaDataView
                {
                    ID = asignacionCuidado.Colaborador.ID,
                    Nombre = asignacionCuidado.Colaborador.Nombre,
                    Apellido = asignacionCuidado.Colaborador.Apellido,
                    Documento = asignacionCuidado.Colaborador.Documento,
                    FechaNacimiento = asignacionCuidado.Colaborador.FechaNacimiento,
                    Email = asignacionCuidado.Colaborador.Email,
                    Telefono = asignacionCuidado.Colaborador.Telefono
                },
                Rol = new BaseEntityDataView
                {
                    ID = asignacionCuidado.Rol.ID,
                    Descripcion = asignacionCuidado.Rol.Descripcion
                },
                Estado = new BaseEntityDataView
                {
                    ID = asignacionCuidado.Estado.ID,
                    Descripcion = asignacionCuidado.Estado.Descripcion
                },
                FechaAlta = asignacionCuidado.FechaAlta,
                Permisos = asignacionCuidado.Permisos.Select(p => new BaseEntityDataView
                {
                    ID = p.ID,
                    Descripcion = p.Descripcion
                }).ToList(),
                FechaEliminacion = asignacionCuidado.FechaEliminacion
            };
        }
    }
}
