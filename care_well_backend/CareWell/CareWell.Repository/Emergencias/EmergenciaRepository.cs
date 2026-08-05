using CareWell.DataViews.Emergencias;
using CareWell.DataViews.General;
using CareWell.Domain.Auth;
using CareWell.Domain.Emergencias;
using CareWell.Domain.EquipoCuidado;
using CareWell.Domain.General;
using CareWell.Global.Constantes.EquipoCuidado;
using CareWell.Queries.Emergencias;

namespace CareWell.Repository.Emergencias
{
    public class EmergenciaRepository : Repository<Emergencia>, IEmergenciaRepository
    {
        public EmergenciaRepository(CareWellDbContext dbContext) : base(dbContext)
        {
        }

        public List<EmergenciaDataView> ObtenerPorPersona(ObtenerEmergenciasQuery query)
        {
            return this.DbSet
                .Where(e => e.Persona.ID == query.PersonaID)
                .OrderByDescending(e => e.FechaHora)
                .Take(query.Cantidad)
                .ToList()
                .Select(MapToDataView)
                .ToList();
        }

        public List<Usuario> GetUsuariosColaboradoresActivos(Emergencia emergencia)
        {
            var personasColaboradores = this.DbContext.Set<AsignacionCuidado>()
                .Where(a => 
                    a.PersonaCuidada.ID == emergencia.Persona.ID && 
                    a.Colaborador.ID != emergencia.Activador.ID &&
                    a.Estado.ID == EstadosAsignacionCuidado.Activa)
                .Select(c => c.Colaborador)
                .Distinct()
                .ToList();

            return this.DbContext.Set<Usuario>()
                .Where(u => personasColaboradores.Contains(u.Persona))
                .Distinct()
                .ToList();
        }

        #region Metodos Privados

        private static EmergenciaDataView MapToDataView(Emergencia emergencia)
        {
            return new EmergenciaDataView
            {
                ID = emergencia.ID,
                FechaHora = emergencia.FechaHora,
                Descripcion = emergencia.Descripcion,
                Persona = MapPersona(emergencia.Persona),
                Activador = MapPersona(emergencia.Activador)
            };
        }

        private static PersonaDataView MapPersona(Domain.General.Persona persona)
        {
            return new PersonaDataView
            {
                ID = persona.ID,
                Nombre = persona.Nombre,
                Apellido = persona.Apellido,
                Documento = persona.Documento,
                FechaNacimiento = persona.FechaNacimiento,
                Email = persona.Email,
                Telefono = persona.Telefono
            };
        }

        #endregion
    }
}
