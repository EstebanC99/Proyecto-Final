using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class TipoEventoSaludConfig : IEntityTypeConfiguration<TipoEventoSalud>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<TipoEventoSalud> builder)
        {
            builder.ToTable("t_TipoEventoSalud");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_TipoEventoSalud").ValueGeneratedOnAdd();

            builder.Property(e => e.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}
