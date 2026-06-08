using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class TipoHabitoVidaConfig : IEntityTypeConfiguration<TipoHabitoVida>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<TipoHabitoVida> builder)
        {
            builder.ToTable("t_TipoHabitoVida");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_TipoHabitoVida").ValueGeneratedOnAdd();

            builder.Property(e => e.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}
