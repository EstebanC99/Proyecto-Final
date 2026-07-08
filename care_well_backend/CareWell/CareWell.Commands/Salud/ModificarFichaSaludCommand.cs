namespace CareWell.Commands.Salud
{
    public class ModificarFichaSaludCommand
    {
        public int ID { get; set; }

        public string FactorSanguineo { get; set; }

        public string? ObraSocial { get; set; }

        public List<AgregarAntecedenteCommand> Antecedentes { get; set; }

        public List<AgregarAlergiaCommand> Alergias { get; set; }

        public List<AgregarEnfermedadCommand> Enfermedades { get; set; }

        public string? Observaciones { get; set; }

        public ModificarFichaSaludCommand()
        {
            this.Antecedentes = new List<AgregarAntecedenteCommand>();
            this.Alergias = new List<AgregarAlergiaCommand>();
            this.Enfermedades = new List<AgregarEnfermedadCommand>();
        }
    }
}
