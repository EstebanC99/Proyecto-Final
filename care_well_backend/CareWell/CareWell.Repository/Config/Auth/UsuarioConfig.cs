using CareWell.Domain.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Auth
{
    public class UsuarioConfig : IEntityTypeConfiguration<Usuario>
    {
        public void Configure(EntityTypeBuilder<Usuario> builder)
        {
            builder.ToTable("t_Usuario");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_Usuario").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Persona).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.NombreUsuario).IsRequired().HasMaxLength(100);
            builder.Property(e => e.ContrasenaHash).IsRequired();
            builder.HasOne(e => e.Estado).WithMany().HasForeignKey("ID_Estado").OnDelete(DeleteBehavior.Restrict);
        }
    }
}
