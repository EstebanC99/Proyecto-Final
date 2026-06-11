using CareWell.Domain.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Auth
{
    public class RefreshTokenConfig : IEntityTypeConfiguration<RefreshToken>
    {
        public void Configure(EntityTypeBuilder<RefreshToken> builder)
        {
            builder.ToTable("t_RefreshToken");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_RefreshToken").ValueGeneratedOnAdd();

            builder.Property(e => e.Token).IsRequired().HasMaxLength(100);
            builder.Property(e => e.Expiracion).IsRequired();
            builder.Property(e => e.Revocado).IsRequired();

            builder.HasOne(e => e.Usuario).WithMany().HasForeignKey("ID_Usuario").OnDelete(DeleteBehavior.Cascade);
        }
    }
}
