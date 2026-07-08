using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class FichaSaludAlergiaRepository : IEntityTypeConfiguration<FichaSaludAlergia>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<FichaSaludAlergia> builder)
        {
            builder.ToTable("t_FichaSaludAlergia");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_FichaSaludAlergia").ValueGeneratedOnAdd();

            builder.Property(e => e.Nombre).IsRequired();
            builder.Property(e => e.Reaccion).IsRequired();
            builder.Property(e => e.Medicamento).IsRequired(false);
        }
    }
}
