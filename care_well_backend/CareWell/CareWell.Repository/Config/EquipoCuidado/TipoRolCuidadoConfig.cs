using CareWell.Domain.EquipoCuidado;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.EquipoCuidado
{
    public class TipoRolCuidadoConfig : IEntityTypeConfiguration<TipoRolCuidado>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<TipoRolCuidado> builder)
        {
            builder.ToTable("t_TipoRolCuidado");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_TipoRolCuidado").ValueGeneratedOnAdd();

            builder.Property(e => e.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}
