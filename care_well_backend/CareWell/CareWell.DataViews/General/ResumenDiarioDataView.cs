namespace CareWell.DataViews.General
{
    public class ResumenDiarioDataView
    {
        public ResumenDiarioDataView()
        {
            this.Habitos = new List<ResumenDiarioHabitosDataView>();
            this.EventosSalud = new List<ResumenDiarioEventosSaludDataView>();
            this.Recomendaciones = new List<string>();
            this.RecordatoriosHoy = new List<string>();
            this.RecordatoriosManana = new List<string>();
            this.HabitosManana = new List<ResumenDiarioHabitosDataView>();
        }

        public string ResumenAcotado { get; set; }

        public string EstadoAnimo { get; set; }

        public string ResumenHabitos { get; set; }

        public List<ResumenDiarioHabitosDataView> Habitos { get; set; }

        public List<ResumenDiarioEventosSaludDataView> EventosSalud { get; set; }

        public List<string> Recomendaciones { get; set; }

        public List<string> RecordatoriosHoy { get; set; }

        public List<string> RecordatoriosManana { get; set; }

        public List<ResumenDiarioHabitosDataView> HabitosManana { get; set; }

        public DateTime GeneradoEn { get; set; }

        public bool TieneDatos
        {
            get
            {
                return !string.IsNullOrEmpty(this.ResumenAcotado) ||
                       !string.IsNullOrEmpty(this.EstadoAnimo) ||
                       !string.IsNullOrEmpty(this.ResumenHabitos) ||
                       this.Habitos.Any() ||
                       this.EventosSalud.Any() ||
                       this.Recomendaciones.Any() ||
                       this.RecordatoriosHoy.Any() ||
                       this.RecordatoriosManana.Any() ||
                       this.HabitosManana.Any();
            }
        }
    }

    public class ResumenDiarioHabitosDataView
    {
        public string Descripcion { get; set; }
        public bool Completado { get; set; }
    }

    public class ResumenDiarioEventosSaludDataView
    {
        public string Descripcion { get; set; }
        public string Hora { get; set; }
        public string? ActividadHabitoAsociado { get; set; }
    }
}
