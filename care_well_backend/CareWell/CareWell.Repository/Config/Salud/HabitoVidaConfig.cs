using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class HabitoVidaConfig : IEntityTypeConfiguration<HabitoVida>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<HabitoVida> builder)
        {
            builder.ToTable("t_HabitoVida");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_HabitoVida").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(e => e.Tipo).WithMany().HasForeignKey("ID_TipoHabitoVida").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.Descripcion).IsRequired();
            builder.Property(e => e.Activo).IsRequired().HasDefaultValue(true);
            builder.Property(e => e.FechaCreacion).IsRequired().HasDefaultValue(DateTime.MinValue);
            builder.HasMany(e => e.Realizaciones).WithOne(n => n.HabitoVida).HasForeignKey("ID_HabitoVida").OnDelete(DeleteBehavior.Cascade);
        }
    }
}
