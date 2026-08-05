using CareWell.Domain.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Auth
{
    public class DispositivoUsuarioConfig : IEntityTypeConfiguration<DispositivoUsuario>
    {
        public void Configure(EntityTypeBuilder<DispositivoUsuario> builder)
        {
            builder.ToTable("t_DispositivoUsuario");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_DispositivoUsuario").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Usuario).WithMany().HasForeignKey("ID_Usuario").OnDelete(DeleteBehavior.Cascade);

            builder.Property(e => e.Token).IsRequired().HasMaxLength(255);
            builder.Property(e => e.Plataforma).IsRequired();
            builder.Property(e => e.Activo).IsRequired();
            builder.Property(e => e.FechaAlta).IsRequired();
            builder.Property(e => e.FechaUltimoUso).IsRequired();

            builder.HasIndex(e => e.Token).IsUnique();
            builder.HasIndex("ID_Usuario", nameof(DispositivoUsuario.Activo));
        }
    }
}
