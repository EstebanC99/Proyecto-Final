using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class FichaSaludAntecedenteRepository : IEntityTypeConfiguration<FichaSaludAntecedente>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<FichaSaludAntecedente> builder)
        {
            builder.ToTable("t_FichaSaludAntecedente");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_FichaSaludAntecedente").ValueGeneratedOnAdd();

            builder.Property(e => e.Nombre).IsRequired();
            builder.Property(e => e.Descripcion).IsRequired();
            builder.Property(e => e.VinculoFamiliar).IsRequired();
        }
    }
}
