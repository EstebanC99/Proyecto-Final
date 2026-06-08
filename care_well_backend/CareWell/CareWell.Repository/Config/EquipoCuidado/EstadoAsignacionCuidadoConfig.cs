using CareWell.Domain.EquipoCuidado;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.EquipoCuidado
{
    public class EstadoAsignacionCuidadoConfig : IEntityTypeConfiguration<EstadoAsignacionCuidado>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<EstadoAsignacionCuidado> builder)
        {
            builder.ToTable("t_EstadoAsignacionCuidado");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_EstadoAsignacionCuidado").ValueGeneratedOnAdd();

            builder.Property(e => e.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}
