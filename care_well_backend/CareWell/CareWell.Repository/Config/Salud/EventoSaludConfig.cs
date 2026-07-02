using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class EventoSaludConfig : IEntityTypeConfiguration<EventoSalud>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<EventoSalud> builder)
        {
            builder.ToTable("t_EventoSalud");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_EventoSalud").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.Tipo).WithMany().HasForeignKey("ID_TipoEvento").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.FechaHora).IsRequired();
            builder.Property(e => e.Descripcion).IsRequired();
            builder.HasMany(e => e.Notas).WithOne(n => n.EventoSalud).HasForeignKey("ID_EventoSalud").OnDelete(DeleteBehavior.Cascade);
            builder.HasOne(e => e.EventoAgenda).WithMany().HasForeignKey("ID_EventoAgenda").IsRequired(false).OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.FechaOcurrenciaEventoAgenda).IsRequired(false);

            builder.HasIndex("ID_EventoAgenda", nameof(EventoSalud.FechaOcurrenciaEventoAgenda)).IsUnique().HasFilter("[ID_EventoAgenda] IS NOT NULL");
        }
    }
}
