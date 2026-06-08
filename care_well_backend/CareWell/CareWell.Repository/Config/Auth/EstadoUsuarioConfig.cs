using CareWell.Domain.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Auth
{
    public class EstadoUsuarioConfig : IEntityTypeConfiguration<EstadoUsuario>
    {
        public void Configure(EntityTypeBuilder<EstadoUsuario> builder)
        {
            builder.ToTable("t_EstadoUsuario");
            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_Estado").ValueGeneratedOnAdd();
            builder.Property(e => e.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}
