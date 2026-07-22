using CareWell.Domain.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Auth
{
    public class CodigoVerificacionEmailConfig : IEntityTypeConfiguration<CodigoVerificacionEmail>
    {
        public void Configure(EntityTypeBuilder<CodigoVerificacionEmail> builder)
        {
            builder.ToTable("t_CodigoVerificacionEmail");

            builder.HasKey(c => c.ID);
            builder.Property(c => c.ID).HasColumnName("ID_CodigoVerificacionEmail").ValueGeneratedOnAdd();

            builder.Property(e => e.CodigoHash).IsRequired().HasMaxLength(200);
            builder.Property(e => e.Expiracion).IsRequired();
            builder.Property(e => e.Consumido).IsRequired();
            builder.Property(e => e.IntentosFallidos).IsRequired();
            builder.Property(e => e.FechaCreacion).IsRequired();

            builder.HasOne(e => e.Usuario).WithMany().HasForeignKey("ID_Usuario").OnDelete(DeleteBehavior.Cascade);
        }
    }
}
