namespace CareWell.Commands.Agenda
{
    public class CrearEventoAgendaCommand
    {
        public int PersonaID { get; set; }

        public string Titulo { get; set; }

        public string? Descripcion { get; set; }

        public int TipoEventoID { get; set; }

        public DateTime FechaHoraInicio { get; set; }

        public int DuracionMinutos { get; set; }

        public bool GenerarEventoSalud { get; set; }

        public int? MinutosAnticipacionRecordatorio { get; set; }

        public int? FrecuenciaRecurrenciaID { get; set; }

        public int? IntervaloRecurrencia { get; set; }

        public DateTime? FechaFinRecurrencia { get; set; }
    }
}
