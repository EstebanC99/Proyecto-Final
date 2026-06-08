using CareWell.Domain.EquipoCuidado;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.EquipoCuidado
{
    public class PermisoCuidadoConfig : IEntityTypeConfiguration<PermisoCuidado>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<PermisoCuidado> builder)
        {
            builder.ToTable("t_PermisoCuidado");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_PermisoCuidado").ValueGeneratedOnAdd();

            builder.Property(e => e.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}
