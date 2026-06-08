using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class FichaSaludConfig : IEntityTypeConfiguration<FichaSalud>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<FichaSalud> builder)
        {
            builder.ToTable("t_FichaSalud");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_FichaSalud").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.Antecedentes);
            builder.Property(e => e.Estudios);
        }
    }
}
