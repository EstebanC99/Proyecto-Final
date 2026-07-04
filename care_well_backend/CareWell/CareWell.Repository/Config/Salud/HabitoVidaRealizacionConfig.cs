using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class HabitoVidaRealizacionConfig : IEntityTypeConfiguration<HabitoVidaRealizacion>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<HabitoVidaRealizacion> builder)
        {
            builder.ToTable("t_HabitoVidaRealizacion");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_HabitoVidaRealizacion").ValueGeneratedOnAdd();

            builder.Property(e => e.FechaHoraRealizacion).IsRequired();
            builder.Property(e => e.Comentarios).IsRequired(false).HasMaxLength(2000);
        }
    }
}
