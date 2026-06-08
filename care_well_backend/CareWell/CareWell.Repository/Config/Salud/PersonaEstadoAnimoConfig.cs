using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class PersonaEstadoAnimoConfig : IEntityTypeConfiguration<PersonaEstadoAnimo>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<PersonaEstadoAnimo> builder)
        {
            builder.ToTable("t_PersonaEstadoAnimo");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_PersonaEstadoAnimo").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Cascade);
            builder.HasOne(e => e.EventoSalud).WithMany().HasForeignKey("ID_EventoSalud").OnDelete(DeleteBehavior.Cascade);
            builder.Property(e => e.FechaHora).IsRequired();
            builder.HasOne(e => e.EstadoAnimo).WithMany().HasForeignKey("ID_EstadoAnimo").OnDelete(DeleteBehavior.Cascade);
            builder.Property(e => e.Observaciones);
        }
    }
}
