namespace CareWell.DataViews.Salud
{
    public class ResumenSaludDataView
    {
        public string? GrupoSanguineo { get; set; }
        public int? CantidadAlergias { get; set; }
        public int? CantidadAntecedentes { get; set; }
        public int? CantidadEnfermedades { get; set; }

        public int? CantidadHabitosCompletados { get; set; }
        public int? CantidadHabitos { get; set; }

        public int? EstadoAnimoID { get; set; }

        public string? UltimoEventoSalud { get; set; }
        public int? CantidadDias { get; set; }
    }
}
