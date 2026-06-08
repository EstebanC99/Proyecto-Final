using CareWell.Domain.Agenda;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Agenda
{
    public class EventoAgendaConfig : IEntityTypeConfiguration<EventoAgenda>
    {
        public void Configure(EntityTypeBuilder<EventoAgenda> builder)
        {
            builder.ToTable("t_EventoAgenda");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_EventoAgenda").ValueGeneratedOnAdd();

            builder.Property(e => e.Titulo).IsRequired().HasMaxLength(200);
            builder.Property(e => e.Descripcion).HasMaxLength(1000);
            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.UsuarioCreador).WithMany().HasForeignKey("ID_Usuario").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.Tipo).WithMany().HasForeignKey("ID_TipoEventoAgenda").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.FechaHoraInicio).IsRequired();
            builder.Property(e => e.FechaHoraFin).IsRequired(false);
        }
    }
}
