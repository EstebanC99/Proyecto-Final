using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class FichaSaludEnfermedadRepository : IEntityTypeConfiguration<FichaSaludEnfermedad>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<FichaSaludEnfermedad> builder)
        {
            builder.ToTable("t_FichaSaludEnfermedad");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_FichaSaludEnfermedad").ValueGeneratedOnAdd();

            builder.Property(e => e.Nombre).IsRequired();
            builder.Property(e => e.Vigente).HasDefaultValue(true).IsRequired();
            builder.Property(e => e.Observacion).IsRequired(false);
        }
    }
}
