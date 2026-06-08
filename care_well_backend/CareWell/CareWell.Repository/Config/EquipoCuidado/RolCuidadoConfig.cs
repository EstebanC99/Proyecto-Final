using CareWell.Domain.EquipoCuidado;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.EquipoCuidado
{
    public class RolCuidadoConfig : IEntityTypeConfiguration<RolCuidado>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<RolCuidado> builder)
        {
            builder.ToTable("t_RolCuidado");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_RolCuidado").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Tipo).WithMany().HasForeignKey("ID_TipoRolCuidado").OnDelete(DeleteBehavior.Restrict);
            builder.HasMany(e => e.Permisos).WithOne(p => p.Rol).HasForeignKey("ID_RolCuidado").OnDelete(DeleteBehavior.Cascade);
        }
    }
}
