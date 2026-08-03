namespace CareWell.DocumentIntelligence.ResumidorDiario
{
    public class ResumidorTextoAgentRequest
    {
        public string NombrePersona { get; set; }
        public DateTime FechaHoy { get; set; }
        public DateTime FechaManana { get; set; }
        public List<EventoRequest> EventosAgenda { get; set; }
        public List<EventoRequest> EventosSalud { get; set; }
        public List<EventoRequest> HabitosVida { get; set; }
        public List<EventoRequest> EstadosAnimo { get; set; }
    }

    public class EventoRequest
    {
        public string Tipo { get; set; }
        public string Descripcion { get; set; }
        public bool Finalizado { get; set; }
        public DateTime? FechaHoraOcurrencia { get; set; }
    }
}
