using CareWell.Domain.Emergencias;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Emergencias
{
    public class EmergenciaConfig : IEntityTypeConfiguration<Emergencia>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<Emergencia> builder)
        {
            builder.ToTable("t_Emergencia");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_Emergencia").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.Activador).WithMany().HasForeignKey("ID_Persona_Activador").OnDelete(DeleteBehavior.Restrict);
            
            builder.Property(e => e.FechaHora).IsRequired();
            builder.Property(e => e.Descripcion).HasMaxLength(500);

            builder.HasIndex("ID_Persona", nameof(Emergencia.FechaHora));
        }
    }
}
