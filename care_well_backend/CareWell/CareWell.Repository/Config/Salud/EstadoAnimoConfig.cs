using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class EstadoAnimoConfig : IEntityTypeConfiguration<EstadoAnimo>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<EstadoAnimo> builder)
        {
            builder.ToTable("t_EstadoAnimo");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_EstadoAnimo").ValueGeneratedOnAdd();

            builder.Property(e => e.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}
