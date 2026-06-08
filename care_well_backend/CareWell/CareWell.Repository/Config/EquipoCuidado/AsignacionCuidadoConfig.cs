using CareWell.Domain.EquipoCuidado;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.EquipoCuidado
{
    public class AsignacionCuidadoConfig : IEntityTypeConfiguration<AsignacionCuidado>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<AsignacionCuidado> builder)
        {
            builder.ToTable("t_AsignacionCuidado");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_AsignacionCuidado").ValueGeneratedOnAdd();

            builder.HasOne(e => e.PersonaCuidada).WithMany().HasForeignKey("ID_Persona_Cuidada").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.Colaborador).WithMany().HasForeignKey("ID_Persona_Colaborador").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.Rol).WithMany().HasForeignKey("ID_RolCuidado").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.Estado).WithMany().HasForeignKey("ID_EstadoAsignacionCuidado").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.FechaAlta).IsRequired();
        }
    }
}
