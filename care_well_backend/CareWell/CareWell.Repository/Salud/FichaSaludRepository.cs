using CareWell.DataViews.Salud;
using CareWell.Domain.Salud;
using CareWell.Queries.Salud;

namespace CareWell.Repository.Salud
{
    public class FichaSaludRepository : Repository<FichaSalud>, IFichaSaludRepository
    {
        public FichaSaludRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public FichaSaludDataView Obtener(FichaSaludQuery query)
        {
            var fichaSalud = this.DbSet.FirstOrDefault(f => f.Persona.ID == query.PersonaID);

            if (fichaSalud is null)
                return null;

            return new FichaSaludDataView
            {
                ID = fichaSalud.ID,
                FactorSanguineo = fichaSalud.FactorSanguineo,
                ObraSocial = fichaSalud.ObraSocial,
                Persona = new DataViews.General.PersonaDataView
                {
                    ID = fichaSalud.Persona.ID,
                    Nombre = fichaSalud.Persona.Nombre,
                    Apellido = fichaSalud.Persona.Apellido,
                    Documento = fichaSalud.Persona.Documento,
                    FechaNacimiento = fichaSalud.Persona.FechaNacimiento,
                },
                Antecedentes = fichaSalud.Antecedentes.Select(MapAntecedenteToDataView).ToList(),
                Alergias = fichaSalud.Alergias.Select(MapAlergiaToDataView).ToList(),
                Enfermedades = fichaSalud.Enfermedades.Select(MapEnfermedadToDataView).ToList(),
                Observaciones = fichaSalud.Observaciones
            };
        }

        #region Metodos Privados

        private static FichaSaludAntecedenteDataView MapAntecedenteToDataView(FichaSaludAntecedente antecedente)
        {
            return new FichaSaludAntecedenteDataView
            {
                ID = antecedente.ID,
                Nombre = antecedente.Nombre,
                Descripcion = antecedente.Descripcion,
                VinculoFamiliar = antecedente.VinculoFamiliar
            };
        }

        private static FichaSaludAlergiaDataView MapAlergiaToDataView(FichaSaludAlergia alergia)
        {
            return new FichaSaludAlergiaDataView
            {
                ID = alergia.ID,
                Nombre = alergia.Nombre,
                Reaccion = alergia.Reaccion,
                Medicamento = alergia.Medicamento
            };
        }

        private static FichaSaludEnfermedadDataView MapEnfermedadToDataView(FichaSaludEnfermedad enfermedad)
        {
            return new FichaSaludEnfermedadDataView
            {
                ID = enfermedad.ID,
                Nombre = enfermedad.Nombre,
                Vigente = enfermedad.Vigente,
                Observacion = enfermedad.Observacion
            };
        }

        #endregion
    }
}
