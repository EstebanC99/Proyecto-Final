namespace CareWell.Domain.Salud
{
    public class HabitoVidaRealizacion : BaseEntity
    {
        public virtual HabitoVida HabitoVida { get; private set; }

        public virtual DateTime FechaHoraRealizacion { get; private set; }

        public virtual string? Comentarios { get; private set; }

        public virtual void Crear(HabitoVida habitoVida,
                                  string? comentarios)
        {
            this.HabitoVida = habitoVida;
            this.FechaHoraRealizacion = DateTime.Now;
            this.Comentarios = comentarios;
        }

        public virtual void Modificar(string? comentarios)
        {
            this.Comentarios = comentarios;
        }
    }
}
