using CareWell.Domain.General;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.General
{
    public class PersonaConfig : IEntityTypeConfiguration<Persona>
    {
        public void Configure(EntityTypeBuilder<Persona> builder)
        {
            builder.ToTable("t_Persona");

            builder.HasKey(p => p.ID);
            builder.Property(p => p.ID).HasColumnName("ID_Persona").ValueGeneratedOnAdd();

            builder.Property(p => p.Nombre).IsRequired().HasMaxLength(100);
            builder.Property(p => p.Apellido).IsRequired().HasMaxLength(100);
            builder.Property(p => p.Documento).IsRequired().HasMaxLength(20);
            builder.Property(p => p.FechaNacimiento).IsRequired();
            builder.Property(p => p.Email).IsRequired().HasMaxLength(256);
            builder.Property(p => p.Telefono).IsRequired().HasMaxLength(30);
            builder.Property(p => p.ImagenPath).HasMaxLength(500);
        }
    }
}
