using CareWell.Domain.Agenda;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Agenda
{
    public class EventoAgendaRecordatorioConfig : IEntityTypeConfiguration<EventoAgendaRecordatorio>
    {
        public void Configure(EntityTypeBuilder<EventoAgendaRecordatorio> builder)
        {
            builder.ToTable("t_EventoAgendaRecordatorio");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_EventoAgendaRecordatorio").ValueGeneratedOnAdd();

            builder.HasOne(e => e.EventoAgenda).WithMany().HasForeignKey("ID_EventoAgenda").OnDelete(DeleteBehavior.Cascade);
            builder.Property(e => e.FechaHoraEnvio).IsRequired();
            builder.Property(e => e.Enviado).IsRequired();
        }
    }
}
