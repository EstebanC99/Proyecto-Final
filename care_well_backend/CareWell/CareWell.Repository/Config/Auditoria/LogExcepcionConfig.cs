using CareWell.Domain.Auditoria;
using CareWell.Global.Constantes.Auditoria;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Auditoria
{
    public class LogExcepcionConfig : IEntityTypeConfiguration<LogExcepcion>
    {
        public void Configure(EntityTypeBuilder<LogExcepcion> builder)
        {
            builder.ToTable("t_LogExcepcion");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_LogExcepcion").ValueGeneratedOnAdd();

            builder.Property(e => e.Tipo).IsRequired().HasMaxLength(ParametrosLogExcepcion.LongitudMaximaTipo);
            builder.Property(e => e.Controlada).IsRequired();
            builder.Property(e => e.Mensaje).IsRequired().HasMaxLength(ParametrosLogExcepcion.LongitudMaximaMensaje);
            builder.Property(e => e.StackTrace);
            builder.Property(e => e.Ruta).IsRequired().HasMaxLength(ParametrosLogExcepcion.LongitudMaximaRuta);
            builder.Property(e => e.Verbo).IsRequired().HasMaxLength(10);
            builder.Property(e => e.TraceIdentifier).IsRequired().HasMaxLength(50);
            builder.Property(e => e.UsuarioID);
            builder.Property(e => e.FechaHora).IsRequired();

            builder.HasIndex(e => e.FechaHora);
            builder.HasIndex(e => new { e.Controlada, e.FechaHora });
        }
    }
}
