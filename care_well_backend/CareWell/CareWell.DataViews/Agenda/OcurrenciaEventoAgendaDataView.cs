namespace CareWell.DataViews.Agenda
{
    public class OcurrenciaEventoAgendaDataView
    {
        public int EventoAgendaID { get; set; }

        public int PersonaID { get; set; }

        public string Titulo { get; set; }

        public string? Descripcion { get; set; }

        public BaseEntityDataView Tipo { get; set; }

        public DateTime FechaHoraInicio { get; set; }

        public DateTime FechaHoraFin { get; set; }

        public bool EsRecurrente { get; set; }

        public bool GenerarEventoSalud { get; set; }

        public int? MinutosAnticipacionRecordatorio { get; set; }
    }
}
