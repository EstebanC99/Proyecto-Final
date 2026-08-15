using CareWell.Domain.General;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.General
{
    public class ResumenDiarioConfig : IEntityTypeConfiguration<ResumenDiario>
    {
        public void Configure(EntityTypeBuilder<ResumenDiario> builder)
        {
            builder.ToTable("t_ResumenDiario");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_ResumenDiario").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Cascade);
            builder.Property(e => e.FechaHoraGeneracion).IsRequired();
            builder.Property(e => e.Contenido).IsRequired();

            builder.HasIndex("ID_Persona").IsUnique();
        }
    }
}
