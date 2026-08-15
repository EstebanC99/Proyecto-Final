using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public class ResumenSaludRepository : Repository, IResumenSaludRepository
    {
        public ResumenSaludRepository(CareWellDbContext dbContext) : base(dbContext) { }

        public ResumenSaludDataView Obtener(ResumenSaludQuery query)
        {
            var fechaHoy = DateTime.Today;

            var fichaSalud = this.DbContext
                .Set<FichaSalud>()
                .FirstOrDefault(f => f.Persona.ID == query.PersonaID);

            var habitosVida = this.DbContext
                .Set<HabitoVida>()
                .Where(h =>
                    h.Persona.ID == query.PersonaID &&
                    h.Activo);

            var estadoAnimo = this.DbContext
                .Set<PersonaEstadoAnimo>()
                .Where(pe =>
                    pe.Persona.ID == query.PersonaID &&
                    pe.FechaHora.Date == fechaHoy)
                .OrderByDescending(pe => pe.FechaHora)
                .FirstOrDefault();

            var ultimoEventoSalud = this.DbContext
                .Set<EventoSalud>()
                .Where(e =>
                    e.Persona.ID == query.PersonaID &&
                    e.FechaHora.Date <= fechaHoy)
                .OrderByDescending(e => e.FechaHora)
                .FirstOrDefault();

            return new ResumenSaludDataView
            {
                GrupoSanguineo = fichaSalud?.FactorSanguineo,
                CantidadAlergias = fichaSalud?.Alergias.Count,
                CantidadAntecedentes = fichaSalud?.Antecedentes.Count,
                CantidadEnfermedades = fichaSalud?.Enfermedades.Count(e => e.Vigente),

                CantidadHabitosCompletados = habitosVida?.Count(h => h.Realizaciones.Any(r => r.FechaHoraRealizacion.Date == fechaHoy)),
                CantidadHabitos = habitosVida?.Count(),

                EstadoAnimoID = estadoAnimo?.EstadoAnimo.ID,

                UltimoEventoSalud = ultimoEventoSalud?.Tipo.Descripcion,
                CantidadDias = ultimoEventoSalud != null ? (int)fechaHoy.Subtract(ultimoEventoSalud.FechaHora.Date).TotalDays : 0
            };
        }
    }
}
