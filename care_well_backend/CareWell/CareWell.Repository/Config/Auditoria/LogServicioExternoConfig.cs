using CareWell.Domain.Auditoria;
using CareWell.Global.Constantes.Auditoria;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Auditoria
{
    public class LogServicioExternoConfig : IEntityTypeConfiguration<LogServicioExterno>
    {
        public void Configure(EntityTypeBuilder<LogServicioExterno> builder)
        {
            builder.ToTable("t_LogServicioExterno");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_LogServicioExterno").ValueGeneratedOnAdd();

            builder.Property(e => e.NombreServicioExterno).IsRequired().HasMaxLength(ParametrosLogServicioExterno.LongitudMaximaNombreServicioExterno);
            builder.Property(e => e.Request).IsRequired();
            builder.Property(e => e.Response).IsRequired();
            builder.Property(e => e.FechaHora).IsRequired();

            builder.HasIndex(e => e.FechaHora);
        }
    }
}
