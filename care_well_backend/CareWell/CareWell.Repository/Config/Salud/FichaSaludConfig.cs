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
            
            builder.Property(e => e.FactorSanguineo).IsRequired();
            builder.Property(e => e.ObraSocial).IsRequired(false);
            builder.Property(e => e.Observaciones).IsRequired(false);

            builder.HasMany(e => e.Antecedentes).WithOne(a => a.FichaSalud).HasForeignKey("ID_FichaSalud").OnDelete(DeleteBehavior.Cascade);
            builder.HasMany(e => e.Alergias).WithOne(a => a.FichaSalud).HasForeignKey("ID_FichaSalud").OnDelete(DeleteBehavior.Cascade);
            builder.HasMany(e => e.Enfermedades).WithOne(a => a.FichaSalud).HasForeignKey("ID_FichaSalud").OnDelete(DeleteBehavior.Cascade);
        }
    }
}
