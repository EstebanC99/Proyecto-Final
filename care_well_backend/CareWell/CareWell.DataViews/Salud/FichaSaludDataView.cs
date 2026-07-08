using CareWell.DataViews.General;

namespace CareWell.DataViews.Salud
{
    public class FichaSaludDataView : BaseDataView
    {
        public PersonaDataView Persona { get; set; }

        public string FactorSanguineo { get; set; }

        public string? ObraSocial { get; set; }

        public List<FichaSaludAntecedenteDataView> Antecedentes { get; set; }

        public List<FichaSaludAlergiaDataView> Alergias { get; set; }

        public List<FichaSaludEnfermedadDataView> Enfermedades { get; set; }

        public string? Observaciones { get; set; }

        public FichaSaludDataView()
        {
            this.Antecedentes = new List<FichaSaludAntecedenteDataView>();
            this.Alergias = new List<FichaSaludAlergiaDataView>();
            this.Enfermedades = new List<FichaSaludEnfermedadDataView>();
        }
    }
}
