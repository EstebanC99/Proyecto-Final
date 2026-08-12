namespace CareWell.DocumentIntelligence.ResumidorDiario
{
    public class ResumidorDiarioAgentResponse
    {
        public ResumidorDiarioAgentResponse()
        {
            this.Habitos = new List<ResumidorDiarioAgentResponseHabito>();
            this.EventosSalud = new List<ResumidorDiarioAgentResponseEventoSalud>();
            this.Recomendaciones = new List<string>();  
            this.RecordatoriosHoy = new List<string>();
            this.RecordatoriosManana = new List<string>();
            this.HabitosManana = new List<ResumidorDiarioAgentResponseHabito>();
        }

        public virtual string ResumenAcotado { get; set; }

        public virtual string EstadoAnimo { get; set; }

        public virtual string ResumenHabitos { get; set; }

        public virtual List<ResumidorDiarioAgentResponseHabito> Habitos { get; set; }

        public virtual List<ResumidorDiarioAgentResponseEventoSalud> EventosSalud { get; set; }

        public virtual List<string> Recomendaciones { get; set; }

        public virtual List<string> RecordatoriosHoy { get; set; }

        public virtual List<string> RecordatoriosManana { get; set; }

        public virtual List<ResumidorDiarioAgentResponseHabito> HabitosManana { get; set; }
    }

    public class ResumidorDiarioAgentResponseHabito
    {
        public virtual string Descripcion { get; set; }
        public virtual bool Completado { get; set; }
    }

    public class ResumidorDiarioAgentResponseEventoSalud
    {
        public virtual string Descripcion { get; set; }
        public virtual string Hora { get; set; }
        public virtual string? ActividadHabitoAsociado { get; set; }
    }
}
