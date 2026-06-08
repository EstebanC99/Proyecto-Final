using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class RecomendacionMedicaConfig : IEntityTypeConfiguration<RecomendacionMedica>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<RecomendacionMedica> builder)
        {
            builder.ToTable("t_RecomendacionMedica");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_RecomendacionMedica").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.Descripcion).IsRequired();
            builder.Property(e => e.FechaHora).IsRequired();
            builder.Property(e => e.NombreProfesional).IsRequired();
        }
    }
}
